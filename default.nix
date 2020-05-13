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
            rev    = "7edbf671f82d8004427c766d3976ff4fbc96acf9";
            sha256 = "068r47ssr7xln3psd878p7ffzck1lmhsicimpsmkx0i21dfdfiaq";
          };

          ghcide-src = pkgs.fetchFromGitHub {
            owner  = "digital-asset";
            repo   = "ghcide";
            rev    = "5ca6556996543312e718559eab665fe3b1926b03";
            sha256 = "1sni15wbj9jmrvhsfv31c0j587xhcfqkc0qg9pmlhf9zw4kgpghd";
          };

          shake-src = pkgs.fetchFromGitHub {
            owner  = "wz1000";
            repo   = "shake";
            rev    = "fb3859dca2e54d1bbb2c873e68ed225fa179fbef";
            sha256 = "0sa0jiwgyvjsmjwpfcpvzg2p7277aa0dgra1mm6afh2rfnjphz8z";
          };

          cabal-helper-src = pkgs.fetchFromGitHub {
            owner  = "DanielG";
            repo   = "cabal-helper";
            rev    = "5b85a4b9e1c6463c94ffa595893ad02c9a3d2ec3";
            sha256 = "1clra3gvhppack5w5kgllhcrfhcs4h21mk7w71pn17332smv4j0i";
          };

          brittany-src = pkgs.fetchFromGitHub {
            owner  = "lspitzner";
            repo   = "brittany";
            rev    = "231c2f5e94b2d242de9990f11673e466418a445c";
            sha256 = "1r5hv20cmw03fvg5m17315vsmrxd2n47amz4w611rfd6aczjafjp";
          };

        in
        {
          mkDerivation = disableOptionalHaskellBuildSteps super;

          haskell-language-server = hlib.justStaticExecutables (self.callCabal2nix "haskell-language-server" hls-src {});

          brittany = self.callCabal2nix "brittany" brittany-src {};

          ghcide = self.callCabal2nix "ghcide" ghcide-src {};

          shake = self.callCabal2nix "shake" shake-src {};

          cabal-helper = self.callCabal2nix "cabal-helper" cabal-helper-src {};

          hie-bios = self.callHackageDirect {
            pkg = "hie-bios";
            ver = "0.5.0";
            sha256 = "116nmpva5jmlgc2dgy8cm5wv6cinhzmga1l0432p305074w720r2";
          } {};

          ormolu = self.callHackageDirect {
            pkg = "ormolu";
            ver = "0.0.5.0";
            sha256 = "09zc5mra3n2kkbvvwvh7y0dh3fbs74i170xy66j90ndagqnfs16g";
          } {};

          ghc-check = self.callHackageDirect {
            pkg = "ghc-check";
            ver = "0.3.0.1";
            sha256 = "1dj909m09m24315x51vxvcl28936ahsw4mavbc53danif3wy09ns";
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
            ver = "1.7.1";
            sha256 = "0n23dhsfjjdmprgmdsrrma8q8ys0zc4ab5vhzmiy2f9gkm0jg0pq";
          } {};

          opentelemetry = self.callHackageDirect {
            pkg = "opentelemetry";
            ver = "0.4.0";
            sha256 = "1lzm1bmis835digmrm3ipgh5zhn99dbkcfp5daqcf8lzr9hg075p";
          } {};

          butcher = self.callHackageDirect {
            pkg = "butcher";
            ver = "1.3.3.1";
            sha256 = "072gw6rd698i03ii9ib77f2b4vf9c9d51lagz6yh6qahj1z6bfi0";
          } {};

          semialign = self.callHackageDirect {
            pkg = "semialign";
            ver = "1.1";
            sha256 = "190yklzcdhyk5drg1vfgjs96c7qvw9p7s8ian5lhgqbnyy2n041d";
          } {};

        };
    };
in
{
  inherit hpkgs;
  inherit pkgs;
}
