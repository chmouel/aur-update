#!/usr/bin/env bash
# Author: Chmouel Boudjnah <chmouel@chmouel.com>
set -eufo pipefail
PROJECT="${PROJECT:-openai/codex}"

latest=$(curl -H "Authorization: token ${GITHUB_TOKEN}" -s https://api.github.com/repos/${PROJECT}/releases | jq -r '[.[] | select(.prerelease == false and (.tag_name | contains("nightly") | not) and (.tag_name | contains("preview") | not))][0].tag_name')
latest=${latest#rust-}
latest=${latest#v}
pkgversion=$(grep '^pkgver=' PKGBUILD)
pkgversion=${pkgversion#pkgver=}

if [[ ${pkgversion} != "${latest}" ]]; then
  echo "Updating PKGBUILD from ${pkgversion} to ${latest}"
  sed -i "s/pkgver=${pkgversion}/pkgver=${latest}/" PKGBUILD
  echo "latest_version=${latest}" >> $GITHUB_OUTPUT
else
  echo
  printf "\033[3;31mPKGBU-ILD is already up to date with version %s\033[0m\n" "${pkgversion}"
  exit 0
fi

updpkgsums && makepkg --printsrcinfo >.SRCINFO
