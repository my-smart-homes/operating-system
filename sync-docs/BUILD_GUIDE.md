# Building Home Assistant Operating System - Complete Guide

**Version:** 16.3 (MY HOME ASSISTANT OS)  
**Date:** December 23, 2025  
**Location:** `/home/fitl/git/me/outsource/mha/operating-system`

---

## 📋 Prerequisites

### System Requirements

**Hardware:**
- **Disk Space:** 20-50 GB (depending on target)
- **RAM:** 8 GB minimum, 16 GB recommended
- **CPU:** Multi-core processor (4+ cores recommended)
- **Time:** 1-4 hours per build (depending on hardware)

**Operating System:**
- Linux (Ubuntu 20.04+ or similar)
- Debian-based distributions work best
- Other distributions may require additional setup

### Required Dependencies

#### Install Build Tools
```bash
sudo apt-get update
sudo apt-get install -y \
    bash bc bison build-essential bzip2 cpio \
    diffutils file flex gawk gcc git graphviz \
    g++ libncurses5-dev libssl-dev \
    make patch perl python3 python3-dev \
    rsync sed tar unzip wget which \
    jq dosfstools mtools parted rsync \
    qemu-user-static libglib2.0-dev libfdt-dev \
    libpixman-1-dev zlib1g-dev ninja-build \
    device-tree-compiler
```

#### Additional Dependencies for Cross-Compilation
```bash
# For ARM builds on x86_64
sudo apt-get install -y qemu-user-static binfmt-support

# For some board-specific tools
sudo apt-get install -y u-boot-tools
```

### Docker (Required)

The OS uses Docker to fetch and prepare container images during the build.

```bash
# If Docker not installed
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Log out and back in, then test
docker run hello-world
```

---

## 🎯 Supported Architectures

Your OS repository (version 16.3) supports these targets:

| Target | Architecture | Description |
|--------|--------------|-------------|
| `generic_x86_64` | x86-64 | Generic PC, Intel NUC, VM |
| `generic_aarch64` | ARM64 | Generic ARM 64-bit devices |
| `ova` | x86-64 | Virtual machine (OVA format) |
| `rpi3_64` | ARM64 | Raspberry Pi 3 (64-bit) |
| `rpi4_64` | ARM64 | Raspberry Pi 4 (64-bit) |
| `rpi5_64` | ARM64 | Raspberry Pi 5 (64-bit) |
| `odroid_c2` | ARM64 | ODROID C2 |
| `odroid_c4` | ARM64 | ODROID C4 |
| `odroid_n2` | ARM64 | ODROID N2 |
| `odroid_m1` | ARM64 | ODROID M1 |
| `odroid_m1s` | ARM64 | ODROID M1S |
| `khadas_vim3` | ARM64 | Khadas VIM3 |
| `green` | ARM64 | Home Assistant Green |
| `yellow` | ARM64 | Home Assistant Yellow |

**Note:** armv7 support was removed in version 16.x. Raspberry Pi 2 is no longer supported.

---

## 🚀 Quick Start Build

### Step 1: Navigate to Repository
```bash
cd /home/fitl/git/me/outsource/mha/operating-system
```

### Step 2: Choose Your Target
Pick from the supported targets list above. For example:
- `generic_x86_64` - For most PCs
- `rpi4_64` - For Raspberry Pi 4
- `ova` - For virtual machines

### Step 3: Build the OS

**Basic build command:**
```bash
make <target>
```

**Example for x86_64:**
```bash
make generic_x86_64
```

**With custom output directory:**
```bash
make O=custom_output generic_x86_64
```

**With proper user/group IDs (recommended):**
```bash
make BUILDER_UID=$(id -u) BUILDER_GID=$(id -g) generic_x86_64
```

### Step 4: Find Your Image
After successful build:
```bash
ls -lh release/
```

You'll find files like:
- `haos_generic-x86-64-16.3.img.xz` - Compressed disk image
- `haos_generic-x86-64-16.3.img` - Uncompressed (if present)
- Various `.raucb` files for updates

---

## 🔧 Advanced Build Options

### Build with Menuconfig (Configuration)

To customize the build configuration:

