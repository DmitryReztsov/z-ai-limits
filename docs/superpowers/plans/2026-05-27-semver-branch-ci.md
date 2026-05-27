# Semver Branch-Based Versioning — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update CI workflow to bump version based on merged PR branch name (`feat/` → minor, `fix/` → patch) and reject non-conforming branch names.

**Architecture:** Single GitHub Actions workflow triggered on PR close (merge only). The `version` job validates the branch name, computes the correct semver bump, updates Info.plist, commits, and tags. Build and release jobs remain unchanged.

**Tech Stack:** GitHub Actions, bash scripting, git

---

### Task 1: Update workflow trigger and add merged-PR condition

**Files:**
- Modify: `.github/workflows/ci.yml:1-11`

- [ ] **Step 1: Replace the trigger and add a top-level condition**

Replace lines 1-11 with:

```yaml
name: Build, Version & Release

on:
  pull_request:
    types:
      - closed

permissions:
  contents: write
  actions: write
```

- [ ] **Step 2: Add `if` condition to each job**

Add `if: github.event.pull_request.merged == true` to all three jobs:

```yaml
jobs:
  version:
    if: github.event.pull_request.merged == true
    runs-on: macos-26
```

```yaml
  build:
    if: github.event.pull_request.merged == true
    needs: version
    runs-on: macos-26
```

```yaml
  release:
    if: github.event.pull_request.merged == true
    needs: [version, build]
    runs-on: macos-26
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "feat: change CI trigger to PR merge only"
```

### Task 2: Add branch name validation step

**Files:**
- Modify: `.github/workflows/ci.yml` (version job, after checkout)

- [ ] **Step 1: Add branch validation step**

Insert after the `actions/checkout@v4` step in the `version` job:

```yaml
      - name: Validate branch name
        run: |
          BRANCH="${{ github.head_ref }}"
          if ! echo "$BRANCH" | grep -qE '^(feat|fix)/.+'; then
            echo "::error::Branch name '$BRANCH' does not match (feat|fix)/pattern. Aborting."
            exit 1
          fi
          echo "branch_type=$(echo "$BRANCH" | cut -d'/' -f1)" >> "$GITHUB_OUTPUT"
        id: branch
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "feat: add branch name validation for semver"
```

### Task 3: Update version bump logic for semver

**Files:**
- Modify: `.github/workflows/ci.yml:20-32` (Bump version step)

- [ ] **Step 1: Replace the Bump version step**

Replace the entire "Bump version" step with:

```yaml
      - name: Bump version
        id: version
        run: |
          LATEST=$(git tag --sort=-version:refname | head -1)
          if [ -z "$LATEST" ]; then
            VERSION="1.0.0"
          else
            MAJOR=$(echo "$LATEST" | sed 's/v//' | cut -d. -f1)
            MINOR=$(echo "$LATEST" | sed 's/v//' | cut -d. -f2)
            PATCH=$(echo "$LATEST" | sed 's/v//' | cut -d. -f3)
            BRANCH_TYPE="${{ steps.branch.outputs.branch_type }}"
            if [ "$BRANCH_TYPE" = "feat" ]; then
              VERSION="$MAJOR.$((MINOR + 1)).0"
            else
              VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
            fi
          fi
          echo "version=$VERSION" >> "$GITHUB_OUTPUT"
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "feat: implement semver bump based on branch type"
```

### Task 4: Manual — enable branch protection on GitHub

**Files:** None (manual GitHub settings)

- [ ] **Step 1: Enable branch protection for `main`**

Go to: **Settings → Branches → Add rule → Branch name pattern: `main`**

Enable:
- "Require a pull request before merging" → at least 1 approval (optional)
- "Do not allow force pushes"

This prevents direct pushes to main and enforces the PR-based workflow.
