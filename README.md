# openai-codex-autoup-bin AUR Package

This repository contains the packaging files (`PKGBUILD`) for the `openai-codex-autoup-bin` package on the Arch User Repository (AUR).

## Automation

This repository is equipped with a GitHub Actions workflow that automatically checks for new releases of `openai-codex` every night.

If a new version is found, the workflow will:
1.  Update the `PKGBUILD` and `.SRCINFO` files with the new version and checksums.
2.  Automatically commit and push the changes to the AUR, making the new version available to users.
