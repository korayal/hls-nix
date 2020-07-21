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
            rev    = "0c99ce0411ed7bc3d43aa8a29c75f1e1fd9ee2bd";
            sha256 = "04859l7vw1a5w0blx5b93w6gg8njzbxwv4x7am2dlbjgqd3gv5pi";
          };

          ghcide-src = pkgs.fetchFromGitHub {
            owner  = "bubba";
            repo   = "ghcide";
            rev    = "7e895cfa53260b41996df707baec496a8f2c75dc";
            sha256 = "1kj2i86mkaxgxlrbmv2d24mch7hywgcy2n61z8paj21chncs1j5w";
          };

          brittany-src = pkgs.fetchFromGitHub {
            owner  = "lspitzner";
            repo   = "brittany";
            rev    = "231c2f5e94b2d242de9990f11673e466418a445c";
            sha256 = "1r5hv20cmw03fvg5m17315vsmrxd2n47amz4w611rfd6aczjafjp";
          };

          cabal-plan-src = pkgs.fetchFromGitHub {
            owner  = "peti";
            repo   = "cabal-plan";
            rev    = "894b76c0b6bf8f7d2f881431df1f13959a8fce87";
            sha256 = "06iklj51d9kh9bhc42lrayypcpgkjrjvna59w920ln41rskhjr4y";
          };

        in
        {
          mkDerivation = disableOptionalHaskellBuildSteps super;

          haskell-language-server = hlib.justStaticExecutables (self.callCabal2nix "haskell-language-server" hls-src {});

          ghcide = self.callCabal2nix "ghcide" ghcide-src {};

          brittany = self.callCabal2nix "brittany" brittany-src {};

          floskell = self.callHackageDirect {
            pkg = "floskell";
            ver = "0.10.3";
            sha256 = "0fqyz16m4097hm3s2acgzn8623ijvfl80id9ghhq68859dsjdz91";
          } {};

          cabal-helper = self.callHackageDirect {
            pkg = "cabal-helper";
            ver = "1.1.0.0";
            sha256 = "1jgsffr7p34lz5y9psvqx8ihyf1rgv6r1ckm0n7i273b06b133ks";
          } {};

          cabal-plan = self.callCabal2nix "cabal-plan" cabal-plan-src {};

          Cabal = self.callHackageDirect {
            pkg = "Cabal";
            ver = "3.0.2.0";
            sha256 = "0w03j3a5ma8li3hrn9xp49pmh9r4whxidm71x9c37x5p6igzihms";
          } {};

          hie-bios = self.callHackageDirect {
            pkg = "hie-bios";
            ver = "0.6.1";
            sha256 = "0yw8yqy1bm7k8n9n2h4jm0kvndbq6mv8snlf7iy2c977cb35nr1l";
          } {};

          ormolu = self.callHackageDirect {
            pkg = "ormolu";
            ver = "0.1.2.0";
            sha256 = "0ik09adifvj6pvqnak8a60plpmdma4h1l3vf82sz5mbzaf1zw4jx";
          } {};

          ghc-check = self.callHackageDirect {
            pkg = "ghc-check";
            ver = "0.5.0.1";
            sha256 = "1zlbss7h6infzhhpilvkpk50gxypkb2li8fspi69jlll5l7wqi3d";
          } {};

          ghc-lib-parser = self.callHackageDirect {
            pkg = "ghc-lib-parser";
            ver = "8.10.1.20200523";
            sha256 = "1fnhqb9l0cg58lalrrn4ms48rnnzlyb7dqa9h2g21m9287q5y6gs";
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

          haddock-api = self.callHackageDirect {
            pkg = "haddock-api";
            ver = "2.22.0@rev:1";
            sha256 = "12nr4qzas6fzn5p4ka27m5gs2rym0bgbfrym34yp0cd6rw9zdcla";
          } {};

          lens = self.callHackageDirect {
            pkg = "lens";
            ver = "4.18";
            sha256 = "1cksr4y687vp81aw8p467ymmmywfprhzq6127gzkdhwl4jcwdybk";
          } {};

          type-equality = self.callHackageDirect {
            pkg = "type-equality";
            ver = "1";
            sha256 = "0bcnl9cmk080glwfba7fhdvijj1iyw6w12hjm2sy06l0h9l0if1p";
          } {};

          haskell-lsp = self.callHackageDirect {
            pkg = "haskell-lsp";
            ver = "0.22.0.0";
            sha256 = "1q3w46qcvzraxgmw75s7bl0qvb2fvff242r5vfx95sqska566b4m";
          } {};

          happy = self.callHackageDirect {
            pkg = "happy";
            ver = "1.19.12";
            sha256 = "0n1ri85hf1h9q5pwvfnddc79ahr9bk7hz8kirzrlyb81qzc3lpc9";
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
            ver = "1.7.3";
            sha256 = "08j4gg2n5cl7ycr943hmyfimgby0xhf5vp8nwrwflg6lrn1s388c";
          } {};

          opentelemetry = self.callHackageDirect {
            pkg = "opentelemetry";
            ver = "0.4.2";
            sha256 = "1cclr4l7s6jmf31vkp1ypzbjm4i77mn7vfvy67w3r2nfda5silkw";
          } {};

          butcher = self.callHackageDirect {
            pkg = "butcher";
            ver = "1.3.3.2";
            sha256 = "08lj4yy6951rjg3kr8613mrdk6pcwaidcx8pg9dvl4vpaswlpjib";
          } {};

          semialign = self.callHackageDirect {
            pkg = "semialign";
            ver = "1.1";
            sha256 = "01wj9sv44y95zvidclvl3qkxrg777n46f1qxwnzq0mw2a9mi6frz";
          } {};

          ansi-terminal = self.callHackageDirect {
            pkg = "ansi-terminal";
            ver = "0.10.3";
            sha256 = "1aa8lh7pl054kz7i59iym49s8w473nhdqgc3pq16cp5v4358hw5k";
          } {};

          base-compat = self.callHackageDirect {
            pkg = "base-compat";
            ver = "0.11.0";
            sha256 = "0dd9f7g5sn0nf2z8slrp113qdq368jrzsxqmhn54rf3bp37x74wd";
          } {};

          indexed-profunctors = self.callHackageDirect {
            pkg = "indexed-profunctors";
            ver = "0.1";
            sha256 = "0vpgbymfhnvip90jwvyniqi34lhz5n3ni1f21g81n5rap0q140za";
          } {};

          optics-core = self.callHackageDirect {
            pkg = "optics-core";
            ver = "0.2";
            sha256 = "0ipshb2yrqwzj1prf08acwpfq2lhcrawnanwpzbpggdhabrfga2h";
          } {};

          optparse-applicative = self.callHackageDirect {
            pkg = "optparse-applicative";
            ver = "0.15.1.0";
            sha256 = "1mii408cscjvids2xqdcy2p18dvanb0qc0q1bi7234r23wz60ajk";
          } {};

          aeson = self.callHackageDirect {
            pkg = "aeson";
            ver = "1.4.6.0";
            sha256 = "05rj0fv5y65dk17v24p3qypvrakkhdj41vrxnyk4wimgaw2g5lq4";
          } {};

          aeson-pretty = self.callHackageDirect {
            pkg = "aeson-pretty";
            ver = "0.8.8";
            sha256 = "1414yr5hpm9l1ya69864zrrd40sa513k7j67dkydrwmfldrbl7lv";
          } {};

          topograph = self.callHackageDirect {
            pkg = "topograph";
            ver = "1.0.0.1";
            sha256 = "1q7gn0x3hrmxpgk5rwc9pmidr2nlxs8zaiza55k6paxd7lnjyh4m";
          } {};

          stylish-haskell = self.callHackageDirect {
            pkg = "stylish-haskell";
            ver = "0.11.0.0";
            sha256 = "1a6jijj1lxmi20m9ddiwlnlf3x6qy3dw4si1pvfk9rpjv9azcydk";
          } {};

          HsYAML = self.callHackageDirect {
            pkg = "HsYAML";
            ver = "0.2.1.0";
            sha256 = "0r2034sw633npz7d2i4brljb5q1aham7kjz6r6vfxx8qqb23dwnc";
          } {};

          HsYAML-aeson = self.callHackageDirect {
            pkg = "HsYAML-aeson";
            ver = "0.2.0.0";
            sha256 = "0zgcp93y93h7rsg9dv202hf3l6sqr95iadd67lmfclb0npfs640m";
          } {};

          lsp-test = self.callHackageDirect {
            pkg = "lsp-test";
            ver = "0.11.0.2";
            sha256 = "1jwvalwj3jblw32zig7d7d3251c6a3k3c2npvkypaslk3w2r8cq8";
          } {};

          shake = self.callHackageDirect {
            pkg = "shake";
            ver = "0.19.1";
            sha256 = "14myzmdywbcwgx03f454ymf5zjirs7wj1bcnhhsf0w1ck122y8q3";
          } {};

          parser-combinators = self.callHackageDirect {
            pkg = "parser-combinators";
            ver = "1.2.1";
            sha256 = "1990d6c1zm2wq4w9521bx7l3arg4ly02hq1ass9n19gs273bxx5h";
          } {};

        };
    };
in
{
  inherit hpkgs;
  inherit pkgs;
}
