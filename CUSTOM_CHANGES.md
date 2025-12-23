# Custom Fork Changes Documentation - Operating System

**Repository:** my-smart-homes/operating-system  
**Date:** December 23, 2025  
**Purpose:** Document custom modifications made to fork before upstream sync

---

## Overview

This document details the 38 custom commits in the fork that differ from upstream Home Assistant OS. The changes primarily consist of version bumps and one critical infrastructure customization.

---

## Custom Commits Summary

### Total Custom Commits: 38

**Pattern:**
- 37 commits are version/meta updates
- 1 commit is critical infrastructure change
- All commits maintain version 13.7.x lineage
- All versions branded as "MY HOME ASSISTANT OS"

---

## Critical Infrastructure Change

### Commit `8d8f24074` (October 16, 2024) ⚠️ **MOST IMPORTANT**

**Message:** "updated supervisor"  
**Author:** fuadnafiz98

**File Modified:** `buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor`

**Change:**
```bash
-SUPERVISOR_IMAGE="ghcr.io/home-assistant/${SUPERVISOR_ARCH}-hassio-supervisor"
+SUPERVISOR_IMAGE="ghcr.io/my-smart-homes/${SUPERVISOR_ARCH}-hassio-supervisor"
```

**Impact:**
- ⚠️ **CRITICAL** - This is the ONLY functional code change
- Changes the container registry for Supervisor
- OS will pull Supervisor from `ghcr.io/my-smart-homes` instead of official registry
- Required for entire custom infrastructure to function

**Preservation:** ✅ **MANDATORY** - Without this, your custom Supervisor won't be used

**Dependencies:**
- Custom Supervisor images must exist at:
  - `ghcr.io/my-smart-homes/amd64-hassio-supervisor`
  - `ghcr.io/my-smart-homes/aarch64-hassio-supervisor`
  - `ghcr.io/my-smart-homes/i386-hassio-supervisor`

---

## Version Update Commits

### Pattern: buildroot-external/meta Updates

All other 37 commits follow this pattern - updating version suffix in the meta file.

### Latest Version Updates (2025)

#### 1. Commit `2a98b1067` (July 16, 2025) - Current HEAD
**Message:** "Update meta"  
**Author:** nafiz-msh  
**Tag:** 13.7.8

```diff
VERSION_MAJOR="13"
VERSION_MINOR="7"
-VERSION_SUFFIX="7"
+VERSION_SUFFIX="8"

HASSOS_NAME="MY HOME ASSISTANT OS"
HASSOS_ID="haos"
```

**Purpose:** Bump to version 13.7.8

---

#### 2. Commit `d18a4385a` (May 12, 2025)
**Message:** "Update meta"  
**Author:** Bhesh Raj Thapa  
**Tag:** 13.7.7

**Purpose:** Bump to version 13.7.7

---

#### 3. Commit `eb1f7e36f` (April 8, 2025)
**Message:** "Update meta"  
**Author:** Bhesh Raj Thapa  
**Tag:** 13.7.6

**Purpose:** Bump to version 13.7.6

---

#### 4. Commit `240286cc3` (March 29, 2025)
**Message:** "Update meta"  
**Author:** Naimur Hasan  
**Tag:** 13.7.5

**Purpose:** Bump to version 13.7.5

---

#### 5. Commit `c6827cf4e` (March 27, 2025)
**Message:** "Update meta"  
**Author:** Naimur Hasan  
**Tag:** 13.7.4

**Purpose:** Bump to version 13.7.4

---

#### 6. Commit `76668e061` (March 20, 2025)
**Message:** "bump 13.7.3"  
**Author:** Naimur Hasan  
**Tag:** 13.7.3

**Purpose:** Bump to version 13.7.3

---

### Version History Timeline

The fork has maintained its own version series starting from 13.x:

```
13.6.0 → 13.7.0 → 13.7.1 → 13.7.2 → 13.7.3 → 13.7.4 → 13.7.5 → 13.7.6 → 13.7.7 → 13.7.8 (current)
```

