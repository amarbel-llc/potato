{
  description = "pomodoro timer that requires the potato to rest for 5 minutes";

  inputs = {
    nixpkgs-master.url = "github:NixOS/nixpkgs/5b7e21f22978c4b740b3907f3251b470f466a9a2";
    nixpkgs.url = "github:NixOS/nixpkgs/6d41bc27aaf7b6a3ba6b169db3bd5d6159cfaa47";
    utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.102";
    go.url = "github:amarbel-llc/eng?dir=devenvs/go";
    shell.url = "github:amarbel-llc/eng?dir=devenvs/shell";
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
