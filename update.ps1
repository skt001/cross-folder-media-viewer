$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

# Keep in sync with index.html IMAGE_EXTS / VIDEO_EXTS
$patterns = @(
  '*.jpg','*.jpeg','*.jpe','*.jfif','*.png','*.gif','*.webp','*.bmp','*.avif',
  '*.svg','*.ico','*.heic','*.heif','*.tif','*.tiff',
  '*.mp4','*.webm','*.mov','*.m4v','*.ogv','*.ogg','*.mpg','*.mpeg',
  '*.mkv','*.avi','*.wmv','*.flv','*.3gp'
)

$skipNames = [System.Collections.Generic.HashSet[string]]::new(
  [string[]]@('index.html','update.bat','update.ps1','media.list','使い方.txt')
)

$files = Get-ChildItem -LiteralPath $root -Recurse -File -Include $patterns |
  Where-Object { -not $skipNames.Contains($_.Name) }

$rel = @(
  $files | ForEach-Object {
    $full = $_.FullName
    $prefix = $root.TrimEnd('\') + '\'
    if ($full.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
      ($full.Substring($prefix.Length) -replace '\\', '/')
    }
  } | Where-Object { $_ } | Sort-Object
)

$listPath = Join-Path $root 'media.list'
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllLines($listPath, $rel, $utf8)
Write-Host ("media.list を更新しました: {0} 件" -f $rel.Count)
