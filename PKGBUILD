# Maintainer: Jack Mahoney <jacksmahoney@gmail.com>
pkgname=openai-codex-bin
pkgver=0.8.0
pkgrel=1
pkgdesc="Lightweight coding agent that runs in your terminal"
arch=('x86_64' 'aarch64')
url="https://github.com/openai/codex"
license=('Apache-2.0')
depends=()
makedepends=()
optdepends=(
   'git'
   'ripgrep: accelerated large-repo search'
)

source_x86_64=(
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-x86_64-unknown-linux-musl.tar.gz"
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-exec-x86_64-unknown-linux-musl.tar.gz"
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-linux-sandbox-x86_64-unknown-linux-musl.tar.gz"
)
sha256sums_x86_64=(
    'db86033cf86489bf47e6a5309ae5276497709b60ecb51596a475ac070c9c17f0'
    '3e02ef37e6a352286a7ab2ed27a6f8c781f552ea9e4ca8a35238066c4d56db48'
    '691095a4e1db54ef7030ef89ca787bf1d37a22d8308c51a2b4984b220c001b01'
)

source_aarch64=(
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-aarch64-unknown-linux-musl.tar.gz"
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-exec-aarch64-unknown-linux-musl.tar.gz"
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-linux-sandbox-aarch64-unknown-linux-musl.tar.gz"
)
sha256sums_aarch64=(
    'b42788e4da013d3c94c87210c367f49241455b5638f0a28850ce050403d1e34f'
    'd9daea8e7e660dd4ff15e5202768b0d13808c44269b8e029436fddf95a136f49'
    'c58ccb799b09f23481ea3df5c5bdc14db090eb32b11870432ab8388ef2baccec'
)

package() {
    install -Dm755 "${srcdir}/codex-${CARCH}-unknown-linux-musl" "${pkgdir}/usr/bin/codex"
    install -Dm755 "${srcdir}/codex-exec-${CARCH}-unknown-linux-musl" "${pkgdir}/usr/bin/codex-exec"
    install -Dm755 "${srcdir}/codex-linux-sandbox-${CARCH}-unknown-linux-musl" "${pkgdir}/usr/bin/codex-linux-sandbox"
}
