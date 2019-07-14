let
    pkgsSrc = fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/8c09536ef10e72c9421c05403c68134480ba7fde.tar.gz";
        sha256 = "1kf8dl583lbabw93lpc4m5f62pqsip870d8n8hgw06s8898l7mkp";
    };
    rakudo-nix = fetchTarball {
        url = "https://github.com/chloekek/rakudo-nix/archive/2019.03.tar.gz";
        sha256 = "0f48rvl4sy1p464fkkxmzz9hwgzym3yg1hfzmm2bqx2qg063ipkh";
    };
    pkgs = import pkgsSrc {
        config = {
            packageOverrides = import rakudo-nix;
        };
    };
in
    pkgs.callPackage ./sixty.nix {}
