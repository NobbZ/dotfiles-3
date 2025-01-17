let direnv_installed = (which direnv | length) > 0
let starship_installed = (which starship | length) > 0

let-env config = {
  show_banner: false
  # use_ansi_coloring: false
  render_right_prompt_on_last_line: true
  hooks: {
    pre_prompt: (if $direnv_installed {
      [{
        code: "
            let direnv = (direnv export json | from json)
            let direnv = if ($direnv | length) == 1 { $direnv } else { {} }
            $direnv | load-env
        "
      }]
    } else {[]})
    command_not_found: {
      |cmd_name| (
        if ($nu.os-info.name == "linux") {try {
          let raw_results = (nix-locate --minimal --no-group --type x --type s --top-level --whole-name --at-root $"/bin/($cmd_name)")
          let parsed = ($raw_results | split row "\n" | each {|elem| ($elem | parse "{attr}.{output}" | first) })
          let names = ($parsed | each {|row|
            if ($row.output == "out") {
              $row.attr
            } else {
              $"($row.attr).($row.output)"
            }
          })
          let names_display = ($names | str join "\n")
          (
            "nix-index found the follwing matches:\n\n" + $names_display
          )
        } catch {
          null
        }}
      )
    }
  }
  keybindings: [
    {
      name: completion_menu
      modifier: none
      keycode: tab
      mode: [emacs vi_normal vi_insert]
      event: {
          until: [
          { send: menu name: completion_menu }
          { send: menunext }
          ]
      }
    }
  ]
  color_config: {
  }
  rm: {
    always_trash: true
  }
  table: {
    mode: compact
    index_mode: auto
  }
  completions: {
    external: (if ((which carapace | length)  > 0) { {
      completer: { |spans| carapace $spans.0 nushell $spans | from json }
    } } else { {} })
  }
}

if $starship_installed {
  let-env STARSHIP_SHELL = "nu"
  let-env STARSHIP_SESSION_KEY = (random chars -l 16)
  let-env STARSHIP_SESSION_KEY = (random chars -l 16)
  let-env PROMPT_MULTILINE_INDICATOR = (starship prompt --continuation)

  let-env PROMPT_INDICATOR = '$ '
  let-env PROMPT_COMMAND = {|| starship prompt $"--cmd-duration=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)" }
} else {}

let-env PROMPT_COMMAND_RIGHT = ''

if ($nu.os-info.name == "windows") {
  let-env DIRENV_CONFIG = ([ $env.APPDATA "direnv" "conf" ] | path join)
  let-env XDG_DATA_HOME = ([ $env.LOCALAPPDATA ] | path join)
  let-env XDG_CACHE_HOME = ([ $env.LOCALAPPDATA "cache" ] | path join)
}
