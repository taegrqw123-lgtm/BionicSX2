#!/usr/bin/env bash
# PORTED FROM: PCSX2 macOS build — BionicSX2 iOS Port
# AUDIT REFERENCE: Phase 2 — Build all third-party static libraries
# Builds all iOS static libraries in dependency order for BionicSX2

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL_DIR="$REPO_ROOT/ios-deps/install"
BUILD_DIR="$REPO_ROOT/ios-deps/build"
SRC_DIR="$REPO_ROOT/ios-deps/src"
TOOLCHAIN="$REPO_ROOT/cmake/ios.toolchain.cmake"

mkdir -p "$INSTALL_DIR" "$BUILD_DIR" "$SRC_DIR"

build_lib() {
    local NAME="$1"; local SRC="$2"; shift 2
    echo ">>> Building $NAME"
    mkdir -p "$BUILD_DIR/$NAME"
    cmake -S "$SRC" -B "$BUILD_DIR/$NAME" \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        "$@"
    cmake --build "$BUILD_DIR/$NAME" --config Release -j"$(sysctl -n hw.logicalcpu)"
    cmake --install "$BUILD_DIR/$NAME"
    echo ">>> $NAME OK"
}

echo "=== BionicSX2 iOS Dependencies Build ==="
echo "Install dir: $INSTALL_DIR"
echo ""

# ── Tier 1: No dependencies ──

# lz4
build_lib "lz4" "$REPO_ROOT/pcsx2/3rdparty/lz4/build/cmake" \
    -DLZ4_BUILD_CLI=OFF -DLZ4_BUILD_LEGACY_LZ4C=OFF 2>/dev/null || \
build_lib "lz4" "$SRC_DIR/lz4" \
    -DLZ4_BUILD_CLI=OFF -DLZ4_BUILD_LEGACY_LZ4C=OFF 2>/dev/null || {
    echo ">>> Cloning lz4..."
    git clone --depth 1 https://github.com/lz4/lz4.git "$SRC_DIR/lz4"
    build_lib "lz4" "$SRC_DIR/lz4/build/cmake" \
        -DLZ4_BUILD_CLI=OFF -DLZ4_BUILD_LEGACY_LZ4C=OFF
}

# zstd
build_lib "zstd" "$REPO_ROOT/pcsx2/3rdparty/zstd/build/cmake" \
    -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_SHARED=OFF -DZSTD_BUILD_STATIC=ON -DZSTD_BUILD_TESTS=OFF 2>/dev/null || \
build_lib "zstd" "$SRC_DIR/zstd" \
    -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_SHARED=OFF -DZSTD_BUILD_STATIC=ON -DZSTD_BUILD_TESTS=OFF 2>/dev/null || {
    echo ">>> Cloning zstd..."
    git clone --depth 1 https://github.com/facebook/zstd.git "$SRC_DIR/zstd"
    build_lib "zstd" "$SRC_DIR/zstd/build/cmake" \
        -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_SHARED=OFF -DZSTD_BUILD_STATIC=ON -DZSTD_BUILD_TESTS=OFF
}

# xz/lzma
build_lib "xz" "$REPO_ROOT/pcsx2/3rdparty/xz" \
    -DBUILD_TESTING=OFF -DXZ_TOOL_XZ=OFF -DXZ_TOOL_XZDEC=OFF -DXZ_TOOL_LZMADEC=OFF -DXZ_TOOL_LZMAINFO=OFF \
    -DCREATE_XZ_SYMLINKS=OFF -DCREATE_LZMA_SYMLINKS=OFF 2>/dev/null || \
build_lib "xz" "$SRC_DIR/xz" \
    -DBUILD_TESTING=OFF -DXZ_TOOL_XZ=OFF -DXZ_TOOL_XZDEC=OFF -DXZ_TOOL_LZMADEC=OFF -DXZ_TOOL_LZMAINFO=OFF \
    -DCREATE_XZ_SYMLINKS=OFF -DCREATE_LZMA_SYMLINKS=OFF 2>/dev/null || {
    echo ">>> Cloning xz..."
    git clone --depth 1 https://github.com/tukaani-project/xz.git "$SRC_DIR/xz"
    build_lib "xz" "$SRC_DIR/xz" \
        -DBUILD_TESTING=OFF -DXZ_TOOL_XZ=OFF -DXZ_TOOL_XZDEC=OFF -DXZ_TOOL_LZMADEC=OFF -DXZ_TOOL_LZMAINFO=OFF \
        -DCREATE_XZ_SYMLINKS=OFF -DCREATE_LZMA_SYMLINKS=OFF
}

