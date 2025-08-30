### PowerShell Profile Definitions
# Prompt config
# Ensure starship rs is installed
#$ENV:STARSHIP_CONFIG = "$env:LOCALAPPDATA\starship.toml"
#$ENV:STARSHIP_CACHE = "$env:LOCALAPPDATA\starship\cache"
Invoke-Expression (&starship init powershell)

# PATH Config & special env vars
$env:TERM = "xterm-256color"
#$env:GOPATH= "$HOME\.go"
#$env:Path += ";$HOME\.local\bin;$env:LOCALAPPDATA\bin;$HOME\.cargo\bin;$HOME\.go\bin"
$env:GOPATH= "$HOME/.go"
$env:Path += ":$HOME/.local/bin:$HOME/.go/bin:$HOME/.cargo/bin:/var/lib/flatpak/exports/bin"

$env:EDITOR="nvim"
$env:PAGER="less"
$env:LESS="-iRrcNK"
$env:PYGMENTIZE_STYLE="github-dark"

# Custom keys setup
Set-PSReadLineOption -Colors @{
    Command = 'Cyan'
    Parameter = 'Green'
    String = 'DarkCyan'
    Default = 'White'
}

## To view all current key modficiations
# Get-PSReadLineKeyHandler

#https://stackoverflow.com/questions/8360215/use-ctrl-d-to-exit-and-ctrl-l-to-cls-in-powershell-console
Set-PSReadlineOption -EditMode Emacs

# Disable beep's
Set-PSReadlineOption -BellStyle None

# Set custom keys some will overrride defualt mode in Emacs
# Either use normal Powershell autocompletition
#Set-PSReadLineKeyHandler -Key "Tab" -Function TabCompleteNext
#Set-PSReadLineKeyHandler -Key "Shift+Tab" -Function TabCompletePrevious
#Set-PSReadLineKeyHandler -Key "Alt+q" -Function MenuComplete
# Use autocompletition more similar to zsh menu
#Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete

Set-PSReadLineKeyHandler -Key "Ctrl+Delete" -Function KillWord
Set-PSReadLineKeyHandler -Key "Ctrl+Backspace" -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key "Ctrl+RightArrow" -Function ForwardWord
Set-PSReadLineKeyHandler -Key "Ctrl+LeftArrow" -Function BackwardWord
Set-PSReadLineKeyHandler -Key "Shift+Home" -Function SelectBackwardsLine
Set-PSReadLineKeyHandler -Key "Shift+End" -Function SelectLine
Set-PSReadLineKeyHandler -Key "Alt+a" -Function SelectAll
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function SelectCommandArgument
Set-PSReadLineKeyHandler -Key "Ctrl+<" -Function Undo
Set-PSReadLineKeyHandler -Key "Ctrl+>" -Function Redo
Set-PSReadLineKeyHandler -Key "Shift+Ctrl+X" -Function Cut
Set-PSReadLineKeyHandler -Key "Shift+Ctrl+C" -Function Copy
Set-PSReadLineKeyHandler -Key "Shift+Ctrl+V" -Function Paste
Set-PSReadLineKeyHandler -Key "Escape" -Function RevertLine
Set-PSReadLineKeyHandler -Key "Shift+Ctrl+Enter" -Function InsertLineBelow
Set-PSReadLineKeyHandler -Key "Ctrl+UpArrow" -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key "Ctrl+p" -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key "Ctrl+P" -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key "Ctrl+DownArrow" -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key "Ctrl+n" -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key "Ctrl+N" -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key "Ctrl+c" -Function CancelLine
Set-PSReadLineKeyHandler -Key "Ctrl+C" -Function CopyOrCancelLine
Set-PSReadLineKeyHandler -Key "Shift+Ctrl+LeftArrow"  -Function SelectBackwardWord
Set-PSReadLineKeyHandler -Key "Shift+Ctrl+RightArrow"  -Function SelectNextWord

# Default values & others not used
#Set-PSReadlineKeyHandler -Key "Ctrl+p" -Function PreviousHistory
#Set-PSReadlineKeyHandler -Key "Ctrl+n" -Function NextHistory
#Set-PSReadLineKeyHandler -Key "Shift+Ctrl+Z" -Function Undo

