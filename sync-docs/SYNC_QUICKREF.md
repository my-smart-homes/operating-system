# Quick Reference: Operating System Sync Guide

**Status:** ⚠️ Ready for sync (backup created)  
**Date:** December 23, 2025  
**Current Version:** 13.7.8 → **Target:** 16.3

---

## 📋 Quick Status

```
Repository: operating-system (my-smart-homes fork)
Backup Branch: backup-pre-sync-20251223
Commits Behind: 475 commits
Custom Changes: 38 commits (mainly version bumps + 1 critical change)
Version Jump: 13.7.8 → 16.3 (3 major versions)
```

---

## 🚀 Quick Start Sync Commands

```bash
# Verify you're on dev branch
git checkout dev

# Merge upstream
git merge upstream/dev

# CRITICAL: Resolve conflicts preserving:
# - my-smart-homes supervisor registry
# - MY HOME ASSISTANT OS branding

# Push backup first (safety)
git push origin backup-pre-sync-20251223

# After testing, push merged changes
git push origin dev
```

---

## ⚠️ THE ONE CRITICAL CHANGE TO PRESERVE

**File:** `buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor`

```bash
# MUST KEEP THIS LINE:
SUPERVISOR_IMAGE="ghcr.io/my-smart-homes/${SUPERVISOR_ARCH}-hassio-supervisor"

# DO NOT LET IT BECOME:
# SUPERVISOR_IMAGE="ghcr.io/home-assistant/${SUPERVISOR_ARCH}-hassio-supervisor"
```

**This is the ONLY functional code change. Everything else is version bumps.**

---

## 📊 What Changed Upstream (475 commits)

### Major Updates
- ✅ Linux kernel → **6.12.62** (security & performance)
- ✅ Docker → **v29.1.3** (latest stable)
- ✅ containerd → **v2.2.0**
- ✅ runC → **v1.3.4**
- ✅ Buildroot → **2025.02.9**
- ✅ OS Agent → **v1.8.1**
- ✅ BlueZ → v5.85
- ✅ Go → v1.25

### Breaking Changes
- ⚠️ **armv7 removed** - Raspberry Pi 2 no longer supported
- ⚠️ Docker content-trust removed
- ⚠️ Major kernel version jump

### New Features
- Configurable console keymaps via localectl
- QingHeng CH9200 USB ethernet support
- RPi USB quirks for JMicron devices
- OCI archive support for Containerd
- Enhanced testing framework

---

## 🛠️ Conflict Resolution Quick Guide

### If you see conflict in hassos-supervisor:

```bash
# KEEP YOUR VERSION:
SUPERVISOR_IMAGE="ghcr.io/my-smart-homes/${SUPERVISOR_ARCH}-hassio-supervisor"
```

### If you see conflict in meta file:

```bash
# UPDATE VERSION but KEEP CUSTOM NAME:
VERSION_MAJOR="16"
VERSION_MINOR="3"
VERSION_SUFFIX="0"

HASSOS_NAME="MY HOME ASSISTANT OS"  # ← Keep this!
HASSOS_ID="haos"

DEPLOYMENT="production"  # or "development"
```

---

## ✅ Pre-Merge Checklist

### Infrastructure Ready?
- [ ] `ghcr.io/my-smart-homes/amd64-hassio-supervisor:latest` exists
- [ ] `ghcr.io/my-smart-homes/aarch64-hassio-supervisor:latest` exists
- [ ] `ghcr.io/my-smart-homes/i386-hassio-supervisor:latest` exists
- [ ] Do you need armv7? (upstream removed it)

### Build Environment Ready?
- [ ] Buildroot dependencies updated
- [ ] Sufficient disk space (20GB+)
- [ ] Docker available for testing
- [ ] Cross-compilation tools installed

---

## 🔍 Post-Merge Verification

### Verify Critical Changes

```bash
# Check supervisor registry (CRITICAL!)
grep "SUPERVISOR_IMAGE" buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor
# Must show: ghcr.io/my-smart-homes

# Check OS branding
grep "HASSOS_NAME" buildroot-external/meta
# Must show: MY HOME ASSISTANT OS

# Check version
cat buildroot-external/meta
# Should show: 16.3.0
```

### Test Build

