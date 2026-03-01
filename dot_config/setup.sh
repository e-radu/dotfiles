sudo apt-get update
sudo apt-get install nala -y
sudo nala upgrade -y
sudo nala install zsh -y
sudo nala install git tree build-essential checkinstall zlib1g-dev libssl-dev -y
sudo nala install wget curl gpg unzip gcc make -y
# install dependencies for tmux
sudo nala install yacc libncurses5-dev libncursesw5-dev libevent-dev -y
# load custom fonts
fc-cache -f -v
# install dependencies for yazi
sudo nala install ffmpeg ffmpegthumbnailer jq poppler-utils fd-find ripgrep xclip -y
sudo ln --symbolic $(which fdfind) /usr/local/bin/fd
# input-remapper is needed to remap Caps Lock to KEY_GRAVE
sudo nala install input-remapper -y

nvim --version
if [ ! $? -eq 0 ]; then
    echo "Installing neovim"
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz

    echo "Installing neovim plugins"
    git clone https://github.com/e-radu/lazy.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
fi

cargo --version
if [ ! $? -eq 0 ]; then
    echo "Installing Rust Cargo"
    curl https://sh.rustup.rs -sSf | sh
else
    echo "Rust Cargo already installed"
fi

starship -V
if [ ! $? -eq 0 ]; then
    echo "Installing Starship"
    curl -sS https://starship.rs/install.sh | sh
else
    echo "Starship already installed"
fi

lazygit --version
if [ ! $? -eq 0 ]; then
    echo "Installing lazygit"
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    echo "Latest lazygit version: $LAZYGIT_VERSION"
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit.tar.gz
    rm -rf lazygit
else
    echo "--> lazygit already installed"
fi

fzf --version
if [ ! $? -eq 0 ]; then
    echo "Installing FZF"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
else
    echo "--> fzf already installed"
fi

atuin --version
if [ ! $? -eq 0]; then
    echo "Installing Atuin"
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
else
    echo "--> atuin already installed"
fi

chsh -s $(which zsh)
zsh

echo "Reloading ZSH config"
source ~/.zshrc
