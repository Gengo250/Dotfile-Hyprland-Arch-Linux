#!/bin/bash

# 1) instalar pacotes base
cd "$HOME"
sudo pacman -S --noconfirm github-cli stow pamixer brightnessctl playerctl ncspot rofi-wayland hyprlock hypridle hyprpaper yazi neovim bottom networkmanager rustup zsh imagemagick acpi pavucontrol

# 2) diretórios do sistema
CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/Dotfile-Hyprland-Arch-Linux"
DOTFILES_CONFIG="$DOTFILES_DIR/.config"
BACKUP_SUFFIX=".bak"

echo "Backing up configuration directories in $CONFIG_DIR based on dotfiles in $DOTFILES_CONFIG"

# ir pro ~/.config
cd "$CONFIG_DIR" || { echo "Could not access $CONFIG_DIR"; exit 1; }

# 3) backup de cada pasta que EXISTE no teu repo
for dir in "$DOTFILES_CONFIG"/*/; do
  folder_name=$(basename "$dir")
  if [ -d "$CONFIG_DIR/$folder_name" ]; then
    echo "Backing up directory: $folder_name"
    mv "$CONFIG_DIR/$folder_name" "$CONFIG_DIR/${folder_name}${BACKUP_SUFFIX}"
  else
    echo "Directory $folder_name not found in $CONFIG_DIR; skipping backup"
  fi
done

# 4) arquivos soltos
FILES=(.zshrc .zshenv .tmux.conf .p10k.zsh wallpapers scripts screenshots)

echo "Backing up individual files in $HOME"
for file in "${FILES[@]}"; do
  if [ -e "$HOME/$file" ]; then
    echo "Backing up file: $file"
    mv "$HOME/$file" "$HOME/${file}${BACKUP_SUFFIX}"
  else
    echo "File $file not found; skipping backup"
  fi
done

# 5) cache do wal
CACHE_WAL="$HOME/.cache/wal"
CACHE_WAL_BAK="$HOME/.cache/wal.bak"

echo "Checking for $CACHE_WAL..."
if [ -d "$CACHE_WAL" ]; then
  echo "Backing up $CACHE_WAL to $CACHE_WAL_BAK"
  mv "$CACHE_WAL" "$CACHE_WAL_BAK"
else
  echo "$CACHE_WAL not found; skipping..."
fi

# 6) aplicar dotfiles com stow (AGORA NO TEU REPO)
echo "Applying dotfiles with stow"
cd "$DOTFILES_DIR" || { echo "Could not access $DOTFILES_DIR"; exit 1; }
stow .

# 7) voltar pro home
cd "$HOME"

# 8) instalar yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm

# 9) pacotes via yay
yay -S --noconfirm neofetch cmatrix cava python-pywal ttf-iosevka otf-hermit-nerd gvfs dbus libdbusmenu-glib libdbusmenu-gtk3 gtk-layer-shell brave-bin zoxide eza fzf thefuck jq socat tmux nvm btop hyprshot bluez bluez-utils bluez-obex bluetuith python-gobject

# 10) powerlevel10k
yay -S --noconfirm zsh-theme-powerlevel10k-git
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

# 11) eww
cd "$HOME"

# (tinha um espacinho errado aqui no original)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

git clone https://github.com/elkowar/eww
cd eww
cargo build --release --no-default-features --features=wayland
cd target/release
chmod +x ./eww
sudo cp ./eww /usr/local/bin/

# 12) network manager e bluetooth
sudo systemctl disable systemd-resolved
sudo systemctl disable systemd-networkd
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# 13) shell
chsh -s /usr/bin/zsh

echo "Installation complete. The system will now reboot."
sudo reboot
