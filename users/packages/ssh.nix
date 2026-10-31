_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      Compression = true;
      ServerAliveInterval = 10;
    };
    settings."github.com" = {
      HostName = "github.com";
      IdentitiesOnly = true;
      IdentityFile = "~/.ssh/github";
      User = "git";
    };
    settings."git.bgp.ne.jp" = {
      HostName = "git.bgp.ne.jp";
      IdentitiesOnly = true;
      IdentityFile = "~/.ssh/github";
      User = "git";
    };
    settings."dev-nix" = {
      HostName = "home.kashu.dev";
      IdentityFile = "~/.ssh/dev-nix";
      Port = 56754;
      User = "kashu";
    };
    settings."desktop" = {
      HostName = "home.kashu.dev";
      IdentityFile = "~/.ssh/dev-nix";
      Port = 56756;
      User = "kashu";
    };
    settings."lab-pc" = {
      HostName = "192.168.50.100";
      IdentityFile = "~/.ssh/lab-pc";
      User = "kashu";
      ProxyJump = "dev-nix";
    };
    settings."u-aizu" = {
      HostName = "sshgate.u-aizu.ac.jp";
      IdentityFile = "~/.ssh/u-aizu";
      User = "m5301034";
    };
    settings."linsv" = {
      HostName = "linsv.u-aizu.ac.jp";
      User = "m5301034";
      IdentityFile = "~/.ssh/u-aizu";
      ProxyJump = "u-aizu";
    };
    settings."llmsv" = {
      HostName = "192.168.11.250";
      IdentityFile = "~/.ssh/github";
    };
    settings."containerlab" = {
      HostName = "172.16.10.110";
      IdentityFile = "~/.ssh/github";
      User = "kashu";
    };
  };
}
