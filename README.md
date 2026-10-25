# Relapse by ardacy2112

A PS5 home-screen web shortcut based on the PS5 Browser Search project.

- **Display name:** Relapse by ardacy2112
- **Target URL:** https://ardacy2112.github.io/relapseardacy
- **Title ID:** RELA21121
- **Icon:** `assets/icon0.png` (512×512 RGBA PNG)

When the tile is launched, the PS5 `deeplinkUri` setting directs the system browser to the configured URL. This does not perform the jailbreak itself.

## Build

Requires Docker Desktop. From this directory run:

```sh
docker compose run --rm relapse-build
```

The build output is created in `build/`. To build only the PKG:

```sh
docker compose run --rm relapse-build make pkg
```

## Install / compatibility

This is a debug/homebrew package intended for a compatible jailbroken PS5 environment. It is **not expected to install or launch on a retail PS5 while jailbreak is inactive**. Compatibility depends on the console firmware and the jailbreak environment.

## Customization

Edit `assets/param.json` to change `deeplinkUri` or `localizedParameters.en-US.titleName`. Replace `assets/icon0.png` with a 512×512 32-bit PNG to change the tile icon.

## Credits and license

Based on the upstream PS5 Browser Search project and its bundled dependencies. See `LICENSE` and the individual dependency licenses for attribution and terms.
