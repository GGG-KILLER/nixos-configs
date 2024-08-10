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
            substituteInPlace $out/bin/${fileName} \
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
    mkdir -p $out/bin
    cp ${filePath} $out/bin/${fileName}
    chmod 0755 $out/bin/${fileName}

    patchShebangs --host $out/bin/${fileName}
    ${replaceCmd}

    wrapProgram $out/bin/${fileName} --prefix PATH : ${binPath}
  ''
