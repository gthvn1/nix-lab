# Flake

## My first flake: tagged hello

- A flake is a directory with a `flake.nix`.
- That file evaluates to one attribute set with two keys that matter:
  - `inputs` and `outputs`
- Flake requires `git`.
- `inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"` is sugar for:
  - `inputs = { nixpgs = {url = "..."}; };`
- `outputs` is a function like in: `({x}: x + 1) {x=10;}` # can be tested in the repl.
- To evaluates the flake and prints its output tree: `nix flake show`
  - For the hello world you should see `packages.x86_64-linux.default` listed as a derivative.
- To build it: `nix build`
  - The result is in *result/*: `ls -l result`
    - It is a symlink to */nix/store*
- And to run it: `nix run`
- Play with the repl: `nix repl`
```
:lf .
outputs
builtins.attrNames outputs
outputs.packages.x86_64-linux.default
```
- Note that the *inputs* shows when loading the flake into the REPL is not the same than the one you set in your flakes. It has been evaluated.

## A dev shell

- To use a shell we do: `nix develop`.
- Without arguments `nix develop` looks up `devShells.${system}.default`.
- Like `nix build/nix run` default to `packages.${system}.default`.
- So in the `flake.init` we set `mkShell {...}` that is a derivation.
- The output of the derivation `mkShell {...}` allows to reconstruct a build-time environment and drops us into it.
- An interesting point:
  - `result/` created when running `nix build` is a link to `/nix/store/...`.
  - External links are tracked by nix in `/nix/var/nix/gcroots/auto/`.
  - It means that a nix GC will not cleanup things we are using

## Home manager

- You can also manage your dots file using home manager.
- There are different "flavors", we will use the flake one.
- just create a directory and git init:

```sh
mkdir -p ~/.config/home-manager
cd ~/.config/home-manager
git init
```

- You need two files:
  - `flake.nix`, the boilerplate, you write it once basically.
  - `home.nix`; the real configuration where you declare packages and programs setting.
  
- Example of a `flake.nix`:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.gthvn1 = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
```
- And the `home.nix`:
```nix
{ pkgs, ... }:
{
  home.username = "gthvn1";
  home.homeDirectory = "/home/gthvn1";
  home.stateVersion = "24.11"; # Pins config-format compatibility; set once.
                               # It is used for backward compat.

  # what you actually want:
  # Note: nil is not available as programs
  home.packages = [ pkgs.nil ];

  programs.home-manager.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
```
- Don't forget to add files: `git add .`
- The first time you run it: `nix run github:nix-community/home-manager -- switch --flake .#gthvn1`
- After that, `home-manager` is installed and you can apply new config by running:
  - `home-manager switch --flake .#gthvn1`
- To see generations: `home-manager generations`
- Profiles are under `~/.local/state/nix/profiles`

## Overlay

**_TODO_**

## Hints

### Nil: the lsp
- To have completion in the editor you need `nil`.
- It can be installed in you nix profile: `nix profile install nixpkgs#nil`.
```sh
ls -l ~/.nix-profile/
ls -l ~/.nix-profile/bin/
```

### Direnv
- To automatically load an env you can use `direnv`:
  - Create a envrc: `echo "use flake" > .envrc`
  - you will have to enable direnv the first time you enter the directory: `direnv allow`
  - Exit dir unload things
  - Status: `direnv status`
  - You can use a cache:
    - install nix-direnv: `nix profile install nixpkgs#nix-direnv`
    - load it in direnv:
      - `mkdir ~/.conf/direnv`
      - and add `source $HOME/.nix-profile/share/nix-direnv/direnvrc` into `~/.config/direnv/direnvrc`
    - That's it.
    - If later you run `nix flake update` it will be revaluated.

### Crane (Rust)
- There is a nice tool that reads your Cargo.lock when building your flake
- It gets the packages into your env
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    crane.url = "github:ipetkov/crane";
  };

  outputs = { self, nixpkgs, crane }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      craneLib = crane.mkLib pkgs;
    in {
      packages.${system}.default = craneLib.buildPackage {
        src = craneLib.cleanCargoSource ./.;
      };

      devShells.${system}.default = craneLib.devShell {
        packages = [ pkgs.rust-analyzer ];
      };
    };
}
```
- `nix flake lock` resolves crane, write it into flake.lock
- With cargo you can generate a *Cargo.lock* without building the project: `cargo generate-lockfile`
```
cargo add serde              # edits Cargo.toml only
cargo generate-lockfile      # resolves versions → writes Cargo.lock
```

### zon2zig
- It is like crane but for Zig.
- It reads `build.zig.zon`

### OCaml
- For OCaml, instead of installing stuff using `opam`, you can install libraries using `ocamlPackages`.
- If you are using a custom opam repo it is probably better to not use nix.
- My understanding is that `ocamlPackages` are from default.
- For a custom repo you will probably need to provide Nix packages yourself...
- Example of dev shells:
```
devShells.${system}.default = pkgs.mkShell {
  packages = [
    pkgs.dune_3
    pkgs.ocaml
    pkgs.ocamlPackages.ocamlformat
    pkgs.ocamlPackages.ocaml-lsp
    pkgs.ocamlPackages.utop
  ];
};
```
