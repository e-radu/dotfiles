# Dotfile configurations

## Installing the environment

```bash
sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
chezmoi init --apply e-radu
cd ~/.config
source setup.sh
source gui_setup.sh
```
