# Flake

## My first flake: tagged hello

- A flake is a directory with a `flake.nix`.
- That file evaluates to one attribute set with two keys that matter:
  - `inputs` and `outputs`
- Flake require git
- `inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"` is sugar for:
  - `inputs = { nixpgs = {url = "..."}; };`
- `outputs` is a function like in: `({x}: x + 1) {x=10;}` # can be tested in the repl
- to evaluates the flake and prints its output tree: `nix flake show`
  - for the hello world you should see `packages.x86_64-linux.default` listed as a derivative.
- to build it: `nix build`
  - the result is in *result/*: `ls -l result`
    - it is a symlink to */nix/store*
- and to run it: `nix run`
- play with the repl:
```
nix repl
:lf .
outputs
builtins.attrNames outputs
outputs.packages.x86_64-linux.default
```
- Note that the *inputs* shows when loading the flake into the REPL is not the same than the one you set in your flakes. It has been evaluated.

## A dev shell

*in progress...*
