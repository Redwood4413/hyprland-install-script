#!/bin/bash
#
# Example of a file
#      user_commands.bash
# that can be used for customizing the EndeavourOS install.
#
# How to use this file:
# 1) Edit this file to your liking.
# 2) Copy it under the /home/liveuser/ folder before starting the install process.
#
# Date added:     2021-Nov-28
# Last modified:  -
#

Msg() {
    local severity="$1"
    local msg="$2"
    echo "==> user_commands.bash: $severity: $msg"
}

GetNewUserName() {
    # This function is required when customizing personal settings.

    if [ -r /tmp/new_username.txt ] ; then
        new_user="$(cat /tmp/new_username.txt)"
        if [ -n "$new_user" ] ; then
            home="/home/$new_user"
        fi
    fi
}

BashrcConfig() {
    Msg info "add settings to $home/.bashrc."

    cat <<EOF >> $home/.bashrc

alias l='ls -la --ignore=.?*'
alias ll='ls -la --ignore=..'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ln='ln -i'

alias nano='nano -l'
alias pacdiff=eos-pacdiff

alias poweroff='sync; poweroff'
alias reboot='sync; reboot'
alias update-grub='grub-mkconfig -o /boot/grub/grub.cfg'
alias df='df -hT'
alias md='code-oss -n'             # Visual Studio Code as a markdown editor
alias grep='grep -n'

bind '"\e[A":history-search-backward'      # history with arrow up key
bind '"\e[B":history-search-forward'       # history with arrow down key
bind 'set show-all-if-ambiguous on'        # complete with single TAB
bind 'set mark-symlinked-directories on'   # complete directory symlinks with slash

export LESS="-RFn"

PS1='\w> '

EOF
    # Make sure file owner is correct
    # (not really needed if the file already exists).
    chown $new_user:$new_user $home/.bashrc
}

HomeSettings() {
    # Here you can add here some user specific stuff.

    local new_user=""
    local home=""

    GetNewUserName   # sets values for variables new_user and home

    # Validity checks.
    if [ -z "$new_user" ] ; then
        Msg warning "user name could not be found!"
        return
    fi
    if [ ! -d "$home" ] ; then
        Msg warning "user's home folder does not exist!"
        return
    fi

    BashrcConfig   # adds settings into ~/.bashrc
}

ManagePackages() {
    # Install and uninstall packages

    local Install=(   # packages to install
        atril
        code
        emacs
        gparted
        gufw
        llpp            # fast PDF reader for complex PDF files
        mpv
        ncdu
        simple-scan
        solaar          # for wireless Logitech mice and keyboards
        terminator
    )

    local Remove=(    # packages to remove
        glances
        s-tui
        parole
        capitaine-cursors
        file-roller
    )

    pacman -Rsn --noconfirm "${Remove[@]}"
    pacman -Syu --noconfirm --needed "${Install[@]}"

    sleep 1     # wait a bit after installing packages
}

ManageServices() {
    # enable the ufw firewall service (ufw comes with gufw)
    systemctl enable ufw
}

Main() {
    ManagePackages
    ManageServices

    HomeSettings

    git clone --depth=1 https://github.com/JaKooLit/Arch-Hyprland.git ~/Arch-Hyprland
    cd ~/Arch-Hyprland
    chmod +x install.sh
    ./install.sh
}

Main
