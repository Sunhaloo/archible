#!/usr/bin/env bash

# import / source the proper file(s)
source functions.sh

# define the dotfiles repository URL
REPO_URL="https://github.com/Sunhaloo/dotfiles.git"
# define the dotfiles folder name
DIR_NAME="dotfiles"
# define my directory where I keep all my repositories
REPO_DIR="$HOME/GitHub/"
# define the configuration directory
CONFIG_DIR="$HOME/.config/"

# change current working directory to home directory
cd $HOME

printf "\n== Dotfiles Setup ==\n\n"

# if the directory at location '~/GitHub/dotfiles' exists
if [[ -d "$REPO_DIR$DIR_NAME" ]]; then
    # meaning that the 'dotfiles' repository already exists
    printf "== Dotfiles Repository Already Exists! ==\n\n"

    # show the user where the repository has been installed
    # NOTE: use `--` to allow the user of '--' characters
    printf -- "-- Repository Located At: %s --\n\n" "$(find "$HOME" -type d -name "$DIR_NAME" 2> /dev/null)"

    printf "== Checking Required Directories ==\n\n"

    # if the directory at location '~/.config' exists
    if [[ -d "$CONFIG_DIR"  ]]; then
        printf -- "-- Configuration Directory Exists --\n\n"

    # meaning that the folder has not been created
    else
        printf -- "-- Creating Configuration Folders / Directory --\n\n"

        # create the '~/.config' folder
        mkdir -p "$CONFIG_DIR"
    fi

# if the 'dotfiles' repository is not present on the system
else
    printf "== Cloning Dotfiles Repository ==\n\n"

    printf "== Checking Required Directories ==\n\n"

    # create the directory '~/GitHub/'
    mkdir "$REPO_DIR"

    # if the directory at location '~/.config' exists
    if [[ -d "$CONFIG_DIR"  ]]; then
        printf -- "-- Configuration Directory Exists --\n\n"

    # meaning that the folder has not been created
    else
        printf -- "-- Creating Configuration Folders / Directory --\n\n"

        # create the '~/.config' folder
        mkdir -p "$CONFIG_DIR"
    fi

    printf "== Cloning Dotfiles Repository ==\n\n"

    # clone the my dotfiles repository
    git clone "$REPO_URL" "$REPO_DIR$DIR_NAME"

    # variable to keep the success status of the clone
    clone_status=$?

    echo
fi

# if the cloning of the respository was successful
if [[ "$clone_status" -eq 0 ]]; then
    # show the user where the repository has been installed
    printf -- "-- Repository Located At: %s --\n\n" "$(find "$HOME" -type d -name "$DIR_NAME" 2> /dev/null)"

    # meaning that return status is '0' ==> clone successful
    # therefore, move each folder into their respective positions
    printf "== Moving Configurations!!! ==\n\n"

    printf -- "-- Creating Home Folders!!! --\n\n"

    # initilise array with directories / folders that we need
    home_directories=(
        "$HOME/Obsidian"
        "$HOME/OBS Studio"
        "$HOME/Screenshots"
        "$HOME/Wallpapers"
    )

    # status flag that can change if not all files are present
    all_exist=true

    # iterate through the list of directories found in `home_directories` array
    for home_dir in "${home_directories[@]}"; do
        # check if each directory is present
        if [[ ! -d "$home_dir" ]]; then
            # output appropriate message
            printf "== Missing Folder: %s ==\n\n" "$home_dir"

            # change the status flag to 'false' as we don't have all folders
            all_exist=false
        fi
    done

    # if all folders exists
    if $all_exist; then
        printf "== All Required Home Folders Exists! ==\n\n"

    # if one or more folders is missing
    else
        printf "== One or More Required Home Folders Are Missing! ==\n\n"

        printf -- "-- Creating Required Missing Home Folders --\n\n"

        # create the XDG Based Home Directories
        xdg-user-dirs-update

        # create all the folders... I know that its fucked up to create everything again
        mkdir ~/{Obsidian,OBS\ Studio,Screenshots,Wallpapers} 2> /dev/null
    fi

    printf "== Moving Configuration Folders and Files! ==\n\n"

    # move the required configuration files
    # WARNING: testing
    # cp -r $HOME/GitHub/dotfiles/{hypr,kanata,kitty,nvim,rofi,starship,tmux,waybar} ~/.config
    cp -r $HOME/GitHub/dotfiles/{hypr,kanata,kitty,rofi,scripts,starship,swaync,tmux,waybar} ~/.config

    printf "== Configuration Folders and Files Successfully Moved!!! ==\n\n"

# if the clone was not successful
else
    # output appropriate message
    printf "== WARNING: Cloned Failed!!! ==\n"

    # remove the unwanted files created
    rm -rf "$REPO_DIR"

    # prompt the user if he wants to delete the configuration folder
    printf "\nDo You Want to Delete The Configuration Folder '%s' [y/N]: " "$CONFIG_DIR"

    # read the data / answer that the user entered
    read rm_config_dir

    # meaning that the user want to remove the configuration folder
    if [[ "$rm_config_dir" == "y" ]]; then
        printf "\n== Deleting Configuration Folder!!! ==\n"

        # delete the configuration folder like the user wanted to
        rm -rf "$CONFIG_DIR"

    # meaning that the user does not want to configure git right now
    elif [[ "$rm_config_dir" == "N" || "$rm_config_dir" == ""  ]]; then
        printf "\n== Skipping Deleting Configuration Folder!!! ==\n"

    # if the user did not enter correct / required input
    else
        printf "\n== Wrong Input... Skipping Deletiong of Configuration Folders!!! ==\n"
    fi

    # return the "error" status code to our main program
    return 1
fi
