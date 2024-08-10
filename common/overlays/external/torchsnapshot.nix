{
  buildPythonPackage,
  fetchPypi,
  pyyaml,
  aiofiles,
  aiohttp,
  importlib-metadata,
  nest-asyncio,
  psutil,
  pyre-extensions,
  torch,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "torchsnapshot";
  version = "0.1.0";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    dist = "py3";
    python = "py3";
    hash = "sha256-j2G2q/WH/HLdgQmTF/pG2JVSU272ruYR43dxVIvcnmg=";
  };

  propagatedBuildInputs = [
    pyyaml
    aiofiles
    aiohttp
    importlib-metadata
    nest-asyncio
    psutil
    pyre-extensions
    torch
    typing-extensions
  ];

  pythonImportsCheck = [ "torchsnapshot" ];
}
