$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$dataDir = Join-Path $root 'data'
$outFile = Join-Path $dataDir 'quran-uthmani.txt'
New-Item -ItemType Directory -Path $dataDir -Force | Out-Null

function Get-QuranAyahCount($path) {
    if (-not (Test-Path $path)) { return 0 }
    $lines = Get-Content -LiteralPath $path -Encoding UTF8
    return ($lines | Where-Object { $_.Length -gt 0 -and -not $_.TrimStart().StartsWith('#') }).Count
}

if ((Get-QuranAyahCount $outFile) -eq 6236) {
    Write-Host 'Official Quran data is already present: 6236 ayahs.' -ForegroundColor Green
    exit 0
}

if (Test-Path $outFile) { Remove-Item $outFile -Force }
$url = 'https://tanzil.net/pub/download/index.php?quranType=uthmani&outType=txt&agree=true'

try {
    Write-Host 'Downloading Uthmani Quran text from the official Tanzil Project...'
    Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing
    $count = Get-QuranAyahCount $outFile
    if ($count -ne 6236) {
        throw "Downloaded Quran data has $count ayahs; expected exactly 6236."
    }
    Write-Host 'Quran text downloaded and verified by verse count: 6236 ayahs.' -ForegroundColor Green
    Write-Host 'Source: Tanzil Project, Quran Text Version 1.1, CC BY 3.0.'
    exit 0
}
catch {
    if (Test-Path $outFile) { Remove-Item $outFile -Force }
    Write-Error ("Could not download a valid Quran text from the official Tanzil source. " + $_.Exception.Message)
    exit 1
}