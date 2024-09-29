sudo apt-get install nala -y
sudo nala update
sudo nala upgrade -y
sudo nala install git rcm build-essential checkinstall zlib1g-dev libssl-dev wget gpg unzip -y
sudo nala install cmake -y

if [ ! -d "~/.rustup"]; then
echo "Installing Rust Cargo"
curl https://sh.rustup.rs -sSf | sh
echo ". \"$HOME/.cargo/env\"" >> ~/.config/.zshrc
fi

echo "Reloading ZSH config"
source ~/.config/.zshrc

starship -V
if [ ! $? -eq 0 ]; then
echo "Installing Starship"
curl -sS https://starship.rs/install.sh | sh
echo "#eval \"$(starship init zsh)\"" >> ~/.config/.zshrc
else
echo "Starship already installed"
fi

echo "Installing eza"
cargo install --locked eza

echo "Installing delta"
cargo install --locked git-delta

echo "Installing bat"
cargo install --locked bat

echo "Installing FZF"
sudo nala install fzf -y

echo "Installing fd-find"
sudo nala install fd-find -y

echo "Installing zoxide"
cargo install --locked zoxide

echo "Installing Zellij"
cargo install --locked zellij
