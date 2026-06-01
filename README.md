# claudock-images

> Single light Docker image to run [Claude Code](https://docs.claude.com/en/docs/claude-code) in a secure, containerized environment.

One image, rebuilt by GitHub Actions every 2 days so Claude Code and base packages stay fresh.

Published at `ghcr.io/helphyy/claudock:latest`. Approx. size: ~2.3 GB.

Contents:
- Claude Code (latest release) + zsh + Powerlevel10k + oh-my-zsh (autosuggestions, syntax highlighting, completions)
- [code-server](https://github.com/coder/code-server) (FOSS VSCode) with the official `Anthropic.claude-code` extension preinstalled
- Browsers: Firefox, Chromium (+ chromedriver for Playwright)
- Git, OpenSSH client, rsync, tree, vim, helix, nano, less, jq, ripgrep, fzf, tmux, asciinema
- Network tools: dig, mtr, traceroute, nc, whois, ipcalc, [asn](https://github.com/nitefood/asn)
- Clipboard forwarding: `xclip` (X11) + `wl-clipboard` (Wayland)
- Built on `debian:stable-slim`, runs as `root` (so `apt install` works during a session), contrib + non-free enabled

Need more (Python toolchain, cloud SDKs, pentest tools...)? Install on demand inside the container with `apt install ...` or `pipx install ...`, or build a project image with `FROM ghcr.io/helphyy/claudock:latest` and add what you need.

## Why this exists

Running Claude Code directly on your host gives an AI agent unrestricted access to your filesystem, your shell history, your cloud credentials, your SSH keys. This image ships everything Claude needs **inside a Docker container** so you can:

- Isolate Claude Code's blast radius from your host.
- Keep one container per project, with its own auth and installed tools.
- Get a "batteries included" base environment ready in seconds.

Pair it with the [Claudock wrapper](https://github.com/helphyy/claudock) for named persistent containers, multi-profile auth, project config, git clone on creation, X11 forwarding, code-server activation, and more.

## Quick start

### Pull

```bash
docker pull ghcr.io/helphyy/claudock:latest
```

### Run standalone (without the wrapper)

```bash
docker run -it --rm \
  -v "$HOME/.claudock-auth:/root/.claude" \
  -v "$PWD:/workspace" \
  ghcr.io/helphyy/claudock:latest
```

This:
- Mounts `~/.claudock-auth` as the persistent Claude credentials store.
- Mounts your current directory at `/workspace`.
- Drops you into a `zsh` shell with `claude` already on the PATH.

Then inside the container:

```bash
claude        # starts Claude Code
```

The first time, Claude Code prompts you to log in. Tokens are written to `/root/.claude` and persisted on the host bind mount.

### Recommended: use the [Claudock wrapper](https://github.com/helphyy/claudock)

```bash
pipx install claudock
claudock start my-project --cwd
```

## Build it yourself

```bash
git clone https://github.com/helphyy/claudock-images.git
cd claudock-images
make build    # tags claudock:latest locally
make push     # tags + pushes to ghcr.io/helphyy/claudock (needs login)
```

## Tags

- `latest`: built from `main`, refreshed every 2 days by the scheduled workflow.
- `YYYY-MM-DD`: dated snapshot of each scheduled build (for pinning).

## Security notes

- The container runs as **root** by design (so `apt install` works during a session). Real isolation comes from the Docker container boundary.
- Default Docker capability set; no `--privileged`, no Docker socket mounted.
- Use `--security-opt=no-new-privileges` (the Claudock wrapper applies it automatically).
- `--x11` (X server forwarding) lets a container observe/inject events on your host: only enable for trusted code.

## License

[GPLv3](LICENSE).

## Links

- Wrapper: <https://github.com/helphyy/claudock>
- Issues: <https://github.com/helphyy/claudock-images/issues>
