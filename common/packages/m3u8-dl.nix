{
  fetchFromGitHub,
  callPackage,
}: let
  src = fetchFromGitHub {
    owner = "GGG-KILLER";
    repo = "m3u8-dl";
    rev = "59b3464a810de311167278a3b4be371ad7741ef7";
    hash = "sha256-G5/i28wlxWG0jskVbvz9AWm6g7Ml/hOXW41RcM0tS8E=";
  };
in
  callPackage src {}