```bash
# Build OS image
make BUILDER_UID=$(id -u) BUILDER_GID=$(id -g) rebuild

# Check build artifacts
ls -lh release/
```

### Test on Hardware

1. Flash image to SD card/USB
2. Boot target device
3. Watch boot logs for errors
4. Verify Supervisor pulls from `my-smart-homes` registry
5. Check system functionality

---

## 🔄 Rollback if Needed

```bash
# Option 1: Reset to backup
git reset --hard backup-pre-sync-20251223

# Option 2: Revert merge
git revert -m 1 <merge-commit-sha>

# Option 3: Use backup branch
git checkout backup-pre-sync-20251223
git branch -D dev
git checkout -b dev
```

---

## 📚 Detailed Documentation

- **Full sync details:** `SYNC_DOCUMENTATION.md`
- **Custom changes analysis:** `CUSTOM_CHANGES.md`
- **This quick guide:** `SYNC_QUICKREF.md`

---

## ⚡ Quick Decisions Needed

### 1. armv7 Support?
**Upstream removed it. Do you need it?**
- **YES** → Must maintain armv7 builds separately
- **NO** → Follow upstream, simpler

### 2. Deployment Mode?
**What mode for your OS?**
- **production** → Stable releases
- **beta** → Testing releases
- **development** → Development builds

### 3. Version Numbering?
**How to version your fork?**
- **Option A:** 16.3.0 (match upstream)
- **Option B:** 16.3.0-msh1 (add suffix)
- **Option C:** 16.3.0-dev (development suffix)

---

## 🎯 Key Files to Watch

| File | What It Does | Action |
|------|-------------|--------|
| `buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor` | Launches Supervisor | **KEEP CUSTOM REGISTRY** |
| `buildroot-external/meta` | Version & branding | Update version, keep name |
| `buildroot-external/scripts/*` | Build scripts | Accept upstream |
| `buildroot-external/rootfs-overlay/*` | OS files | Review changes |

---

## 💡 Pro Tips

### Merge Safely
```bash
# Create temporary branch for testing
git checkout -b test-merge
git merge upstream/dev
# Test build, if successful, merge to dev
```

### Parallel Testing
```bash
# Keep old version running while testing new
# Flash new version to separate SD card
# Compare functionality side-by-side
```

### Document Everything
```bash
# Note any issues during merge
echo "Issue: ..." >> MERGE_NOTES.md
# Track custom fixes applied
```

---

## 🚨 Common Issues & Solutions

### Issue: Build Fails

**Symptom:** Buildroot compilation errors

**Solutions:**
1. Update Buildroot dependencies
2. Clear build cache: `make clean`
3. Check disk space
4. Review build logs

### Issue: Supervisor Not Found

**Symptom:** OS can't find Supervisor image

**Solutions:**
1. Check registry URL in hassos-supervisor script
2. Verify images exist in registry
3. Test docker pull manually

### Issue: Boot Failure

**Symptom:** OS doesn't boot after flash

**Solutions:**
1. Check boot partition integrity
2. Verify kernel config
3. Review hardware compatibility
4. Test on different device

---

## 📞 Important URLs

- **Fork:** `https://github.com/my-smart-homes/operating-system`
- **Upstream:** `https://github.com/home-assistant/operating-system`
- **Container Registry:** `ghcr.io/my-smart-homes/*`
- **Buildroot:** `https://buildroot.org/`

---

## 🎯 Success Criteria

Merge is successful when:
- [x] Build completes without errors
- [x] Image boots on hardware
- [x] Supervisor downloads from `ghcr.io/my-smart-homes`
- [x] System shows "MY HOME ASSISTANT OS"
- [x] Docker runtime works
- [x] Network functional
- [x] Storage accessible
- [x] Integration with Supervisor works

---

## ⏱️ Estimated Timeline

- **Merge:** 30 minutes (conflicts + testing)
- **Build:** 2-4 hours (depending on hardware)
- **Flash & Boot:** 15 minutes
- **Testing:** 1-2 hours
- **Total:** ~4-7 hours

---

**Remember:** 
1. The supervisor registry path is the ONLY critical custom code change
2. Everything else is just version numbers
3. Keep custom branding
4. Test thoroughly before deploying

---

_Last Updated: December 23, 2025 05:29 UTC_
