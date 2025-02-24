#!/bin/bash

# Update and upgrade the system
sudo pacman -Syu --noconfirm

# Install Chrome Remote Desktop (using AUR helper)
if ! command -v yay &> /dev/null; then
    sudo pacman -S --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi
yay -S chrome-remote-desktop --noconfirm

# Install XFCE
sudo pacman -S --noconfirm xfce4 xfce4-goodies

# Install Display Manager if not installed
sudo pacman -S --noconfirm lightdm

# Configure Chrome Remote Desktop to use XFCE
echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" | sudo tee /etc/chrome-remote-desktop-session

# Prompt for new user details
read -p "Enter the new username: " NEW_USER
read -s -p "Enter the password for $NEW_USER: " USER_PASSWORD
echo
read -s -p "Confirm password: " CONFIRM_PASSWORD
echo

# Validate password match
while [ "$USER_PASSWORD" != "$CONFIRM_PASSWORD" ]; do
    echo "Passwords do not match. Please try again."
    read -s -p "Enter the password for $NEW_USER: " USER_PASSWORD
    echo
    read -s -p "Confirm password: " CONFIRM_PASSWORD
    echo
done

# Validate username
while [[ -z "$NEW_USER" ]]; do
    echo "Username cannot be empty. Please try again."
    read -p "Enter the new username: " NEW_USER
done

# Add the user and set the password
sudo adduser --disabled-password --gecos "" $NEW_USER
echo "$NEW_USER:$USER_PASSWORD" | sudo chpasswd

# Add the user to the sudo group
sudo usermod -aG wheel $NEW_USER

# Create the chrome-remote-desktop group and add the user
sudo groupadd chrome-remote-desktop
sudo usermod -aG chrome-remote-desktop $NEW_USER

# Install Firefox
sudo pacman -S --noconfirm firefox

echo "Installation complete. Please log in as the user '$NEW_USER' to complete the Chrome Remote Desktop setup."

# Instructions for the user
echo "You are now being logged in as $NEW_USER to apply the group membership changes."
echo "Install Chrome remote desktop extension on your browser"
echo "Open and go to Setup via SSH > Set up another computer > begin > next > authorize > Debian Linux > Copy command"
echo "Paste the command copied from chrome remote desktop and paste on the linux terminal and enter to run"
echo "Enter pin"
echo "The remote desktop connection should now be running"

# Switch to the new user
echo "Switching to user $NEW_USER..."
exec su - $NEW_USER