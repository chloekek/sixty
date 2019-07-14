{stdenv, makeWrapper, perl, rakudo}:
stdenv.mkDerivation {
    name = "sixty";
    src = stdenv.lib.cleanSource ./..;
    buildInputs = [makeWrapper rakudo];
    phases = ["unpackPhase" "installPhase"];
    installPhase = ''
        mkdir --parents $out/bin $out/share/doc

        cp --recursive bin lib t $out/share

        makeWrapper \
            ${rakudo}/bin/perl6 \
            $out/bin/sixty.example \
            --prefix PERL6LIB , $out/share/lib \
            --add-flags $out/share/bin/example

        makeWrapper \
            ${perl}/bin/prove \
            $out/bin/sixty.test \
            --prefix PERL6LIB , $out/share/lib \
            --add-flags --exec \
            --add-flags ${rakudo}/bin/perl6 \
            --add-flags --recurse \
            --add-flags $out/share/t
    '';
}