```bash
# Configure before building
make <target>-config

# This opens Buildroot's menuconfig
# Navigate with arrow keys, select with Space, save with S

# After configuring, build
make <target>
```

### Clean Builds

**Clean specific target:**
```bash
make clean
```

**Clean everything:**
```bash
rm -rf output/
```

**Clean and rebuild:**
```bash
make clean && make <target>
```

### Parallel Building

Speed up builds with parallel jobs:
```bash
# Use all CPU cores
make -j$(nproc) generic_x86_64

# Or specify number of jobs
make -j8 generic_x86_64
```

### Custom Buildroot Options

Pass options to underlying Buildroot:
```bash
make <target> BR2_JLEVEL=$(nproc)
```

---

## 📝 Step-by-Step: Building for Raspberry Pi 4

Let's walk through a complete example:

### 1. Prepare Environment
```bash
cd /home/fitl/git/me/outsource/mha/operating-system

# Ensure Docker is running
docker ps

# Check available targets
make help
```

### 2. Start the Build
```bash
# Build with proper user permissions
make BUILDER_UID=$(id -u) BUILDER_GID=$(id -g) rpi4_64
```

### 3. Monitor Build Progress
The build will:
1. Initialize Buildroot
2. Download packages and toolchain (first time only)
3. Build cross-compilation toolchain
4. Build kernel
5. Build root filesystem
6. Fetch Supervisor container
7. Create disk image

**This takes 1-4 hours depending on your hardware.**

### 4. Check Output
```bash
# List built images
ls -lh output/images/

# List release files
ls -lh release/
```

### 5. Flash to SD Card
```bash
# Decompress if needed
unxz release/haos_rpi4-64-16.3.img.xz

# Flash to SD card (replace /dev/sdX with your SD card)
# WARNING: This will erase the SD card!
sudo dd if=release/haos_rpi4-64-16.3.img of=/dev/sdX bs=4M status=progress
sync
```

---

## 🏗️ Build Process Details

### What Happens During Build

#### Phase 1: Initialization (5-10 minutes)
- Buildroot setup
- External configuration loading
- Dependency checking

#### Phase 2: Toolchain Build (30-60 minutes, first time only)
- Cross-compilation toolchain
- Cached for subsequent builds

#### Phase 3: Package Building (30-90 minutes)
- Linux kernel compilation
- System packages (busybox, systemd, etc.)
- Docker components
- OS Agent
- Board-specific tools

#### Phase 4: Container Preparation (5-15 minutes)
- Download Supervisor container from `ghcr.io/my-smart-homes`
- Download plugin containers (DNS, Audio, CLI, etc.)
- Download Core landing page container
- Import into data partition

#### Phase 5: Image Creation (5-10 minutes)
- Root filesystem packing
- Partition layout
- Bootloader installation
- Image compression

### Build Artifacts

**In `output/` directory:**
- `images/` - Built images and kernels
- `build/` - Build intermediates
- `host/` - Host tools
- `target/` - Target root filesystem
- `staging/` - Staging area

**In `release/` directory:**
- `haos_<board>-<arch>-<version>.img.xz` - Compressed image
- `haos_<board>-<arch>-<version>.raucb` - OTA update bundle
- Various update files

---

## ⚠️ Common Issues & Solutions

### Issue 1: Build Fails - Missing Dependencies
**Symptom:** Error about missing packages or tools

**Solution:**
```bash
# Install missing build dependencies
sudo apt-get update
sudo apt-get install -y build-essential git

# Check the error message for specific package names
```

### Issue 2: Disk Space Exhausted
**Symptom:** "No space left on device"

**Solution:**
```bash
# Check space
df -h

# Clean old builds
rm -rf output/

# Build requires 20-50GB free space
```

### Issue 3: Docker Permission Denied
**Symptom:** "permission denied while trying to connect to Docker"

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or
newgrp docker
```

### Issue 4: Download Failures
**Symptom:** "Failed to download..." errors

**Solution:**
```bash
# Check internet connection
ping google.com

# Retry the build - downloads resume from where they stopped
make <target>
```

### Issue 5: Toolchain Build Fails
**Symptom:** Errors during toolchain compilation

**Solution:**
```bash
# Clean and retry
make clean
make <target>

