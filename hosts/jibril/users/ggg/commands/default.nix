{ self, system, pkgs, ... }:
{
  home-manager.users.ggg.home.packages = [
    (pkgs.pog.pog {
      name = "docker-registry-cleanup";
      description = "A tool to cleanup the docker-registry";
      runtimeInputs = with pkgs; [
        curl
        jq
      ];
      strict = true;
      script =
        helpers: with helpers; ''
          shopt -s nullglob

          if [[ $EUID -ne 0 ]]; then
              die "please run as root"
          fi

          for repo in $(curl -Ls GET http://docker.lan/v2/_catalog | jq -r '.repositories[]'); do
              tags=(/var/lib/docker-registry/docker/registry/v2/repositories/"$repo"/_manifests/tags/*);
              if [ "''${#tags[@]}" -lt 1 ]; then
                  ${spinner {
                    command = ''rm -r "/var/lib/docker-registry/docker/registry/v2/repositories/$repo"'';
                    title = "Removing repository $repo due to no tags being in it...";
                  }}
              fi
          done
        '';
    })
    self.packages.${system}.find-ata
  ];
}
