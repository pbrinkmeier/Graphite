let
  # Get oxalica's Rust overlay for better Rust integration
  rust-overlay-source = builtins.fetchGit {
    url = "https://github.com/oxalica/rust-overlay";
  };
  # Import it so we can use it in Nix
  rust-overlay = import rust-overlay-source;

  # Import system packages overlaid with the Rust overlay
  pkgs = import <nixpkgs> {
    overlays = [ rust-overlay ];
  };

  # Define the rustc we need
  rustc-wasm = pkgs.rust-bin.stable.latest.default.override {
    targets = [ "wasm32-unknown-unknown" ];
    # wasm-pack needs this
    extensions = [ "rust-src" ];
  };
in
  # Make a shell with the dependencies we need
  pkgs.mkShell {
    packages = [
      rustc-wasm
      pkgs.nodejs
      pkgs.cargo
      # We use wasm-pack from the system packages,
      # so make sure to do 'npm install --omit=optional'
      pkgs.wasm-pack
      # Likewise, we use cargo-watch from the system packages,
      # no need to install it via cargo
      pkgs.cargo-watch

      pkgs.openssl
      pkgs.pkg-config
    ];
  }
