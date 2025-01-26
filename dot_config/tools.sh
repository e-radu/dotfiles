function check_and_install_tool {
    $1 --version
    if [ ! $? -eq 0 ]; then
        echo "Installing $1 ..."
        cargo install --locked $1
    else
        echo "--> $1 already installed."
    fi
}

cargoTools=("eza" "bat" "zoxide" "yazi-fm" "yazi-cli" "tlrc")

for tool in "${cargoTools[@]}"; do
    check_and_install_tool $tool
done

delta --version
if [ ! $? -eq 0 ]; then
    echo "Installing delta"
    cargo install --locked git-delta
else
    echo "--> delta already installed"
fi

node -v
if [ ! $? -eq 0 ]; then
    echo "Installing NodeJS"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    source ~/.zshrc
    nvm install 22
else
    echo "NodeJS already installed"
fi
