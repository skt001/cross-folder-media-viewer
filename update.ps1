# update.ps1 - builds media.json (an index of the images/videos under this folder).
# ASCII only on purpose: Windows PowerShell 5.1 reads BOM-less UTF-8 scripts as ANSI.
# Runs on Windows PowerShell 5.1 (powershell.exe, built into Windows) and on PowerShell 7.

$ErrorActionPreference = 'Stop'

try {
    try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

    $root = $PSScriptRoot
    if (-not $root) { $root = Split-Path -Parent $MyInvocation.MyCommand.Path }
    $outName = 'media.json'
    $logPath = Join-Path $root 'update.log'
    Remove-Item -LiteralPath $logPath -Force -ErrorAction SilentlyContinue

    function Write-Log([string]$msg) {
        Write-Host $msg
        Add-Content -LiteralPath $logPath -Value $msg -Encoding UTF8
    }

    # extension -> kind. Whether a browser can show a file is not judged here.
    $imageExts = 'jpg jpeg jpe jfif jif jfi pjpeg pjp png apng gif webp bmp dib avif avifs svg svgz ico cur ' +
        'heic heif heics heifs hif tif tiff jxl jp2 j2k j2c jpf jpx jpm jxr wdp hdp tga icb vda vst pcx ' +
        'pbm pgm ppm pnm pam xbm xpm psd psb exr hdr dds icns wbmp ' +
        'dng cr2 cr3 crw nef nrw arw srf sr2 orf raf rw2 rwl pef srw x3f 3fr erf mef mrw kdc dcr iiq'
    $videoExts = 'mp4 webm mov qt m4v ogv ogg mpg mpeg mkv avi wmv flv 3gp 3g2 3gpp 3gp2 mp4v mpe mpv m1v m2v ' +
        'vob ogm asf wm rm rmvb divx f4v mts m2ts m2t tp trp ts mod dat mxf dv ivf y4m nsv amv lrv insv ' +
        'gifv wtv dvr-ms h264 h265 hevc 264 265'

    $kindOf = @{}   # PowerShell hashtables are case-insensitive
    foreach ($e in ($imageExts -split '\s+')) { if ($e) { $kindOf[$e] = 'image' } }
    foreach ($e in ($videoExts -split '\s+')) { if ($e) { $kindOf[$e] = 'video' } }

    # Walk the tree. An unreadable folder does not stop the run; it is reported instead.
    # Links (reparse points) to folders are not followed, to avoid loops; they are reported too.
    $sep = [System.IO.Path]::DirectorySeparatorChar
    $prefix = $root.TrimEnd($sep, '/', '\') + $sep
    $paths = New-Object 'System.Collections.Generic.List[string]'
    $kinds = New-Object 'System.Collections.Generic.List[string]'
    $exts = New-Object 'System.Collections.Generic.List[string]'
    $skipped = New-Object 'System.Collections.Generic.List[string]'
    $stack = New-Object 'System.Collections.Generic.Stack[string]'
    $stack.Push($root)

    while ($stack.Count -gt 0) {
        $dir = $stack.Pop()
        try {
            $files = [System.IO.Directory]::GetFiles($dir)
            $subs = [System.IO.Directory]::GetDirectories($dir)
        } catch {
            $skipped.Add($dir)
            continue
        }

        foreach ($f in $files) {
            $name = [System.IO.Path]::GetFileName($f)
            if ($name.StartsWith('.')) { continue } # dotfiles are hidden by convention; excluded
            $dot = $name.LastIndexOf('.')
            if ($dot -le 0 -or $dot -eq ($name.Length - 1)) { continue }
            $ext = $name.Substring($dot + 1).ToLowerInvariant()
            if (-not $kindOf.ContainsKey($ext)) { continue }
            $rel = $f.Substring($prefix.Length)
            if ($sep -eq '\') { $rel = $rel.Replace('\', '/') }
            $paths.Add($rel)
            $kinds.Add($kindOf[$ext])
            $exts.Add($ext)
        }

        foreach ($d in $subs) {
            $dname = [System.IO.Path]::GetFileName($d)
            if ($dname.StartsWith('.')) { continue } # dot-folders are hidden by convention; not walked
            $isLink = $false
            try {
                $attr = [System.IO.File]::GetAttributes($d)
                $isLink = (($attr -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
            } catch {
                $skipped.Add($d)
                continue
            }
            if ($isLink) { $skipped.Add($d) } else { $stack.Push($d) }
        }
    }

    # Stable, culture-independent order. Sort an index array by path, then apply it to kind/ext.
    $n = $paths.Count
    $order = New-Object 'int[]' $n
    for ($i = 0; $i -lt $n; $i++) { $order[$i] = $i }
    $pathArr = $paths.ToArray()
    [System.Array]::Sort($pathArr, $order, [System.StringComparer]::Ordinal)
    $kindArr = New-Object 'string[]' $n
    $extArr = New-Object 'string[]' $n
    for ($i = 0; $i -lt $n; $i++) {
        $kindArr[$i] = $kinds[$order[$i]]
        $extArr[$i] = $exts[$order[$i]]
    }

    # Build JSON by hand: exact names, and fast on Windows PowerShell 5.1.
    $special = [char[]]((0..31) + 34 + 92)
    $evaluator = [System.Text.RegularExpressions.MatchEvaluator]{
        param($m)
        $c = [int][char]$m.Value
        if ($c -eq 34) { '\"' } elseif ($c -eq 92) { '\\' } else { '\u{0:x4}' -f $c }
    }
    function Quote-Json([string]$s) {
        if ($s.IndexOfAny($special) -ge 0) {
            $s = [regex]::Replace($s, '["\\\x00-\x1f]', $evaluator)
        }
        return '"' + $s + '"'
    }

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('[')
    for ($i = 0; $i -lt $pathArr.Length; $i++) {
        if ($i -gt 0) { [void]$sb.Append(',') }
        [void]$sb.Append("`n")
        [void]$sb.Append('{"path":' + (Quote-Json $pathArr[$i]) + ',"kind":"' + $kindArr[$i] + '","ext":' + (Quote-Json $extArr[$i]) + '}')
    }
    [void]$sb.Append("`n]`n")

    # Write to a temporary file, then replace: a failed run leaves the previous media.json intact.
    $out = Join-Path $root $outName
    $tmp = $out + '.tmp'
    try {
        [System.IO.File]::WriteAllText($tmp, $sb.ToString(), (New-Object System.Text.UTF8Encoding $false))
        Move-Item -LiteralPath $tmp -Destination $out -Force
    } finally {
        if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
    }

    $nImg = @($kindArr | Where-Object { $_ -eq 'image' }).Count
    $nVid = @($kindArr | Where-Object { $_ -eq 'video' }).Count
    Write-Log ("{0} updated: {1} items (images {2}, videos {3})" -f $outName, $pathArr.Length, $nImg, $nVid)
    if ($skipped.Count -gt 0) {
        Write-Log ("Skipped {0} folder(s) (unreadable, path too long, or a link that is not followed):" -f $skipped.Count)
        foreach ($s in $skipped) { Write-Log ("  " + $s) }
    }
} catch {
    Write-Host ("ERROR: " + $_.Exception.Message)
    try { Add-Content -LiteralPath $logPath -Value ("ERROR: " + $_.Exception.Message) -Encoding UTF8 } catch { }
    exit 1
}
