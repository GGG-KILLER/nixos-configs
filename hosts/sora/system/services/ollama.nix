{ ... }:
{
  services.ollama.enable = true;
  services.ollama.acceleration = "cuda";
  services.ollama.loadModels = [
    # General
    "deepseek-r1"
    "gemma3"
    "qwen3"
    "devstral"
    "llama4"
    "phi4"

    # Coding
    "devstral"
    "wizardlm2"
    "codestral"
  ];
}