# fmt — add_subdirectory in main CMake, but build standalone for iOS deps
build_lib "fmt" "$REPO_ROOT/pcsx2/3rdparty/fmt" \
    -DFMT_TEST=OFF -DFMT_DOC=OFF 2>/dev/null || true

# ── Tier 2: Depends on lz4/zstd/lzma ──

# zlib
build_lib "zlib" "$REPO_ROOT/pcsx2/3rdparty/zlib" \
    -DZLIB_BUILD_EXAMPLES=OFF 2>/dev/null || \
build_lib "zlib" "$SRC_DIR/zlib" \
    -DZLIB_BUILD_EXAMPLES=OFF 2>/dev/null || {
    echo ">>> Cloning zlib..."
    git clone --depth 1 https://github.com/madler/zlib.git "$SRC_DIR/zlib"
    build_lib "zlib" "$SRC_DIR/zlib" -DZLIB_BUILD_EXAMPLES=OFF
}

# ── Tier 3: Depends on zlib ──

# libpng
build_lib "libpng" "$REPO_ROOT/pcsx2/3rdparty/libpng" \
    -DPNG_SHARED=OFF -DPNG_STATIC=ON -DPNG_TESTS=OFF -DZLIB_ROOT="$INSTALL_DIR" 2>/dev/null || \
build_lib "libpng" "$SRC_DIR/libpng" \
    -DPNG_SHARED=OFF -DPNG_STATIC=ON -DPNG_TESTS=OFF -DZLIB_ROOT="$INSTALL_DIR" 2>/dev/null || {
    echo ">>> Cloning libpng..."
    git clone --depth 1 https://github.com/glennrp/libpng.git "$SRC_DIR/libpng"
    build_lib "libpng" "$SRC_DIR/libpng" \
        -DPNG_SHARED=OFF -DPNG_STATIC=ON -DPNG_TESTS=OFF -DZLIB_ROOT="$INSTALL_DIR"
}

# libzip
build_lib "libzip" "$REPO_ROOT/pcsx2/3rdparty/libzip" \
    -DBUILD_TOOLS=OFF -DBUILD_REGRESS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_DOC=OFF \
    -DENABLE_COMMONCRYPTO=ON -DENABLE_GNUTLS=OFF -DENABLE_MBEDTLS=OFF -DENABLE_OPENSSL=OFF \
    -DZLIB_ROOT="$INSTALL_DIR" 2>/dev/null || \
build_lib "libzip" "$SRC_DIR/libzip" \
    -DBUILD_TOOLS=OFF -DBUILD_REGRESS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_DOC=OFF \
    -DENABLE_COMMONCRYPTO=ON -DENABLE_GNUTLS=OFF -DENABLE_MBEDTLS=OFF -DENABLE_OPENSSL=OFF \
    -DZLIB_ROOT="$INSTALL_DIR" 2>/dev/null || {
    echo ">>> Cloning libzip..."
    git clone --depth 1 https://github.com/nih-at/libzip.git "$SRC_DIR/libzip"
    build_lib "libzip" "$SRC_DIR/libzip" \
        -DBUILD_TOOLS=OFF -DBUILD_REGRESS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_DOC=OFF \
        -DENABLE_COMMONCRYPTO=ON -DENABLE_GNUTLS=OFF -DENABLE_MBEDTLS=OFF -DENABLE_OPENSSL=OFF \
        -DZLIB_ROOT="$INSTALL_DIR"
}

# freetype
build_lib "freetype" "$REPO_ROOT/pcsx2/3rdparty/freetype" \
    -DFT_DISABLE_BZIP2=ON -DFT_DISABLE_HARFBUZZ=ON -DFT_DISABLE_BROTLI=ON \
    -DZLIB_ROOT="$INSTALL_DIR" -DPNG_ROOT="$INSTALL_DIR" 2>/dev/null || \
