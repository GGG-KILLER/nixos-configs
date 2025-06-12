{ ... }:
{
  services.ollama.enable = true;
  services.ollama.acceleration = "cuda";
  services.ollama.loadModels = [
    # General
    "deepseek-r1"
    "gemma3"

    # Coding (continue.dev)
    "llama3.1:8b"
    "qwen2.5-coder:1.5b-base"
    "nomic-embed-text:latest"
  ];
}
