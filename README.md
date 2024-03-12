# nixos-configs
My own NixOS Configs

## Structure
- `common`: common configs shared across all hosts (laptops, desktops and servers)
- `common/secrets`: not-so-secret secrets (just things I don't want to be public to all of GitHub) using [git-crypt-agessh](https://github.com/mtoohey31/git-crypt-agessh)
- `hosts`: individual configuration for each host (laptop, desktop or server)
- `secrets`: encrypted secrets using [agenix](https://github.com/ryantm/agenix)

## Hosts
- `f.ggg.dev`: The backend for services I host publicly
- `shiro`: My home server where I host my own services along with some others
- `sora`: My desktop
- `vpn-proxy`: A proxy I made for some of my friends which are in risk of MITM to use

## License
These configs are licensed under MIT.

So do whatever you want to them, but please give me credit as I have given credit for the ones I obtained from others.

If you find any files that you have authored in this repository and proper credit has not been given, please get in touch with me, and I'll rectify that.

## Snippets

Getting the hash for a VSCode extension:
```bash
nix hash to-sri --type sha256 $(nix-prefetch-url --type sha256 "https://ms-dotnettools.gallery.vsassets.io/_apis/public/gallery/publisher/ms-dotnettools/extension/csdevkit/1.4.28/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage?targetPlatform=linux-x64")
```
