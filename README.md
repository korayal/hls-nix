# hls-nix

A nix-buildable derivation for [haskell-language-server](https://github.com/haskell/haskell-language-server)

# Getting started

## 1. Use Cachix to avoid compilation (optional if you like compiling for 2h)

    $ nix-env -iA cachix -f https://cachix.org/api/v1/install
    $ cachix use korayal-hls

## 2. Install ghcide

Currently available for `ghc865`, `ghc864`, `ghc883`, `ghc882`, `ghc8101`:

### On NixOS

```nix
environment.systemPackages = [
  (import (builtins.fetchTarball "https://github.com/korayal/hls-nix/tarball/master") {}).hls-ghc865
];
```

### With Nix

    $ nix-env -iA hls-ghc865 -f https://github.com/korayal/hls-nix/tarball/master

# 3. [Continue by following upstream instructions](https://github.com/haskell/haskell-language-server)
