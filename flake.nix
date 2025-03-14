{
  inputs = {
    utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      utils,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.${system};
        nvim =
          (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
            plugins = with pkgs.vimPlugins; [
              # TODO: build using locked versions... also, get rid of recursion
              # nvim-treesitter.withAllGrammars
              plenary-nvim
              (pkgs.callPackage ./parsers.nix { })
            ];
          }).overrideAttrs
            {
              dontStrip = true;
              dontFixup = true;

              installPhase = ''
                mv $out/bin/nvim $out/bin/nvim-test
              '';

              meta.mainProgram = "nvim-test";
            };

        run-tests = pkgs.writeShellApplication {
          name = "run-tests";
          text = ''
            export HOME
            HOME="$(mktemp -d)"

            export LUA_PATH="./?.lua;''${LUA_PATH:-}"

            ${lib.getExe nvim} --headless \
              -c "PlenaryBustedDirectory tests { init = './scripts/minimal_init.lua', nvim_cmd = '${lib.getExe nvim}', sequential = true }"
          '';
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            gnumake
            nvim
            stylua
            highlight-assertions
            which
            run-tests
          ];
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "nvim-ts-autotag";
          version = "0.0.0";
          src = ./.;

          nativeBuildInputs = [
            nvim
            pkgs.which
            pkgs.highlight-assertions
          ];

          buildPhase = ''
            export HOME="$(mktemp -d)"
            ./run-tests.sh
            touch $out
          '';

          dontInstall = true;
        };
      }
    );
}
