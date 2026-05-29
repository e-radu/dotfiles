# ============================================================================
# PowerShell User Profile - chezmoi managed
# Target: ~\.config\powershell\user_profile.ps1
# Dot-sourced from $PROFILE (Documents\PowerShell\Microsoft.PowerShell_profile.ps1)
# ============================================================================

$ErrorActionPreference = 'Continue'

# ---------------------------------------------------------------------------
# Environment Variables
# ---------------------------------------------------------------------------
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'

$env:PATH = @(
    "$env:USERPROFILE\.local\bin"
    "$env:USERPROFILE\.local\share\cargo\bin"
    "$env:LOCALAPPDATA\nvm"
    "C:\Program Files\Neovim\bin"
    "C:\Program Files\Git\bin"
    "$env:PATH"
) -join ';'

# ---------------------------------------------------------------------------
# PSReadLine Configuration
# ---------------------------------------------------------------------------
$PSROptions = @{
    EditMode                = 'Emacs'
    PredictionSource        = 'HistoryAndPlugin'
    PredictionViewStyle     = 'InlineView'
    MaximumHistoryCount     = 50000
    HistoryNoDuplicates      = $true
    HistorySearchCursorMovesToEnd = $true
    ShowToolTips            = $true
    BellStyle               = 'None'
}
Set-PSReadLineOption @PSROptions

Set-PSReadLineKeyHandler -Key Ctrl+p -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key Ctrl+n -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Ctrl+z -Function Undo
Set-PSReadLineKeyHandler -Key Ctrl+y -Function Redo

# ---------------------------------------------------------------------------
# Aliases - Directory Navigation
# ---------------------------------------------------------------------------
New-Item -Path "Function:" -Name ".." -Value { Set-Location .. } -ItemType Function -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "Function:" -Name "..." -Value { Set-Location ..\.. } -ItemType Function -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "Function:" -Name ".3" -Value { Set-Location ..\..\.. } -ItemType Function -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "Function:" -Name ".4" -Value { Set-Location ..\..\..\.. } -ItemType Function -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path "Function:" -Name ".5" -Value { Set-Location ..\..\..\..\.. } -ItemType Function -Force -ErrorAction SilentlyContinue | Out-Null

# ---------------------------------------------------------------------------
# Aliases - Listing with eza (fallback to Get-ChildItem)
# ---------------------------------------------------------------------------
Remove-Item -Path Alias:ls -Force -ErrorAction SilentlyContinue
Remove-Item -Path Alias:la -Force -ErrorAction SilentlyContinue
Remove-Item -Path Alias:ll -Force -ErrorAction SilentlyContinue

if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls  { eza -al --color=always --group-directories-first @args }
    function la  { eza -a  --color=always --group-directories-first @args }
    function ll  { eza -l  --color=always --group-directories-first @args }
    function lt  { eza -aT --color=always --group-directories-first @args }
    function l.  { eza -al --color=always --group-directories-first .. @args }
    function l.. { eza -al --color=always --group-directories-first ..\.. @args }
    function l...{ eza -al --color=always --group-directories-first ..\..\.. @args }
} else {
    function ls  { Get-ChildItem @args }
    Remove-Item -Path Alias:la -Force -ErrorAction SilentlyContinue
    Remove-Item -Path Alias:ll -Force -ErrorAction SilentlyContinue
    function la  { Get-ChildItem -Force @args }
    function ll  { Get-ChildItem | Format-Table Mode, Length, LastWriteTime, Name }
    function lt  { Get-ChildItem -Recurse -Force @args }
    function l.  { Get-ChildItem -Path .. @args }
    function l.. { Get-ChildItem -Path ..\.. @args }
    function l...{ Get-ChildItem -Path ..\..\.. @args }
}

# ---------------------------------------------------------------------------
# Aliases - Editor
# ---------------------------------------------------------------------------
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    function v { nvim @args }
} elseif (Get-Command vim -ErrorAction SilentlyContinue) {
    function v { vim @args }
} elseif (Get-Command code -ErrorAction SilentlyContinue) {
    function v { code @args }
}

# ---------------------------------------------------------------------------
# Aliases - Tool replacements
# ---------------------------------------------------------------------------
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -ErrorAction SilentlyContinue
    function cat { bat @args }
}