# Custom aliases
Remove-Alias -Force nv -ErrorAction SilentlyContinue
New-Alias v nvim
New-Alias vi nvim
New-Alias vim nvim
New-Alias nv nvim
New-Alias lg lazygit
Remove-Alias -Force rm -ErrorAction SilentlyContinue
New-Alias rm trash

# Oh My Zsh partial git aliases/functions
# Install-Module git-aliases -Scope CurrentUser -AllowClobber
Import-Module git-aliases -DisableNameChecking

# Custom git aliases/functions
function gs { git status }
function gc { param($m) git commit -m "$m" }
function gal { git add . }
function gpn { git push }

function dev {
  ssh dev
}

function xdev {
  ssh xdev
}

function adev {
  ssh adev
}

function vdiff($f1, $f2) {
  nvim -d "$f1" "$f2"
}

New-Alias vimdiff vdiff

function lazygp {
  git add .
  git commit -m "$args"
  git push
}

# fzf Modules config
# The following will requiere fzf installed and the PSFzf module
# Install-Module -Name PSFzf
# winget install fzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PSReadLineKeyHandler -Key "Tab" -ScriptBlock { Invoke-FzfTabCompletion }
Set-PSReadLineKeyHandler -Key "Shift+Tab" -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -TabExpansion

# bat Config
# winget install bat
Remove-Alias -Force cat -ErrorAction SilentlyContinue
 function global:cat {
   bat -P --style 'header,grid' $args
 }

# git-delta Config
#$env:GIT_PAGER=delta

# tldr Config
$env:TLDR_CACHE_ENABLED=1
$env:TLDR_CACHE_MAX_AGE=720

# thefuck Config
# pip install thefuck
$env:PYTHONIOENCODING="utf-8"
Invoke-Expression "$(thefuck --alias f)"
$env:THEFUCK_EXCLUDE_RULES="fix_file"

# eza Config
$env:EZA_COLORS="da=38;5;252:sb=38;5;204:sn=38;5;43:xa=8:\
uu=38;5;245:un=38;5;241:ur=38;5;223:uw=38;5;223:ux=38;5;223:ue=38;5;223:\
gr=38;5;153:gw=38;5;153:gx=38;5;153:tr=38;5;175:tw=38;5;175:tx=38;5;175:\
gm=38;5;203:ga=38;5;203:mp=3;38;5;111:im=38;2;180;150;250:vi=38;2;255;190;148:\
mu=38;2;255;175;215:lo=38;2;255;215;183:cr=38;2;240;160;240:\
do=38;2;200;200;246:co=38;2;255;119;153:tm=38;2;148;148;148:\
cm=38;2;230;150;210:bu=38;2;95;215;175:sc=38;2;110;222;222"

Remove-Alias -Force ls -ErrorAction SilentlyContinue
function global:ls {
  $newargs = @()
  $wc_collection = @("\*","\?","\[")
  foreach ($arg in $args) {
    if ($arg -match '~') {
      $subarg = Resolve-Path -Path $arg -ErrorAction SilentlyContinue
      if (Test-Path -Path $subarg -ErrorAction SilentlyContinue) {
        $arg = $($subarg | Select-String -Raw Users)
      }
    }
    if ($arg -notmatch ($wc_collection -join "|") -or ($arg -match '`\[' -and $arg -notmatch "\*|\?")) {
      if ($newargs -notcontains $arg) {
        if ($arg -match '`\[') {
          $subarg = $arg.Replace('`[','[').Replace('`]',']')
          $subarg = $subarg -replace '/$','' -replace '^./',''
          $newargs += $subarg
        }
        else {
          $newargs += $arg
        }
      }
    }
    elseif ($arg -match ($wc_collection -join "|"))  {
        $processed=$(Get-ChildItem -Name $arg -ErrorAction SilentlyContinue)
      if ($processed) {
        foreach($object in $processed) {
          if ($newargs -notcontains $object) {
          $newargs += $object
          }
        }
      }
      else {
        if ($newargs -notcontains $arg) {
          if ($arg -match '`\[') {
            $subarg = $arg.Replace('`[','[').Replace('`]',']')
            $subarg = $subarg -replace '/$','' -replace '^./',''
            $newargs += $subarg
          }
          else {
            $newargs += $arg
          }
        }
      }
    }
  }
  eza -gH --color=always $newargs
}

