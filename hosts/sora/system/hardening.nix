# Copied from: https://github.com/NixOS/nixpkgs/blob/79aaddff29307748c351a13d66f9d1fba4218624/nixos/modules/profiles/hardened.nix
# I'm not including it to ensure I only get the parts I want.
{ config, lib, ... }:
let
  inherit (lib) mkForce mkDefault mkOverride;
in
{
  ##
  ## Cannot use hardened kernel otherwise opensnitchd's eBPF mode doesn't work.
  ##

  # Restrict nix to only root and my user
  nix.settings.allowed-users = mkForce [
    "root"
    "ggg"
  ];

  # Use a safer memory allocator that uses LLVM's AddressSanitizer
  environment.memoryAllocator.provider = "scudo";
  environment.variables.SCUDO_OPTIONS = "ZeroContents=1";

  # Disable loading of kernel modules after booting
  security.lockKernelModules = true;

  # Prevent the kernel image from being replaced
  security.protectKernelImage = true;

  security.forcePageTableIsolation = true;

  # This is required by podman to run containers in rootless mode.
  security.unprivilegedUsernsClone = mkDefault config.virtualisation.containers.enable;

  security.virtualisation.flushL1DataCache = "always";

  security.apparmor.enable = true;
  security.apparmor.killUnconfinedConfinables = mkDefault true;

  boot.kernelParams = [
    # Don't merge slabs
    "slab_nomerge"

    # Overwrite free'd pages
    "page_poison=1"

    # Enable page allocator randomization
    "page_alloc.shuffle=1"

    ##
    ## Keep debugfs enabled for opensnitch
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
  boot.kernel.sysctl."kernel.kptr_restrict" = mkOverride 500 2;

  ##
  ## Keep bpf() JIT enabled but harden it
  ##
  boot.kernel.sysctl."net.core.bpf_jit_harden" = 2;

  # Disable ftrace debugging
  boot.kernel.sysctl."kernel.ftrace_enabled" = mkDefault false;

  ##
  ## Reverse path filtering removed for VPN
  ##

  # Ignore broadcast ICMP (mitigate SMURF)
  boot.kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = mkDefault true;

  # Ignore incoming ICMP redirects (note: default is needed to ensure that the
  # setting is applied to interfaces added after the sysctls are set)
  boot.kernel.sysctl."net.ipv4.conf.all.accept_redirects" = mkDefault false;
  boot.kernel.sysctl."net.ipv4.conf.all.secure_redirects" = mkDefault false;
  boot.kernel.sysctl."net.ipv4.conf.default.accept_redirects" = mkDefault false;
  boot.kernel.sysctl."net.ipv4.conf.default.secure_redirects" = mkDefault false;
  boot.kernel.sysctl."net.ipv6.conf.all.accept_redirects" = mkDefault false;
  boot.kernel.sysctl."net.ipv6.conf.default.accept_redirects" = mkDefault false;

  # Ignore outgoing ICMP redirects (this is ipv4 only)
  boot.kernel.sysctl."net.ipv4.conf.all.send_redirects" = mkDefault false;
  boot.kernel.sysctl."net.ipv4.conf.default.send_redirects" = mkDefault false;
}
