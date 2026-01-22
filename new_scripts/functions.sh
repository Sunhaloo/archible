#!/usr/bin/env bash

# internet connection checker
check_internet_connection() {
  printf "\n== Checking Internet Connection ==\n"

  if ping -c 1 -W 2 8.8.8.8 &>/dev/null || ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
    printf "\n-- Internet Connection Present --\n\n"
    return 0
  else
    printf "\n-- No Internet Connection --\n" >&2
    return 1
  fi
}

# general wrapper - error checking function
run_command() {
  local description="$1"
  shift

  printf "\n-- %s --\n" "$description"

  if "$@"; then
    return 0
  else
    local exit_code=$?
    printf "Error: %s failed (exit code: %s)\n" "$description" "$exit_code" >&2
    return $exit_code
  fi
}

# function to display welcome logo
logo() {
  echo
  cat <<"EOF"
     _             _     _ _     _
    / \   _ __ ___| |__ (_) |__ | | ___
   / _ \ | '__/ __| '_ \| | '_ \| |/ _ \
  / ___ \| | | (__| | | | | |_) | |  __/
 /_/   \_\_|  \___|_| |_|_|_.__/|_|\___|

              "Less is More"
EOF
}

# check if package is already installed
is_installed() {
  pacman -Q "$1" &>/dev/null
}

# check if package group is already installed
is_group_installed() {
  pacman -Qg "$1" &>/dev/null
}

# yay AUR installation
yay_installation() {
  printf "\n== YAY AUR Helper ==\n"

  if command -v yay &>/dev/null; then
    printf "\n-- YAY is already installed --\n"
    return 0
  fi

  printf "\n-- Installing YAY AUR Helper --\n"

  local yay_dir="/tmp/yay"

  run_command "Installing YAY Dependencies" sudo pacman -S --needed --noconfirm git base-devel || return 1

  rm -rf "$yay_dir"
  run_command "Cloning YAY Repository" git clone https://aur.archlinux.org/yay.git "$yay_dir" || return 1

  cd "$yay_dir" || return 1
  run_command "Building and Installing YAY" makepkg -si --noconfirm || {
    cd - >/dev/null
    return 1
  }

  cd - >/dev/null
  rm -rf "$yay_dir"

  printf "\n-- YAY installation complete --\n"
}

# update the system
update_system() {
  run_command "Syncing databases and upgrading packages" yay -Syyu --noconfirm
}

# install packages on the system through both pacman and AUR
install_packages() {
  local packages=("$@")
  local not_on_sys=()

  for pkgs in "${packages[@]}"; do
    if ! is_installed "$pkgs" && ! is_group_installed "$pkgs"; then
      not_on_sys+=("$pkgs")
    fi
  done

  if [[ "${#not_on_sys[@]}" -eq 0 ]]; then
    printf "\n-- All packages already installed --\n"
    return 0
  fi

  run_command "Installing ${#not_on_sys[@]} package(s)" yay -S --noconfirm "${not_on_sys[@]}"
}

# install laptop specific packages
install_laptop_packages() {
  printf "\n== Laptop Specific Packages ==\n"

  read -r -p "Are you on a laptop? [y/N]: " laptop_user

  case "${laptop_user,,}" in
  y | yes)
    printf "\n-- Installing Laptop Packages --\n"
    local laptop_packages=("$@")

    if ! install_packages "${laptop_packages[@]}"; then
      printf "\n-- Failed to install laptop packages --\n" >&2
      return 1
    fi
    ;;
  n | no | "")
    printf "\n-- Skipping Laptop Packages --\n"
    ;;
  *)
    printf "\n-- Invalid input. Skipping laptop packages --\n" >&2
    return 1
    ;;
  esac
}

# enable all the required services
enable_services() {
  local services=("$@")

  printf "\n== Enabling Services ==\n"

  for service in "${services[@]}"; do
    if systemctl is-enabled "$service" &>/dev/null; then
      printf "\n-- %s is already enabled --\n" "$service"
    else
      run_command "Enabling service: $service" sudo systemctl enable "$service"
    fi
  done
}

