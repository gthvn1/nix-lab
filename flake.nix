{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.${system}.default = pkgs.hello;
        devShells.${system}.default = pkgs.mkShell {
          packages = [
            pkgs.cowsay
            pkgs.hello
          ];
        };
      };
}
