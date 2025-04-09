{
  # Dependencies
  lib,
  makeWrapper,
  runCommand,
  # Actual args
  filePath,
  dependencies,
  replacements ? { },
  buildInputs ? [ ],
}:
with lib;
let
  binPath = makeBinPath dependencies;
  fileName = builtins.baseNameOf filePath;
  replaceCmd =
    if replacements == { } then
      ""
    else
      builtins.concatStringsSep "\n" (
        flip mapAttrsToList replacements (
          name: val: ''
            substituteInPlace $out/lib/${fileName} \
              --subst-var-by "${toString name}" "${toString val}"
          ''
        )
      );
in
runCommand "${fileName}-script"
  {
    inherit buildInputs;
    nativeBuildInputs = [ makeWrapper ];
  }
  ''
    mkdir -p $out/bin $out/lib
    cp ${filePath} $out/lib/${fileName}
    chmod 0755 $out/lib/${fileName}

    patchShebangs --host $out/lib/${fileName}
    ${replaceCmd}

    makeWrapper $out/lib/${fileName} $out/bin/${fileName} --inherit-argv0 --prefix PATH : ${binPath}
  ''