Remove-Item Alias:grep -ErrorAction SilentlyContinue
function grep { Select-String @args }

function xc  { Set-Clipboard @args }
function xcp { Get-Clipboard @args }

if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    function lg { lazygit @args }
}

if (Get-Command delta -ErrorAction SilentlyContinue) {
    $env:GIT_PAGER = 'delta'
}

Remove-Item Alias:which -ErrorAction SilentlyContinue
function which { Get-Command @args }

function df {
    Get-PSDrive -PSProvider FileSystem | Select-Object Name,
        @{N='Used(GB)';E={[math]::Round(($_.Used/1GB),2)}},
        @{N='Free(GB)';E={[math]::Round(($_.Free/1GB),2)}},
        @{N='Total(GB)';E={[math]::Round(($_.Used+$_.Free)/1GB,2)}}
}

function free {
    $os = Get-CimInstance Win32_OperatingSystem
    [PSCustomObject]@{
        TotalMemGB     = [math]::Round($os.TotalVisibleMemorySize/1MB, 2)
        FreeMemGB      = [math]::Round($os.FreePhysicalMemory/1MB, 2)
        UsedMemGB      = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory)/1MB, 2)
        MemUsagePct    = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100, 1)
    }
}

if (-not (Get-Command tree -ErrorAction SilentlyContinue)) {
    function tree { Get-ChildItem -Recurse -Directory | ForEach-Object { $_.FullName } }
}

# ---------------------------------------------------------------------------
# PSFzf Integration
# ---------------------------------------------------------------------------
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf -ErrorAction SilentlyContinue
    Set-PsFzfOption -PSReadLineChordProvider 'Ctrl+t' -PSReadLineChordReverseHistory 'Ctrl+r'
    Set-PsFzfOption -AltCChord 'Alt+c'
    Set-PsFzfOption -TabExpansion
    Set-PsFzfOption -EnableAliasYank -EnableAliasFuzzyEdit
}

# ---------------------------------------------------------------------------
# zoxide (smart cd)
# ---------------------------------------------------------------------------
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    try {
        Remove-Item -Path Alias:cd -Force -ErrorAction SilentlyContinue
        Remove-Item -Path Alias:cd.. -Force -ErrorAction SilentlyContinue
        $initScript = zoxide init powershell --cmd cd 2>$null | Out-String
        if ($initScript.Trim()) {
            Invoke-Expression $initScript
        }
    } catch {
        Write-Warning "zoxide init skipped: $_"
    }
}

# ---------------------------------------------------------------------------
# Starship Prompt
# ---------------------------------------------------------------------------
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# ---------------------------------------------------------------------------
# Atuin History
# ---------------------------------------------------------------------------
if (Get-Command atuin -ErrorAction SilentlyContinue) {
    Invoke-Expression (atuin init powershell | Out-String)
}

# ---------------------------------------------------------------------------
# Terminal Icons
# ---------------------------------------------------------------------------
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------------
# GitHub Copilot CLI
# ---------------------------------------------------------------------------
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Set-PSReadLineKeyHandler -Key 'Ctrl+\' -ScriptBlock {
        $input = gh copilot suggest 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0) {
            $suggestion = $input | Select-String -Pattern '```\w*\s*\n(.*?)\n```' -AllMatches
            if ($suggestion.Matches) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($suggestion.Matches[0].Groups[1].Value)
            }
        }
    }
    Set-PSReadLineKeyHandler -Key 'Ctrl+|' -ScriptBlock {
        $line = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$null)
        if ($line) {
            $result = gh copilot explain $line 2>&1 | Out-String
            Write-Host "`n$result" -ForegroundColor Cyan
        }
    }
}

# ---------------------------------------------------------------------------
# nvm (nvm-windows)
# ---------------------------------------------------------------------------
if (Get-Command nvm -ErrorAction SilentlyContinue) {
    $env:NVM_HOME = "$env:APPDATA\nvm"
    $env:NVM_SYMLINK = "C:\Program Files\nodejs"
    $env:PATH = "$env:NVM_HOME;$env:NVM_SYMLINK;$env:PATH"
}

# ---------------------------------------------------------------------------
# Local / Machine-specific overrides
# ---------------------------------------------------------------------------
$localProfile = Join-Path (Split-Path $PROFILE) 'local_profile.ps1'
if (Test-Path $localProfile) { . $localProfile }
