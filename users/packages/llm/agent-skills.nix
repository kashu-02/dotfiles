{ inputs, ... }:
{
  imports = [ inputs.agent-skills-nix.homeManagerModules.default ];

  programs.agent-skills = {
    enable = true;

    sources.yomiyasu = {
      input = "yomiyasu";
      subdir = "skills";
    };
    skills.enable = [ "yomiyasu" ];

    targets = {
      codex = {
        enable = true;
        dest = ".codex/skills";
        structure = "link";
      };
      claude = {
        enable = true;
        dest = ".claude/skills";
        structure = "link";
      };
      opencode = {
        enable = true;
        dest = ".config/opencode/skills";
        structure = "link";
      };
    };
  };
}
