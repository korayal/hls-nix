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
            rev    = "6ddefac2a4e410c62b9652e1fb338bc34becad66";
            sha256 = "1n7iralxbgqljkjr45z2bfg20j44a5gzf5mh6xp45skip6bk5g7n";
          };

          ghcide-src = pkgs.fetchFromGitHub {
            owner  = "digital-asset";
            repo   = "ghcide";
            rev    = "174b17c0064d0fde72d1b0313572ad0c389ec263";
            sha256 = "10hzspsr36n6q7ha9pn6l70s7icz2zzi19g3vab7ng2izrv09sfi";
          };

          hie-bios-src = pkgs.fetchFromGitHub {
            owner  = "fendor";
            repo   = "hie-bios";
            rev    = "f0abff9c855ea7e6624617df669825f3f62f723b";
            sha256 = "0wakwnw5f7gmdjs9gjldvl9pxpp7ycj0agx9xplk5xrqzyic3d99";
          };

          shake-src = pkgs.fetchFromGitHub {
            owner  = "mpickering";
            repo   = "shake";
            rev    = "4d56fe9f09bd3bd63ead541c571c756995da490a";
            sha256 = "04jpgndny3h5cpm5hnk90h8wj3m1ap7d554cy0w42c2k2z0r2cvq";
          };

          cabal-helper-src = pkgs.fetchFromGitHub {
            owner  = "DanielG";
            repo   = "cabal-helper";
            rev    = "5b85a4b9e1c6463c94ffa595893ad02c9a3d2ec3";
            sha256 = "1clra3gvhppack5w5kgllhcrfhcs4h21mk7w71pn17332smv4j0i";
          };


        in
        {
          mkDerivation = disableOptionalHaskellBuildSteps super;

          haskell-language-server = hlib.justStaticExecutables (self.callCabal2nix "haskell-language-server" hls-src {});

          ghcide = self.callCabal2nix "ghcide" ghcide-src {};

          hie-bios = self.callCabal2nix "hie-bios" hie-bios-src {};

          shake = self.callCabal2nix "shake" shake-src {};

          cabal-helper = self.callCabal2nix "cabal-helper" cabal-helper-src {};

          ormolu = self.callHackageDirect {
            pkg = "ormolu";
            ver = "0.0.5.0";
            sha256 = "09zc5mra3n2kkbvvwvh7y0dh3fbs74i170xy66j90ndagqnfs16g";
          } {};

          ghc-check = self.callHackageDirect {
            pkg = "ghc-check";
            ver = "0.1.0.3";
            sha256 = "038llbvryk5y27jbdpbshp0zw5lw1j6m7qk7vx1n96ykqdzkh649";
          } {};

          ghc-lib-parser = self.callHackageDirect {
            pkg = "ghc-lib-parser";
            ver = "8.10.1.20200412";
            sha256 = "05adhjbvkgpx0bwzv1klc2a356d23zqdbj502iapqksirjkk6cqj";
          } {};

          ghc-parser-ex = self.callHackageDirect {
            pkg = "ghc-parser-ex";
            ver = "8.10.0.4";
            sha256 = "08gb6v5316m4xy1kclzbkr6bqrlg2lh0kplzg5lzsdx93bwcjyzb";
          } {};

          haddock-library = self.callHackageDirect {
            pkg = "haddock-library";
            ver = "1.9.0";
            sha256 = "12nr4qzas6fzn5p4ka27m5gs2rym0bgbfrym34yp0cd6rw9zdcl3";
          } {};

          haskell-lsp = self.callHackageDirect {
            pkg = "haskell-lsp";
            ver = "0.22.0.0";
            sha256 = "1q3w46qcvzraxgmw75s7bl0qvb2fvff242r5vfx95sqska566b4m";
          } {};

          haskell-lsp-types = self.callHackageDirect {
            pkg = "haskell-lsp-types";
            ver = "0.22.0.0";
            sha256 = "1apjclphi2v6ggrdnbc0azxbb1gkfj3x1vkwpc8qd6lsrbyaf0n8";
          } {};

          regex-tdfa = self.callHackageDirect {
            pkg = "regex-tdfa";
            ver = "1.3.1.0";
            sha256 = "1a0l7kdjzp98smfp969mgkwrz60ph24xy0kh2dajnymnr8vd7b8g";
          } {};

          regex-base = self.callHackageDirect {
            pkg = "regex-base";
            ver = "0.94.0.0";
            sha256 = "0x2ip8kn3sv599r7yc9dmdx7hgh5x632m45ga99ib5rnbn6kvn8x";
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

          extra = self.callHackageDirect {
            pkg = "extra";
            ver = "1.6.21";
            sha256 = "0x0k4gb0wmhy7q64mfm4wrcjhb2xg0l5bkk0q1jj0kgzyf8gvk67";
          } {};

          opentelemetry = self.callHackageDirect {
            pkg = "opentelemetry";
            ver = "0.3.0";
            sha256 = "190yklzcdhyk5drg1vfgjs96c7qvw9p7s8ian5lhgqbnyy2n041m";
          } {};

        };
    };
in
{
  inherit hpkgs;
  inherit pkgs;
}
