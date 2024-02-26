{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		flake-utils.url = "github:numtide/flake-utils";

		fenix = {
			url = "github:nix-community/fenix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		crane = {
			url = "github:ipetkov/crane";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = {self, nixpkgs, flake-utils, fenix, crane, ...}:
		flake-utils.lib.eachDefaultSystem (system:
			let
				pkgs = import nixpkgs {
					system = system;
				};

				fnx = fenix.packages.${system};

				toolchain = (with fnx; with stable; combine [
					rustc
					cargo
					llvm-tools-preview
					targets.wasm32-unknown-unknown.stable.rust-std
				]);

				craneLib = (crane.mkLib pkgs).overrideToolchain toolchain;


				#fenix.packages.${system}.stable.withComponents [
				#	"cargo"
				#	"rustc"
				#	"llvm-tools-preview"
				#];

				rust_platform = pkgs.makeRustPlatform {
					rustc = toolchain;
					cargo = toolchain;
				};

				rerun_cli = pkgs.callPackage ./default.nix { inherit craneLib;};

			in {
				packages.default = rerun_cli;
			});



}
