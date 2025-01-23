# shellcheck shell=bash
# Source: https://github.com/emmanuelrosa/erosanix/blob/6a39f836ad719177c201c95cec9e2b1b373e1b40/hooks/copy-desktop-icons.sh

# Setup hook that installs specified desktop icons.
#
# Example usage in a derivation:
#
#   { …, makeDesktopIcon, copyDesktopIcons, … }:
#
#   let icon = makeDesktopIcon { … }; in
#   stdenv.mkDerivation {
#     …
#     nativeBuildInputs = [ copyDesktopIcons ];
#
#     desktopIcon = icon;
#     …
#   }

postInstallHooks+=(copyDesktopIcons)

copyDesktopIcons() {
    if [ -z "$desktopIcon" ]; then
        return
    fi

    mkdir -p $out/share/icons
    ln -s ${desktopIcon}/hicolor $out/share/icons
}
