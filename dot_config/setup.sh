sudo apt-get update
sudo apt-get install nala -y
sudo nala upgrade -y
sudo nala install zsh -y
sudo nala install git tree build-essential checkinstall zlib1g-dev libssl-dev -y
sudo nala install wget gpg unzip gcc make ripgrep xclip fd-find tmux -y
fc-cache -f -v
# sudo nala install cmake -y

wezterm --version
if [ ! $? -eq 0 ]; then
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo nala update
sudo nala install wezterm -y
else
echo "Wezterm already installed"
fi

brave-browser --version
if [ ! $? -eq 0 ]; then
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo nala update
sudo nala install brave-browser -y
else
echo "Brave browser already installed"
fi



function check_and_install_tool {
$1 --version
if [ ! $? -eq 0 ]; then
echo "Installing $1 ..."
cargo install --locked $1
else
echo "--> $1 already installed."
fi
}

nvim --version
if [ ! $? -eq 0 ]; then
echo "Installing neovim"
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz

echo "Installing neovim plugins"
git clone https://github.com/e-radu/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
fi

cargo --version
if  [ ! $? -eq 0 ]; then
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
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz
rm lazygit
else
echo "--> lazygit already installed"
fi

cargoTools=("eza" "bat" "zoxide" "zellij")

for tool in "${cargoTools[@]}"; do
check_and_install_tool $tool
done

# delta --version
# if [ ! $? -eq 0 ]; then
# echo "Installing delta"
# cargo install --locked git-delta
# else
# echo "delta already installed"
# fi

fzf --version
if [ ! $? -eq 0 ]; then
echo "Installing FZF"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
else
echo "--> fzf already installed"
fi

chsh -s $(which zsh)
zsh

echo "Reloading ZSH config"
source ~/.zshrc

