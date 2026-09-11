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
