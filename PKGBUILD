# Maintainer: Jack Mahoney <jacksmahoney@gmail.com>
pkgname=openai-codex-bin
pkgver=0.9.0
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

sha256sums_x86_64=('440b786574f55d09bacb2058647638f8cefc4cb881f6f94ff147a2075852b4ed'
                   'dc1ad949e704ed6dabd780e4e0632fea1b4342d7e110c5c50176e311b3ad5a89'
                   '6a35efd686f6c0b1133950aa4a077992ffb69a4014eaf6c7a545f497cee185b9')
sha256sums_aarch64=('e9428a167f475b76dcaf5d6d314ce393db1de4294fef412f4bb8ea42bf10cf91'
                    '2f444120b3438d45a546415c02083a1174dca471985395aa96fc77eaae96630a'
                    'ffdc41953ef1dbcbac9cbe4a92f574b4c88a70443744e1ef0c8a14c55c68f007')

package() {
    install -Dm755 "${srcdir}/codex-${CARCH}-unknown-linux-gnu" "${pkgdir}/usr/bin/codex"
    install -Dm755 "${srcdir}/codex-exec-${CARCH}-unknown-linux-gnu" "${pkgdir}/usr/bin/codex-exec"
    install -Dm755 "${srcdir}/codex-linux-sandbox-${CARCH}-unknown-linux-gnu" "${pkgdir}/usr/bin/codex-linux-sandbox"
}
