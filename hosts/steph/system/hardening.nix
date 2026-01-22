# Copied from: https://github.com/NixOS/nixpkgs/blob/79aaddff29307748c351a13d66f9d1fba4218624/nixos/modules/profiles/hardened.nix
# I'm not including it to ensure I only get the parts I want.
{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  # Cannot use hardened kernel otherwise opensnitchd's eBPF mode doesn't work.

  # Restrict nix to only root and my user
  nix.settings.allowed-users = mkForce [
    "root"
    "ggg"
  ];

  # NOTE: cannot use alternative allocators because Jetbrains Rider breaks.
  # environment.memoryAllocator.provider = "scudo";
  # environment.variables.SCUDO_OPTIONS = lib.concatStringsSep ":" [
  #   "dealloc_type_mismatch=true"
  #   "delete_size_mismatch=true"
  #   "may_return_null=false"
  # ];

  # Disable loading of kernel modules after booting
  # security.lockKernelModules = true;

  # Prevent the kernel image from being replaced
  security.protectKernelImage = true;

  security.forcePageTableIsolation = true;

  # This is required by podman to run containers in rootless mode.
  security.unprivilegedUsernsClone = true;

  security.virtualisation.flushL1DataCache = "always";

  security.apparmor.enable = true;
  security.apparmor.killUnconfinedConfinables = true;

  boot.kernelParams = [
    # Don't merge slabs
    "slab_nomerge"

    # Overwrite free'd pages
    "page_poison=1"

    # Enable page allocator randomization
    "page_alloc.shuffle=1"

    ##
    ## Keep debugfs enabled for scx
    ##
  ];

  boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    # Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "ntfs"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];

  # Hide kptrs even for processes with CAP_SYSLOG
  boot.kernel.sysctl."kernel.kptr_restrict" = 2;

  # Keep bpf() JIT enabled for scx but harden it
  boot.kernel.sysctl."net.core.bpf_jit_harden" = 2;

  # Disable ftrace debugging
  boot.kernel.sysctl."kernel.ftrace_enabled" = false;

  # Reverse path filtering removed for VPN

  # Ignore broadcast ICMP (mitigate SMURF)
  boot.kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = true;

  # Ignore incoming ICMP redirects (note: default is needed to ensure that the
  # setting is applied to interfaces added after the sysctls are set)
  boot.kernel.sysctl."net.ipv4.conf.all.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.all.secure_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.secure_redirects" = false;
  boot.kernel.sysctl."net.ipv6.conf.all.accept_redirects" = false;
  boot.kernel.sysctl."net.ipv6.conf.default.accept_redirects" = false;

  # Ignore outgoing ICMP redirects (this is ipv4 only)
  boot.kernel.sysctl."net.ipv4.conf.all.send_redirects" = false;
  boot.kernel.sysctl."net.ipv4.conf.default.send_redirects" = false;
}
