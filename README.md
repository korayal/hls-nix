# hls-nix

A nix-buildable derivation for [haskell-language-server](https://github.com/haskell/haskell-language-server)

I've written this derivation just to test it out myself. Any suggestions are welcome!

## Installation

This build has a cachix cache already available, and it can be setup with the
commands below:

```
$ nix-env -iA cachix -f https://cachix.org/api/v1/install
$ cachix use korayal-hls
```

Install with the command below:

```
nix-env -iA hpkgs.haskell-language-server -f https://github.com/korayal/hls-nix/tarball/master
```
