{
  lib,
  stdenv,
  fetchurl,
  cpio,
}:

stdenv.mkDerivation {
  pname = "gosset";
  version = "284";

  src = fetchurl {
    urls = [
      "https://neilsloane.com/gosset/codemart.cpio"
      "https://github.com/brubsby/gosset/releases/download/v${version}/codemart.cpio"
    ];
    sha256 = "0g6ayla8xi50i2x7k2q5n3m6crwfg6rj7y8z5cz1mdyndj4nf6rr";
  };

  patches = [ ./fix-compilation.patch ];

  nativeBuildInputs = [ cpio ];

  unpackPhase = ''
    runHook preUnpack
    mkdir source
    cd source
    cpio -id < $src
    sourceRoot=.
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild
    $CC -std=gnu89 -fpermissive -w -DGOSSETSRC="\"$out/share/gosset\"" main.c -o gosset -lm
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 gosset $out/bin/gosset

    mkdir -p $out/share/gosset
    cp *.a help.file help.sh $out/share/gosset/

    # Gosset expects to find files in the current working directory or specific paths.
    # We might need to wrap it or patch it to look in $out/share/gosset.
    # For now, we install the binaries and data.
    runHook postInstall
  '';

  meta = {
    description = "General-purpose program for constructing experimental designs";
    homepage = "https://neilsloane.com/gosset/";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ brubsby ];
    platforms = lib.platforms.linux;
    mainProgram = "gosset";
  };
}
