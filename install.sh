#!/bin/bash

output(){
    echo -e '\e[35m'$1'\e[0m';
}

warn(){
    echo -e '\e[31m'$1'\e[0m';
}

PANEL=latest
WINGS=latest

preflight(){
    output "Jexactyl Install & Upgrade Script"
    output "Copyright © 2022 Vikas Dongre <zvikasdongre@gmail.com>."
    output ""

    output "Please note that this script is meant to be installed on a fresh OS. Installing it on a non-fresh OS may cause problems."
    output "Automatic operating system detection initialized..."

    os_check

    if [ "$EUID" -ne 0 ]; then
        output "Please run as root."
        exit 3
    fi

    output "Automatic architecture detection initialized..."
    MACHINE_TYPE=`uname -m`
    if [ "${MACHINE_TYPE}" == 'x86_64' ]; then
        output "64-bit server detected! Good to go."
        output ""
    else
        output "Unsupported architecture detected! Please switch to 64-bit (x86_64)."
        exit 4
    fi

    output "Automatic virtualization detection initialized..."
    if [ "$lsb_dist" =  "ubuntu" ]; then
        apt-get update --fix-missing
        apt-get -y install software-properties-common
        add-apt-repository -y universe
        apt-get -y install virt-what curl
    elif [ "$lsb_dist" =  "debian" ]; then
        apt update --fix-missing
        apt-get -y install software-properties-common virt-what wget curl dnsutils
    elif [ "$lsb_dist" = "fedora" ] || [ "$lsb_dist" = "centos" ] || [ "$lsb_dist" = "rhel" ] || [ "$lsb_dist" = "rocky" ] || [ "$lsb_dist" = "almalinux" ]; then
        yum -y install virt-what wget bind-utils
    fi
    virt_serv=$(echo $(virt-what))
    if [ "$virt_serv" = "" ]; then
        output "Virtualization: Bare Metal detected."
    elif [ "$virt_serv" = "openvz lxc" ]; then
        output "Virtualization: OpenVZ 7 detected."
    elif [ "$virt_serv" = "xen xen-hvm" ]; then
        output "Virtualization: Xen-HVM detected."
    elif [ "$virt_serv" = "xen xen-hvm aws" ]; then
        output "Virtualization: Xen-HVM on AWS detected."
        warn "When creating allocations for this node, please use the internal IP as Google Cloud uses NAT routing."
        warn "Resuming in 10 seconds..."
        sleep 10
    else
        output "Virtualization: $virt_serv detected."
    fi
    output ""
    if [ "$virt_serv" != "" ] && [ "$virt_serv" != "kvm" ] && [ "$virt_serv" != "vmware" ] && [ "$virt_serv" != "hyperv" ] && [ "$virt_serv" != "openvz lxc" ] && [ "$virt_serv" != "xen xen-hvm" ] && [ "$virt_serv" != "xen xen-hvm aws" ]; then
        warn "Unsupported type of virtualization detected. Please consult with your hosting provider whether your server can run Docker or not. Proceed at your own risk."
        warn "No support would be given if your server breaks at any point in the future."
        warn "Proceed?\n[1] Yes.\n[2] No."
        read choice
        case $choice in 
            1)  output "Proceeding..."
                ;;
            2)  output "Cancelling installation..."
                exit 5
                ;;
        esac
        output ""
    fi


install_options(){
    output "Please select your installation option:"
    output "[1] Install the panel ${PANEL}."
    output "[2] Install the wings ${WINGS}."
    output "[3] Install the panel ${PANEL} and wings ${WINGS}."
    output "[4] Upgrade panel to ${PANEL}."
    output "[5] Upgrade wings to ${WINGS}."
    output "[6] Upgrade panel to ${PANEL} and daemon to ${WINGS}."
    output "[7] Install phpMyAdmin (only use this after you have installed the panel)."
    output "[8] Emergency MariaDB root password reset."
    output "[9] Emergency database host information reset."
    read -r choice
    case $choice in
        1 ) installoption=1
            output "You have selected ${PANEL} panel installation only."
            ;;
        2 ) installoption=2
            output "You have selected wings ${WINGS} installation only."
            ;;
        3 ) installoption=3
            output "You have selected ${PANEL} panel and wings ${WINGS} installation."
            ;;
        4 ) installoption=4
            output "You have selected to upgrade the panel to ${PANEL}."
            ;;
	      5 ) installoption=5
            output "You have selected to upgrade the daemon to ${DAEMON}."
            ;;
        6 ) installoption=6
            output "You have selected to upgrade panel to ${PANEL} and daemon to ${DAEMON}."
            ;;
        7 ) installoption=7
            output "You have selected to install phpMyAdmin."
            ;;
        8 ) installoption=8
            output "You have selected MariaDB root password reset."
            ;;
        9 ) installoption=9
            output "You have selected Database Host information reset."
            ;;
        * ) output "You did not enter a valid selection."
            install_options
    esac
}

