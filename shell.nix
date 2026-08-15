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
    # Lưu ý: KHÔNG dùng rustup (shim cần tải toolchain riêng).
    # rustc/cargo thẳng từ nixpkgs đã kèm sẵn target wasm32-unknown-unknown.
    trunk
    rustc
    cargo
    tailwindcss

    # Tooling
    gcc          # C linker (cc) cho Rust build-scripts / proc-macros
    lld          # cung cấp wasm-ld/lld cho target wasm32
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
    if rustc --print target-list 2>/dev/null | grep -q wasm32-unknown-unknown; then
      echo "    wasm32-unknown-unknown target: OK"
    else
      echo "    WARNING: target wasm32-unknown-unknown KHONG co san trong rustc cua nixpkgs!"
    fi
    echo "--- trunk ---"
    trunk --version
  '';
}
