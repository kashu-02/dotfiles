{ pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    compression = true;
    serverAliveInterval = 10;
    matchBlocks."github.com" = {
      hostname = "github.com";
      identitiesOnly = true;
      identityFile = "~/.ssh/github";
      user = "git";
    };
    matchBlocks."dev-nix" = {
      hostname = "home.kashu.dev";
      identityFile = "~/.ssh/dev-nix";
      port = 56754;
      user = "kashu";
    };
    matchBlocks."lab-pc" = {
      hostname = "192.168.50.100";
      identityFile = "~/.ssh/lab-pc";
      user = "kashu";
      proxyJump = "dev-nix";
    };
    matchBlocks."u-aizu" = {
      hostname = "sshgate.u-aizu.ac.jp";
      identityFile = "~/.ssh/u-aizu";
      user = "s1300071";
    };
    matchBlocks."linsv" = {
      hostname = "linsv.u-aizu.ac.jp";
      proxyJump = "u-aizu";
    };
  };
}
