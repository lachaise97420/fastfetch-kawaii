# install.ps1 — install kitty + the kawaii fastfetch config on Windows.
# Run from PowerShell (no admin needed for scoop; winget may prompt for UAC).
param(
    [switch]$NoKitty
)

function Say($msg) { Write-Host "♡ $msg" -ForegroundColor Magenta }
function Warn($msg) { Write-Host "! $msg" -ForegroundColor Yellow }

$ErrorActionPreference = "Stop"

# --- pick a package manager -----------------------------------------------
$pm = $null
if (Get-Command winget -ErrorAction SilentlyContinue) { $pm = "winget" }
elseif (Get-Command scoop -ErrorAction SilentlyContinue) { $pm = "scoop" }
elseif (Get-Command choco -ErrorAction SilentlyContinue) { $pm = "choco" }

if (-not $pm) {
    Warn "No package manager found (winget/scoop/choco)."
    Warn "Install one first: https://winget.run  or  https://scoop.sh"
    exit 1
}

function Install-Pkg($id) {
    switch ($pm) {
        "winget" { winget install --id $id --silent --accept-source-agreements --accept-package-agreements }
        "scoop"  { scoop install $id }
        "choco"  { choco install $id -y }
    }
}

# --- dependencies ---------------------------------------------------------
if (-not (Get-Command fastfetch -ErrorAction SilentlyContinue)) {
    Say "Installing fastfetch via $pm"
    $ffId = if ($pm -eq "winget") { "Fastfetch-cli.Fastfetch" } elseif ($pm -eq "scoop") { "fastfetch" } else { "fastfetch" }
    Install-Pkg $ffId
}

if (-not $NoKitty -and -not (Get-Command kitty -ErrorAction SilentlyContinue)) {
    Say "Installing kitty via $pm"
    $kId = if ($pm -eq "winget") { "kovidgoyal.Kitty" } elseif ($pm -eq "scoop") { "kitty" } else { "kitty" }
    Install-Pkg $kId
}

# --- directories ----------------------------------------------------------
$home = $env:USERPROFILE
$ffCfg = Join-Path $home ".config\fastfetch"
$emblemDir = Join-Path $home "Pictures\ryoemblems"
New-Item -ItemType Directory -Force -Path $ffCfg | Out-Null
New-Item -ItemType Directory -Force -Path $emblemDir | Out-Null

# --- fastfetch config -----------------------------------------------------
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$srcCfg = Join-Path $scriptDir "config.jsonc"
$dstCfg = Join-Path $ffCfg "config.jsonc"
if (Test-Path $srcCfg) {
    Copy-Item $srcCfg $dstCfg -Force
    Say "fastfetch config installed -> $dstCfg"
} else {
    Warn "config.jsonc not found next to install.ps1"
}

# --- emblem (optional) ----------------------------------------------------
$srcEmblem = Join-Path $scriptDir "..\preview.png"
$dstEmblem = Join-Path $emblemDir "loli.png"
if ((Test-Path $srcEmblem) -and -not (Test-Path $dstEmblem)) {
    Copy-Item $srcEmblem $dstEmblem -Force
    Say "emblem installed -> $dstEmblem"
}

# --- kitty user overrides --------------------------------------------------
if (-not $NoKitty) {
    $kittyCfg = Join-Path $home ".config\kitty"
    $kittyUser = Join-Path $kittyCfg "user.conf"
    if (-not (Test-Path $kittyUser)) {
        New-Item -ItemType Directory -Force -Path $kittyCfg | Out-Null
        @'
# User overrides

# Glass terminal
background_opacity 0.6
background_blur 3
text_contrast 40
dynamic_background_opacity yes

# Cute interior borders
window_padding_width 14
window_margin_width 8
window_border_width 2
active_border_color #ff69b4
inactive_border_color #6bb6ff
bell_border_color #ff69b4
draw_minimal_borders no
'@ | Set-Content -Path $kittyUser -Encoding UTF8
        Say "kitty user.conf created"
    } else {
        Say "kitty user.conf already exists — left untouched"
    }
}

Say "done! open a new terminal and run: fastfetch"
Say "♡ have a cute day ♡"
