{stdenv, fetchFromGitHub
, callPackage
, ninja, meson , pkgconfig
, libusb, readline, libewf, perl, zlib, openssl
, gtk2 ? null, vte ? null, gtkdialog ? null
, python ? null
, ruby ? null
, lua ? null
, useX11, rubyBindings, pythonBindings, luaBindings
}:

assert useX11 -> (gtk2 != null && vte != null && gtkdialog != null);
assert rubyBindings -> ruby != null;
assert pythonBindings -> python != null;


let
  inherit (stdenv.lib) optional;

  generic = {
    version_commit,
    gittap,
    gittip,
    rev,
    version,
    sha256,
    cs_tip,
    cs_sha256
  }:
    stdenv.mkDerivation rec {
      name = "radare2-${version}";

      src = fetchFromGitHub {
        owner = "radare";
        repo = "radare2";
        inherit rev sha256;
      };

      postPatch = let
        capstone = fetchFromGitHub {
          owner = "aquynh";
          repo = "capstone";
          # version from $sourceRoot/shlr/Makefile
          rev = cs_tip;
          sha256 = cs_sha256;
        };
      in ''
        if ! grep -F "CS_TIP=${cs_tip}" shlr/Makefile; then echo "CS_TIP mismatch"; exit 1; fi
        # When using meson, it expects capstone source relative to build directory
        mkdir -p build/shlr
        ln -s ${capstone} build/shlr/capstone
      '';

      postInstall = ''
        ln -s $out/bin/radare2 $out/bin/r2
        install -D -m755 $src/binr/r2pm/r2pm $out/bin/r2pm
      '';

      mesonFlags = [
        "-Dr2_version_commit=${version_commit}"
        "-Dr2_gittap=${gittap}"
        "-Dr2_gittip=${gittip}"
        # 2.8.0 expects this, but later it becomes an option with default=false.
        "-Dcapstone_in_builddir=true"
      ];

      enableParallelBuilding = true;

      nativeBuildInputs = [ pkgconfig ninja meson ];
      buildInputs = [ readline libusb libewf perl zlib openssl]
        ++ optional useX11 [gtkdialog vte gtk2]
        ++ optional rubyBindings [ruby]
        ++ optional pythonBindings [python]
        ++ optional luaBindings [lua];

      meta = {
        description = "unix-like reverse engineering framework and commandline tools";
        homepage = http://radare.org/;
        license = stdenv.lib.licenses.gpl2Plus;
        maintainers = with stdenv.lib.maintainers; [raskin makefu mic92];
        platforms = with stdenv.lib.platforms; linux;
        inherit version;
      };
  };
in {
  #<generated>
  # DO NOT EDIT! Automatically generated by ./update.py
  radare2 = generic {
    version_commit = "19349";
    gittap = "2.9.0";
    gittip = "d5e9539ec8068ca2ab4759dc3b0697781ded4cc8";
    rev = "2.9.0";
    version = "2.9.0";
    sha256 = "0zz6337p9095picfvjrcnqaxdi2a2b68h9my523ilnw8ynwfhdzw";
    cs_tip = "782ea67e17a391ca0d3faafdc365b335a1a8930a";
    cs_sha256 = "1maww4ir78a193pm3f8lr2kdkizi7rywn68ffa65ipyr7j4pl6i4";
  };
  r2-for-cutter = generic {
    version_commit = "19251";
    gittap = "2.8.0-118-gb0547831f";
    gittip = "b0547831f127b7357e3c93bc43933482a4d6213b";
    rev = "b0547831f127b7357e3c93bc43933482a4d6213b";
    version = "2018-08-07";
    sha256 = "1ix42kipd1aayb494ajbxawzc1cwikm9fxk343d1kchxx4a30a1m";
    cs_tip = "782ea67e17a391ca0d3faafdc365b335a1a8930a";
    cs_sha256 = "1maww4ir78a193pm3f8lr2kdkizi7rywn68ffa65ipyr7j4pl6i4";
  };
  #</generated>
}
