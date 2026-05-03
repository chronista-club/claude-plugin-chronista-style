#!/usr/bin/env bash
# Generic Rust binary → ghcr.io image build script (Mac M-series cross-compile path).
#
# Skill: cross-build-image (chronista-style)
# Origin: fleetstage Phase B-3 Step 6 (2026-05-03)
#
# === 使い方 ===
#   PACKAGE=<cargo-package> BIN=<bin-name> IMAGE=<ghcr-image> ./build-and-push.sh
#
#   例:
#     PACKAGE=fleetstage-hq BIN=fleetstage-hq-api \
#     IMAGE=ghcr.io/chronista-club/fleetstage-hq-api \
#     ./build-and-push.sh
#
# === Prereq ===
#   brew install cargo-zigbuild zig sccache
#   rustup target add x86_64-unknown-linux-gnu
#   gh auth token | docker login ghcr.io -u <user> --password-stdin
#
# === Cache 階層 (高速化) ===
#   1. sccache (~/.cache/sccache, 10 GB) — rustc invocation 単位
#   2. zig cache (~/.cache/zig) — zig-cc の C/C++ obj cache
#   3. cargo target/ (./target) — incremental build artifact
#   4. cargo registry (~/.cargo/registry) — git/crates.io source
#   5. buildx registry cache (<image>:cache tag on ghcr) — image layer cache

set -euo pipefail

# mise の shim を PATH に通す。 #!/usr/bin/env bash で起動した script は zsh-rc の
# mise activate hook を読まないため、 shim 経由で .mise.toml の rust toolchain を解決。
if [ -d "$HOME/.local/share/mise/shims" ]; then
    export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

# === 必須 env ===
: "${PACKAGE:?PACKAGE 未設定 (例: PACKAGE=fleetstage-hq)}"
: "${BIN:?BIN 未設定 (例: BIN=fleetstage-hq-api)}"
: "${IMAGE:?IMAGE 未設定 (例: IMAGE=ghcr.io/chronista-club/fleetstage-hq-api)}"

# === 任意 env (default 設定) ===
TARGET="${TARGET:-x86_64-unknown-linux-gnu}"
PLATFORM="${PLATFORM:-linux/amd64}"
DOCKERFILE="${DOCKERFILE:-Dockerfile.${BIN}}"
ROOT="${ROOT:-$(pwd)}"

# sccache を rustc wrapper に挿入。 既設定なら尊重。
export RUSTC_WRAPPER="${RUSTC_WRAPPER:-sccache}"

cd "$ROOT"

# === git sha (image tag 用) ===
if git rev-parse --git-dir >/dev/null 2>&1; then
    SHA="$(git rev-parse --short HEAD)"
else
    SHA="nogit-$(date +%s)"
fi

echo "==> 1/4 zigbuild  ($TARGET, package=$PACKAGE, bin=$BIN)"
echo "    RUSTC_WRAPPER=$RUSTC_WRAPPER"
cargo zigbuild \
    --release \
    --target "$TARGET" \
    --package "$PACKAGE" \
    --bin "$BIN"

# === build 成否を tee の罠回避で再検証 ===
if [ ! -x "target/$TARGET/release/$BIN" ]; then
    echo "ERROR: cargo zigbuild は exit 0 だが binary が無い。 上のログを確認。" >&2
    exit 1
fi

echo "==> 2/4 stage binary to dist/$BIN"
mkdir -p dist
cp -f "target/$TARGET/release/$BIN" "dist/$BIN"
ls -lh "dist/$BIN"
file "dist/$BIN" || true

echo "==> 3/4 buildx --push (platform=$PLATFORM, dockerfile=$DOCKERFILE, tags=latest+$SHA)"
# --cache-from / --cache-to で ghcr の :cache tag に image layer を保存。
# mode=max で 中間 layer も全部 push、 次回 build で hit させる。
docker buildx build \
    --platform "$PLATFORM" \
    -f "$DOCKERFILE" \
    -t "$IMAGE:latest" \
    -t "$IMAGE:$SHA" \
    --cache-from "type=registry,ref=$IMAGE:cache" \
    --cache-to "type=registry,ref=$IMAGE:cache,mode=max" \
    --push \
    .

echo "==> 4/4 sccache stats"
sccache --show-stats || true

echo
echo "==> done."
echo "    pushed: $IMAGE:latest  +  $IMAGE:$SHA"
echo "    cache:  $IMAGE:cache"
