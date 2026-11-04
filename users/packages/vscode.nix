{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    # The stable package still expects the pre-1.122 ripgrep layout.
    package = pkgs.unstable.vscode;
  };
}
