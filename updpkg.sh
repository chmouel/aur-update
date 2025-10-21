#!/usr/bin/env bash
# Author: Chmouel Boudjnah <chmouel@chmouel.com>
# Multi-package updater for AUR repositories.
set -euo pipefail

CONFIG_FILE=${CONFIG_FILE:-packages.json}
PACKAGE_FILTER=""

usage() {
  cat <<'USAGE'
Usage: updpkg.sh [--package NAME] [--all]

  --package NAME   Update only the package identified by NAME
  --all            Update all enabled packages (default)
  -h, --help       Show this help message

Environment variables:
  CONFIG_FILE  Path to the packages.json configuration (default: packages.json)
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      [[ $# -lt 2 ]] && { usage >&2; exit 1; }
      PACKAGE_FILTER=$2
      shift 2
      ;;
    --all)
      PACKAGE_FILTER=""
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
done

err() {
  printf 'Error: %s\n' "$*" >&2
}

require_file() {
  local path=$1
  [[ -f $path ]] || { err "File not found: $path"; exit 1; }
}

require_dir() {
  local path=$1
  [[ -d $path ]] || { err "Directory not found: $path"; exit 1; }
}

if [[ ! -f "$CONFIG_FILE" ]]; then
  err "Configuration file not found: $CONFIG_FILE"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  err "jq is required but was not found in PATH"
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  err "curl is required but was not found in PATH"
  exit 1
fi

mapfile -t PACKAGE_ENTRIES < <(
  if [[ -n "$PACKAGE_FILTER" ]]; then
    jq -c --arg name "$PACKAGE_FILTER" '.[] | select((.enabled // true) and .name == $name)' "$CONFIG_FILE"
  else
    jq -c '.[] | select(.enabled // true)' "$CONFIG_FILE"
  fi
)

if [[ ${#PACKAGE_ENTRIES[@]} -eq 0 ]]; then
  if [[ -n "$PACKAGE_FILTER" ]]; then
    err "No enabled package named '$PACKAGE_FILTER' found in $CONFIG_FILE"
  else
    err "No enabled packages found in $CONFIG_FILE"
  fi
  exit 1
fi

strip_prefixes() {
  local version=$1
  shift || true
  for prefix in "$@"; do
    if [[ -n $prefix && $version == "$prefix"* ]]; then
      version=${version#"$prefix"}
    fi
  done
  printf '%s\n' "$version"
}

fetch_github_version() {
  local pkg_json=$1
  local name=$2
  local project
  project=$(jq -r '.github_project // empty' <<< "$pkg_json")
  if [[ -z $project ]]; then
    err "[$name] Missing required field: github_project"
    exit 1
  fi

  local curl_args=(-fsSL)
  if [[ -n ${GITHUB_TOKEN:-} ]]; then
    curl_args+=(-H "Authorization: token ${GITHUB_TOKEN}")
  fi

  local releases
  releases=$(curl "${curl_args[@]}" "https://api.github.com/repos/${project}/releases")

  local excludes_json
  excludes_json=$(jq -c '.github_tag_excludes // []' <<< "$pkg_json")

  local tag
  tag=$(jq -r --argjson excludes "$excludes_json" '
    def excluded($excludes):
      if ($excludes | length) == 0 then false
      else any($excludes[]; (.tag_name | contains(.)))
      end;
    [ .[]
      | select((.prerelease // false) | not)
      | select((.draft // false) | not)
      | select(excluded($excludes) | not)
    ][0].tag_name
  ' <<< "$releases")

  if [[ -z $tag || $tag == "null" ]]; then
    err "[$name] Could not find a suitable GitHub release tag"
    exit 1
  fi

  mapfile -t prefixes < <(jq -r '.version_strip_prefixes[]?' <<< "$pkg_json")
  strip_prefixes "$tag" "${prefixes[@]}"
}

fetch_npm_version() {
  local pkg_json=$1
  local name=$2
  local npm_package
  npm_package=$(jq -r '.npm_package // empty' <<< "$pkg_json")
  if [[ -z $npm_package ]]; then
    err "[$name] Missing required field: npm_package"
    exit 1
  fi

  local version
  version=$(curl -fsSL "https://registry.npmjs.org/${npm_package}/latest" | jq -r '.version')
  if [[ -z $version || $version == "null" ]]; then
    err "[$name] Unable to fetch npm version for ${npm_package}"
    exit 1
  fi
  printf '%s\n' "$version"
}

LATEST_VERSION=""
update_package() {
  local pkg_json=$1
  local name path method pkgbuild_path current_version latest_version

  name=$(jq -r '.name' <<< "$pkg_json")
  path=$(jq -r '.path' <<< "$pkg_json")
  method=$(jq -r '.method' <<< "$pkg_json")

  if [[ -z $name || $name == "null" ]]; then
    err "Encountered package without a name"
    exit 1
  fi

  if [[ -z $path || $path == "null" ]]; then
    err "[$name] Missing required field: path"
    exit 1
  fi

  if [[ ${path} != /* ]]; then
    path="./${path}"
  fi

  if command -v realpath >/dev/null 2>&1; then
    path=$(realpath -m "$path")
  fi

  require_dir "$path"

  pkgbuild_path="$path/PKGBUILD"
  require_file "$pkgbuild_path"

  current_version=$(grep '^pkgver=' "$pkgbuild_path" | head -n 1 | cut -d'=' -f2-)
  if [[ -z $current_version ]]; then
    err "[$name] Unable to read current pkgver from $pkgbuild_path"
    exit 1
  fi

  case $method in
    github_release)
      latest_version=$(fetch_github_version "$pkg_json" "$name")
      ;;
    npm_latest)
      latest_version=$(fetch_npm_version "$pkg_json" "$name")
      ;;
    *)
      err "[$name] Unknown update method: $method"
      exit 1
      ;;
  esac

  if [[ $current_version == "$latest_version" ]]; then
    printf '[%s] PKGBUILD already up to date (%s)\n' "$name" "$current_version"
    LATEST_VERSION=""
    return 0
  fi

  printf '[%s] Updating PKGBUILD from %s to %s\n' "$name" "$current_version" "$latest_version"
  sed -i -E "s/^pkgver=.*/pkgver=${latest_version}/" "$pkgbuild_path"

  (cd "$path" && updpkgsums && makepkg --printsrcinfo > .SRCINFO)

  if [[ -n ${GITHUB_OUTPUT:-} ]]; then
    {
      echo "package=${name}"
      echo "latest_version=${latest_version}"
    } >> "$GITHUB_OUTPUT"
  fi

  LATEST_VERSION="$latest_version"
}

updated_packages=()
for pkg_json in "${PACKAGE_ENTRIES[@]}"; do
  LATEST_VERSION=""
  update_package "$pkg_json"
  if [[ -n $LATEST_VERSION ]]; then
    updated_packages+=("$(jq -r '.name' <<< "$pkg_json"):$LATEST_VERSION")
  fi
done

if [[ ${#updated_packages[@]} -eq 0 ]]; then
  echo "No updates were necessary."
else
  printf 'Updated packages:\n'
  for item in "${updated_packages[@]}"; do
    printf '  - %s\n' "$item"
  done
fi
