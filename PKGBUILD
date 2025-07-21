# Maintainer: Jack Mahoney <jacksmahoney@gmail.com>
pkgname=openai-codex-bin
pkgver=0.8.0
pkgrel=2
pkgdesc="Lightweight coding agent that runs in your terminal"
arch=('x86_64' 'aarch64')
url="https://github.com/openai/codex"
license=('Apache-2.0')
optdepends=(
   'git: for working with git repositories'
   'ripgrep: accelerated large-repo search'
)

source_x86_64=(
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-x86_64-unknown-linux-gnu.tar.gz"
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-exec-x86_64-unknown-linux-gnu.tar.gz"
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-linux-sandbox-x86_64-unknown-linux-gnu.tar.gz"
)
sha256sums_x86_64=(
    '23c207fdd08e88f2e1e4d5bc8aaded5bf2bb301d7606acdf6ad6ee65d6470651'
    '43bc186043ef60262e356fc8d18f8439fc47341f0b1b53dd5e22c6158b523c4f'
    '2d9f3b6c776a70d341ec7ac4535f638f48f7bc8fca3d4256e80c55e01c65b566'
)

source_aarch64=(
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-aarch64-unknown-linux-gnu.tar.gz"
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-exec-aarch64-unknown-linux-gnu.tar.gz"
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-linux-sandbox-aarch64-unknown-linux-gnu.tar.gz"
)
sha256sums_aarch64=(
    'cc112e0cb8c3bd746e07ea7bd91773abc0fba6fe77ce364ef531dabd2e00d8a8'
    '82c8bab4af07eb06e2c13ae4e936642d2c9a99a4b5f92367d466e2f430797890'
    '1fb5d9cbb2296201e1cc079807c7e2491dc01e692379a8bc9244d48dc424ca38'
)

package() {
    install -Dm755 "${srcdir}/codex-${CARCH}-unknown-linux-gnu" "${pkgdir}/usr/bin/codex"
    install -Dm755 "${srcdir}/codex-exec-${CARCH}-unknown-linux-gnu" "${pkgdir}/usr/bin/codex-exec"
    install -Dm755 "${srcdir}/codex-linux-sandbox-${CARCH}-unknown-linux-gnu" "${pkgdir}/usr/bin/codex-linux-sandbox"
}
