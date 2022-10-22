{
  lib,
  makeWrapper,
  runCommand,
  dependencies,
  filePath,
  replacements ? {},
}:
with lib; let
  binPath = makeBinPath dependencies;
  fileName = builtins.baseNameOf filePath;
  replaceCmd =
    if replacements == {}
    then ""
    else
      builtins.concatStringsSep "\n" (flip mapAttrsToList replacements (name: val: ''
        substituteInPlace $out/bin/${fileName} \
          --subst-var-by "${toString name}" "${toString val}"
      ''));
in
  runCommand "${fileName}-script"
  {
    nativeBuildInputs = [makeWrapper];
  } ''
    mkdir -p $out/bin

    cp ${filePath} $out/bin/${fileName}
    patchShebangs $out/bin/${fileName}
    ${replaceCmd}
    chmod 0755 $out/bin/${fileName}

    wrapProgram $out/bin/${fileName} --prefix PATH : ${binPath}
  ''
