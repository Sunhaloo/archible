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

# main menu shown at the start and end of each "job"
display_menu() {
  logo

  echo

  printf "\n          == Main Menu ==\n\n"
  printf "      [1] Base System Install\n"
  printf "      [2] Laptop Specific Packages Install\n"
  printf "      [3] Enable Services\n"
  printf "      [4] Kanata Keyboard Remapper\n"
  printf "      [5] Exit ( Reboot )\n\n"
  printf "      Enter your choice: "
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

  clear
}

# install packages on the system through ( both ) pacman and AUR
install_packages() {
  local packages=("$@")
  not_on_sys=()

  for pkgs in "${packages[@]}"; do
    if ! is_installed "$pkgs" && ! is_group_installed "$pkgs"; then
      not_on_sys+=("$pkgs")
    fi
  done

  if [[ "${#not_on_sys[@]}" -ne 0 ]]; then
    run_command "Installing Packages" yay -S --noconfirm "${not_on_sys[@]}"
  fi

  clear
}

# install laptop specific packages

display_menu
