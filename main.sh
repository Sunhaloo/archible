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
read -r -p "Install Hyprland? [Y/n]: " wm_choice

case "${wm_choice,,}" in
n | no)
  WINDOW_MANAGER_CHOICE="None"
  WM_PACKAGES=()
  printf "\n-- Skipping Hyprland — no window manager will be installed --\n"
  ;;
y | yes | "")
  WINDOW_MANAGER_CHOICE="Hyprland"
  WM_PACKAGES=("${HYPRLAND_WM[@]}")
  printf "\n-- Installing Hyprland --\n"
  ;;
*)
  printf "\n-- Invalid input. Defaulting to Hyprland --\n"
  WINDOW_MANAGER_CHOICE="Hyprland"
  WM_PACKAGES=("${HYPRLAND_WM[@]}")
  ;;
esac

printf "\n-- Selected: %s --\n\n" "$WINDOW_MANAGER_CHOICE"

# ============================================================================
# PACKAGE INSTALLATION
# ============================================================================

# install general dependencies
install_packages "${GENERAL_DEPENDENCIES[@]}"

# install file management dependencies
install_packages "${FILE_MANAGEMENT_DEPENDENCIES[@]}"

# install security packages
install_packages "${SECURITY[@]}"

# install selected window manager
if [[ ${#WM_PACKAGES[@]} -gt 0 ]]; then
  install_packages "${WM_PACKAGES[@]}"
else
  printf "\n-- Skipping Window Manager Packages Installation --\n"
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
install_packages "${PROGRAMMING[@]}"

# setup rust
printf "\n== Setting Up Rust ==\n\n"
run_command "Setting Rustup default to stable" rustup default stable

# ============================================================================
# MAIN LAPTOP PACKAGES
# ============================================================================

# install main laptop packages
if [[ ${#MAIN_LAPTOP[@]} -gt 0 ]]; then
  read -r -p "Would you like to install main laptop packages? [y/N]: " install_main_laptop
  if [[ "${install_main_laptop,,}" =~ ^y(es)?$ ]]; then
    install_packages "${MAIN_LAPTOP[@]}"
  else
    printf "\n-- Skipping main laptop packages --\n"
  fi
fi

# ============================================================================
# SECONDARY LAPTOP PACKAGES
# ============================================================================

# install secondary laptop packages
if [[ ${#SECONDARY_LAPTOP[@]} -gt 0 ]]; then
  read -r -p "Would you like to install secondary laptop packages? [y/N]: " install_secondary_laptop
  if [[ "${install_secondary_laptop,,}" =~ ^y(es)?$ ]]; then
    install_packages "${SECONDARY_LAPTOP[@]}"
  else
    printf "\n-- Skipping secondary laptop packages --\n"
  fi
fi

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