# Or completely reset
rm -rf output/
make <target>
```

### Issue 6: Container Download Fails
**Symptom:** "Failed to fetch container image"

**Solution:**
```bash
# Verify custom registry is accessible
docker pull ghcr.io/my-smart-homes/amd64-hassio-supervisor:latest

# Check version endpoint
curl https://my-smart-homes.github.io/version-data/data.json

# If images don't exist, build/push them first
```

### Issue 7: Memory Issues
**Symptom:** Build killed or system freezes

**Solution:**
```bash
# Reduce parallel jobs
make -j2 <target>  # Use only 2 cores

# Add swap space if needed
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## 🧪 Testing Your Build

### Step 1: Verify Image Integrity
```bash
cd release/

# Check file exists and has reasonable size
ls -lh haos_*.img.xz

# Decompress and check
unxz -k haos_*.img.xz
file haos_*.img

# Should show: DOS/MBR boot sector
```

### Step 2: Test in Virtual Machine (x86_64 only)

**Using QEMU:**
```bash
# Decompress image
unxz release/haos_generic-x86-64-16.3.img.xz

# Run in QEMU
qemu-system-x86_64 \
  -enable-kvm \
  -m 2048 \
  -smp 2 \
  -drive file=release/haos_generic-x86-64-16.3.img,format=raw \
  -net nic -net user,hostfwd=tcp::8123-:8123
```

**Using VirtualBox:**
1. Convert image to VDI:
   ```bash
   VBoxManage convertfromraw haos_generic-x86-64-16.3.img haos.vdi
   ```
2. Create VM with VDI as disk
3. Boot and test

### Step 3: Flash to Physical Device

**For SD cards (Raspberry Pi, etc.):**
```bash
# Find SD card device
lsblk

# Flash (replace /dev/sdX)
sudo dd if=release/haos_rpi4-64-16.3.img of=/dev/sdX bs=4M status=progress conv=fsync

# Alternative: Use balenaEtcher (GUI tool)
```

**For USB drives / SSDs:**
Same as SD card, just use the appropriate device.

### Step 4: First Boot Verification

After flashing and booting:

1. **Check OS boots** - Should see boot messages
2. **Check OS name** - Should show "MY HOME ASSISTANT OS"
3. **Wait for Supervisor** - 2-5 minutes for first start
4. **Check logs:**
   ```bash
   # If you have console access
   journalctl -f
   
   # Check Supervisor
   docker logs hassio_supervisor
   ```
5. **Access UI** - http://<device-ip>:8123

### Step 5: Verify Custom Infrastructure

**Check Supervisor image source:**
```bash
docker inspect hassio_supervisor | grep Image
# Should show: ghcr.io/my-smart-homes/...
```

**Check version endpoint:**
```bash
# From the device
curl https://my-smart-homes.github.io/version-data/data.json
```

**Check OS info:**
```bash
cat /etc/os-release
# Should show: MY HOME ASSISTANT OS
```

---

## 📊 Build Times Reference

Approximate build times on different hardware:

| Hardware | Cores | RAM | Time (first) | Time (rebuild) |
|----------|-------|-----|--------------|----------------|
| Laptop i5 | 4 | 8GB | 3-4 hours | 30-60 min |
| Desktop i7 | 8 | 16GB | 1.5-2 hours | 20-30 min |
| Workstation Xeon | 16 | 32GB | 45-60 min | 10-15 min |
| Cloud VM (4 core) | 4 | 8GB | 3-4 hours | 30-45 min |

**Note:** First build is much slower due to toolchain compilation. Subsequent builds reuse cached artifacts.

---

## 🔐 Build Verification Checklist

After successful build:

### File Verification
- [ ] Image file exists in `release/`
- [ ] File size is reasonable (500MB-2GB compressed)
- [ ] Can decompress without errors
- [ ] File command shows correct disk image type

### Boot Test
- [ ] OS boots successfully
- [ ] Shows "MY HOME ASSISTANT OS" branding
- [ ] Network interface comes up
- [ ] Docker service starts

