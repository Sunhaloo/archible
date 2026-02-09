#!/usr/bin/env bash

# to use helper functions
source functions.sh

REPO_URL="https://github.com/Sunhaloo/dotfiles.git"
DIR_NAME="dotfiles"
REPO_DIR="$HOME/GitHub"
CONFIG_DIR="$HOME/.config"

# initialize clone status
clone_status=0

# function to ensure config directory exists
ensure_config_dir() {
  if [[ -d "$CONFIG_DIR" ]]; then
    printf "\n-- Configuration Directory Located At: %s --\n\n" "$CONFIG_DIR"
  else
    printf "\n-- Creating Configuration Directory --\n\n"
    mkdir -p "$CONFIG_DIR"
  fi
}

# go to the home directory and start the process
cd "$HOME" || exit 1

printf "\n== Dotfiles Setup ==\n\n"

# files and folders setup
if [[ -d "$REPO_DIR/$DIR_NAME" ]]; then
  printf "\n-- Dotfiles Repository Already Exists! --\n\n"
  printf "\n-- Repository Located At: %s --\n\n" "$REPO_DIR/$DIR_NAME"
  printf "\n== Checking Required Directories ==\n\n"

  ensure_config_dir

else
  printf "== Cloning Dotfiles Repository ==\n\n"
  printf "\n-- Checking Required Directories --\n\n"

  mkdir -p "$REPO_DIR"
  ensure_config_dir

  run_command "Cloning Dotfiles Repository" git clone "$REPO_URL" "$REPO_DIR/$DIR_NAME"
  clone_status=$?

  echo
fi

# check for cloning status
if [[ "$clone_status" -eq 0 ]]; then
  printf "\n-- Repository Located At: %s --\n\n" "$REPO_DIR/$DIR_NAME"
  printf "\n== Moving Configurations ==\n\n"
  printf "\n-- Creating Home Folders --\n\n"

  # define home directories to create
  home_dirs=(
    "$HOME/Obsidian"
    "$HOME/OBS Studio"
    "$HOME/Screenshots"
    "$HOME/Wallpapers"
  )

  # create the XDG Based Home Directories first
  xdg-user-dirs-update

  # create all home directories
  mkdir -p "${home_dirs[@]}"

  printf "\n-- Home Folders Created --\n\n"

  printf "\n== Moving Configuration Folders and Files! ==\n\n"

  # define config folders to copy from dotfiles
  config_folders=(
    "dunst"
    "hypr"
    "kanata"
    "kitty"
    "niri"
    "nvim"
    "pypr"
    "rofi"
    "starship"
    "tmux"
    "waybar"
  )

  # copy each config folder
  for folder in "${config_folders[@]}"; do
    if [[ -d "$HOME/GitHub/dotfiles/$folder" ]]; then
      if cp -r "$HOME/GitHub/dotfiles/$folder" "$HOME/.config/"; then
        printf "-- Copied: %s --\n" "$folder"
      else
        printf "-- Failed to copy: %s --\n" "$folder" >&2
      fi
    else
      printf "-- Missing: %s --\n" "$folder" >&2
    fi
  done

  printf "\n-- Configuration Folders and Files Successfully Moved --\n\n"

  # copy zsh configuration file to home directory
  if [[ -f "$REPO_DIR/$DIR_NAME/zsh/.zshrc" ]]; then
    if cp "$REPO_DIR/$DIR_NAME/zsh/.zshrc" "$HOME/.zshrc"; then
      printf "\n-- Copied: .zshrc to home directory --\n\n"
    else
      printf "\n-- Failed to copy: .zshrc --\n" >&2
    fi
  else
    printf "\n-- Missing: .zshrc --\n" >&2
  fi

else
  printf "\n== WARNING: Clone Failed ==\n" >&2

  # clean up only the dotfiles directory
  rm -rf "$REPO_DIR/$DIR_NAME" 2>/dev/null

  exit 1
fi
