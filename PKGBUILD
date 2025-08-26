# Maintainer: Jack Mahoney <jacksmahoney@gmail.com>
pkgname=openai-codex-bin
pkgver=0.24.0
pkgrel=1
pkgdesc="Lightweight coding agent that runs in your terminal"
arch=('x86_64' 'aarch64')
url="https://github.com/openai/codex"
license=('Apache')
provides=('openai-codex')
conflicts=('openai-codex')
optdepends=(
   'git: for working with git repositories'
   'ripgrep: accelerated large-repo search'
)

source_x86_64=(
    "codex-${pkgver}-x86_64.tar.gz::https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-x86_64-unknown-linux-gnu.tar.gz"
)
sha256sums_x86_64=('62dbff47b50c2397a3ff06d7a5fa5dd85b5898237703737a0563e18b8f317e6b')
sha256sums_aarch64=('2890f8ae32e4e81bc5dce9ddb2ec0e5b2b13d4331d272d41ecbc9aa651e54bb9')

source_aarch64=(
    "codex-${pkgver}-aarch64.tar.gz::https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-aarch64-unknown-linux-gnu.tar.gz"
)

package() {
    cd "$srcdir"

    if [[ "$CARCH" == "x86_64" ]]; then
        install -Dm755 "codex-x86_64-unknown-linux-gnu" "$pkgdir/usr/bin/codex"
    fi

    if [[ "$CARCH" == "aarch64" ]]; then
        install -Dm755 "codex-aarch64-unknown-linux-gnu" "$pkgdir/usr/bin/codex"
    fi
}
