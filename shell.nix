# KernelStore dev shell — dùng fetchTarball, không cần channel, không cần flake.
# Cách chạy: nix-shell
let
  nixpkgsTarball = builtins.fetchTarball
    "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
  pkgs = import nixpkgsTarball { };
in
pkgs.mkShell {
  name = "kernelstore-dev";

  buildInputs = with pkgs; [
    # Backend: ASP.NET Core 10
    dotnet-sdk_10
    dotnet-aspnetcore_10

    # Frontend: Rust + Leptos (WASM) build
    trunk
    rustup
    rustc
    cargo
    tailwindcss

    # Tooling
    pkg-config
    openssl
    docker
    docker-compose
    postgresql_16

    # Utils
    jq
    curl
    git
  ];

  shellHook = ''
    echo "[OK] KernelStore dev environment"
    echo "--- dotnet ---"
    dotnet --version
    echo "--- rust ---"
    rustc --version
    cargo --version
    if ! rustup target list --installed 2>/dev/null | grep -q wasm32-unknown-unknown; then
      rustup default stable 2>/dev/null || true
      rustup target add wasm32-unknown-unknown || true
    fi
    rustup target list --installed 2>/dev/null | grep wasm32 || true
    echo "--- trunk ---"
    trunk --version
  '';
}
