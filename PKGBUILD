# Maintainer: Jack Mahoney <jacksmahoney@gmail.com>
pkgname=openai-codex-bin
pkgver=0.19.0
pkgrel=1
pkgdesc="Lightweight coding agent that runs in your terminal"
arch=('x86_64' 'aarch64')
url="https://github.com/openai/codex"
license=('Apache-2.0')
provides=('openai-codex')
conflicts=('openai-codex')
optdepends=(
   'git: for working with git repositories'
   'ripgrep: accelerated large-repo search'
)

source_x86_64=(
    "codex-${pkgver}.tar.gz::https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-x86_64-unknown-linux-gnu.tar.gz"
    "codex-exec-${pkgver}.tar.gz::https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-exec-x86_64-unknown-linux-gnu.tar.gz"
    "codex-linux-sandbox-${pkgver}.tar.gz::https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-linux-sandbox-x86_64-unknown-linux-gnu.tar.gz"
)
sha256sums_x86_64=('a8202a1846fc63053bd3118c4c6a306eb1534536b2a5038bff3394a70ac207c1'
                   'f387427dcf4bd9af511a8ae72e8a2fa4098604c5a9233ec903d411bb86edd4a4'
                   '2e1fe99b1c7917ae2e1f000ce425c46438ab5ebadb6e545e400237238e324b23')

source_aarch64=(
    "codex-${pkgver}.tar.gz::https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-aarch64-unknown-linux-gnu.tar.gz"
    "codex-exec-${pkgver}.tar.gz::https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-exec-aarch64-unknown-linux-gnu.tar.gz"
    "codex-linux-sandbox-${pkgver}.tar.gz::https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-linux-sandbox-aarch64-unknown-linux-gnu.tar.gz"
)
sha256sums_aarch64=('a8202a1846fc63053bd3118c4c6a306eb1534536b2a5038bff3394a70ac207c1'
                    'f387427dcf4bd9af511a8ae72e8a2fa4098604c5a9233ec903d411bb86edd4a4'
                    '2e1fe99b1c7917ae2e1f000ce425c46438ab5ebadb6e545e400237238e324b23')

package() {
    install -Dm755 "${srcdir}/codex-${CARCH}-unknown-linux-gnu" "${pkgdir}/usr/bin/codex"
    install -Dm755 "${srcdir}/codex-exec-${CARCH}-unknown-linux-gnu" "${pkgdir}/usr/bin/codex-exec"
    install -Dm755 "${srcdir}/codex-linux-sandbox-${CARCH}-unknown-linux-gnu" "${pkgdir}/usr/bin/codex-linux-sandbox"
}