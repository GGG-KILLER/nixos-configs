{...}: {
  nixpkgs.overlays = [
    (self: super: {
      local = let
        inherit (super) fetchFromGitHub callPackage;
        deb = fetchFromGitHub {
          owner = "GGG-KILLER";
          repo = "DiscordEmailBridge";
          rev = "v0.1.0";
          hash = "sha256-/EWpHzxX8EVzudBRBj8wMA+EQq+u9qxD1vn8mWvO5Js=";
        };
        m3u8-dl = fetchFromGitHub {
          owner = "GGG-KILLER";
          repo = "m3u8-dl";
          rev = "59b3464a810de311167278a3b4be371ad7741ef7";
          hash = "sha256-G5/i28wlxWG0jskVbvz9AWm6g7Ml/hOXW41RcM0tS8E=";
        };
      in {
        discord-email-bridge = callPackage deb {};
        m3u8-dl = callPackage m3u8-dl {};
        git-credential-manager = callPackage ./git-credential-manager {};
        winfonts = callPackage ./winfonts {};
        npm = callPackage ./npm {inherit (super) nodejs;};
        prometheus-lm-sensors-exporter = callPackage ./lm-sensors-exporter {};
        mockoon = callPackage ./mockoon.nix {};
        csharp-vscode-ext = callPackage ./ms-dotnettools.csharp {};
        csdevkit-vscode-ext = callPackage ./ms-dotnettools.csdevkit {};
      };
    })
  ];
}
