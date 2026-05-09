# Dotf2

My personal dotfiles managed with Ansible.

## Prerequisites

```bash
brew install ansible
```

You also need a `.vault_pass` file at the repo root containing the password for `provision/secrets.yml` (used to decrypt API tokens during provisioning).

## Configuration

User information is configured in `provision/group_vars/all.yml`:
- `user_name` — Your full name for git config
- `user_email` — Your email for git config

Secrets (API keys, tokens) live in `provision/secrets.yml`, encrypted with Ansible vault. To edit:

```bash
ansible-vault edit provision/secrets.yml --vault-password-file .vault_pass
```

## Installation

Full setup (installs homebrew packages and configures all tools):

```bash
make install
```

Update specific tools only:

```bash
make install tags=zsh,vim
make install tags=brew      # Install/update homebrew packages only
make install tags=git       # Configure git only
```

Available tags: `brew`, `git`, `zsh`, `vim`, `nvim`, `tmux`, `helix`, `ghostty`, `starship`, `devtools`, `claude`.

## Claude Code / RTK

The `claude` tag installs and configures Claude Code:
- Symlinks `~/.claude/settings.json` and `~/.claude/CLAUDE.md` from `dotfiles/claude/`
- Renders `~/.mcp.json` from the Jinja template, with Trello/Datadog secrets pulled from the vault
- Installs [RTK](https://github.com/rtk-ai/rtk) (Rust Token Killer) and runs `rtk init -g` to install the token-saving hook into Claude Code (idempotent — skipped if `~/.claude/RTK.md` already exists)

## Post-Installation

Create `~/.zshrc.secrets` for any environment variables that should not be committed to git.
