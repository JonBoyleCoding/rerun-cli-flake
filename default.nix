{ lib
, binaryen
, cargo-binutils
, fetchFromGitHub
, pkg-config
, protobuf
, libxkbcommon
, vulkan-loader
, stdenv
, darwin
, wayland
, xorg
, autoPatchelfHook
, craneLib
, makeWrapper
}:

craneLib.buildPackage rec {
  pname = "rerun-cli";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "rerun-io";
    repo = "rerun";
    rev = version;
    hash = "sha256-HgzzuvCpzKgWC8it0PSq62hBjjqpdgYtQQ50SNbr3do=";
  };

	strictDeps = true;
	cargoExtraArgs = "-p rerun-cli";
	doCheck = false;

  nativeBuildInputs = [
    pkg-config
    protobuf
	binaryen
	autoPatchelfHook
	makeWrapper
  ];

  linux-libs = if stdenv.isLinux then with xorg; [
	  libX11 libXext libXrender libXtst
		  libXi libXrandr libXcursor libXinerama
		  libXcomposite libXdamage libXfixes libXxf86vm
		  libXxf86dga libXmu libXpm libXaw
		  libXft libXfont2 libXv libXScrnSaver
		  libXpresent libXres libXvMC libXxf86dga
		  libXxf86vm libXxf86misc
  ] else [];

  buildInputs = [
    libxkbcommon
    vulkan-loader
	cargo-binutils
	autoPatchelfHook
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreGraphics
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.Foundation
    darwin.apple_sdk.frameworks.IOKit
    darwin.apple_sdk.frameworks.Metal
    darwin.apple_sdk.frameworks.QuartzCore
    darwin.apple_sdk.frameworks.Security
  ] ++ lib.optionals stdenv.isLinux [
    wayland
  ] ++ linux-libs;

  cargoArtifacts = craneLib.buildDepsOnly {
	  inherit src buildInputs strictDeps pname;
  };

  postInstall = ''
	wrapProgram $out/bin/rerun --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"
  '';

  meta = with lib; {
    description = "Visualize streams of multimodal data. Fast, easy to use, and simple to integrate.  Built in Rust using egui";
    homepage = "https://github.com/rerun-io/rerun";
    changelog = "https://github.com/rerun-io/rerun/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ ];
    mainProgram = "rerun-cli";
  };
}
