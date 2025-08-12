# Maintainer: Jack Mahoney <jacksmahoney@gmail.com>
pkgname=openai-codex-bin
pkgver=0.21.0
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
    "codex-${pkgver}.tar.gz::https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-x86_64-unknown-linux-gnu.tar.gz"
)
sha256sums_x86_64=('0100efc40a34e2bd42d49de43353a45b510772ea92aca52589ce637e6c432c5d')

source_aarch64=(
    "codex-${pkgver}.tar.gz::https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-aarch64-unknown-linux-gnu.tar.gz"
)
sha256sums_aarch64=('7e63259f371112e8064ece02851323a0a325defd018f5770514dce9fa4fe7c94')

package() {
    cd "$srcdir"

    if [[ "$CARCH" == "x86_64" ]]; then
        install -Dm755 "codex-x86_64-unknown-linux-gnu" "$pkgdir/usr/bin/codex"
    fi

    if [[ "$CARCH" == "aarch64" ]]; then
        install -Dm755 "codex-aarch64-unknown-linux-gnu" "$pkgdir/usr/bin/codex"
    fi
}
