#!/usr/bin/env bash

# internet connection checker
check_internet_connection() {
  printf "\n== Checking Internet Connection ==\n"
  if ping -c 1 -W 2 8.8.8.8 &>/dev/null || ping -c 1 -W 2 1.1.1.1 &>/dev/null; then
    printf "\n-- Internet Connection Present --\n"

    return 0
  else
    printf "\n-- No Internet Connection --\n"

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

    echo "Error: $description failed (exit code: $exit_code)" >&2

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

# check if package ( group ) is already installed
is_group_installed() {
  pacman -Qg "$1" &>/dev/null
}

# 'yay' AUR installation
yay_installation() {
  printf "\n== YAY AUR Helper ==\n"

  if command -v yay &>/dev/null; then
    printf "\n-- YAY has already been installed! --\n"

  else
    cd $HOME
    printf "\n-- Installing YAY AUR Helper --\n"

    # install yay's dependencies
    run_command "Installing YAY Dependencies" sudo pacman -S --needed git base-devel

    # clone the actual git repository
    run_command "Clone YAY Git Repository" git clone https://aur.archlinux.org/yay.git

    # install yay locally on system
    cd yay
    run_command "Installing YAY" makepkg -si
    cd .. && rm -rf yay
  fi
}

# update the system
update_system() {
  # refresh pacman and AUR packages
  run_command "Refreshing Pacman Packages" sudo pacman -Syy --noconfirm
  run_command "Refreshing AUR Packages" yay -Syy --noconfirm

  # update all packages found on the system
  run_command "Refreshing Pacman Packages" sudo pacman -Syu --noconfirm
  run_command "Refreshing AUR Packages" yay -Syu --noconfirm
}

# install packages on the system through ( both ) pacman and AUR
install_packages() {
  local packages=("$@")
  not_on_sys=()

  for pkgs in "${packages[@]}"; do
    # populate the packages that are not installed on the system
    if ! is_installed "$pkgs" && ! is_group_installed "$pkgs"; then
      not_on_sys+=("$pkgs")
    fi
  done

  if [[ "${#not_on_sys[@]}" -ne 0 ]]; then
    # actually use install the packages using `yay`
    run_command "Installing Packages" yay -S --noconfirm "${not_on_sys[@]}"
  fi
}

# install laptop specific packages
install_laptop_packages() {
  printf "\n== Laptop Specific Packages!!! ==\n\n"

  read -p "Are you on laptop [y/N]: " laptop_user

  if [[ "$laptop_user" == "y" ]]; then
    printf "\n-- Installing Laptop Specific Packages!!! --\n"

    local laptop_packages=("$@")

    # use the pre-existing `install_packages` function to install laptop specific packages
    if ! install_packages "${laptop_packages[@]}"; then
      printf "\n== Failed to installed Laptop specific packages!!! ==\n"

    fi

  elif [[ "$laptop_user" == "N" || "$laptop_user" == "" ]]; then
    printf "\n-- Skipping Laptop Packages! --\n"

  else
    printf "\n== Wrong input... Skipping laptop packages!!! ==\n"
  fi
}

# enabled all the required services
enable_services() {
  local services=("$@")

  for service in "${services[@]}"; do
    if ! systemctl is-enabled "$service" &>/dev/null; then
      # enable all th services found inside the "services" array
      run_command "Enabling service: $service" sudo systemctl enable "$service"

    else
      printf "\n -- $service is already enabled --\n"

    fi
  done
}

# tmux plugin manager installation
tmux_plugin_manager() {
  printf "== TMUX Plugin Manager ==\n"

  if [[ -d "$HOME/.tmux" || -d "$HOME/.config/tmux/plugins/tpm" ]]; then
    printf "\n-- TMUX Plugin Manager Folder Exists! --\n\n"

  else
    run_command "Installing TPM" git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

    printf "-- TMUX Plugin Manager Installed --\n"
  fi
}

# git configuration and SSH setup
git_configuration_setup() {
  # INFO: Link to Documentation:
  # https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent?platform=linux

  read -p "Are You On Hyprland? Do You Have A Browser? [y/N]: " user_desktop

  if [[ "$user_desktop" == "y" ]]; then
    printf "\n== Git Configuration and Setup! ==\n\n"

    read -p "Enter Your Email ( Attached To GitHub ): " git_email
    read -p "Confirm Your Email: " git_email_confirmation

    # check if the email actually matches
    if [[ "$git_email" == "$git_email_confirmation" ]]; then
      printf "\n-- Email Confirmed! --\n\n"

    else
      printf "\n-- Emails Did NOT Match Up!!! --\n"

      return 1
    fi

    read -p "Please Enter Your Username ( Attached To GitHub ): " git_username

    printf "\n-- Setting Up User Specific Configurations --\n\n"

    # git configuration using user's data
    git config set --global user.email "$git_email"
    git config set --global user.name "$git_username"
    git config set --global init.defaultBranch main

    printf "\n-- Setting Up User Configurations Completed --\n\n"

    # list the configuration applied
    git config list | head

    printf "\n== SSH Key Setup for Git - GitHub == \n\n"

    # following the documentation
    ssh-keygen -t ed25519 -C "$git_email"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519

    printf "\n-- SSH Key ( Already Copied To Clipboard ) --\n\n"

    # display the SSH key and also copy to the clipboard
    cat ~/.ssh/id_ed25519.pub && cat ~/.ssh/id_ed25519.pub | wl-copy

  elif [[ "$user_desktop" == "N" || "$user_desktop" == "" ]]; then
    printf "\n== Skipping Git Configurations!!! ==\n"

  else
    printf "\n== Wrong Input... Skipping Laptop Packages!!! ==\n"

  fi
}

# reboot the computer ( as need be )
reboot_computer() {
  read -p "Do You Want To Reboot The System [Y/n]: " user_reboot

  if [[ "$user_reboot" == "Y" || "$user_reboot" == "" ]]; then
    printf "\n== Rebooting System... ==\n"

    sleep 0.5s

    logo

    # reboot the system
    systemctl reboot

  elif [[ "$user_reboot" == "n" ]]; then
    printf "\n== Installation and Setup Complete! ==\n\n"

    logo

    exit 0

  else
    printf "\n== Wrong Input... Skipping Rebooting!!! ==\n"

  fi
}
