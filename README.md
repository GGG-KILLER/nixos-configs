# NixOS-configs
My own NixOS Configs

## Structure
- `common/secrets`: not-so-secret secrets (just things I don't want to be public to all of GitHub) using [git-crypt-agessh](https://github.com/mtoohey31/git-crypt-agessh)
- `hosts`: individual configuration for each host (laptop, desktop or server)
- `modules`: shared snippets of configuration used across my machines
- `secrets`: encrypted secrets using [agenix](https://github.com/ryantm/agenix)

## Hosts
- `shiro`: My NAS
- `jibril`: My home server where I host a bunch of services
- `sora`: My desktop (now a glorified Steam Deck connected to a TV)
- `steph`: My laptop

## License
These configs are licensed under MIT **except for files under `hosts/sora/system/desktop/opensnitch/reject`**.

So do whatever you want to them, but please give me credit as I have given credit for the ones I obtained from others.

If you find any files that you have authored in this repository and proper credit has not been given, please get in touch with me, and I'll rectify that.

## Snippets

Getting the hash for a VS Code extension:
```bash
nix hash to-sri --type sha256 $(nix-prefetch-url --type sha256 "https://ms-dotnettools.gallery.vsassets.io/_apis/public/gallery/publisher/ms-dotnettools/extension/csdevkit/1.4.28/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage?targetPlatform=linux-x64")
```
