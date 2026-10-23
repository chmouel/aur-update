#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/package"

cat >"$tmp_dir/bin/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

url=""
for arg in "$@"; do
  url=$arg
done

case "$url" in
  *page=1)
    jq -n '
      ([range(0; 25000) | "x"] | join("")) as $body
      |
      [
        {tag_name: "v0.50.2", prerelease: false, draft: false, body: $body},
        {tag_name: "v0.52.0", prerelease: false, draft: false, body: $body},
        {tag_name: "v0.9.0", prerelease: false, draft: false, body: $body},
        {tag_name: "v9.0.0", prerelease: true, draft: false, body: $body},
        {tag_name: "v8.0.0", prerelease: false, draft: true, body: $body},
        {tag_name: "v99.0.0-nightly", prerelease: false, draft: false, body: $body}
      ] + [
        range(0; 94) as $i
        | {tag_name: ("v0.1." + ($i | tostring)), prerelease: false, draft: false, body: $body}
      ]
    '
    ;;
  *page=2)
    jq -n '[
      {tag_name: "v0.53.0", prerelease: false, draft: false},
      {tag_name: "v0.51.0", prerelease: false, draft: false}
    ]'
    ;;
  *)
    printf 'Unexpected GitHub API URL: %s\n' "$url" >&2
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
  }
]' >"$tmp_dir/packages.json"

PATH="$tmp_dir/bin:$PATH" CONFIG_FILE="$tmp_dir/packages.json" \
  "$repo_root/updpkg.sh" --package test-package

grep -qx 'pkgver=0.53.0' "$tmp_dir/package/PKGBUILD"
grep -qx 'pkgrel=1' "$tmp_dir/package/PKGBUILD"
printf 'GitHub release selection regression passed\n'