function global:ll {
  ls -lgH --color=always $args
}

function global:l {
  ls -lgHA --color=always $args
}

function global:l. {
  $hiddenargs=$(Get-ChildItem -Hidden -Name -ErrorAction SilentlyContinue)
  $newargs = $args + $hiddenargs
  ls -d .* --color=always $newargs
}

function global:tree {
  ls -a -I ".git|node_modules|venv" --tree --color=always $args
}

# zoxide Config
# winget install ajeetdsouza.zoxide
Invoke-Expression(& { (zoxide init powershell | sed 's/LiteralPath/Path/g' | sed 's/Set-Location -Path $dir -Passthru -ErrorAction Stop/$dir=$dir -replace "\\\[","`[" -replace "\\\]","`]"\nSet-Location -Path $dir -Passthru -ErrorAction Stop/g' | Out-String) })

# procs config
# winget install procs
Invoke-Expression(& { (procs --gen-completion-out powershell | Out-String) })

Remove-Alias -Force cd -ErrorAction SilentlyContinue
$env:ZOLDPWD = ""
function global:cd {
  $env:ZCURRENTPWD = (Get-Location).Path

  if ($args.Count -eq 0) {
    z
    $env:ZOLDPWD = $env:ZCURRENTPWD
    $env:ZCURRENTPWD = (Get-Location).Path
    return
  } elseif ($args.Count -eq 1 -and $args -match '^-') {
    if ([string]::IsNullOrEmpty($env:ZOLDPWD)) {
      Write-Error "No current previous PWD, going to '~'"
      z ~
      $env:ZOLDPWD = $env:ZCURRENTPWD
      $env:ZCURRENTPWD = (Get-Location).Path
      return
    }
    $env:ZOLDPWD = $env:ZOLDPWD -replace '\[','`[' -replace '\]','`]'
    z $env:ZOLDPWD
    $env:ZOLDPWD = $env:ZCURRENTPWD
    $env:ZCURRENTPWD = (Get-Location).Path
    return
  }

  $newargs = @()
  $wc_collection = @("\*","\?","\[")
  foreach ($arg in $args) {
    if ($arg -notmatch ($wc_collection -join "|") -or ($arg -match '`\[')) {
      if ($newargs -notcontains $arg) {
        $newargs += $arg
      }
    }
    elseif ($arg -match ($wc_collection -join "|") -and ($arg -notmatch '`\['))  {
      if ($arg -match "^\.") {
        $processed=$(Get-ChildItem -Directory -Name -Hidden $arg -ErrorAction SilentlyContinue)
      }
      else {
        $processed=$(Get-ChildItem -Directory -Name $arg -ErrorAction SilentlyContinue)
      }
      if ($processed) {
        foreach($object in $processed) {
          if ($newargs -notcontains $object) {
          $newargs += $object
          }
        }
      }
      else {
        if ($newargs -notcontains $arg) {
          $newargs += $arg
        }
      }
    }
  }

  if (Test-Path -Path $newargs[0]) {
    if ($newargs.Count -gt 1) {
      Write-Error "Only can cd into a single path"
    }
    z $newargs[0]
  } else {
    $finalargs=$(Join-String -InputObject $newargs -Separator ' ')
    Invoke-Expression "z $finalargs"
  }

  $env:ZOLDPWD = $env:ZCURRENTPWD
  $env:ZCURRENTPWD = (Get-Location).Path

}

function global:cdi {
  $env:ZCURRENTPWD = (Get-Location).Path
  $result = __zoxide_bin query -i -- @args
  if ($LASTEXITCODE -eq 0) {
    $result = $result -replace '\[','`[' -replace '\]','`]'
    z $result
    $env:ZOLDPWD = $env:ZCURRENTPWD
    $env:ZCURRENTPWD = (Get-Location).Path
  }
}


