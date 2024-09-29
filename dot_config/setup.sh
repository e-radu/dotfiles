sudo apt-get install nala -y
sudo nala update
sudo nala upgrade -y
sudo nala install git tree build-essential checkinstall zlib1g-dev libssl-dev
sudo nala install wget gpg unzip gcc make ripgrep xclip -y
sudo nala install cmake -y

echo "Installing neovim"
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz

echo "Installing neovim plugins"
git clone https://github.com/e-radu/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

if [ ! -d "~/.rustup"]; then
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

echo "Reloading ZSH config"
source ~/.config/.zshrc

echo "Installing eza"
cargo install --locked eza

echo "Installing delta"
cargo install --locked git-delta

echo "Installing bat"
cargo install --locked bat

echo "Installing FZF"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

echo "Installing fd-find"
sudo nala install fd-find -y

echo "Installing zoxide"
cargo install --locked zoxide

echo "Installing Zellij"
cargo install --locked zellij
