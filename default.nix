let

  defaultNixpkgs = fetchTarball {
    # a recent-ish SHA from the release-21.05 branch
    url = "https://github.com/NixOS/nixpkgs/archive/60f3e3675b13f5c9d788f54939ac747bb66e6ff9.tar.gz";
    sha256 = "1azmrhhpa8q37zvyj0g4faq8ibill8hgbdlf337y2np2qigciwgm";
  };

in
{ ghc ? "ghc8104"
, agpl ? true
, pkgs ? import defaultNixpkgs {
    config = {
      allowUnfree = true; # allow unfree internal dependencies
      allowBroken = true;
      dontHaddock = true;
      doCheck = false;
    };
  }
}:
let
  hlib = pkgs.haskell.lib;
  inherit (pkgs.lib) fakeSha256;
  disableOptionalHaskellBuildSteps = super: args: super.mkDerivation (args // {
    doCheck = false;
    doBenchmark = false;
    doHoogle = false;
    doHaddock = false;
    enableLibraryProfiling = false;
    enableExecutableProfiling = false;
    configureFlags = if agpl then [] else ["-f-agpl"];
  });

  hpkgs = pkgs.haskell.packages.${ghc}.override
    {
      overrides = self: super:
        let
          hls-src = pkgs.fetchFromGitHub {
            owner  = "haskell";
            repo   = "haskell-language-server";
            rev    = "2857eeece0398e1cd4b2ffb6069b05c4d2308b39";
            sha256 = "03wf1sfbk3z3m3wnr36shvsn1axw8aidmd0j6f0mk4n95ff0pwn1";
          };

          ghc-api-compat-src = pkgs.fetchFromGitHub {
            owner  = "hsyl20";
            repo   = "ghc-api-compat";
            rev    = "8fee87eac97a538dbe81ff1ab18cff10f2f9fa15";
            sha256 = "16bibb7f3s2sxdvdy2mq6w1nj1lc8zhms54lwmj17ijhvjys29vg";
          };

          ormolu-src = pkgs.fetchFromGitHub {
            owner  = "tweag";
            repo   = "ormolu";
            rev    = "98617071305f996ad10a6b767ca0c2ae65b1da39";
            sha256 = "1camqj1pmr383w6lpvgd2fhvwvbz3iyvflislr0ja6gig2p2lhca";
          };

        in
        {
          mkDerivation = disableOptionalHaskellBuildSteps super;

          ghcide = self.callCabal2nix "ghcide" "${hls-src}/ghcide" {};
          hie-compat = self.callCabal2nix "hie-compat" "${hls-src}/hie-compat" {};
          hls-graph = self.callCabal2nix "hls-graph" "${hls-src}/hls-graph" {};
          hls-plugin-api = self.callCabal2nix "hls-plugin-api" "${hls-src}/hls-plugin-api" {};

          hls-brittany-plugin = self.callCabal2nix "hls-brittany-plugin" "${hls-src}/plugins/hls-brittany-plugin" {};
          hls-call-hierarchy-plugin = self.callCabal2nix "hls-call-hierarchy-plugin" "${hls-src}/plugins/hls-call-hierarchy-plugin" {};
          hls-class-plugin = self.callCabal2nix "hls-class-plugin" "${hls-src}/plugins/hls-class-plugin" {};
          hls-eval-plugin = self.callCabal2nix "hls-eval-plugin" "${hls-src}/plugins/hls-eval-plugin" {};
          hls-explicit-imports-plugin = self.callCabal2nix "hls-explicit-imports-plugin" "${hls-src}/plugins/hls-explicit-imports-plugin" {};
          hls-floskell-plugin = self.callCabal2nix "hls-floskell-plugin" "${hls-src}/plugins/hls-floskell-plugin" {};
          hls-fourmolu-plugin = self.callCabal2nix "hls-fourmolu-plugin" "${hls-src}/plugins/hls-fourmolu-plugin" {};
          hls-haddock-comments-plugin = self.callCabal2nix "hls-haddock-comments-plugin" "${hls-src}/plugins/hls-haddock-comments-plugin" {};
          hls-hlint-plugin = self.callCabal2nix "hls-hlint-plugin" "${hls-src}/plugins/hls-hlint-plugin" {};
          hls-module-name-plugin = self.callCabal2nix "hls-module-name-plugin" "${hls-src}/plugins/hls-module-name-plugin" {};
          hls-ormolu-plugin = self.callCabal2nix "hls-ormolu-plugin" "${hls-src}/plugins/hls-ormolu-plugin" {};
          hls-pragmas-plugin = self.callCabal2nix "hls-pragmas-plugin" "${hls-src}/plugins/hls-pragmas-plugin" {};
          hls-refine-imports-plugin = self.callCabal2nix "hls-refine-imports-plugin" "${hls-src}/plugins/hls-refine-imports-plugin" {};
          hls-retrie-plugin = self.callCabal2nix "hls-retrie-plugin" "${hls-src}/plugins/hls-retrie-plugin" {};
          hls-splice-plugin = self.callCabal2nix "hls-splice-plugin" "${hls-src}/plugins/hls-splice-plugin" {};
          hls-stylish-haskell-plugin = self.callCabal2nix "hls-stylish-haskell-plugin" "${hls-src}/plugins/hls-stylish-haskell-plugin" {};
          hls-tactics-plugin  = self.callCabal2nix "hls-tactics-plugin" "${hls-src}/plugins/hls-tactics-plugin" {};

          haskell-language-server = (self.callCabal2nix "haskell-language-server" hls-src {}).overrideAttrs(attrs: {
            configureFlags = ["--enable-executable-dynamic"];
          });

          apply-refact = self.callHackageDirect {
            pkg = "apply-refact";
            ver = "0.9.3.0";
            sha256 = "1jfq1aw91finlpq5nn7a96za4c8j13jk6jmx2867fildxwrik2qj";
          } {};

          brittany = self.callHackageDirect {
            pkg = "brittany";
            ver = "0.13.1.2";
            sha256 = "1b9bl2y4lvbs0vsaw86z413hpk649cxr399yshpwf2xqpgcw9c72";
          } {};

          Cabal = self.callHackageDirect {
            pkg = "Cabal";
            ver = "3.0.2.0";
            sha256 = "0w03j3a5ma8li3hrn9xp49pmh9r4whxidm71x9c37x5p6igzihms";
          } {};

          ghc-api-compat = self.callCabal2nix "ghc-api-compat" ghc-api-compat-src {};

          hlint = self.callHackageDirect {
            pkg = "hlint";
            ver = "3.2.7";
            sha256 = "1w3f0140c347kjhk6sbjh28p4gf4f1nrzp4rn589j3dkcb672l43";
          } {};

          ghc-lib = self.callHackageDirect {
            pkg = "ghc-lib";
            ver = "8.10.5.20210606";
            sha256 = "1m65982m9vzkslk88krkl30kfcvjx2acx9lh8d2jcyw1ql32f0qa";
          } {};

          ghc-lib-parser = self.callHackageDirect {
            pkg = "ghc-lib-parser";
            ver = "8.10.5.20210606";
            sha256 = "0kphq6x8n2krxbhjrs45z3jkvix262v16rw0x7dw412bidk0cz7r";
          } {};

          refinery = self.callHackageDirect {
            pkg = "refinery";
            ver = "0.4.0.0";
            sha256 = "1ic7qvfizh5av3b3hp8db08v6b0hmac20smyhbaqzwvfpdgnjq71";
          } {};

          ormolu = self.callCabal2nix "ormolu" ormolu-src {};

          optparse-applicative = self.callHackageDirect {
            pkg = "optparse-applicative";
            ver = "0.15.1.0";
            sha256 = "1mii408cscjvids2xqdcy2p18dvanb0qc0q1bi7234r23wz60ajk";
          } {};

          ansi-terminal = self.callHackageDirect {
            pkg = "ansi-terminal";
            ver = "0.10.3";
            sha256 = "1aa8lh7pl054kz7i59iym49s8w473nhdqgc3pq16cp5v4358hw5k";
          } {};

          retrie = self.callHackageDirect {
            pkg = "retrie";
            ver = "0.1.1.1";
            sha256 = "0gnp6j35jnk1gcglrymvvn13sawir0610vh0z8ya6599kyddmw7l";
          } {};

          lsp-test = self.callHackageDirect {
            pkg = "lsp-test";
            ver = "0.14.0.1";
            sha256 = "10lnyg7nlbd3ymgvjjlrkfndyy7ay9cwnsk684p08k2gzlric4yq";
          } {};

          lsp-types = self.callHackageDirect {
            pkg = "lsp-types";
            ver = "1.3.0.0";
            sha256 = "0qajyyj2d51daa4y0pqaa87n4nny0i920ivvzfnrk9gq9386iac7";
          } {};

          lsp = self.callHackageDirect {
            pkg = "lsp";
            ver = "1.2.0.1";
            sha256 = "1lhzsraiw11ldxvxn8ax11hswpyzsvw2da2qmp3p6fc9rfpz4pj5";
          } {};

          hiedb = self.callHackageDirect {
            pkg = "hiedb";
            ver = "0.4.0.0";
            sha256 = "13jz8c46zfpf54ya2wsv4akhn0wcfc6qjazqsjfir5gpvsi7v8xr";
          } {};

          implicit-hie-cradle = self.callHackageDirect {
            pkg = "implicit-hie-cradle";
            ver = "0.3.0.5";
            sha256 = "15a7g9x6cjk2b92hb2wilxx4550msxp1pmk5a2shiva821qaxnfq";
          } {};

          implicit-hie = self.callHackageDirect {
            pkg = "implicit-hie";
            ver = "0.1.2.6";
            sha256 = "067bmw5b9qg55ggklbfyf93jgpkbzmprmgv906jscfzvv1h8266c";
          } {};

          ghc-source-gen = self.callHackageDirect {
            pkg = "ghc-source-gen";
            ver = "0.4.1.0";
            sha256 = "0kk599vk54ckikpxkzwrbx7z5x0xr20hr179rldmnlb34bf9mpnk";
          } {};
        };
    };
in
{
  inherit hpkgs;
  inherit pkgs;
}
