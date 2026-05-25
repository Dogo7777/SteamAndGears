# SteamAndGears – Cloud‑Native Fedora Bootc Desktop

**SteamAndGears** is a modern, immutable desktop OS built on **Fedora Bootc (Bootable Containers)**.  
It is not “just another distro” — it is a **cloud‑native desktop infrastructure** optimized for gaming, development, and performance‑oriented workloads.

## 🎯 What SteamAndGears is

SteamAndGears delivers a **Fedora Bootc‑based desktop OS** where the root filesystem (`/`) is a **read‑only OCI image**, updated via **atomic, A/B image‑based updates**.  

Think of it as a **desktop environment managed like a cloud service**:  
- OS image defined in a `Containerfile`.  
- Updates pull OCI images.  
- Reboot activates the new version — or rolls back if needed.

The default environment is **KDE Plasma** with a carefully curated set of fast, lightweight tools and extensive support for containerized development and gaming.

## 🔧 Core pillars

### 1. Immutable architecture

- Root filesystem (`/`) is a **read‑only OCI container image**, built from `fedora-bootc-source` or similar.  
- No live package mutations: the OS cannot be corrupted by partial `dnf` updates or broken dependencies.  
- All configuration lives in stateful, writable layers (e.g., `/var`, `/home`, `/etc` overlays), preserving the declarative “infrastructure as code” model.

### 2. Atomic A/B updates

- **Image‑based updates** via `bootc`: new OS versions are downloaded as OCI images, and activation happens at reboot.  
- Two active image slots (A/B): if the new version fails, the system rolls back to the previous slot instantly.  
- Updates are **transactional**: either the full image is applied, or the system remains unchanged.

### 3. Clean base (minimalism, “zero‑garbage”)

- Base environment: **KDE Plasma** with only essential components (no bloated preinstalled suites).  
- Curated tooling for performance:
  - Terminal: **Ptyxis** (or similar lightweight, fast terminal emulator).  
  - File manager: **Nautilus** optimized for SSDs and fast I/O.  
- Optional metapackages allow you to add “dev stack” or “gaming stack” overlays without polluting the base.

### 4. Gaming & development ready

- **Optimized kernel**:
  - `CachyOS`‑style tuned kernel with **low‑latency scheduler** and reduced scheduling overhead.  
  - **Mitigations off** (where safe) for higher CPU performance.  
  - Enabled **ZRAM** and tuned swap behavior for small‑RAM workloads.  
- **CPU tuning**:
  - Intel‑specific tuning for Turbo Boost, power‑saving, and responsiveness.  
- **Containerized development**:
  - Development environments fully encapsulated via **Distrobox** and **Toolbox**.  
  - No “pollution” of the host OS: you can run any distro (Debian, Ubuntu, Arch, etc.) inside disposable containers.

### 5. GitHub‑centric lifecycle (GHCR + CI)

- **Base image and variants** are hosted on **GitHub Container Registry (GHCR)** as `ghcr.io/<your-org>/steamandgears`.  
- Builds are fully automated via:
  - `Containerfile` defining the immutable OS image.  
  - GitHub Actions building new OCI images and pushing them to GHCR.  
- Versioning follows **OCI image tags**:
  - `latest` → rolling edge desktop.  
  - `stable-vX.Y` → tested, stable releases.

## 🖼️ Architecture overview (simplified)

Clients install a **disk image derived from the SteamAndGears Bootc OCI image** (via `bootc image build` or Podman Desktop).  
From that point on:

- OS updates are **pull‑based OCI images** from GHCR.  
- The desktop UX is **KDE Plasma + performance‑tuned stack**.  
- Containerized dev/gaming environments run isolated via **Distrobox** and **Toolbox**.

## 🧑‍💻 Target audience

SteamAndGears is ideal for:

- **Developers** who want:
  - Stable, atomic OS updates.  
  - Clean base + containerized dev environments.  
- **Performance‑oriented users**:
  - Low‑latency gaming and creative workloads.  
  - Tuned CPU, kernel, and memory behavior.  
- **Desktop infra teams / admins**:
  - Declarative, image‑based lifecycle.  
  - Rollback‑ready, versioned deployments.

## 🚀 Getting started (template)

```bash
# 1. Install bootc (if not already present)
sudo dnf install bootc

# 2. Pull the SteamAndGears base image from GHCR
sudo podman pull ghcr.io/<your-org>/steamandgears:latest

# 3. Switch to the new image (A/B update)
sudo bootc switch --transport=containers-storage ghcr.io/<your-org>/steamandgears:latest

# 4. Reboot to activate
sudo reboot
```

From there, you can:

- Use `distrobox` to run any dev environment:
  ```bash
  distrobox create --image ubuntu:24.04 dev-ubuntu
  distrobox enter dev-ubuntu
  ```
- Use `toolbox` if you prefer Podman‑style containers.

## 📦 Why SteamAndGears is the “Cloud‑Native Desktop”

- **Infra as OCI images**: your desktop is defined in a `Containerfile`, just like a cloud VM.  
- **Git‑driven lifecycle**: changes are PRs → CI builds → new OCI tags → atomic updates.  
- **Zero “manual apt” hell**: no more partial upgrades breaking the system.  
- **Consistent dev‑to‑prod**: your dev desktop and workstation cluster share the same image model.

---

🔧 **Want to customize?**  
- Fork this repo.  
- Tweak the `Containerfile` to add your preferred tools, themes, or runtimes.  
- Push a new OCI tag and let your users upgrade via `bootc switch`.

✅ **Repository name suggestion**:  
Given the concept, something like `steamandgears-desktop` or `steamandgears-bootc` works well as the GitHub repo name.

Se quiser, posso também gerar uma versão em **português do Brasil** deste README, com foco em usuários brasileiros e comunidades locais.