build_lib "freetype" "$SRC_DIR/freetype" \
    -DFT_DISABLE_BZIP2=ON -DFT_DISABLE_HARFBUZZ=ON -DFT_DISABLE_BROTLI=ON \
    -DZLIB_ROOT="$INSTALL_DIR" -DPNG_ROOT="$INSTALL_DIR" 2>/dev/null || {
    echo ">>> Cloning freetype..."
    git clone --depth 1 https://gitlab.freedesktop.org/freetype/freetype.git "$SRC_DIR/freetype"
    build_lib "freetype" "$SRC_DIR/freetype" \
        -DFT_DISABLE_BZIP2=ON -DFT_DISABLE_HARFBUZZ=ON -DFT_DISABLE_BROTLI=ON \
        -DZLIB_ROOT="$INSTALL_DIR" -DPNG_ROOT="$INSTALL_DIR"
}

# ── Tier 4: Depends on lz4 + zstd + zlib ──

# libchdr
build_lib "libchdr" "$REPO_ROOT/pcsx2/3rdparty/libchdr" \
    -DWITH_SYSTEM_ZLIB=ON -DZLIB_ROOT="$INSTALL_DIR" \
    -Dlz4_DIR="$INSTALL_DIR/lib/cmake/lz4" \
    -Dzstd_DIR="$INSTALL_DIR/lib/cmake/zstd" 2>/dev/null || \
build_lib "libchdr" "$SRC_DIR/libchdr" \
    -DWITH_SYSTEM_ZLIB=ON -DZLIB_ROOT="$INSTALL_DIR" \
    -Dlz4_DIR="$INSTALL_DIR/lib/cmake/lz4" \
    -Dzstd_DIR="$INSTALL_DIR/lib/cmake/zstd" 2>/dev/null || {
    echo ">>> Cloning libchdr..."
    git clone --depth 1 https://github.com/rtissera/libchdr.git "$SRC_DIR/libchdr"
    build_lib "libchdr" "$SRC_DIR/libchdr" \
        -DWITH_SYSTEM_ZLIB=ON -DZLIB_ROOT="$INSTALL_DIR" \
        -Dlz4_DIR="$INSTALL_DIR/lib/cmake/lz4" \
        -Dzstd_DIR="$INSTALL_DIR/lib/cmake/zstd"
}

# ── Tier 5: Audio (independent) ──

# soundtouch
build_lib "soundtouch" "$REPO_ROOT/pcsx2/3rdparty/soundtouch" \
    -DCMAKE_CXX_FLAGS="-DSOUNDTOUCH_DISABLE_X86_OPTIMIZATIONS" 2>/dev/null || \
build_lib "soundtouch" "$SRC_DIR/soundtouch" \
    -DCMAKE_CXX_FLAGS="-DSOUNDTOUCH_DISABLE_X86_OPTIMIZATIONS" 2>/dev/null || {
    echo ">>> Cloning soundtouch..."
    git clone --depth 1 https://codeberg.org/soundtouch/soundtouch.git "$SRC_DIR/soundtouch"
    build_lib "soundtouch" "$SRC_DIR/soundtouch" \
        -DCMAKE_CXX_FLAGS="-DSOUNDTOUCH_DISABLE_X86_OPTIMIZATIONS"
}

# cubeb
build_lib "cubeb" "$REPO_ROOT/pcsx2/3rdparty/cubeb" \
    -DBUILD_TESTS=OFF -DBUILD_TOOLS=OFF -DUSE_SANITIZERS=OFF 2>/dev/null || \
build_lib "cubeb" "$SRC_DIR/cubeb" \
    -DBUILD_TESTS=OFF -DBUILD_TOOLS=OFF -DUSE_SANITIZERS=OFF 2>/dev/null || {
    echo ">>> Cloning cubeb..."
    git clone --depth 1 https://github.com/mozilla/cubeb.git "$SRC_DIR/cubeb"
    build_lib "cubeb" "$SRC_DIR/cubeb" \
        -DBUILD_TESTS=OFF -DBUILD_TOOLS=OFF -DUSE_SANITIZERS=OFF
}

echo ""
echo "=== BionicSX2 iOS Dependencies Build Complete ==="
echo "Libraries in: $INSTALL_DIR/lib/"
ls -la "$INSTALL_DIR/lib/" 2>/dev/null || echo "(no libraries yet)"
echo "Headers in: $INSTALL_DIR/include/"
ls "$INSTALL_DIR/include/" 2>/dev/null || echo "(no headers yet)"
