#!/usr/bin/env bash

# source required files
source functions.sh
source packages.conf

# ============================================================================
# PRE-INSTALLATION CHECKS
# ============================================================================

# display welcome logo
logo

# check internet connection
if ! check_internet_connection; then
  printf "\n-- ERROR: Internet connection required. Exiting... --\n" >&2
  exit 1
fi

# ============================================================================
# SYSTEM SETUP
# ============================================================================

# install yay aur helper
yay_installation || exit 1

# update system packages
update_system

# ============================================================================
# WINDOW MANAGER SELECTION
# ============================================================================

printf "\n== Window Manager Selection ==\n\n"
printf "Which window manager would you like to install?\n"
printf "  [1] Hyprland (default)\n"
printf "  [2] Niri\n"
printf "  [3] Both Niri and Hyprland\n"
printf "  [4] None (skip window manager)\n\n"
read -r -p "Enter your choice [1/2/3/4]: " wm_choice

# default to hyprland if empty
wm_choice="${wm_choice:-1}"

case "$wm_choice" in
  1)
    WINDOW_MANAGER_CHOICE="Hyprland"
    WM_PACKAGES=("${HYPRLAND[@]}")
    ;;
  2)
    WINDOW_MANAGER_CHOICE="Niri"
    WM_PACKAGES=("${NIRI[@]}")
    ;;
  3)
    WINDOW_MANAGER_CHOICE="Both Niri and Hyprland"
    WM_PACKAGES=("${NIRI[@]}" "${HYPRLAND[@]}")
    ;;
  4)
    WINDOW_MANAGER_CHOICE="None"
    WM_PACKAGES=()
    ;;
  *)
    printf "\n-- Invalid choice. Defaulting to Hyprland --\n"
    WINDOW_MANAGER_CHOICE="Hyprland"
    WM_PACKAGES=("${HYPRLAND[@]}")
    ;;
esac

printf "\n-- Selected: %s --\n\n" "$WINDOW_MANAGER_CHOICE"

# ============================================================================
# PACKAGE INSTALLATION
# ============================================================================

# install dependencies
install_packages "${DEPENDENCIES[@]}"

# install wayland common packages
install_packages "${WAYLAND_COMMON[@]}"

# install selected window manager
if [[ ${#WM_PACKAGES[@]} -gt 0 ]]; then
  install_packages "${WM_PACKAGES[@]}"
else
  printf "\n-- Skipping window manager installation --\n"
fi

# install appearance packages
install_packages "${APPEARANCE[@]}"

# install desktop applications
install_packages "${APPLICATIONS[@]}"

# install cli tools
install_packages "${CLI_TOOLS[@]}"

# install shell
install_packages "${SHELL[@]}"

# install fonts
install_packages "${FONTS[@]}"

# install programming languages
install_packages "${LANGS[@]}"

# setup rust
printf "\n== Setting Up Rust ==\n\n"
run_command "Setting Rustup default to stable" rustup default stable

# ============================================================================
# EXTRAS
# ============================================================================

# install extra packages
if [[ ${#EXTRAS[@]} -gt 0 ]]; then
  read -r -p "Would you like to install extra packages? [y/N]: " install_extras
  if [[ "${install_extras,,}" =~ ^y(es)?$ ]]; then
    install_packages "${EXTRAS[@]}"
  else
    printf "\n-- Skipping extra packages --\n"
  fi
fi

# ============================================================================
# LAPTOP PACKAGES
# ============================================================================

# install old laptop specific packages
install_laptop_packages "${OLD_LAPTOP[@]}"

# ============================================================================
# SERVICES
# ============================================================================

# enable required services
enable_services "${SERVICES[@]}"

# ============================================================================
# DOTFILES SETUP
# ============================================================================

# source dotfiles script
if ! source dotfiles.sh; then
  printf "\n-- WARNING: Dotfiles setup failed or was skipped --\n" >&2
fi

# ============================================================================
# ADDITIONAL SETUP
# ============================================================================

# install tmux plugin manager
tmux_plugin_manager

# configure kanata
kanata_configuration

# configure git and ssh
git_configuration_setup

# ============================================================================
# FINISH
# ============================================================================

# change shell to zsh and reboot
reboot_computer
