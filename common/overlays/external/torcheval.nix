{
  buildPythonPackage,
  fetchPypi,
  torch,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "torcheval";
  version = "0.0.7";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    dist = "py3";
    python = "py3";
    hash = "sha256-IMw02seqmzL5Qsip8BTR0CCYYxts0LECwHhgBXcBeVY=";
  };

  propagatedBuildInputs = [
    torch
    typing-extensions
  ];

  pythonImportsCheck = [ "torcheval" ];
}
