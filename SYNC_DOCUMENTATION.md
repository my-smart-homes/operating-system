# Operating System Repository Sync Documentation

**Date:** December 23, 2025  
**Repository:** my-smart-homes/operating-system  
**Sync Type:** Upstream merge from home-assistant/operating-system

---

## 1. Repository Status Before Sync

### Current State
- **Current Version:** 13.7.8 (custom build)
- **Upstream Version:** 16.3 (latest stable)
- **Branch:** dev (tracking origin/dev)
- **OS Name:** MY HOME ASSISTANT OS
- **Deployment:** development

### Backup Information
- **Backup Branch:** `backup-pre-sync-20251223`
- **Backup Point:** commit 2a98b1067 (13.7.8)

### Fork-Specific Commits
**Total Custom Commits:** 38 commits not in upstream

**Recent Custom Commits (last 20):**
1. `2a98b1067` - Update meta (13.7.8)
2. `d18a4385a` - Update meta (13.7.7)
3. `eb1f7e36f` - Update meta (13.7.6)
4. `240286cc3` - Update meta (13.7.5)
5. `c6827cf4e` - Update meta (13.7.4)
6. `76668e061` - bump 13.7.3
7. `d32b83532` - bump version
8. `16975c1a7` - bump version
9. `c9c747b78` - bump version
10. `d4de62a0c` - bump version
11. `22f2f09ce` - bump version
12. `fa478775e` - bump version
13. `6c0dc626a` - Update meta
14. `47386075e` - bump version
15. `b35c4db93` - bump version
16. `05ed510ce` - bump version
17. `b896976ff` - bump version
18. `1e9ecd987` - update tests
19. `8d8f24074` - updated supervisor ⚠️ **CRITICAL**
20. `1e8c6a857` - revert test

### Upstream Remote
- **URL:** https://github.com/home-assistant/operating-system.git
- **Status:** Added and fetched successfully
- **Commits Behind:** 475 commits
- **Version Gap:** 13.7.8 → 16.3 (major version jump)

---

## 2. Major Changes in Upstream (13.7.8 → 16.3)

### Version History
Major version releases between fork and upstream:
- **13.x series** (fork is at 13.7.8)
- **14.0** → 14.1 → 14.2
- **15.0** → 15.1 → 15.2
- **16.0** → 16.1 → 16.2 → **16.3** (current)

Also available but not on stable:
- **17.0.rc1** → 17.1.dev0 (development branch)

### Statistical Overview
- **Total Commits:** 475 new commits
- **Files Changed:** 310 files
- **Lines Added:** 6,745 insertions
- **Lines Removed:** 9,726 deletions

### Key Feature Categories

#### 1. Kernel Updates (Critical)
- **Current (13.7.x):** Linux kernel 6.x (older)
- **Upstream (16.3):** Linux kernel **6.12.62** (latest)
- Multiple kernel updates throughout versions 14-16
- Security patches and performance improvements
- New hardware support

#### 2. Docker/Container Runtime (Critical)
- **Docker:** Updated to **v29.1.3** (from older version)
- **containerd:** Updated to **v2.2.0**
- **runC:** Updated to **v1.3.4**
- Improved container performance and security
- Fixed slow system startup issues
- OCI archive support for Containerd snapshotter

#### 3. Buildroot Updates
- **Buildroot:** Updated to **2025.02.9**
- Build system improvements
- Toolchain updates
- Package management enhancements

#### 4. OS Agent Updates
- Updated to **v1.8.1** (from older version)
- Better Supervisor communication
- Improved system monitoring

#### 5. System Components
- **BlueZ:** Updated to v5.85 (Bluetooth stack)
- **kbd:** Updated to v2.9.0 (keyboard tools)
- **Go:** Updated to v1.25 (for building components)
- Configurable console keymaps via `localectl`

#### 6. Hardware Support
- Support for QingHeng CH9200 USB ethernet adapters
- RPi USB quirks for JMicron JMS583 Gen 2 Bridge
- Various driver updates

#### 7. Architecture Changes ⚠️ **BREAKING**
- **Removed armv7 support** - No longer building for armv7 targets
- This affects Raspberry Pi 2 and similar devices
- Only amd64, aarch64, i386 supported now

#### 8. Security & AppArmor
- Per-channel AppArmor profiles on clean installs
- Removed Docker content-trust (cosign) support
- Removed Docker key.json handling
- Enhanced security configurations

#### 9. Scripts & Tools Improvements
- Cleaned up hassio build scripts
- Updated hassos-cli functionality
- Improved haos-swapfile handling
- Enhanced haos-wipe capabilities
- Better data disk management

#### 10. Testing Improvements
- New OS update tests
- Enhanced smoke tests
- Supervisor integration tests
- Offline mode testing

---

## 3. Critical Custom Changes Analysis

### Most Important Custom Change

**Commit `8d8f24074`: "updated supervisor"**

**File:** `buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor`

