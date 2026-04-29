# claudock-images

> Turnkey Docker images to run [Claude Code](https://docs.claude.com/en/docs/claude-code) in a secure, containerized environment.

Five flavors are published, all share the same hardened base, all ship a [code-server](https://github.com/coder/code-server) (FOSS VSCode) with the official `Anthropic.claude-code` extension preinstalled. Pick the one that fits your workload.

| Image | Use case | Includes | Approx. size |
|---|---|---|---|
| **`claudock-minimal`** | Run Claude Code with a real browser, nothing else | Claude + zsh/p10k + code-server + git + Firefox + Chromium | ~2.3 GB |
| **`claudock-dev`** | Day-to-day software dev with Claude | minimal + Python (uv, pipx, ipython), Node 22 + pnpm + bun, Go, Rust, gh, glab, httpie, yq | ~4.8 GB |
| **`claudock-cloud`** | Cloud / IaC / orchestration work | minimal + HashiCorp suite + Kubernetes (kubectl, helm, k9s, …) + AWS/GCP/Azure + OpenShift `oc` + Ansible | ~5.7 GB |
| **`claudock-security`** | Code audit & light pentest with AI assistance | minimal + nmap, masscan, sqlmap, gobuster, ffuf, hashcat, john, hydra, gdb, radare2, binwalk, semgrep, … | ~4.4 GB |
| **`claudock-full`** | The kitchen sink | dev + cloud + security combined | ~10 GB |

All variants are built on `debian:stable-slim`, run as `root` (so `apt install` works during a session), and share the same shell DX: zsh + Powerlevel10k + oh-my-zsh + autosuggestions + syntax-highlighting + completions, generous history, sensible aliases.

## Why this exists

Running Claude Code directly on your host gives an AI agent unrestricted access to your filesystem, your shell history, your cloud credentials, your SSH keys. These images ship everything Claude needs **inside a Docker container** so you can:

- Isolate Claude Code's blast radius from your host.
- Keep one container per project, with its own auth and installed tools.
- Get a "batteries included" dev environment ready in seconds.

Pair them with the [Claudock wrapper](https://github.com/helphyy/claudock) for named persistent containers, multi-profile auth, project config, git clone on creation, X11 forwarding, code-server activation, and more.

## Quick start

### Pull the variant you want

```bash
docker pull ghcr.io/helphyy/claudock-minimal:latest
docker pull ghcr.io/helphyy/claudock-dev:latest
docker pull ghcr.io/helphyy/claudock-cloud:latest
docker pull ghcr.io/helphyy/claudock-security:latest
docker pull ghcr.io/helphyy/claudock-full:latest
```

### Run standalone (without the wrapper)

```bash
docker run -it --rm \
  -v "$HOME/.claudock-auth:/root/.claude" \
  -v "$PWD:/workspace" \
  ghcr.io/helphyy/claudock-dev:latest
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

make build-minimal      # 2.3 GB
make build-dev          # 4.8 GB (extends minimal)
make build-cloud        # 5.7 GB (extends minimal)
make build-security     # 4.4 GB (extends minimal)
make build-full         # 10  GB (extends dev + cloud + security)
make build-all          # all five
```

## Tags

Each variant is published on GHCR under `ghcr.io/helphyy/<name>`:

- `latest`: current stable
- `vX.Y.Z`: pinned versions
- `dev`: built from `main`, may be unstable

## Security notes

- Containers run as **root** by design (so `apt install` works during a session). Real isolation comes from the Docker container boundary.
- Default Docker capability set; no `--privileged`, no Docker socket mounted.
- Use `--security-opt=no-new-privileges` (the Claudock wrapper applies it automatically).
- The `claudock-security` image ships offensive tooling. Use it **only on systems you are authorized to test**.
- `--x11` (X server forwarding) lets a container observe/inject events on your host: only enable for trusted code.

## Acknowledgements

Image structure and variant taxonomy are heavily inspired by
[Exegol](https://github.com/ThePorgs/Exegol). Many thanks to the Exegol team
for the design patterns we re-used (single base image, layered variant
inheritance, named persistent containers).

## License

[GPLv3](LICENSE).

## Links

- Wrapper: <https://github.com/helphyy/claudock>
- Issues: <https://github.com/helphyy/claudock-images/issues>
