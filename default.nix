let
  defaultNixpkgs = fetchTarball {
    # a recent-ish SHA from the release-19.09 branch. (Apr 14, 2020)
    url = "https://github.com/NixOS/nixpkgs/archive/ee95a68c5ef0b4c2843754581688e54bc1bee0e5.tar.gz";
    sha256 = "160raids1zlawmi0v7rmhai54gidfc1kdqj0zcqqzpcc9darnlmi";
  };

in
{ ghc ? "ghc865"
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

  disableOptionalHaskellBuildSteps = super: args: super.mkDerivation (args // {
    doCheck = false;
    doBenchmark = false;
    doHoogle = false;
    doHaddock = false;
    enableLibraryProfiling = false;
    enableExecutableProfiling = false;
  });


  hpkgs = pkgs.haskell.packages.${ghc}.override
    {
      overrides = self: super:
        let
          hls-src = pkgs.fetchFromGitHub {
            owner  = "haskell";
            repo   = "haskell-language-server";
            rev    = "5570da98ac51cdd71a7b82b7c3538d2f892332c6";
            sha256 = "1znij5l9f5k9jskj6f8vmbxsqmp861pc6w825nbjif7gz27izc7g";
          };

          ghcide-src = pkgs.fetchFromGitHub {
            owner  = "digital-asset";
            repo   = "ghcide";
            rev    = "74311d255cc4a804de6ec69e6db4c13851c108f1";
            sha256 = "0dcv3rk4knks104h6vpjyfh73d1aplh30p05kfhhv06v39zqg5d8";
          };

        in
        {
          mkDerivation = disableOptionalHaskellBuildSteps super;

          haskell-language-server = hlib.justStaticExecutables (self.callCabal2nix "haskell-language-server" hls-src {});

          ghcide = self.callCabal2nix "ghcide" ghcide-src {};

          ormolu = self.callHackageDirect {
            pkg = "ormolu";
            ver = "0.0.3.1";
            sha256 = "0q1g3j8naw4xzn2m35cbf4vbi1077ys0dada5q0bvw8xvzhfb0xm";
          } {};

          ghc-check = self.callHackageDirect {
            pkg = "ghc-check";
            ver = "0.1.0.3";
            sha256 = "038llbvryk5y27jbdpbshp0zw5lw1j6m7qk7vx1n96ykqdzkh649";
          } {};

          ghc-lib-parser = self.callHackageDirect {
            pkg = "ghc-lib-parser";
            ver = "8.8.2";
            sha256 = "08gb6v5316m4xy1kclzbkr6bqrlg2lh0kplzg5lzsdx93bwcjyz8";
          } {};

          haddock-library = self.callHackageDirect {
            pkg = "haddock-library";
            ver = "1.9.0";
            sha256 = "12nr4qzas6fzn5p4ka27m5gs2rym0bgbfrym34yp0cd6rw9zdcl3";
          } {};

          haskell-lsp = self.callHackageDirect {
            pkg = "haskell-lsp";
            ver = "0.21.0.0";
            sha256 = "1j6nvaxppr3wly2cprv556yxr220qw1ghd3ac139iw16ihfjvz8a";
          } {};

          haskell-lsp-types = self.callHackageDirect {
            pkg = "haskell-lsp-types";
            ver = "0.21.0.0";
            sha256 = "0vq7v6k9szmwxh2haphgzb3c2xih6h5yyq57707ncg0ha75bhlll";
          } {};

          regex-tdfa = self.callHackageDirect {
            pkg = "regex-tdfa";
            ver = "1.3.1.0";
            sha256 = "1a0l7kdjzp98smfp969mgkwrz60ph24xy0kh2dajnymnr8vd7b8g";
          } {};

          shake = self.callHackageDirect {
            pkg = "shake";
            ver = "0.18.5";
            sha256 = "0p9gb2px0k3jcdqgb8d7gdfh9swj1vchcs70r6sp5zkwrzzxlcaf";
          } {};

          regex-base = self.callHackageDirect {
            pkg = "regex-base";
            ver = "0.94.0.0";
            sha256 = "0x2ip8kn3sv599r7yc9dmdx7hgh5x632m45ga99ib5rnbn6kvn8x";
          } {};

          hie-bios = self.callHackageDirect {
            pkg = "hie-bios";
            ver = "0.4.0";
            sha256 = "19lpg9ymd9656cy17vna8wr1hvzfal94gpm2d3xpnw1d5qr37z7x";
          } {};

          cabal-helper = self.callHackageDirect {
            pkg = "cabal-helper";
            ver = "1.0.0.0";
            sha256 = "1av9vh1szhhnmjysv488padj0gm462yii8brs2kndj90a7fd40yv";
          } {};

          temporary = self.callHackageDirect {
            pkg = "temporary";
            ver = "1.2.1";
            sha256 = "1whv9yahq0gvfwl6i7rg156nrpv297rxsicz9cwmp959v599rbwr";
          } {};

          clock = self.callHackageDirect {
            pkg = "clock";
            ver = "0.7.2";
            sha256 = "167m4qrwfmrpv9q9hsiy8jsi5dmx9r2djivrp2q4cpwp251ckccl";
          } {};

        };
    };
in
{
  inherit hpkgs;
  inherit pkgs;
}
