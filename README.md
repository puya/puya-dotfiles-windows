# 🧰 Puya's Dotfiles

A personal collection of configuration files and setup tools for my development environment on macOS. Powered by [`dotbot`](https://github.com/anishathalye/dotbot) for easy setup.

## 🔧 What's included

- **ZSH** shell configuration with [Oh My Zsh](https://ohmyz.sh/)
- **ASDF** version manager for Node.js, Python, and more
- `.tool-versions` to auto-switch runtime versions per project
- `dev-setup.md` with a full write-up of how my system is configured
- Dotbot for automatic symlinking of config files

## 🚀 Quick setup (on a new machine)

```bash
git clone --recursive git@github.com:puya/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install
```

> Make sure [Homebrew](https://brew.sh/) and `asdf` are installed beforehand.

## 📁 Files linked to home directory

| Target           | Source          |
|------------------|------------------|
| `~/.zshrc`        | `.zshrc`          |
| `~/.tool-versions`| `.tool-versions`  |
| `~/dev-setup.md`  | `dev-setup.md`    |

---

## 🧠 Notes

- This repo is a living setup. Expect updates and tweaks as I refine my workflow.
- Feel free to fork or use as a base for your own dotfiles!
