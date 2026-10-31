{ pkgs, ... }:
{
  imports = [
    ./mcp-servers/mcp.nix
  ];

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.llm-agents.claude-code;
    settings = {
      includeCoAuthoredBy = false;
      remoteControlAtStartup = true;
      statusLine = {
        type = "command";
        command = toString (
          pkgs.writeShellScript "claude-statusline" ''
            input=$(cat)
            jq=${pkgs.jq}/bin/jq
            date=${pkgs.coreutils}/bin/date

            model=$(echo "$input" | $jq -r '.model.display_name // empty')

            # rate_limits は Pro/Max かつ最初の API レスポンス後にのみ存在する
            limit() {
              local label=$1 key=$2 fmt=$3 pct reset color
              pct=$(echo "$input" | $jq -r ".rate_limits.$key.used_percentage // empty")
              [ -z "$pct" ] && return
              reset=$(echo "$input" | $jq -r ".rate_limits.$key.resets_at // empty")
              pct=$(printf '%.0f' "$pct")
              if [ "$pct" -ge 80 ]; then color=31; elif [ "$pct" -ge 50 ]; then color=33; else color=32; fi
              printf ' │ %s \033[%sm%s%%\033[0m' "$label" "$color" "$pct"
              [ -n "$reset" ] && printf ' \033[90m(%s)\033[0m' "$($date -d "@$reset" +"$fmt")"
            }

            printf '\033[36m%s\033[0m' "$model"
            limit 5h five_hour '%H:%M'
            limit week seven_day '%m/%d %H:%M'
            echo
          ''
        );
      };
    };
  };
}