# tmux plugin manager installation
tmux_plugin_manager() {
  printf "\n== TMUX Plugin Manager ==\n"

  local tpm_dir="$HOME/.config/tmux/plugins/tpm"

  if [[ -d "$tpm_dir" ]]; then
    printf "\n-- TPM is already installed --\n"
    return 0
  fi

  run_command "Installing TPM" git clone https://github.com/tmux-plugins/tpm "$tpm_dir" || return 1
  printf "\n-- TPM installation complete --\n"
}

# git configuration and SSH setup
git_configuration_setup() {
  printf "\n== Git Configuration and SSH Setup ==\n"

  read -r -p "Do you want to configure Git and SSH? [y/N]: " user_choice

  if [[ ! "${user_choice,,}" =~ ^y(es)?$ ]]; then
    printf "\n-- Skipping Git configuration --\n"
    return 0
  fi

  local git_email git_email_confirmation git_username

  while true; do
    read -r -p "Enter your GitHub email: " git_email
    read -r -p "Confirm your email: " git_email_confirmation

    if [[ "$git_email" == "$git_email_confirmation" ]]; then
      printf "\n-- Email confirmed --\n"
      break
    else
      printf "\n-- Emails do not match. Try again --\n" >&2
    fi
  done

  read -r -p "Enter your GitHub username: " git_username

  printf "\n-- Configuring Git --\n"

  git config --global user.email "$git_email"
  git config --global user.name "$git_username"
  git config --global init.defaultBranch main

  printf "\n-- Current Git Configuration --\n"
  git config --global --list | grep -E "(user|init)"

  printf "\n== SSH Key Setup ==\n"

  local ssh_key="$HOME/.ssh/id_ed25519"

  if [[ -f "$ssh_key" ]]; then
    printf "\n-- SSH key already exists --\n"
    read -r -p "Generate new key? (will backup old key) [y/N]: " regenerate

    if [[ "${regenerate,,}" =~ ^y(es)?$ ]]; then
      mv "$ssh_key" "${ssh_key}.backup.$(date +%s)"
      mv "${ssh_key}.pub" "${ssh_key}.pub.backup.$(date +%s)"
    else
      printf "\n-- Using existing SSH key --\n"
      cat "${ssh_key}.pub"

      if command -v wl-copy &>/dev/null; then
        cat "${ssh_key}.pub" | wl-copy
        printf "\n-- SSH key copied to clipboard --\n"
      fi

      printf "\n-- Add this key to GitHub: https://github.com/settings/keys --\n"
      return 0
    fi
  fi

  ssh-keygen -t ed25519 -C "$git_email" -f "$ssh_key" -N "" || return 1

  eval "$(ssh-agent -s)"
  ssh-add "$ssh_key"

  printf "\n-- SSH Public Key --\n"
  cat "${ssh_key}.pub"

  if command -v wl-copy &>/dev/null; then
    cat "${ssh_key}.pub" | wl-copy
    printf "\n-- SSH key copied to clipboard --\n"
  else
    printf "\n-- wl-copy not found. Please copy the key manually --\n"
  fi

  printf "\n-- Add this key to GitHub: https://github.com/settings/keys --\n"
}

# reboot the computer
reboot_computer() {
  printf "\n== Installation Complete ==\n"

  read -r -p "Reboot the system now? [Y/n]: " user_reboot

  case "${user_reboot,,}" in
  n | no)
    printf "\n-- Setup complete. Reboot when ready --\n\n"
    logo
    exit 0
    ;;
  y | yes | "")
    printf "\n-- Rebooting system --\n"
    sleep 1
    logo
    sudo systemctl reboot
    ;;
  *)
    printf "\n-- Invalid input. Skipping reboot --\n" >&2
    ;;
  esac
}