```bash
-SUPERVISOR_IMAGE="ghcr.io/home-assistant/${SUPERVISOR_ARCH}-hassio-supervisor"
+SUPERVISOR_IMAGE="ghcr.io/my-smart-homes/${SUPERVISOR_ARCH}-hassio-supervisor"
```

**Impact:**
- ⚠️ **CRITICAL** - Changes where OS downloads Supervisor from
- Points to custom registry: `ghcr.io/my-smart-homes`
- **MUST BE PRESERVED** for custom infrastructure to work

**Preservation:** ✅ **MANDATORY**

---

### Version Bumping Pattern

All other commits follow a simple pattern of updating the version in `buildroot-external/meta`:

```diff
VERSION_MAJOR="13"
VERSION_MINOR="7"
-VERSION_SUFFIX="7"
+VERSION_SUFFIX="8"

HASSOS_NAME="MY HOME ASSISTANT OS"
HASSOS_ID="haos"
```

**Changes:**
1. Custom OS name: "MY HOME ASSISTANT OS" (not "Home Assistant OS")
2. Version suffix incrementing for custom builds
3. All within version 13.7.x series

**Preservation:** ✅ **REQUIRED** - Custom branding

---

## 4. Potential Conflicts & Concerns

### Major Breaking Changes to Watch

1. **armv7 Removal**
   - If you support armv7 devices, this is a problem
   - Would need to maintain armv7 builds separately
   - Check if your users have Raspberry Pi 2 or similar

2. **Supervisor Image Path**
   - Upstream script has likely been updated
   - Your custom registry path MUST be reapplied
   - This is THE most critical change to preserve

3. **Docker Content-Trust Removal**
   - Cosign verification removed upstream
   - Check if this affects your security model

4. **Kernel Version Jump**
   - From 6.x (old) to 6.12.62
   - Major kernel update, test hardware compatibility
   - Check if custom kernel configs still work

### Expected Merge Conflicts

1. **buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor**
   - CONFLICT EXPECTED: Supervisor image URL
   - Resolution: Keep `ghcr.io/my-smart-homes` path

2. **buildroot-external/meta**
   - CONFLICT POSSIBLE: Version numbers and OS name
   - Resolution: Update version to 16.3, keep custom name

3. **matrix.json**
   - File deleted upstream (matrix.json removed)
   - If you have custom matrix, may conflict

4. **Build scripts**
   - Various build scripts updated
   - May have minor conflicts if you customized them

---

## 5. Infrastructure Requirements

### Container Images Required

Your custom infrastructure must provide:

```
ghcr.io/my-smart-homes/amd64-hassio-supervisor
ghcr.io/my-smart-homes/aarch64-hassio-supervisor
ghcr.io/my-smart-homes/i386-hassio-supervisor
```

**Note:** If you still support armv7, you'll need to maintain that separately since upstream removed it.

### Build Dependencies

After sync, you'll need:
- Buildroot 2025.02.9 or compatible
- Linux kernel 6.12.62 sources
- Updated toolchains
- Docker 29.1.3+ for testing

---

## 6. Merge Strategy Recommendations

### Option 1: Merge Upstream (RECOMMENDED)

```bash
git checkout dev
git merge upstream/dev

# Resolve conflicts:
# - Keep custom supervisor image path
# - Update version to 16.3
# - Keep custom OS name
```

**Pros:**
- Gets all latest features
- Keeps git history clean
- Easiest to maintain long-term

**Cons:**
- Need to resolve conflicts carefully
- Large version jump (13.7 → 16.3)
- Need thorough testing

---

### Option 2: Cherry-pick Critical Updates

```bash
# Pick specific commits for security/critical updates only
git cherry-pick <kernel-update-commits>
git cherry-pick <docker-update-commits>
```

**Pros:**
- More control over what changes
- Can test incrementally
- Lower risk

**Cons:**
- Very time-consuming (475 commits)
- May miss important dependencies
- Will diverge more from upstream

---

## 7. Recommended Sync Steps

### Pre-Sync Checklist
- [x] Create backup branch (`backup-pre-sync-20251223`)
- [x] Add upstream remote
- [x] Fetch upstream tags and branches
- [ ] Review if armv7 support is needed
- [ ] Verify custom supervisor images exist for v16.3
- [ ] Check custom kernel configs compatibility
- [ ] Review build environment readiness

### Sync Process
1. Ensure you're on dev branch
2. Review this documentation
3. Perform merge: `git merge upstream/dev`
4. Resolve conflicts (see section 8)
5. Update buildroot-external/meta with correct version
6. Keep custom supervisor image path
7. Test build
8. Test on hardware
9. Push changes

### Post-Sync Verification
- [ ] OS builds successfully
- [ ] Boots on target hardware
- [ ] Supervisor downloads from custom registry
- [ ] Docker runtime works correctly
- [ ] Kernel loads properly
- [ ] Network functionality works
- [ ] Storage/disk operations work
- [ ] Hardware devices recognized
- [ ] Integration with custom Supervisor works

---

## 8. Conflict Resolution Guide

