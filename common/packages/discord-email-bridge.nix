{
  fetchFromGitHub,
  callPackage,
}: let
  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "DiscordEmailBridge";
    rev = "v0.1.0";
    hash = "sha256-/EWpHzxX8EVzudBRBj8wMA+EQq+u9qxD1vn8mWvO5Js=";
  };
in
  callPackage src {}
