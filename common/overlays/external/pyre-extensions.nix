{
  buildPythonPackage,
  fetchPypi,
  typing-extensions,
  typing-inspect,
}:
buildPythonPackage rec {
  pname = "pyre-extensions";
  version = "0.0.30";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-unkjxIbgia+zehBiOo9K6C1zz/QkJtcRxIrwcOW8MbI=";
  };

  propagatedBuildInputs = [
    typing-extensions
    typing-inspect
  ];

  pythonImportsCheck = [ "pyre_extensions" ];
}
