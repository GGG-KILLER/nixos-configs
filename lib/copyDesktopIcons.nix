# Source: https://github.com/emmanuelrosa/erosanix/blob/6a39f836ad719177c201c95cec9e2b1b373e1b40/flake.nix#L30
{ makeSetupHook }: makeSetupHook { name = "copyDesktopIcons"; } ./copy-desktop-icons.sh
