{
  description = "Rust Project Template.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust.url = "github:oxalica/rust-overlay";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, rust }:
    utils.lib.eachDefaultSystem
      (
        system:
        let
          project-name = "wwasm";
          rust-channel = "nightly";
          rust-version = "2023-03-19"; # 1.70.0
          rust-overlay = import rust;

          pkgs = import nixpkgs {
            inherit system;
            overlays = [ rust-overlay ];
          };

          rust-toolchain = pkgs.rust-bin."${rust-channel}"."${rust-version}".default.override {
            extensions = [
              "rust-std"
              "rust-src"
            ];
            targets = [ "wasm32-unknown-unknown" ];
          };

          # TODO: fix derivation build error
          # drv-build-error: [6] Couldn't resolve host name (Could not resolve host: index.crates.io)
          wasm32-build = pkgs.stdenv.mkDerivation {
            name = project-name;
            src = ./.;
            installPhase = ''
              cp -r $src $out
              cargo check
            '';
            buildPhase = ''
              wasm-pack build --target=no-modules
            '';
            # RUSTFLAGS="-C linker=lld";
            nativeBuildInputs = with pkgs; [
              rust-toolchain
              wasm-pack
              wasm-bindgen-cli              
            ];
            # Set Environment Variables
            RUST_BACKTRACE = 1;
          };
        in
        rec {
          # `nix build`
          packages."${project-name}" = wasm32-build;
          defaultPackage = packages."${project-name}";

          # `nix develop`
          devShell = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [ pkg-config ];
            buildInputs = with pkgs; [
              rust-toolchain
              rust-analyzer
              wasm-pack
              perl
              openssl
            ];
          };
        }
      );
}
