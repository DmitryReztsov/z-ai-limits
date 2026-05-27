# Semver Branch-Based Versioning via CI

## Summary

Update the GitHub Actions CI workflow to bump versions based on merged branch name patterns. Branches prefixed with `feat/` trigger a minor version bump; `fix/` triggers a patch bump. Direct pushes to main are not versioned.

## Branch Naming Convention

- Format: `(type)/branch-name`
- Valid types: `feat`, `fix`
- Examples: `feat/dark-mode`, `fix/color-palette`
- Branch names not matching this pattern cause the CI to fail

## Version Bump Rules

| Branch prefix | Bump type | Example           |
|---------------|-----------|-------------------|
| `feat/`       | Minor     | `1.1.19` → `1.2.0` |
| `fix/`        | Patch     | `1.1.19` → `1.1.20` |

## Workflow Changes

### Trigger
- Current: `on: push: branches: [main]`
- New: `on: pull_request: types: [closed]` with `if: github.event.pull_request.merged == true`

### Branch detection
- Use `${{ github.head_ref }}` to get the source branch name on PR merge
- Validate against regex `^(feat|fix)/.+`
- Fail the workflow with a descriptive error if the branch name doesn't match

### Version bump logic
Replace the current always-patch-bump with:
1. Parse latest tag to extract MAJOR.MINOR.PATCH
2. Check branch prefix from `github.head_ref`
3. If `feat/`: bump MINOR, reset PATCH to 0
4. If `fix/`: bump PATCH

### Protected branch (manual GitHub settings step)
Enable on the GitHub repository Settings → Branches → `main`:
- "Require a pull request before merging"
- "Require status checks to pass before merging" (optional, for future CI checks)

## Files Changed

- `.github/workflows/ci.yml` — single workflow file with all changes

## Jobs

1. **version** — validates branch name, computes new version, updates Info.plist, commits, tags, pushes
2. **build** — builds the app (unchanged logic, different trigger)
3. **release** — creates GitHub release, updates homebrew tap (unchanged logic)
