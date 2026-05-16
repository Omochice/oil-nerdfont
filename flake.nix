{
  description = "Integrate oil.nvim with vim-nerdfont";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-packages = {
      url = "github:Omochice/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      flake-utils,
      nur-packages,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            nur-packages.overlays.default
          ];
        };
        treefmt = treefmt-nix.lib.evalModule pkgs (
          { ... }:
          let
            rumdlConfig = (pkgs.formats.toml { }).generate "rumdl.toml" {
              # keep-sorted start
              MD004.style = "dash";
              MD007.indent = 4;
              MD007.style = "fixed";
              MD041.enabled = false;
              MD049.style = "underscore";
              MD050.style = "asterisk";
              MD055.style = "leading-and-trailing";
              MD060.enabled = true;
              MD060.style = "aligned";
              global.line_length = 0;
              # keep-sorted end
            };
          in
          {
            settings.global.excludes = [
              "CHANGELOG.md"
              ".github/release-please-manifest.json"
            ];
            settings.formatter = {
              # keep-sorted start block=yes
              rumdl = {
                command = "${pkgs.lib.getExe pkgs.rumdl}";
                options = [
                  "fmt"
                  "--config"
                  (toString rumdlConfig)
                ];
                includes = [ "*.md" ];
              };
              # keep-sorted end
            };
            programs = {
              # keep-sorted start block=yes
              keep-sorted.enable = true;
              nixfmt.enable = true;
              toml-sort.enable = true;
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
        run-as = name: program: {
          type = "app";
          program = program |> pkgs.writeShellScript name |> toString;
        };
      in
      {
        # keep-sorted start
        apps.check-actions =
          ''
            set -e
            ${pkgs.lib.getExe pkgs.ghalint} run
            ${pkgs.lib.getExe pkgs.actionlint} -color
            ${pkgs.lib.getExe pkgs.zizmor} .github/
          ''
          |> run-as "check-actions";
        apps.check-lua =
          ''
            set -e
            ${pkgs.lib.getExe pkgs.stylua} --check lua/**/*.lua
            ${pkgs.lib.getExe pkgs.selene} lua/**/*.lua
          ''
          |> run-as "check-lua";
        apps.check-renovate-config =
          ''
            set -e
            ${pkgs.renovate}/bin/renovate-config-validator --strict renovate.json5
          ''
          |> run-as "check-renovate-config";
        checks.formatting = treefmt.config.build.check self;
        formatter = treefmt.config.build.wrapper;
        # keep-sorted end
      }
    );
}
