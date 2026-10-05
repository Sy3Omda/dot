# dot

My personal Linux terminal bootstrap for quickly setting up a consistent Zsh + tmux environment on Ubuntu/Debian systems.

## Quick Setup

```bash
apt install -y git curl && git clone https://github.com/Sy3Omda/dot.git && cd dot && bash install.sh
```

Then restart the terminal or run:

```bash
exec zsh
```

## Includes

- Zsh + Oh My Zsh
- Oh My Tmux
- Zsh autosuggestions, syntax highlighting & completions
- `eza`, `bat`, `fzf`, `fd`, `tree` and Powerline fonts
- Useful Git, system, disk and network aliases
- Customized tmux status bar
- Automatic tmux attach when connecting over SSH

> **Warning:** The installer replaces `~/.zshrc` and `~/.tmux.conf.local` and changes the default shell to Zsh.

## Files

```text
install.sh             # Bootstrap installer
file.zshrc             # Zsh configuration
file.tmux.conf.local   # tmux configuration
```

Tested primarily on Ubuntu/Debian.
