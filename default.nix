let
  defaultNixpkgs = fetchTarball {
    # a recent-ish SHA from the release-19.09 branch. (Apr 14, 2020)
    url = "https://github.com/NixOS/nixpkgs/archive/ee95a68c5ef0b4c2843754581688e54bc1bee0e5.tar.gz";
    sha256 = "160raids1zlawmi0v7rmhai54gidfc1kdqj0zcqqzpcc9darnlmi";
  };

in
{ ghc ? "ghc865"
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
            rev    = "61c69fd387281c2222f75f13542eaa2e91cbc1b1";
            sha256 = "17l4mgs8hpaa133j8444zlzzxd9nlw3cr4a6i5440d59wk3ipkmd";
          };

          ghcide-src = pkgs.fetchFromGitHub {
            owner  = "haskell";
            repo   = "ghcide";
            rev    = "9b8aaf9b06846571cc0b5d46680e686e4f9153a3";
            sha256 = "0clwg8fgnsgwzl6rbni7p6xifl117f6h5hjsdyy0swnbjkxkqpaa";
          };


          brittany-src = if agpl then pkgs.fetchFromGitHub {
            owner  = "bubba";
            repo   = "brittany";
            rev    = "c59655f10d5ad295c2481537fc8abf0a297d9d1c";
            sha256 = "1rkk09f8750qykrmkqfqbh44dbx1p8aq1caznxxlw8zqfvx39cxl";
          } else null;

          HsYAML-aeson-src = pkgs.fetchFromGitHub {
            owner  = "hvr";
            repo   = "HsYAML-aeson";
            rev    = "6a6b02787c881f20327061566f7ae263926b7245";
            sha256 = "1lrxnsjfrrg7w2symxl04jvzqcsym4spcbi99f1sc52g3cl82sfz";
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

          hie-compat = self.callCabal2nix "hie-compat" "${ghcide-src}/hie-compat" {};
          hls-plugin-api = self.callCabal2nix "hls-plugin-api" "${hls-src}/hls-plugin-api" {};
          hls-tactics-plugin = self.callCabal2nix "tactics" "${hls-src}/plugins/tactics" {};
          hls-hlint-plugin = self.callCabal2nix "hls-hlint-plugin" "${hls-src}/plugins/hls-hlint-plugin" {};

          haskell-language-server = hlib.justStaticExecutables (self.callCabal2nix "haskell-language-server" hls-src {});

          ghcide = self.callCabal2nix "ghcide" ghcide-src {};

          brittany = if agpl then self.callCabal2nix "brittany" brittany-src {} else null;

          HsYAML-aeson = self.callCabal2nix "HsYAML-aeson" HsYAML-aeson-src {};

          floskell = self.callHackageDirect {
            pkg = "floskell";
            ver = "0.10.4";
            sha256 = "0n1gy6yf7lzzh9l67712rr7bjliyifi9xjnc6i9rppiv5adj2xyf";
          } {};

          fourmolu = self.callHackageDirect {
            pkg = "fourmolu";
            ver = "0.2.0.0";
            sha256 = "1dkv9n9m0wrpila8z3fq06p56c7af6avd9kv001s199b0ca7pwa6";
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
            ver = "0.7.1";
            sha256 = "137f1dy0fmlrzngwcmgnxghcih7f2rfq5bdnizbwy9534dn4dr42";
          } {};

          ormolu = self.callHackageDirect {
            pkg = "ormolu";
            ver = "0.1.3.0";
            sha256 = "0wmkqyavmhpxmrc794jda9x0gy6kmzlmv5waq1031xfgqxmki72y";
          } {};

          ghc-check = self.callHackageDirect {
            pkg = "ghc-check";
            ver = "0.5.0.1";
            sha256 = "1zlbss7h6infzhhpilvkpk50gxypkb2li8fspi69jlll5l7wqi3d";
          } {};

          ghc-lib = self.callHackageDirect {
            pkg = "ghc-lib";
            ver = "8.10.2.20200916";
            sha256 = "1gx0ijay9chachmd1fbb61md3zlvj24kk63fk3dssx8r9c2yp493";
          } {};

          ghc-lib-parser = self.callHackageDirect {
            pkg = "ghc-lib-parser";
            ver = "8.10.2.20200916";
            sha256 = "1apm9zn484sm6b8flbh6a2kqnv1wjan4l58b81cic5fc1jsqnyjk";
          } {};

          ghc-lib-parser-ex = self.callHackageDirect {
            pkg = "ghc-lib-parser-ex";
            ver = "8.10.0.16";
            sha256 = "0dp8plj708ss3im6rmp41kpj0df71kjzpw1kqkpn0dhms9yr1g0x";
          } {};

          ghc-source-gen = self.callHackageDirect {
            pkg = "ghc-source-gen";
            ver = "0.4.0.0";
            sha256 = "0b7h369h1wcdmm5bx5vp4is2k9biczz0d8711sibfzj70h0yvxmm";
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
            ver = "0.10.5";
            sha256 = "0fq38x47dlwz3j6bdrlfslscz83ccwsjrmqq6l7m005331yn7qc6";
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
            ver = "1.5.2.0";
            sha256 = "0rz7j7bcj5li2c5dmiv3pnmbs581vzkl9rbx9wq2v06f4knaklkf";
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
            ver = "0.12.2.0";
            sha256 = "1ck8i550rvzbvzrm7dvgir73slai8zmvfppg3n5v4igi7y3jy0mr";
          } {};

          HsYAML = self.callHackageDirect {
            pkg = "HsYAML";
            ver = "0.2.1.0";
            sha256 = "0r2034sw633npz7d2i4brljb5q1aham7kjz6r6vfxx8qqb23dwnc";
          } {};

          lsp-test = self.callHackageDirect {
            pkg = "lsp-test";
            ver = "0.11.0.6";
            sha256 = "19mbbkjpgpmkna26i4y1jvp305srv3kwa5b62x30rlb3rqf2vy5v";
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

          ghc-exactprint = self.callHackageDirect {
            pkg = "ghc-exactprint";
            ver = "0.6.3.2";
            sha256 = "0l9piqqgdi8xd46nj1jizp0r0v526d7f61y05xm8k4aamjaj59d0";
          } {};

          primitive = self.callHackageDirect {
            pkg = "primitive";
            ver = "0.7.1.0";
            sha256 = "1mmhfp95wqg6i5gzap4b4g87zgbj46nnpir56hqah97igsbvis7j";
          } {};

          retrie = self.callHackageDirect {
            pkg = "retrie";
            ver = "0.1.1.1";
            sha256 = "0gnp6j35jnk1gcglrymvvn13sawir0610vh0z8ya6599kyddmw7l";
          } {};

          these = self.callHackageDirect {
            pkg = "these";
            ver = "1.1.1.1";
            sha256 = "1i1nfh41vflvqxi8w8n2s35ymx2z9119dg5zmd2r23ya7vwvaka1";
          } {};

          yaml = self.callHackageDirect {
            pkg = "yaml";
            ver = "0.11.4.0";
            sha256 = "1qwc9n85plnx80rfips7kafp0flznazqwwazsidcf96fg6bzfndf";
          } {};

          refinery = self.callHackageDirect {
            pkg = "refinery";
            ver = "0.3.0.0";
            sha256 = "08s5pw6j3ncz96zfc2j0cna2zbf4vy7045d6jpzmq2sa161qnpgi";
          } {};

          implicit-hie-cradle = self.callHackageDirect {
            pkg = "implicit-hie-cradle";
            ver = "0.3.0.0";
            sha256 = "0fc1zh3wrq3hrbh8l06a0cjpnzd3x03rgla7s93c1cbqaal4imix";
          } {};

          implicit-hie = self.callHackageDirect {
            pkg = "implicit-hie";
            ver = "0.1.2.3";
            sha256 = "1f6dxcky15fjmvbar8pb7wnr8bmvvca9111igkf8v2ikz4494vdz";
          } {};

          apply-refact = self.callHackageDirect {
            pkg = "apply-refact";
            ver = "0.8.2.1";
            sha256 = "0nnprv5lbk7c8w1pa4kywk0cny6prjaml4vnw70s8v6c1r1dx2rx";
          } {};

          hlint = self.callHackageDirect {
            pkg = "hlint";
            ver = "3.2.1";
            sha256 = "01ycw48n7sdx1jfp37vy684jp5y380ry703bngldlw22k4mdk7xq";
          } {};

        };
    };
in
{
  inherit hpkgs;
  inherit pkgs;
}
