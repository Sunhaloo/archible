#!/usr/bin/env bash

# import / source the proper file(s)
source functions.sh
source packages.conf

# call the function to display the logo
print_logo

# call the function to install `yay` ( if need be )
yay_installation 

# refresh packages and update the whole system
update_system 

# install all the dependency packages
install_packages "${DEPENDENCIES[@]}"
# install all the packages related to the window manager 'Hyprland'
install_packages "${WINDOW_MANAGER[@]}"
# install all the packages related to "Desktop" applications / programs
install_packages "${DESKTOP[@]}"
# install all the packages related to coding and development
install_packages "${DEVELOPMENT[@]}"
# install all the packages related to coding and development
install_packages "${LANGS[@]}"
# install all the packages related to fonts used
install_packages "${FONTS[@]}"

printf "== Setup Rustup and Cargo ==\n\n"

# initialise rust - cargo
rustup default stable

# install all the utility packages
install_packages "${SYSTEM_UTILS[@]}"

# call the function to check if user is on laptop and if need be install laptop packages
laptop_packages "${LAPTOP[@]}"

# enable all the required services
enable_services "${SERVICES[@]}"

# import / source the proper file to be able to move configuration files and folders
if ! source dotfiles.sh; then
    printf "\nConfiguration SH was Skipped or Failed, continuing with the rest...\n"
fi

# call the function to "manually" install OMZ
oh_my_zsh_manual
 
# call the function to install TPM
tmux_plugin_manager

# call the function to ask if the user wants to install and configure kanata key remapper
kanata_configuration

# import / source the proper file to configure git and setup SSH key
if ! git_configuration; then
    printf "\nGit Configuration was Skipped or Failed, continuing with the rest...\n"
fi

# call the function to check if the user wants to reboot the system
reboot_computer