**Custom Version Lineage:**
- Started at version 13.6.0
- All versions in 13.7.x series are custom builds
- Each increment is a micro version bump
- Pattern: VERSION_SUFFIX increments

**Meanwhile, Upstream Progressed:**
```
13.x → 14.0 → 14.1 → 14.2 → 15.0 → 15.1 → 15.2 → 16.0 → 16.1 → 16.2 → 16.3 (current)
```

**Gap:** Fork is approximately 3 major versions behind

---

## Custom Branding

### OS Name Customization

**Every version includes this branding:**

```bash
HASSOS_NAME="MY HOME ASSISTANT OS"
HASSOS_ID="haos"
DEPLOYMENT="development"
```

**Impact:**
- System identifies as "MY HOME ASSISTANT OS" instead of "Home Assistant OS"
- Custom branding appears in:
  - Boot screen
  - System information
  - Logs
  - UI displays

**Preservation:** ✅ **REQUIRED** - Custom branding identity

---

## Test Updates

### Commit `1e9ecd987`: "update tests"

Some test modifications were made, but details are in the version history. These are minor compared to the supervisor image change.

---

## Files Affected Summary

### Primary Files Modified Across Commits

1. **buildroot-external/meta** (37 times)
   - Version number updates
   - Custom OS name maintained
   - Deployment mode set

2. **buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor** (1 time)
   - ⚠️ Critical registry change

3. **Test files** (minor updates)
   - Occasional test adjustments

---

## Merge Strategy for Custom Changes

### Critical Change Preservation

**The hassos-supervisor script change MUST be preserved:**

```bash
# This line is the key to your entire custom infrastructure
SUPERVISOR_IMAGE="ghcr.io/my-smart-homes/${SUPERVISOR_ARCH}-hassio-supervisor"
```

**How to Preserve During Merge:**

1. **When conflict occurs in hassos-supervisor:**
   ```bash
   # Choose your version:
   git checkout --ours buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor
   
   # Or manually edit to ensure my-smart-homes registry is used
   ```

2. **Verify after merge:**
   ```bash
   grep "my-smart-homes" buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor
   ```

---

### Version Number Strategy

**Recommended approach for buildroot-external/meta:**

```bash
# Accept upstream version numbers
VERSION_MAJOR="16"
VERSION_MINOR="3"
VERSION_SUFFIX="0"

# But keep your custom name
HASSOS_NAME="MY HOME ASSISTANT OS"
HASSOS_ID="haos"

# Decide on deployment
DEPLOYMENT="production"  # or "development"
```

**Rationale:**
- Use upstream version numbers for compatibility
- Maintain custom branding
- Clear identification as custom build

---

## Pre-Merge Checklist

### Infrastructure Verification

Before merging, ensure these exist:

- [ ] `ghcr.io/my-smart-homes/amd64-hassio-supervisor:latest`
- [ ] `ghcr.io/my-smart-homes/aarch64-hassio-supervisor:latest`
- [ ] `ghcr.io/my-smart-homes/i386-hassio-supervisor:latest`

If planning to support armv7 (upstream removed it):
- [ ] `ghcr.io/my-smart-homes/armv7-hassio-supervisor:latest`

### Build Environment

- [ ] Buildroot dependencies updated
- [ ] Cross-compilation tools ready
- [ ] Sufficient disk space for build
- [ ] Docker available for testing

---

## Conflict Resolution Priority

### 🔴 CRITICAL (Must Preserve)

1. **Supervisor image registry path**
   - File: `buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor`
   - Must point to: `ghcr.io/my-smart-homes`

2. **OS branding**
   - File: `buildroot-external/meta`
   - Must say: "MY HOME ASSISTANT OS"

### 🟡 IMPORTANT (Recommended)

