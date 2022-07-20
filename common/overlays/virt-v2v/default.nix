{
  autoPatchelfHook,
  dpkg,
  fetchurl,
  jansson,
  lib,
  libguestfs-with-appliance,
  libnbd,
  libosinfo,
  libvirt,
  libxml2,
  pcre2,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "virt-v2v";
  version = "2.0.6";

  src = fetchurl {
    url = "http://ftp.br.debian.org/debian/pool/main/v/${pname}/${pname}_${version}-1_amd64.deb";
    hash = "sha256-TVDZeplFxbtw9s+GiLelYeh8Awh2M9/uYQpHpYl8+Gw=";
  };

  unpackCmd = "${dpkg}/bin/dpkg-deb -x $curSrc .";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    jansson
    libguestfs-with-appliance
    libnbd
    libosinfo
    libvirt
    libxml2
    pcre2
  ];

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "Tools for accessing and modifying virtual machine disk images";
    license = with licenses; [gpl2Plus lgpl21Plus];
    homepage = "https://libguestfs.org/";
    maintainers = with maintainers; [offline];
    platforms = platforms.linux;
    # this is to avoid "output size exceeded"
    hydraPlatforms =
      if appliance != null
      then appliance.meta.hydraPlatforms
      else platforms.linux;
  };
}
