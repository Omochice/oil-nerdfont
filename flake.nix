{
  description = "Integrate oil.nvim with vim-nerdfont";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:Omochice/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      treefmt-nix,
      nur,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ nur.overlays.default ];
        }
      );

      treefmt =
        system:
        treefmt-nix.lib.evalModule nixpkgsFor.${system} (
          { ... }:
          {
            settings.global.excludes = [
              "CHANGELOG.md"
              ".github/release-please-manifest.json"
            ];
            programs = {
              # keep-sorted start block=yes
              formatjson5 = {
                enable = true;
                indent = 2;
              };
              keep-sorted.enable = true;
              mdformat.enable = true;
              nixfmt.enable = true;
              pinact = {
                enable = true;
                update = false;
              };
              stylua.enable = true;
              taplo.enable = true;
              yamlfmt = {
                enable = true;
                settings = {
                  formatter = {
                    type = "basic";
                    retain_line_breaks_single = true;
                  };
                };
              };
              # keep-sorted end
            };
          }
        );
    in
    {
      # keep-sorted start block=yes
      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          run-as = name: program: {
            type = "app";
            program = program |> pkgs.writeShellScript name |> builtins.toString;
          };
        in
        {
          check-actions =
            ''
              set -e
              ${pkgs.ghalint}/bin/ghalint run
              ${pkgs.actionlint}/bin/actionlint -color
              ${pkgs.zizmor}/bin/zizmor .github/workflows/*.yml
            ''
            |> run-as "check-actions";
          check-lua =
            ''
              set -e
              ${pkgs.stylua}/bin/stylua --check lua/**/*.lua
              ${pkgs.selene}/bin/selene lua/**/*.lua
            ''
            |> run-as "check-lua";
          check-renovate-config =
            ''
              set -e
              ${pkgs.renovate}/bin/renovate-config-validator --strict renovate.json5
            ''
            |> run-as "check-renovate-config";
        }
      );
      formatter = forAllSystems (system: (treefmt system).config.build.wrapper);
      # keep-sorted end
    };
}
