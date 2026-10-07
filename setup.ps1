$ProgressPreference = 'SilentlyContinue'

Write-Host "=== 1/4 Stabdomi Teams procesai... ===" -ForegroundColor Cyan
Get-Process -Name "*teams*" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Tiksliniai katalogai
$TeamsFolder = "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\Backgrounds\Uploads"
$ClassicFolder = "$env:APPDATA\Microsoft\Teams\Backgrounds\Uploads"

foreach ($dir in @($TeamsFolder,$ClassicFolder)) {
    if (-not (Test-Path $dir)) { 
        New-Item -ItemType Directory -Path $dir -Force | Out-Null 
    }
}

# Fonų konfigūracija su GUID ir GitHub nuorodomis
$Backgrounds = @(
    @{
        Guid = "a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d"
        Url  = "https://raw.githubusercontent.com/listonas2/fonoteka/refs/heads/main/AUTOVEZIS_BG_TEAMS.png"
        Name = "AUTOVEZIS"
    },
    @{
        Guid = "b2c3d4e5-f6a7-4b6c-9d0e-1f2a3b4c5d6e"
        Url  = "https://raw.githubusercontent.com/listonas2/fonoteka/refs/heads/main/TENTAS_BG_final.png"
        Name = "TENTAS"
    }
)

Write-Host "`n=== 2/4 Siunčiami failai ir generuojami GUID su miniatiūromis... ===" -ForegroundColor Cyan
$wc = New-Object System.Net.WebClient

foreach ($bg in $Backgrounds) {
    Write-Host "Atsiunčiamas $($bg.Name)..." -ForegroundColor Yellow
    $tempFile = "$env:TEMP\$($bg.Guid).png"
    $wc.DownloadFile($bg.Url, $tempFile)
    
    # New Teams aplankas
    Copy-Item $tempFile "$TeamsFolder\$($bg.Guid).png" -Force
    Copy-Item $tempFile "$TeamsFolder\$($bg.Guid)_thumb.png" -Force
    
    # Classic Teams aplankas (atsarginiam palaikymui)
    Copy-Item $tempFile "$ClassicFolder\$($bg.Guid).png" -Force
    Copy-Item $tempFile "$ClassicFolder\$($bg.Guid)_thumb.png" -Force
    
    Write-Host "Sėkmingai paruoštas: $($bg.Name) ($($bg.Guid))" -ForegroundColor Green
}
$wc.Dispose()

Write-Host "`n=== 3/4 Atnaujinamos failų datos, kad fonai būtų viršuje... ===" -ForegroundColor Cyan
$now = Get-Date
foreach ($dir in @($TeamsFolder,$ClassicFolder)) {
    Get-ChildItem -Path $dir -Filter "*.png" | ForEach-Object {
        $_.CreationTime =$now
        $_.LastWriteTime =$now
    }
}
Write-Host "Datos sėkmingai atnaujintos į naujausią laiką!" -ForegroundColor Green

Write-Host "`n=== 4/4 Paleidžiama New Teams... ===" -ForegroundColor Cyan
Start-Process "ms-teams:"

Write-Host "`nPROCESAS BAIGTAS! Patikrinkite Effects and avatars langą." -ForegroundColor Green