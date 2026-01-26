# Kali Build Slim

A **minimal, macOS-friendly, Apple Silicon–native Kali Linux container** designed for penetration testers, cloud security engineers, and red teamers who want:

* 🪶 A *lean* base image (no scanners, no bloat)
* 🍎 First-class support for **macOS containers (ARM64 / Apple Silicon)**
* 🐳 A clean **container-native workflow** (ephemeral by default)
* ☁️ Built-in **cloud & Kubernetes tooling**
* ⌨️ Shell behavior that **matches a hardened macOS Zsh setup**

This project is opinionated by design: it gives you a sharp baseline and lets you install anything else *on demand*, inside disposable containers.

---

## ✨ Philosophy

> *Containers should feel like home — without polluting the host.*

This image intentionally:

* ❌ Avoids heavyweight scanners and GUI tools
* ❌ Avoids raw-socket / kernel-dependent tooling
* ❌ Avoids persistent state unless **you explicitly mount it**

Instead, it provides:

* A fast, familiar Zsh environment
* Frequently used, low-bloat pentest tools
* Cloud + Kubernetes CLIs that integrate with host credentials
* Wordlists mounted from the host (not baked into the image)

If you need a tool once:

```bash
apt update && apt install -y toolname
```

Use it → exit → container gone → Mac stays clean.

The goal is to keep the macOS host clean and fast, installing tools ephemerally inside containers only when needed.

---

## Important: macOS-first, Docker-free by design

This setup is intentionally built around **macOS-native container workflows**, not Docker Desktop.

It assumes:
- Apple Silicon (M1/M2/M3)
- Containers backed by the **Apple Virtualization Framework**
- A lightweight, on-demand container runtime (e.g. Podman on macOS)

If you are looking for a traditional Linux Docker host or a Kali-in-Docker setup, this repository is **not** optimized for that use case.

---

## 🧰 What’s Included

### Core Utilities

* `curl`, `jq`, `git`
* `vim`, `tmux`, `zsh`
* `ca-certificates`, `gnupg`, `unzip`

### Lightweight Pentest Tools

These are CLI-only, container-safe, and used constantly:

* `nmap`
* `ffuf`
* `gobuster`
* `sqlmap`
* `dnsutils`
* `python3-impacket`
* `netcat-traditional`, `socat`

### Cloud & Kubernetes Tooling (ARM64-native)

* ☁️ AWS CLI v2
* ☁️ Google Cloud CLI
* ☸️ `kubectl`
* ☸️ `helm`
* 🐳 Docker CLI (client only)

---

## ❌ What’s *Not* Included (On Purpose)

* Metasploit, ZAP, Burp
* Heavy cloud / K8s scanners
* Ruby / Node ecosystems
* Raw-packet tools (masscan, responder, tcpdump)
* GUI applications

These either:

* Don’t work well in macOS containers
* Add massive image size
* Are better run on the host or in a VM

---

## 🏗️ Building the Image (Apple Silicon)

```bash
container buildx build \
  --platform linux/arm64 \
  -t kali-min .
```

Verify architecture:

```bash
container run --rm kali-min uname -m
# aarch64
```

---

## 🚀 Running the Container

### Recommended run command

```bash
container run -it --rm \
  -v $(pwd):/work \
  -v ~/seclists:/usr/share/seclists:ro \
  -v ~/.aws:/root/.aws \
  -v ~/.kube:/root/.kube \
  kali-min
```

### Why these mounts matter

| Mount                 | Purpose               |
| --------------------- | --------------------- |
| `/work`               | Working directory     |
| `/usr/share/seclists` | Wordlists (read-only) |
| `~/.aws`              | AWS credentials       |
| `~/.kube`             | Kubernetes contexts   |

---

## 📂 Wordlists (SecLists)

Wordlists are **not installed in the image**.

Clone once on the host:

```bash
git clone https://github.com/danielmiessler/SecLists ~/seclists
```

They are automatically detected by the shell when mounted.

---

## ⌨️ Shell Experience

This container ships with a **tuned Zsh environment** that mirrors a hardened macOS setup:

### Features

* Emacs-style keybindings
* macOS-consistent navigation shortcuts
* Menu-based tab completion
* Cloud-aware prompt
* OPSEC-friendly root indicator

### Prompt Enhancements

* 🔴 Red prompt when running as `root`
* ☁️ AWS profile shown if set
* ☸️ Kubernetes context shown if available
* ⚠️ Warning if SecLists is not mounted

### Per-project overrides

Create a local file:

```bash
.zshrc.local
```

Automatically sourced on directory change. Useful for:

* Setting `AWS_PROFILE`
* Target-specific variables
* Temporary aliases

---

## 📦 Ephemeral Installs (Recommended Workflow)

Install tools only when needed:

```bash
apt update && apt install -y smbclient
```

Exit the container when done — nothing persists unless mounted.

Optional speed-up using an APT cache volume:

```bash
container run -it --rm \
  -v kali-apt-cache:/var/cache/apt \
  kali-min
```

---

## 🍎 macOS Notes

* Designed for Docker Desktop, Colima, or Podman Machine
* Native ARM64 — no emulation
* No kernel or raw-socket assumptions
* Host tools (Burp, Metasploit, browsers) stay on macOS

For raw packet attacks or L2 testing, use a **Kali VM instead**.

---

## 🧠 Who This Is For

* Penetration testers who value clean workflows
* Cloud security engineers
* Red teamers working across environments
* Anyone tired of bloated “kitchen sink” images

---

## 📜 License

MIT — use it, fork it, adapt it.

---

## 🙌 Acknowledgements

* Kali Linux
* Oh My Zsh
* SecLists
* The community that values *less, but better*

---

If this helped you, consider sharing improvements or adaptations — this setup is meant to evolve with real-world use.
