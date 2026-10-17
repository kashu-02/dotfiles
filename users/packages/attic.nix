{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv) isLinux isDarwin;
  atticBin = "${pkgs.attic-client}/bin/attic";
  configFile = "${config.home.homeDirectory}/.config/attic/config.toml";
in
{
  home.packages = with pkgs; [
    attic-client
  ];

  systemd.user.services.attic-watch-store = lib.mkIf isLinux {
    Unit = {
      Description = "Attic Nix Store Watcher (auto-push to main cache)";
      After = [ "network-online.target" ];
      ConditionPathExists = configFile;
    };
    Service = {
      ExecStart = "${atticBin} watch-store main";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  launchd.agents.attic-watch-store = lib.mkIf isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "test -f \"${configFile}\" && exec ${atticBin} watch-store main"
      ];
      KeepAlive = {
        PathState = {
          "${configFile}" = true;
        };
      };
      RunAtLoad = true;
    };
  };
}
