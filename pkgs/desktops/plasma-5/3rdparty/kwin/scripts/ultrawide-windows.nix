{ lib, mkDerivation, fetchFromGitHub,
  plasma-framework, kwindowsystem }:

mkDerivation rec {
  name = "kwin-ultrawide-windows";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "lucmos";
    repo = "UltrawideWindows";
    rev = "10bc8d02178503302070dd884e1e01d5390046f4";
    sha256 = "0dfmblp4dz0nr665qmilywgvwxy3ppv7xrr43hznph12ffnz9r13";
  };

  buildInputs = [
    plasma-framework kwindowsystem
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    plasmapkg2 --type kwinscript --install ${src} --packageroot $out/share/kwin/scripts
    install -Dm644 ${src}/metadata.desktop $out/share/kservices5/ultrawide-windows.desktop

    runHook postInstall
  '';

  meta = with lib; {
    description = "Tiling script for kwin";
    license = licenses.gpl2;
    maintainers = with maintainers; [ peterhoeg ];
    inherit (src.meta) homepage;
    inherit (kwindowsystem.meta) platforms;
  };
}
