# Load OS-specific zshrc file
if [ -f "$HOME/.zshrc.local" ]; then
	source "$HOME/.zshrc.local"
fi

# Load additional stuff
if [ -f "$HOME/.zsh_plugins" ]; then
	source "$HOME/.zsh_plugins"
fi

