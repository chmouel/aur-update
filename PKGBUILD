# Maintainer: Jack Mahoney <jacksmahoney@gmail.com>
pkgname=openai-codex-bin
pkgver=0.10.0
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
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-x86_64-unknown-linux-gnu.tar.gz"
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-exec-x86_64-unknown-linux-gnu.tar.gz"
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-linux-sandbox-x86_64-unknown-linux-gnu.tar.gz"
)
source_aarch64=(
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-aarch64-unknown-linux-gnu.tar.gz"
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-exec-aarch64-unknown-linux-gnu.tar.gz"
    "https://github.com/openai/codex/releases/download/rust-v${pkgver}/codex-linux-sandbox-aarch64-unknown-linux-gnu.tar.gz"
)

sha256sums_x86_64=('fea15eed6942b94a5ed5c0a5592df798039b897861ea71baa8a8ae3763a3d62d'
                   '8a70889cb1917ccc8bff6cf45fa422ce1b0b5898044315c8f8256e3df5507cb6'
                   '9f46319b5354fc73606ce68a61dc030c19c7d517c50a78a9e417a327ef9887cc')
sha256sums_aarch64=('dee36218c7dd6ecbc99a54aabe9114ab130c03801bc8d277d74cc4540e8dfbd9'
                    '5f1d15dba0e47546189356acffe34f2ed1a2596f89d749b22d71a3c1b402be61'
                    '7ab04244547a98d66a2c4e7e29b79a3c9ea947504cf0cf7e14c3384ebf69b06d')

package() {
    install -Dm755 "${srcdir}/codex-${CARCH}-unknown-linux-gnu" "${pkgdir}/usr/bin/codex"
    install -Dm755 "${srcdir}/codex-exec-${CARCH}-unknown-linux-gnu" "${pkgdir}/usr/bin/codex-exec"
    install -Dm755 "${srcdir}/codex-linux-sandbox-${CARCH}-unknown-linux-gnu" "${pkgdir}/usr/bin/codex-linux-sandbox"
}
