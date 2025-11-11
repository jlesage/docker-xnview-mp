#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

export DEBIAN_FRONTEND=noninteractive

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

XNVIEW_MP_ROOTFS=/tmp/xnview-mp-rootfs
XNVIEW_MP_INSTALL_DIR=/opt/xnview-mp

log() {
    echo ">>> $*"
}

XNVIEW_MP_URL="$1"

if [ -z "$XNVIEW_MP_URL" ]; then
    log "ERROR: XnView MP URL missing."
    exit 1
fi

log "Updating APT cache..."
apt-get update

log "Installing build prerequisites..."
apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    locales \
    patchelf \
    file \
    rsync \
    libasound2 \
    libegl1 \
    libgbm1 \
    libgtk2.0-0 \
    libgl1 \
    libglib2.0-0 \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    libheif1 \
    libpulse0 \
    libpulse-mainloop-glib0 \
    libwayland-client0 \
    libwayland-cursor0 \
    libwayland-egl1 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-shape0 \
    libxcb-xkb1 \
    libxcb-render-util0 \
    libxcb-keysyms1 \
    libxcb-xinerama0 \
    libxkbcommon0 \
    libxkbcommon-x11-0 \

# Generate locale.
locale-gen en_US.UTF-8

# Create XnView MP install directory.
mkdir -p "$XNVIEW_MP_INSTALL_DIR"

log "Downloading XnView MP..."
curl -# -L -f ${XNVIEW_MP_URL} | tar xz --strip 1 -C "$XNVIEW_MP_INSTALL_DIR"

rm -r \
    "$XNVIEW_MP_INSTALL_DIR"/lib/wayland* \
    "$XNVIEW_MP_INSTALL_DIR"/lib/platformthemes/libqgtk3.so \

ln -s libOpenEXR.so "$XNVIEW_MP_INSTALL_DIR"/Plugins/libOpenEXR-3_2.so.29
ln -s libOpenEXRCore-3_2.so "$XNVIEW_MP_INSTALL_DIR"/Plugins/libOpenEXRCore-3_2.so.29

# Define extra libraries that are needed.  These libraries are loaded
# dynamically (dlopen) and are not catched by tracking dependencies.
EXTRA_LIBS="
    /lib/x86_64-linux-gnu/libnss_dns
    /lib/x86_64-linux-gnu/libnss_files
    /lib/x86_64-linux-gnu/libnss_compat
    /usr/lib/x86_64-linux-gnu/libheif
"

# GLX support Adds ~150MB to the image.
#EXTRA_LIBS="
#    $EXTRA_LIBS
#    /usr/lib/x86_64-linux-gnu/libGLX_mesa.so
#    /usr/lib/x86_64-linux-gnu/dri/swrast_dri.so
#"

log "Copying extra libraries..."
for LIB in $EXTRA_LIBS
do
    cp -av "$LIB"* "$XNVIEW_MP_INSTALL_DIR"/lib/
done

log "Extracting shared library dependencies..."
find "$XNVIEW_MP_INSTALL_DIR" -type f | xargs file | grep "dynamically linked" | cut -d : -f 1 | while read BIN
do
    echo "Dependencies for $BIN:"
    RAW_DEPS="$(LD_LIBRARY_PATH="$XNVIEW_MP_INSTALL_DIR/lib:$XNVIEW_MP_INSTALL_DIR/Plugins" ldd "$BIN")"
    echo "================================"
    echo "$RAW_DEPS"
    echo "================================"

    if echo "$RAW_DEPS" | grep -q " not found"; then
        echo "ERROR: Some libraries are missing!"
        exit 1
    fi

    LD_LIBRARY_PATH="$XNVIEW_MP_INSTALL_DIR/lib:$XNVIEW_MP_INSTALL_DIR/Plugins" ldd "$BIN" | (grep " => " || true) | cut -d'>' -f2 | sed 's/^[[:space:]]*//' | cut -d'(' -f1 | while read dep
    do
        dep_real="$(realpath "$dep")"
        dep_basename="$(basename "$dep_real")"

        # Skip already-processed libraries.
        [ ! -f "$XNVIEW_MP_INSTALL_DIR/lib/$dep_basename" ] || continue
        [ ! -f "$XNVIEW_MP_INSTALL_DIR/Plugins/$dep_basename" ] || continue

        echo "  -> Found library: $dep"
        cp "$dep_real" "$XNVIEW_MP_INSTALL_DIR/lib/"
        while true; do
            [ -L "$dep" ] || break;
            ln -sf "$dep_basename" "$XNVIEW_MP_INSTALL_DIR"/lib/$(basename $dep)
            dep="$(readlink -f "$dep")"
        done

        dep_fname="$(basename "$dep")"
        if [[ "$dep_fname" =~ ^ld-* ]]; then
            echo "$dep_fname" > /tmp/interpreter_fname
            echo "    -> This is the interpreter."
        fi
    done
done

log "Copying interpreter..."
cp -v /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 "$XNVIEW_MP_INSTALL_DIR"/lib/

log "Patching ELF of binaries..."
BINARIES="
    $XNVIEW_MP_INSTALL_DIR/XnView
"
for BIN in $BINARIES; do
    echo "  -> Setting interpreter of $BIN..."
    patchelf --set-interpreter "$XNVIEW_MP_INSTALL_DIR"/lib/ld-linux-x86-64.so.2 "$BIN"
done

log "Patching ELF of libraries..."
find "$XNVIEW_MP_INSTALL_DIR"/Plugins -type f | xargs file | grep "LSB shared object" | cut -d : -f 1 | while read FILE
do
    echo "  -> Setting rpath of $FILE..."
    patchelf --set-rpath '$ORIGIN;$ORIGIN/../lib' "$FILE"
done
find "$XNVIEW_MP_INSTALL_DIR"/lib/*/ -type f | xargs file | grep "LSB shared object" | cut -d : -f 1 | while read FILE
do
    echo "  -> Setting rpath of $FILE..."
    patchelf --set-rpath '$ORIGIN/../../lib' "$FILE"
done
find "$XNVIEW_MP_INSTALL_DIR"/qml/*/ -type f | xargs file | grep "LSB shared object" | cut -d : -f 1 | while read FILE
do
    echo "  -> Setting rpath of $FILE..."
    patchelf --set-rpath '$ORIGIN/../../lib' "$FILE"
done

log "Creating rootfs..."
ROOTFS_CONTENT="
    $XNVIEW_MP_INSTALL_DIR
    /etc/fonts
    /usr/share/mime
    /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
"
mkdir "$XNVIEW_MP_ROOTFS"
echo "$ROOTFS_CONTENT" | while read i
do
    [ -n "$i" ] || continue
    rsync -Rav "$i" "$XNVIEW_MP_ROOTFS"
done

echo "Content of $XNVIEW_MP_ROOTFS:"
find "$XNVIEW_MP_ROOTFS"

echo "XnView MP built successfully."

# vim:ft=sh:ts=4:sw=4:et:sts=4