### Supervisor Test
- [ ] Supervisor container pulls from `ghcr.io/my-smart-homes`
- [ ] Supervisor starts without errors
- [ ] Web UI accessible on port 8123
- [ ] Version shows 2025.12.3 (or current)

### Functionality Test
- [ ] Can access Home Assistant UI
- [ ] Add-on store loads
- [ ] Can install an add-on
- [ ] Settings accessible
- [ ] Logs viewable

---

## 🎓 Tips & Best Practices

### 1. Use Incremental Builds
Don't clean unless necessary:
```bash
# Good - fast rebuild
make rpi4_64

# Only when needed
make clean && make rpi4_64
```

### 2. Separate Output Directories
Build multiple targets without conflicts:
```bash
make O=output-x86 generic_x86_64
make O=output-rpi4 rpi4_64
```

### 3. Save Build Logs
```bash
make rpi4_64 2>&1 | tee build.log
```

### 4. Use ccache for Faster Rebuilds
```bash
# Install ccache
sudo apt-get install ccache

# Buildroot will use it automatically
```

### 5. Monitor Resource Usage
```bash
# In another terminal
htop  # or top
watch -n1 df -h  # watch disk space
```

### 6. Version Control Your Changes
```bash
# Before building
git status
git diff

# Document changes in commit
```

---

## 📚 Additional Resources

### Documentation
- **OS Docs:** `Documentation/` directory in repo
- **Buildroot Manual:** https://buildroot.org/downloads/manual/manual.html
- **HA Developer Docs:** https://developers.home-assistant.io/docs/operating-system

### Configuration Files
- **Board configs:** `buildroot-external/configs/`
- **Kernel configs:** `buildroot-external/kernel/`
- **Package definitions:** `buildroot-external/package/`
- **Scripts:** `buildroot-external/scripts/`

### Key Custom Files
- **Meta:** `buildroot-external/meta` (version, branding)
- **Supervisor script:** `buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor`
- **Version URL:** `buildroot-external/package/hassio/hassio.mk`

---

## 🐛 Debugging Build Issues

### Enable Verbose Output
```bash
make V=1 rpi4_64
```

### Check Specific Package Build
```bash
# After a failed build
cd output/build/<package-name>
make

# Check config
cd output/
make <package-name>-dirclean
make <package-name>-reconfigure
```

### Inspect Build Environment
```bash
# Enter build container (if using Docker build)
docker run -it --rm -v $PWD:/work homeassistant/amd64-builder bash

# Check buildroot config
cd output/
make menuconfig
```

### Get Help
```bash
# Buildroot help
make buildroot-help

# List all Buildroot targets
make help

# Show configuration for target
make <target>-config
```

---

## 🚀 Next Steps After Building

### 1. Deploy OS
- Flash to device
- Boot and verify
- Configure network

### 2. Build Supervisor
- See supervisor build documentation
- Use compatible version
- Deploy to device

### 3. Customize Further
- Modify kernel configs
- Add custom packages
- Adjust partition sizes
- Create custom board support

### 4. Set Up CI/CD
- Automate builds
- Publish to registry
- Version management

---

## ⚡ Quick Reference Commands

```bash
# List available targets
make help

# Build for specific target
make generic_x86_64

# Build with multiple cores
make -j$(nproc) rpi4_64

# Clean and rebuild
make clean && make rpi4_64

# Configure before building
make rpi4_64-config

# Check built images
ls -lh release/

# Verify image
file release/*.img

# Flash to SD card
sudo dd if=release/*.img of=/dev/sdX bs=4M status=progress
```

---

## 📞 Getting Help

If you encounter issues:

1. **Check this guide** - Common issues section
2. **Check build logs** - Look for specific errors
3. **Search documentation** - `Documentation/` directory
4. **Check Buildroot docs** - For Buildroot-specific issues
5. **Review sync docs** - `SYNC_DOCUMENTATION.md` for custom changes

---

**Document Version:** 1.0  
**Last Updated:** December 23, 2025  
**OS Version:** 16.3 (MY HOME ASSISTANT OS)

---

*For detailed information about the sync and custom changes, see `SYNC_DOCUMENTATION.md` and `CUSTOM_CHANGES.md`*
