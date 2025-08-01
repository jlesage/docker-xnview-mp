#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Make sure the configuration directory exists.
mkdir -p /config/.xnviewmp

# Install default configuration.
if [ ! -f /config/.xnviewmp/xnview.ini ]; then
    cp -v /defaults/xnview.ini /config/.xnviewmp/xnview.ini
    sed-patch "s/<UUID>/$(uuidgen)/" /config/.xnviewmp/xnview.ini
fi

# Handle light/dark mode.
if ! grep -q '^style=\(0\|-1\|-2\)$' /config/.xnviewmp/xnview.ini; then
    # Nothing to do: user selected a custom theme.
    :
elif is-bool-val-false "${DARK_MODE:-0}"; then
    sed -i 's/^borderColor=.*/borderColor=172 172 172/' /config/.xnviewmp/xnview.ini
    sed -i 's/^defaultLabelBColor=.*/defaultLabelBColor=210 210 210/' /config/.xnviewmp/xnview.ini
    sed -i 's/^defaultLabelColor=.*/defaultLabelColor=0 0 0/' /config/.xnviewmp/xnview.ini
    sed -i 's/^thumbBackColor=.*/thumbBackColor=234 234 234/' /config/.xnviewmp/xnview.ini
    sed -i 's/^thumbBorderColor=.*/thumbBorderColor=255 255 255/' /config/.xnviewmp/xnview.ini
    sed -i 's/^prevBackColor=.*/prevBackColor=241 241 241/' /config/.xnviewmp/xnview.ini
    sed -i 's/^useShadow=.*/useShadow=true/' /config/.xnviewmp/xnview.ini
    sed -i 's/^style=.*/style=-1/' /config/.xnviewmp/xnview.ini
    sed -i 's/^backColor=./backColor=241 241 241/' /config/.xnviewmp/xnview.ini
    sed -i 's/^fullBackColor=./fullBackColor=241 241 241/' /config/.xnviewmp/xnview.ini
else
    sed -i 's/^borderColor=.*/borderColor=38 38 38/' /config/.xnviewmp/xnview.ini
    sed -i 's/^defaultLabelBColor=.*/defaultLabelBColor=38 38 38/' /config/.xnviewmp/xnview.ini
    sed -i 's/^defaultLabelColor=.*/defaultLabelColor=225 225 225/' /config/.xnviewmp/xnview.ini
    sed -i 's/^thumbBackColor=.*/thumbBackColor=38 38 38/' /config/.xnviewmp/xnview.ini
    sed -i 's/^thumbBorderColor=.*/thumbBorderColor=38 38 38/' /config/.xnviewmp/xnview.ini
    sed -i 's/^prevBackColor=.*/prevBackColor=55 55 55/' /config/.xnviewmp/xnview.ini
    sed -i 's/^useShadow=.*/useShadow=false/' /config/.xnviewmp/xnview.ini
    sed -i 's/^style=.*/style=-2/' /config/.xnviewmp/xnview.ini
    sed -i 's/^backColor=.*/backColor=55 55 55/' /config/.xnviewmp/xnview.ini
    sed -i 's/^fullBackColor=.*/fullBackColor=55 55 55/' /config/.xnviewmp/xnview.ini
fi

# vim:ft=sh:ts=4:sw=4:et:sts=4
