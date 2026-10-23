#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/package"

cat >"$tmp_dir/bin/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

request=$(cat)
owner=$(jq -r '.variables.owner' <<< "$request")
cursor=$(jq -r '.variables.cursor // "start"' <<< "$request")

if [[ $owner == broken ]]; then
  jq -n '{data: {repository: null}, errors: [{message: "Could not resolve to a Repository"}]}'
  exit 0
fi

case "$cursor" in
  start)
    jq -n '{data: {repository: {releases: {
      pageInfo: {hasNextPage: true, endCursor: "page2"},
      nodes: ([
        {tagName: "v0.50.2", isPrerelease: false, isDraft: false},
        {tagName: "v0.52.0", isPrerelease: false, isDraft: false},
        {tagName: "v0.9.0", isPrerelease: false, isDraft: false},
        {tagName: "v9.0.0", isPrerelease: true, isDraft: false},
        {tagName: "v8.0.0", isPrerelease: false, isDraft: true},
        {tagName: "v99.0.0-nightly", isPrerelease: false, isDraft: false},
        {tagName: "python-v99.0.0", isPrerelease: false, isDraft: false}
      ] + [
        range(0; 93) as $i
        | {tagName: ("v0.1." + ($i | tostring)), isPrerelease: false, isDraft: false}
      ])
    }}}}'
    ;;
  page2)
    jq -n '{data: {repository: {releases: {
      pageInfo: {hasNextPage: false, endCursor: "end"},
      nodes: [
        {tagName: "v0.53.0", isPrerelease: false, isDraft: false},
        {tagName: "v0.51.0", isPrerelease: false, isDraft: false}
      ]
    }}}}'
    ;;
  *)
    printf 'Unexpected cursor: %s\n' "$cursor" >&2
    exit 1
    ;;
esac
EOF

for command in updpkgsums makepkg; do
  cat >"$tmp_dir/bin/$command" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
EOF
  chmod +x "$tmp_dir/bin/$command"
done
chmod +x "$tmp_dir/bin/curl"

cat >"$tmp_dir/package/PKGBUILD" <<'EOF'
pkgname=test-package
pkgver=0.50.2
pkgrel=2
EOF

jq -n --arg path "$tmp_dir/package" '[
  {
    name: "test-package",
    path: $path,
    method: "github_release",
    github_project: "example/test-package",
    github_tag_excludes: ["nightly"],
    version_strip_prefixes: ["v"],
    enabled: true
  },
  {
    name: "broken-package",
    path: $path,
    method: "github_release",
    github_project: "broken/missing",
    enabled: true
  }
]' >"$tmp_dir/packages.json"

run_updpkg() {
  PATH="$tmp_dir/bin:$PATH" GITHUB_TOKEN=fake-token CONFIG_FILE="$tmp_dir/packages.json" \
    "$repo_root/updpkg.sh" "$@"
}

run_updpkg --package test-package

grep -qx 'pkgver=0.53.0' "$tmp_dir/package/PKGBUILD"
grep -qx 'pkgrel=1' "$tmp_dir/package/PKGBUILD"
printf 'GitHub release selection regression passed\n'

if output=$(run_updpkg --package broken-package 2>&1); then
  printf 'Expected GraphQL error to fail the update\n' >&2
  exit 1
fi
grep -q 'GitHub API error for broken/missing: Could not resolve to a Repository' <<< "$output"
printf 'GitHub API error handling passed\n'
