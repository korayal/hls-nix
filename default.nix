let

  defaultNixpkgs = fetchTarball {
    # a recent-ish SHA from the nixos-21.05 branch
    url = "https://github.com/NixOS/nixpkgs/archive/8e1306519d5d820c3144089a3bbbc16991f4c1e3.tar.gz";
    sha256 = "1zhqzqchf8kw8zqp2yrd6zaa9wxm6n9cz9isnlqbmycnn0xpga08";
  };

in
{ ghc ? "ghc8107"
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
            rev    = "311107eabbf0537e0c192b2c377d282505b4eff1";
            sha256 = "0z1r4ra7w4pnv6am6pppvsslgqmbmn3mxnpyc233rq7dbv0ly336";
          };

          # ormolu-src = pkgs.fetchFromGitHub {
          #   owner  = "tweag";
          #   repo   = "ormolu";
          #   rev    = "98617071305f996ad10a6b767ca0c2ae65b1da39";
          #   sha256 = "1camqj1pmr383w6lpvgd2fhvwvbz3iyvflislr0ja6gig2p2lhca";
          # };

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

          brittany = self.callHackageDirect {
            pkg = "brittany";
            ver = "0.13.1.2";
            sha256 = "1b9bl2y4lvbs0vsaw86z413hpk649cxr399yshpwf2xqpgcw9c72";
          } {};

          bytestring-encoding = self.callHackageDirect {
            pkg = "bytestring-encoding";
            ver = "0.1.1.0";
            sha256 = "0qwwwya0f6qrbnp25vhb6zc2sk2xixfgwiaaywys2c1dsyw4mhrz";
          } {};

          floskell = self.callHackageDirect {
            pkg = "floskell";
            ver = "0.10.5";
            sha256 = "1flhdky8df170i1f2n5q3d4f3swma47m9lqwmzr5cg4dgjk85vdr";
          } {};

          heap-size = self.callHackageDirect {
            pkg = "heap-size";
            ver = "0.3.0.1";
            sha256 = "1lhzsraiw11ldxvxn8ax11hswpyzsvw2da2qmp3p6fc9rfpz4pja";
          } {};

          hiedb = self.callHackageDirect {
            pkg = "hiedb";
            ver = "0.4.1.0";
            sha256 = "11s7lfkd6fc3zf3kgyp3jhicbhxpn6jp0yjahl8d28hicwr2qdpi";
          } {};

          implicit-hie = self.callHackageDirect {
            pkg = "implicit-hie";
            ver = "0.1.2.6";
            sha256 = "067bmw5b9qg55ggklbfyf93jgpkbzmprmgv906jscfzvv1h8266c";
          } {};

          implicit-hie-cradle = self.callHackageDirect {
            pkg = "implicit-hie-cradle";
            ver = "0.3.0.5";
            sha256 = "15a7g9x6cjk2b92hb2wilxx4550msxp1pmk5a2shiva821qaxnfq";
          } {};

          lsp = self.callHackageDirect {
            pkg = "lsp";
            ver = "1.2.0.1";
            sha256 = "1lhzsraiw11ldxvxn8ax11hswpyzsvw2da2qmp3p6fc9rfpz4pj5";
          } {};

          lsp-test = self.callHackageDirect {
            pkg = "lsp-test";
            ver = "0.14.0.1";
            sha256 = "10lnyg7nlbd3ymgvjjlrkfndyy7ay9cwnsk684p08k2gzlric4yq";
          } {};

          lsp-types = self.callHackageDirect {
            pkg = "lsp-types";
            ver = "1.3.0.1";
            sha256 = "19k28zf1vw60wqfxllcs7zk9j6lnkx5kkvjnh22vkvn6m9zzflyw";
          } {};

          monad-dijkstra = self.callHackageDirect {
            pkg = "monad-dijkstra";
            ver = "0.1.1.3";
            sha256 = "0b8yj2p6f0h210hmp9pnk42jzrrhc4apa0d5a6hpa31g66jxigy8";
          } {};

          optparse-applicative = self.callHackageDirect {
            pkg = "optparse-applicative";
            ver = "0.15.1.0";
            sha256 = "1mii408cscjvids2xqdcy2p18dvanb0qc0q1bi7234r23wz60ajk";
          } {};

          refinery = self.callHackageDirect {
            pkg = "refinery";
            ver = "0.4.0.0";
            sha256 = "1ic7qvfizh5av3b3hp8db08v6b0hmac20smyhbaqzwvfpdgnjq71";
          } {};

          retrie = self.callHackageDirect {
            pkg = "retrie";
            ver = "0.1.1.1";
            sha256 = "0gnp6j35jnk1gcglrymvvn13sawir0610vh0z8ya6599kyddmw7l";
          } {};

          ansi-terminal = self.callHackageDirect {
            pkg = "ansi-terminal";
            ver = "0.10.3";
            sha256 = "1aa8lh7pl054kz7i59iym49s8w473nhdqgc3pq16cp5v4358hw5k";
          } {};

          stylish-haskell = self.callHackageDirect {
            pkg = "stylish-haskell";
            ver = "0.12.2.0";
            sha256 = "1ck8i550rvzbvzrm7dvgir73slai8zmvfppg3n5v4igi7y3jy0mr";
          } {};

          apply-refact = self.callHackageDirect {
            pkg = "apply-refact";
            ver = "0.9.3.0";
            sha256 = "1jfq1aw91finlpq5nn7a96za4c8j13jk6jmx2867fildxwrik2qj";
          } {};

          ghc-source-gen = self.callHackageDirect {
            pkg = "ghc-source-gen";
            ver = "0.4.2.0";
            sha256 = "1bsmvbjjnhfyc4axdx4rcksbdxv3sc4bskzfjr15r26p77rayram";
          } {};

          hlint = self.callHackageDirect {
            pkg = "hlint";
            ver = "3.2.7";
            sha256 = "1w3f0140c347kjhk6sbjh28p4gf4f1nrzp4rn589j3dkcb672l43";
          } {};

          ghc-lib = self.callHackageDirect {
            pkg = "ghc-lib";
            ver = "8.10.7.20210828";
            sha256 = "0gfsxck155nx97jsnzqskagmnwb8sx09h0k0vknbnsmipmmlm0s7";
          } {};

          ghc-lib-parser = self.callHackageDirect {
            pkg = "ghc-lib-parser";
            ver = "8.10.7.20210828";
            sha256 = "0whpn8j63g6gfmmp9yz630zzqmabjm3k7m2zp1yzby8fywib4p1l";
          } {};

          prettyprinter = self.callHackageDirect {
            pkg = "prettyprinter";
            ver = "1.7.1";
            sha256 = "0ddf0wb06sqipklh00ah3wazy37g8hnnm99n8g96xmwbhakmpaz2";
          } {};

          # TODO enable this when all formatters support ghc-lib > 9
          # ghc-lib = self.callHackageDirect {
          #   pkg = "ghc-lib";
          #   ver = "9.0.1.20210324";
          #   sha256 = "0iv3y2gs6x5jgyybkb6h7p5z6qvhz7mjjcfxblnss89c96nlrdmm";
          # } {};

          # ghc-lib-parser = self.callHackageDirect {
          #   pkg = "ghc-lib-parser";
          #   ver = "9.0.1.20210324";
          #   sha256 = "0kf45jnp62lwfv585c5rfpxw7ywbz92ivxx7h53nxqa1dw5di7qp";
          # } {};

          # ghc-lib-parser-ex = self.callHackageDirect {
          #   pkg = "ghc-lib-parser-ex";
          #   ver = "9.0.0.4";
          #   sha256 = "0kf45jnp62lwfv585c5rfpxw7ywbz92ivxx7h53nxqa1dw5di7qa";
          # } {};

          # hlint = self.callHackageDirect {
          #   pkg = "hlint";
          #   ver = "3.3";
          #   sha256 = "0kf45jnp62lwfv585c5rfpxw7ywbz92ivxx7h53nxqa1dw5di7qb";
          # } {};

        };
    };
in
{
  inherit (hpkgs) haskell-language-server;
}
