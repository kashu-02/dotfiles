{ lib, inputs, ... }:
let
  # google/skills nests skills under skills/<category>/. Agents only read one
  # level of skills, so each category becomes its own source.
  googleCategories = [
    "ads"
    "analytics"
    "cloud"
    "developers"
    "identity"
  ];
  googleSources = lib.genAttrs' googleCategories (
    cat:
    lib.nameValuePair "google-${cat}" {
      input = "google-skills";
      subdir = "skills/${cat}";
    }
  );
in
{
  imports = [ inputs.agent-skills-nix.homeManagerModules.default ];

  programs.agent-skills = {
    enable = true;

    sources = googleSources // {
      yomiyasu = {
        input = "yomiyasu";
        subdir = "skills";
      };
      supabase = {
        input = "supabase-agent-skills";
        subdir = "skills";
      };
      anthropic = {
        input = "anthropic-skills";
        subdir = "skills";
      };
      vercel = {
        input = "vercel-agent-skills";
        subdir = "skills";
      };
      routeros = {
        input = "routeros-skills";
        subdir = ".";
        filter.maxDepth = 1;
      };
      ix-toolkit = {
        input = "ix-toolkit";
        subdir = "skills";
      };
    };

    skills = {
      enableAll = (builtins.attrNames googleSources) ++ [
        "supabase"
        "routeros"
        "ix-toolkit"
      ];
      enable = [
        "yomiyasu"
        # anthropics/skills
        "frontend-design"
        "pdf"
        "docx"
        "pptx"
        "xlsx"
        "mcp-builder"
        "webapp-testing"
        "claude-api"
        "skill-creator"
        "canvas-design"
        "theme-factory"
        "web-artifacts-builder"
        "algorithmic-art"
        # vercel-labs/agent-skills
        "web-design-guidelines"
      ];
      # Match the directory name to the skill's frontmatter name.
      explicit.vercel-react-best-practices = {
        from = "vercel";
        path = "react-best-practices";
      };
    };

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
