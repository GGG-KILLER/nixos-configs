{
  buildPythonPackage,
  fetchPypi,
  torch,
  numpy,
  fsspec,
  tensorboard,
  packaging,
  psutil,
  pyre-extensions,
  typing-extensions,
  setuptools,
  tqdm,
  tabulate,
  torchsnapshot,
}:
buildPythonPackage rec {
  pname = "torchtnt";
  version = "0.2.0";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    dist = "py3";
    python = "py3";
    hash = "sha256-sM5Kgu/FySzMeFYYuUYyBs7tJ7tsJEdkz7qpMj6GWWE=";
  };

  propagatedBuildInputs = [
    torch
    numpy
    fsspec
    tensorboard
    packaging
    psutil
    pyre-extensions
    typing-extensions
    setuptools
    tqdm
    tabulate
    torchsnapshot
  ];

  pythonImportsCheck = ["torchtnt"];
}
