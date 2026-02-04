_:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        compression = true;
        serverAliveInterval = 10;
      };
      "github.com" = {
        hostname = "github.com";
        identitiesOnly = true;
        identityFile = "~/.ssh/github";
        user = "git";
      };
      "dev-nix" = {
        hostname = "home.kashu.dev";
        identityFile = "~/.ssh/dev-nix";
        port = 56754;
        user = "kashu";
      };
      "lab-pc" = {
        hostname = "192.168.50.100";
        identityFile = "~/.ssh/lab-pc";
        user = "kashu";
        proxyJump = "dev-nix";
      };
      "u-aizu" = {
        hostname = "sshgate.u-aizu.ac.jp";
        identityFile = "~/.ssh/u-aizu";
        user = "s1300071";
      };
      "linsv" = {
        hostname = "linsv.u-aizu.ac.jp";
        proxyJump = "u-aizu";
      };
      "llmsv" = {
        hostname = "192.168.11.250";
        identityFile = "~/.ssh/github";
      };
    };
  };
}
