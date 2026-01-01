<div align="center">
  <h1>AnyVM Docker</h1>
  <p><strong>Spin up disposable VMs for any OS target, instantly inside Docker.</strong></p>

  [![Build and Publish Docker Image](https://github.com/anyvm-org/docker/actions/workflows/docker-build.yml/badge.svg)](https://github.com/anyvm-org/docker/actions/workflows/docker-build.yml)
  [![License](https://img.shields.io/github/license/anyvm-org/docker)](https://github.com/anyvm-org/docker/blob/main/LICENSE)
</div>

<hr />

AnyVM Docker allows you to run full operating systems (FreeBSD, OpenBSD, NetBSD, Haiku, etc.) inside a Docker container using QEMU. It's perfect for testing, CI/CD, and "throwaway" development environments.

## 🚀 Quick Start

Run a FreeBSD VM instantly:
```bash
docker run --rm -it ghcr.io/anyvm-org/anyvm --os freebsd
```
> [!TIP]
> Replace `--os freebsd` with your desired OS (e.g., `openbsd`, `netbsd`, `haiku`, `ubuntu`).

---

## ✨ Features

- **Multi-Arch & Multi-OS**: Supports x86_64, ARM64, and RISC-V targets.
- **Persistent Storage**: Cache downloaded images to avoid re-downloads.
- **Automatic Port Discovery**: Automatically detects and mounts host folders.
- **KVM Support**: Hardware acceleration if the host supports it.
- **VNC & Web Access**: Built-in VNC and noVNC (Web) access.
- **Integrated SSH**: Automatic SSH daemon for easy VM interaction.

---

## 🛠️ Common Scenarios

### 📁 1. Mount Host Folder into VM
Share files between your host and the guest VM.
```bash
mkdir -p workspace
docker run --rm -it \
  -v $(pwd)/workspace:/mnt/host \
  ghcr.io/anyvm-org/anyvm --os freebsd
```

### 💾 2. Persistent Image Storage
Cache VM images in a host directory to save bandwidth and time.
```bash
docker run --rm -it \
  -v $(pwd)/anyvm-data:/data \
  ghcr.io/anyvm-org/anyvm --os freebsd
```

### 🌐 3. Expose Ports & Forward Traffic
Access VM services from your host machine.
```bash
docker run --rm -it \
  -p 10022:10022 -p 8080:8080 \
  ghcr.io/anyvm-org/anyvm --os freebsd -p 8080:80
```
*The first `-p` publishes container port 8080; the second `-p` (after image name) forwards container 8080 to VM port 80.*

### ⚡ 4. Enable KVM Acceleration
Significantly improve performance if your host supports KVM.
```bash
docker run --rm -it \
  --device /dev/kvm:/dev/kvm:rw \
  ghcr.io/anyvm-org/anyvm --os freebsd
```

---

## 🔌 Exposed Ports

The container exposes several ports by default for convenience:

| Port | Service | Description |
|:---:|:---|:---|
| `10022` | **SSH** | Connect via `ssh -p 10022 root@localhost` |
| `6080` | **Web VNC** | Access GUI via browser at `http://localhost:6080` |
| `5900` | **VNC** | Access GUI via VNC client |
| `7000` | **Monitor** | Access QEMU Monitor console |

---

## ⌨️ Advanced: Direct Commands
Use `--` to execute a command inside the VM directly via SSH after boot.
```bash
docker run --rm -it ghcr.io/anyvm-org/anyvm --os freebsd -- uname -a
```

---

## 📖 More Information
For a full list of supported operating systems and advanced options, please visit the [AnyVM Main Repository](https://github.com/anyvm-org/anyvm).

<div align="center">
  <br />
  <sub>Built with ❤️ by the AnyVM Team</sub>
</div>
