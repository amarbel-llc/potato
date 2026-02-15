{
  description = "pomodoro timer that requires the potato to rest for 5 minutes";

  inputs = {
    nixpkgs-master.url = "github:NixOS/nixpkgs/b28c4999ed71543e71552ccfd0d7e68c581ba7e9";
    nixpkgs.url = "github:NixOS/nixpkgs/23d72dabcb3b12469f57b37170fcbc1789bd7457";
    utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.102";
    go.url = "github:friedenberg/eng?dir=devenvs/go";
    shell.url = "github:friedenberg/eng?dir=devenvs/shell";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      go,
      shell,
      nixpkgs-master,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            go.overlays.default
          ];
        };

        version = "0.1.0";

        potato = pkgs.buildGoApplication {
          pname = "potato";
          inherit version;
          src = ./.;
          modules = ./gomod2nix.toml;
          subPackages = [ "cmd/potato" ];

          meta = with pkgs.lib; {
            description = "pomodoro timer that requires the potato to rest for 5 minutes";
            homepage = "https://github.com/friedenberg/potato";
            license = licenses.mit;
          };
        };
      in
      {
        packages = {
          default = potato;
          inherit potato;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            just
          ];

          inputsFrom = [
            go.devShells.${system}.default
            shell.devShells.${system}.default
          ];

          shellHook = ''
            echo "potato - dev environment"
          '';
        };

        apps.default = {
          type = "app";
          program = "${potato}/bin/potato";
        };
      }
    );
}