oh_no(){
    output "In case your dumb, which you are since you are using an install script, you may not even know what is nano."
    output "Please, if you want to understand, read the docs."
    output "Here is the documentation: https://docs.jexactyl.com/"
    output "Good luck."
}

update_wings(){
    output "Do you know why are you using this script?"
    output "Just go read the docs."
    output "Here is the documentation: https://pterodactyl.io/wings/1.0/upgrading.html"
    output "Good luck."
}

update_jexactyl(){
    output "You probably don't even know what's going on."
    output "Theres a litteral easy way to upgrade Jexactyl: the docs."
    output "Here is the docs: https://docs.jexactyl.com/#/latest/panel/updating/manual"
    output "Good luck."
}

update_both(){
    output "You probably don't even know what's going on."
    output "Theres a litteral easy way to upgrade Jexactyl: the docs."
    output "Here is the docs: https://docs.jexactyl.com/#/latest/panel/updating/manual"
    output "Also for Wings, here's the docs to update Wings: https://pterodactyl.io/wings/1.0/upgrading.html" 
    output "Good luck."
}

install_phpmyadmin(){
    output "Installing phpMyAdmin is really easy like expected."
    output "Go find a tutorial. I'm not searching for one."
}

root_pass(){
    output "Finding a MariaDB root password reset?"
    output "Go find a tutorial. I'm not searching for one."
}

database_host_reset(){
    output "Resetting your databse, huh?"
    output "Go find a tutorial."
}

nstall_options(){
    output ""
    output "Please select your installation option:"
    output "[1] Install the panel ${PANEL}."
    output "[2] Install the wings ${WINGS}."
    output "[3] Install the panel ${PANEL} and wings ${WINGS}."
    output "[4] Upgrade panel to ${PANEL}."
    output "[5] Upgrade wings to ${WINGS}."
    output "[6] Upgrade panel to ${PANEL} and daemon to ${WINGS}."
    output "[7] Install phpMyAdmin (only use this after you have installed the panel)."
    output "[8] Emergency MariaDB root password reset."
    output "[9] Emergency database host information reset."
    read -r choice
    case $choice in
        1 ) output "Don't even try to use this script. It will not work."
            ;;
        2 ) output "Don't even try to use this script. It will not work."
            ;;
        3 ) output "Don't even try to use this script. It will not work."
            ;;
        4 ) output "Don't even try to use this script. It will not work."
            ;;
        5 ) output "Don't even try to use this script. It will not work."
            ;;
        6 ) output "Don't even try to use this script. It will not work."
            ;;
        7 ) output "Don't even try to use this script. It will not work."
            ;;
        8 ) output "Don't even try to use this script. It will not work."
            ;;
        9 ) output "Don't even try to use this script. It will not work."
            ;;
        * ) output "Don't even try to use this script. It will not work."
            ;;
    esac
}

#Execution
preflight
install_options
case $installoption in 
    1)  oh_no
        nstall_options
        ;;
    2)  oh_no
        nstall_options
        ;;
    3)  oh_no
        nstall_options
        ;;
    4)  update_jexactyl
        nstall_options
        ;;
    5)  update_wings
        nstall_options
        ;;
    6)  update_both
        nstall_options
	;;
    7)  install_phpmyadmin
        nstall_options
        ;;
    8)  root_pass
        nstall_options
        ;;
    9)  database_host_reset
        nstall_options
        ;;
esac
