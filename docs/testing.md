# Testing the Multi-Package Updater

This guide shows how to exercise the automation for both GitHub-based and npm-based packages managed by this repository.

## 1. Prerequisites

- An Arch Linux environment (local, VM, or container). The GitHub workflow uses `archlinux:latest`.
- Tools installed: `base-devel`, `git`, `jq`, `curl`, `npm`, `updpkgsums`, `makepkg`.
- Optional: `GITHUB_TOKEN` with `repo` scope to avoid GitHub API rate limits when testing GitHub releases.

## 2. Prepare a Clean Workspace

```bash
# Ensure dependencies are present
sudo pacman -Syu --noconfirm --needed base-devel git jq curl npm

# Clone a fresh copy if you want to avoid polluting your main repo
git clone <this-repo-url> aur-update-test
cd aur-update-test
```

## 3. Test a GitHub-Based Package (`openai-codex-autoup-bin`)

1. Confirm the current upstream version:

   ```bash
   GH_TOKEN=<token> curl -fsSL https://api.github.com/repos/openai/codex/releases | jq '.[0].tag_name'
   ```

2. Run the updater for the package:

   ```bash
   GITHUB_TOKEN=<token> ./updpkg.sh --package openai-codex-autoup-bin
   ```

3. Inspect results:
   - Verify `aur/openai-codex-autoup-bin/PKGBUILD` has the new `pkgver`.
   - Check `.SRCINFO` was regenerated (`git diff` should show updated checksum/version).
   - If no update was needed, the script will print `[openai-codex-autoup-bin] PKGBUILD already up to date`.

## 4. Test an npm-Based Package (`claude-code-acp`)

1. Ensure network access to npm registry (or set up an offline tarball, see below).
2. Run the updater:

   ```bash
   ./updpkg.sh --package claude-code-acp
   ```

3. Inspect results:
   - Confirm `pkgver` was changed to the latest npm version.
   - `aur/claude-code-acp/.SRCINFO` should reflect the new tarball URL and checksum.

### Offline / Air-Gapped Testing

If outbound network calls are blocked, simulate an npm update:

```bash
cd aur/claude-code-acp
npm pack @zed-industries/claude-code-acp --pack-destination tmp
latest_tar=$(ls tmp/claude-code-acp-*.tgz | sort | tail -n1)
sha256sum "$latest_tar"
```

Use the tarball name to edit `PKGBUILD` manually, set `pkgver` to match the tarball, update the checksum with the value from `sha256sum`, and run `makepkg --printsrcinfo > .SRCINFO`. Afterwards, run `./updpkg.sh --package claude-code-acp` to ensure it exits without changing anything.

## 5. Run the Full Matrix Locally

Execute all enabled packages in one go:

```bash
GITHUB_TOKEN=<token> ./updpkg.sh --all
```

The script prints a summary of which packages were updated. Check `git status` and `git diff` for changes.

## 6. Dry-Run the GitHub Workflow

Use the helper script to trigger and watch the workflow (requires the GitHub CLI authenticated for the repo):

```bash
./run-and-tail-workflow.sh
```

This mirrors what happens nightly: the workflow reads `packages.json`, runs the updater per package inside an Arch container, commits, and pushes.

## 7. Cleanup

If you ran tests in a throwaway clone, simply delete the directory. Otherwise, discard local changes with `git reset --hard` and `git clean -fd` once you have recorded your observations.