3. **Version numbers**
   - File: `buildroot-external/meta`
   - Recommendation: Use upstream 16.3, add custom suffix

### 🟢 NORMAL (Accept Upstream)

4. **All other files**
   - Accept upstream changes unless specifically customized
   - Most build scripts, configs, etc.

---

## Post-Merge Verification Commands

### Verify Critical Changes Preserved

```bash
# Check supervisor registry
grep "SUPERVISOR_IMAGE" buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor
# Should output: ghcr.io/my-smart-homes/...

# Check OS branding
grep "HASSOS_NAME" buildroot-external/meta
# Should output: MY HOME ASSISTANT OS

# Check version
cat buildroot-external/meta
# Should show version 16.3 with custom name
```

---

## Risk Assessment

### Low Risk Items
- ✅ Version suffix numbers - Can be updated freely
- ✅ Test modifications - Usually minor impact
- ✅ Deployment mode - Can be changed

### High Risk Items
- ⚠️ **Supervisor registry change** - Breaking if lost
- ⚠️ **OS name** - Identity/branding issue if lost

---

## Rollback Scenarios

### If Supervisor Registry Gets Lost

**Symptom:** OS tries to pull from `ghcr.io/home-assistant` and fails

**Fix:**
```bash
# Edit the file
vi buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor

# Change line to:
SUPERVISOR_IMAGE="ghcr.io/my-smart-homes/${SUPERVISOR_ARCH}-hassio-supervisor"

# Rebuild and reflash
```

### If OS Name Gets Lost

**Symptom:** System shows "Home Assistant OS" instead of custom name

**Fix:**
```bash
# Edit the meta file
vi buildroot-external/meta

# Change line to:
HASSOS_NAME="MY HOME ASSISTANT OS"

# Rebuild
```

---

## Technical Debt

### Current Issues

1. **Version number divergence**
   - Fork at 13.7.8, upstream at 16.3
   - Large gap makes syncing harder
   - Recommendation: Sync now, then stay closer

2. **No custom channel support**
   - Using "development" deployment
   - Consider: "stable", "beta", "dev" channels

3. **Manual version bumping**
   - 37 commits just for version numbers
   - Could be automated with CI/CD

### Recommendations

1. **Automate version bumps**
   - Use CI/CD to increment version
   - Reduce manual commits

2. **Track upstream more closely**
   - Don't let version gap grow this large again
   - Consider monthly sync schedule

3. **Document custom channels**
   - If using custom update channels, document them
   - Align with supervisor version endpoint

---

## Related Files

### Key Files in Repository

1. **buildroot-external/meta** - Version and branding
2. **buildroot-external/rootfs-overlay/usr/sbin/hassos-supervisor** - Supervisor launcher
3. **buildroot-external/rootfs-overlay/usr/sbin/hassos-cli** - CLI tools
4. **buildroot-external/rootfs-overlay/usr/sbin/hassos-config** - Configuration
5. **buildroot-external/scripts/** - Build scripts

### Files to Watch During Merge

- `hassos-supervisor` - Critical
- `meta` - Important
- `hassos-config` - Check if customized
- Build scripts - Usually accept upstream

---

## Authors of Custom Commits

Custom commits made by team members:
- **nafiz-msh / fuadnafiz98** - Infrastructure changes
- **Bhesh Raj Thapa** - Version bumps
- **Naimur Hasan** - Version bumps

---

## Summary

**Simple Summary:**
- 38 custom commits total
- 37 are just version number increments
- 1 is critical: Changes Supervisor registry to custom
- All maintain custom branding "MY HOME ASSISTANT OS"

**Must Preserve:**
1. Supervisor image path → `ghcr.io/my-smart-homes`
2. OS name → "MY HOME ASSISTANT OS"

**Can Update:**
- Version numbers to 16.3
- All other upstream changes

---

**Document Version:** 1.0  
**Last Updated:** December 23, 2025 05:29 UTC  
**Status:** Pre-merge analysis complete