### Critical File: hassos-supervisor Script

**Expected Conflict:**
```bash
<<<<<<< HEAD
SUPERVISOR_IMAGE="ghcr.io/my-smart-homes/${SUPERVISOR_ARCH}-hassio-supervisor"
=======
SUPERVISOR_IMAGE="ghcr.io/home-assistant/${SUPERVISOR_ARCH}-hassio-supervisor"
>>>>>>> upstream/dev
```

**Resolution: KEEP YOUR VERSION**
```bash
SUPERVISOR_IMAGE="ghcr.io/my-smart-homes/${SUPERVISOR_ARCH}-hassio-supervisor"
```

---

### Critical File: buildroot-external/meta

**Expected Conflict:**
```bash
<<<<<<< HEAD
VERSION_MAJOR="13"
VERSION_MINOR="7"
VERSION_SUFFIX="8"

HASSOS_NAME="MY HOME ASSISTANT OS"
=======
VERSION_MAJOR="16"
VERSION_MINOR="3"
VERSION_SUFFIX="0"

HASSOS_NAME="Home Assistant OS"
>>>>>>> upstream/dev
```

**Resolution: UPDATE VERSION, KEEP CUSTOM NAME**
```bash
VERSION_MAJOR="16"
VERSION_MINOR="3"
VERSION_SUFFIX="0"

HASSOS_NAME="MY HOME ASSISTANT OS"  # Keep your custom name
HASSOS_ID="haos"

DEPLOYMENT="production"  # Or keep "development" if needed
```

---

### Conflict Resolution Priority
1. 🔴 **CRITICAL:** Supervisor image path - MUST point to my-smart-homes
2. 🔴 **CRITICAL:** OS custom name - Keep "MY HOME ASSISTANT OS"
3. 🟡 **IMPORTANT:** Version numbers - Update to 16.3
4. 🟢 **NORMAL:** Other script updates - Accept upstream unless customized

---

## 9. Testing Plan

### Build Testing
```bash
# After merge, test building
make BUILDER_UID=$(id -u) BUILDER_GID=$(id -g) rebuild
```

### Boot Testing
1. Flash to SD card/USB
2. Boot on target hardware
3. Check boot logs for errors
4. Verify Supervisor starts

### Integration Testing
1. Verify Supervisor container pulls from `ghcr.io/my-smart-homes`
2. Check Supervisor version
3. Verify Core integration
4. Test add-on installation
5. Verify network configuration
6. Test storage operations

---

## 10. Rollback Plan

If issues arise:

```bash
# Return to backup branch
git checkout backup-pre-sync-20251223

# Or reset main
git checkout dev
git reset --hard backup-pre-sync-20251223
git push origin dev --force  # DANGEROUS - use with caution
```

---

## 11. Post-Merge Action Items

### Immediate
1. Test build on all architectures (amd64, aarch64, i386)
2. Test boot on representative hardware
3. Verify Supervisor integration
4. Update any CI/CD pipelines

### Short-term
1. Document any new issues encountered
2. Update build documentation
3. Notify users of version upgrade
4. Monitor for bug reports

### Long-term
1. Decide on armv7 support (maintain separately or drop)
2. Plan for regular upstream syncs
3. Consider automation for version bumps
4. Document custom build process

---

## 12. Architecture Support Matrix

### Before Sync (13.7.8)
- ✅ amd64
- ✅ aarch64
- ✅ armv7 (if you built it)
- ✅ i386

### After Sync (16.3)
- ✅ amd64
- ✅ aarch64
- ❌ **armv7 REMOVED by upstream**
- ✅ i386

**Decision Required:** Do you need armv7 support?
- If YES: Must maintain armv7 builds separately
- If NO: Can follow upstream directly

---

## 13. Related Repositories

This sync is part of larger smart home update:
- ✅ **core-updated** - Already done
- ✅ **frontend-updated** - Already done
- 📍 **operating-system** - Current (DO THIS FIRST)
- 📋 **supervisor** - Next (documentation ready)

---

## 14. Contact & References

- **Upstream Repository:** https://github.com/home-assistant/operating-system
- **Fork Repository:** https://github.com/my-smart-homes/operating-system
- **Buildroot Documentation:** https://buildroot.org/
- **Home Assistant OS Docs:** https://github.com/home-assistant/operating-system/tree/dev/Documentation

---

## 15. Important Notes

### Kernel Upgrade Impact
- Linux 6.12.62 is significantly newer than what's in 13.7.8
- Test all hardware thoroughly
- Check for driver compatibility
- Review kernel configs

### Docker Version Jump
- Docker 29.1.3 has breaking changes from older versions
- Test container operations extensively
- Verify Supervisor compatibility

### Build System Changes
- Buildroot 2025.02.9 may require build environment updates
- Check build dependencies
- May need updated cross-compilation tools

---

**Document Version:** 1.0  
**Last Updated:** December 23, 2025 05:29 UTC  
**Status:** Pre-sync analysis complete
