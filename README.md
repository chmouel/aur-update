# AUR Package Automation

This repository hosts multiple Arch User Repository (AUR) packages and keeps them up to date automatically.

- Packaging files live under `aur/<package-name>/` (for example `aur/openai-codex-autoup-bin/PKGBUILD`).
- Update rules are declared in `packages.json` so that each package can opt into the correct update method (GitHub release or npm registry).
- `updpkg.sh` reads that configuration, bumps `pkgver`, regenerates `.SRCINFO`, and prints a short summary.

## Configuration (`packages.json`)

Each object in `packages.json` represents one package:

- `name` – identifier used in logs and in the GitHub Actions matrix.
- `path` – directory that contains the package’s `PKGBUILD` (relative paths are allowed).
- `method` – how to determine the latest version. Supported values:
  - `github_release`: track the latest non-prerelease GitHub release.
  - `npm_latest`: track the latest version on the npm registry (this folds in the bash snippet from the question above).
- `github_project`, `github_tag_excludes`, `version_strip_prefixes` – optional fields used only by the GitHub release method.
- `npm_package` – required when `method` is `npm_latest`.
- `enabled` – set to `false` to keep a package in the file but skip it during automation.

Add new packages by creating `aur/<new-package>/PKGBUILD`, adding an entry to `packages.json`, and enabling it when you are ready.

## Local usage

```bash
# Update the GitHub-based package locally (requires `jq`, `curl`, `updpkgsums`, `makepkg`).
./updpkg.sh --package openai-codex-autoup-bin

# Update every enabled package defined in packages.json.
./updpkg.sh --all
```

Passing `GITHUB_TOKEN=<token>` improves GitHub API rate limits for packages that use `github_release`.

## GitHub Actions & Testing

The workflow at `.github/workflows/aur-update.yml`:

1. Reads `packages.json` and builds a job matrix for every enabled package.
2. Runs `updpkg.sh --package <name>` inside an Arch Linux container so that `makepkg` and `updpkgsums` are available.
3. Commits and pushes any changes back to this repository. (You can extend the final step to push to your AUR remote if desired.)

The workflow is triggered on a nightly schedule, manual `workflow_dispatch`, or when configuration files change. Use `run-and-tail-workflow.sh` locally to trigger and follow a run.

For step-by-step validation instructions (both GitHub-release and npm-based packages), see `docs/testing.md`.
