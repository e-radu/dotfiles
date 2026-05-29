# ============================================================================
# PowerShell Setup Script - chezmoi managed
# Target: ~\.config\powershell\setup.ps1
# Run once after chezmoi apply to install tools and configure profile.
# Usage:
#   Install: pwsh -ExecutionPolicy Bypass -File ~\.config\powershell\setup.ps1
#   Update:  pwsh -ExecutionPolicy Bypass -File ~\.config\powershell\setup.ps1 -Update
# ============================================================================

param(
    [switch]$Update
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# 0. Early exit if already set up
# ---------------------------------------------------------------------------
$profilePath = $PROFILE
$sourcePath = "$env:USERPROFILE\.config\powershell\user_profile.ps1"
$profileSourced = (Test-Path $profilePath) -and (
    (Get-Content $profilePath -Raw -ErrorAction SilentlyContinue) -match [regex]::Escape(". '$sourcePath'")
)
$scoopShims = "$env:USERPROFILE\scoop\shims"
$scoopGlobal = "$env:USERPROFILE\scoop\apps\scoop\current\bin"
$scoopExists = (Get-Command scoop -ErrorAction SilentlyContinue) -or
               (Test-Path "$scoopShims\scoop.exe") -or
               (Test-Path "$env:USERPROFILE\scoop\apps\scoop\current")

if ($profileSourced -and -not $Update) {
    Write-Host ">>> Profile already configured." -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 1a. Update mode: upgrade all tools and exit
# ---------------------------------------------------------------------------
if ($Update) {
    Write-Host "=======================================" -ForegroundColor Magenta
    Write-Host "  Updating all tools..." -ForegroundColor Magenta
    Write-Host "=======================================" -ForegroundColor Magenta

    $env:PATH = "$scoopShims;$scoopGlobal;$env:PATH"

    if ($scoopExists) {
        Write-Host "`n>>> Updating Scoop..." -ForegroundColor Cyan
        scoop update
        Write-Host "`n>>> Updating Scoop packages..." -ForegroundColor Cyan
        scoop update *
    }

    if (Get-Command cargo -ErrorAction SilentlyContinue) {
        $env:PATH = "$env:USERPROFILE\.local\share\cargo\bin;$env:PATH"
        Write-Host "`n>>> Updating cargo tools..." -ForegroundColor Cyan
        $cargoPackages = @('eza', 'zoxide', 'tlrc', 'dysk')
        foreach ($pkg in $cargoPackages) {
            $isInstalled = Get-Command $pkg -ErrorAction SilentlyContinue
            if ($isInstalled) {
                Write-Host "    Updating $pkg..." -ForegroundColor White
                cargo install --locked $pkg
            }
        }
        if (Get-Command ya -ErrorAction SilentlyContinue) {
            Write-Host "    Updating yazi-cli..." -ForegroundColor White
            cargo install --locked yazi-cli
        }
    }

    $psModules = @('PSFzf', 'Terminal-Icons', 'posh-git')
    foreach ($mod in $psModules) {
        $hasModule = Get-Module -ListAvailable -Name $mod
        if ($hasModule) {
            Write-Host ">>> Updating PS module: $mod" -ForegroundColor Cyan
            Update-Module -Name $mod -Force -ErrorAction SilentlyContinue
        }
    }

    $nvimConfig = "$env:LOCALAPPDATA\nvim"
    if (Test-Path "$nvimConfig\.git") {
        Write-Host "`n>>> Updating Neovim config..." -ForegroundColor Cyan
        Push-Location $nvimConfig
        git pull
        Pop-Location
    }

    Write-Host "`n=======================================" -ForegroundColor Magenta
    Write-Host "  Update complete!" -ForegroundColor Magenta
    Write-Host "=======================================" -ForegroundColor Magenta
    exit 0
}

# ---------------------------------------------------------------------------
# 1. Ensure Scoop is in PATH for subsequent commands
# ---------------------------------------------------------------------------
$env:PATH = "$scoopShims;$scoopGlobal;$env:PATH"

# ---------------------------------------------------------------------------
# 2. Install Scoop (if missing)
# ---------------------------------------------------------------------------

if (-not $scoopExists) {
    Write-Host ">>> Installing Scoop..." -ForegroundColor Cyan
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
} else {
    Write-Host ">>> Scoop already installed" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 2. Add Scoop buckets (check local dirs to avoid re-cloning)
# ---------------------------------------------------------------------------
$buckets = @('extras', 'nerd-fonts', 'versions')
$bucketsDir = "$env:USERPROFILE\scoop\buckets"
foreach ($bucket in $buckets) {
    if (-not (Test-Path "$bucketsDir\$bucket")) {
        Write-Host ">>> Adding Scoop bucket: $bucket" -ForegroundColor Cyan
        scoop bucket add $bucket
    } else {
        Write-Host ">>> Scoop bucket '$bucket' already added" -ForegroundColor Green
    }
}

# ---------------------------------------------------------------------------
# 3. Install tools via Scoop
# ---------------------------------------------------------------------------
$scoopPackages = @(
    'bat'
    'lazygit'
    'fzf'
    'starship'
    'neovim'
    'gh'
    'ripgrep'
    'fd'
    'nvm'
    'delta'
    'atuin'
    'yazi'
)

$scoopInstalled = scoop list | ForEach-Object { $_.Name }

foreach ($pkg in $scoopPackages) {
    if ($pkg -notin $scoopInstalled) {
        Write-Host ">>> Installing via Scoop: $pkg" -ForegroundColor Cyan
        scoop install $pkg
    } else {
        Write-Host ">>> $pkg already installed" -ForegroundColor Green
    }
}

# ---------------------------------------------------------------------------
# 4. Install tools via Cargo (if cargo is available)
# ---------------------------------------------------------------------------
$cargoPackages = @('eza', 'zoxide', 'tlrc', 'dysk')

if (Get-Command cargo -ErrorAction SilentlyContinue) {
    # Ensure cargo bin is in PATH for this session
    $env:PATH = "$env:USERPROFILE\.local\share\cargo\bin;$env:PATH"

    foreach ($pkg in $cargoPackages) {
        $isInstalled = Get-Command $pkg -ErrorAction SilentlyContinue
        if (-not $isInstalled) {
            Write-Host ">>> Installing via Cargo: $pkg" -ForegroundColor Cyan
            cargo install --locked $pkg
        } else {
            Write-Host ">>> $pkg already installed" -ForegroundColor Green
        }
    }

    # yazi-cli (ya) is separate from yazi-fm
    $yaInstalled = Get-Command ya -ErrorAction SilentlyContinue
    if (-not $yaInstalled) {
        Write-Host ">>> Installing via Cargo: yazi-cli" -ForegroundColor Cyan
        cargo install --locked yazi-cli
    } else {
        Write-Host ">>> yazi-cli already installed" -ForegroundColor Green
    }
} else {
    Write-Host "!!! Cargo not found. Install Rust first: https://rustup.rs" -ForegroundColor Yellow
    Write-Host "!!! Skipping: eza, zoxide, tlrc, dysk, yazi-cli" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# 5. Install PowerShell modules
# ---------------------------------------------------------------------------
$psModules = @('PSFzf', 'Terminal-Icons', 'posh-git')

foreach ($mod in $psModules) {
    $hasModule = Get-Module -ListAvailable -Name $mod
    if (-not $hasModule) {
        Write-Host ">>> Installing PowerShell module: $mod" -ForegroundColor Cyan
        Install-Module -Name $mod -Scope CurrentUser -Force -SkipPublisherCheck
    } else {
        Write-Host ">>> PowerShell module '$mod' already installed" -ForegroundColor Green
    }
}

# ---------------------------------------------------------------------------
# 6. Configure $PROFILE to dot-source our user_profile.ps1
# ---------------------------------------------------------------------------
$profileDir = Split-Path $profilePath -Parent

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if (Test-Path $profilePath) {
    $content = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    $line = ". '$sourcePath'"
    if ($content -notmatch [regex]::Escape($line)) {
        Write-Host ">>> Adding dot-source to $profilePath" -ForegroundColor Cyan
        Add-Content -Path $profilePath -Value "`n$line"
    } else {
        Write-Host ">>> Profile already sources user_profile.ps1" -ForegroundColor Green
    }
} else {
    Write-Host ">>> Creating $profilePath" -ForegroundColor Cyan
    ". '$sourcePath'" | Out-File -FilePath $profilePath -Encoding utf8
}

# ---------------------------------------------------------------------------
# 7. Install Nerd Font (Agave Nerd Font)
# ---------------------------------------------------------------------------
$fontName = 'Agave-NF'
$fontInstalled = $null -ne (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "*$fontName*" -ErrorAction SilentlyContinue) -or
                 $null -ne (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name "*$fontName*" -ErrorAction SilentlyContinue) -or
                 (Test-Path "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Fonts\*Agave*")

if (-not $fontInstalled) {
    Write-Host ">>> Installing Nerd Font: Agave Nerd Font" -ForegroundColor Cyan
    scoop install Agave-NF
} else {
    Write-Host ">>> Nerd Font already installed" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 8. Clone Neovim config (lazy.nvim)
# ---------------------------------------------------------------------------
$nvimConfig = "$env:LOCALAPPDATA\nvim"

if (-not (Test-Path "$nvimConfig\.git")) {
    if (Test-Path $nvimConfig) {
        Write-Host ">>> nvim config dir exists but not a git repo, skipping..." -ForegroundColor Yellow
    } else {
        Write-Host ">>> Cloning lazy.nvim config..." -ForegroundColor Cyan
        git clone https://github.com/e-radu/lazy.nvim.git $nvimConfig
    }
} else {
    Write-Host ">>> lazy.nvim config already cloned" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 9. Post-install info
# ---------------------------------------------------------------------------
Write-Host "`n=======================================" -ForegroundColor Magenta
Write-Host "  PowerShell Setup Complete!" -ForegroundColor Magenta
Write-Host "=======================================" -ForegroundColor Magenta
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. Restart PowerShell or run: . `$PROFILE" -ForegroundColor White
Write-Host "  2. If using Windows Terminal, set font to 'Agave Nerd Font'" -ForegroundColor White
Write-Host "  3. Run 'chezmoi apply' to ensure all dotfiles are in place`n" -ForegroundColor White
