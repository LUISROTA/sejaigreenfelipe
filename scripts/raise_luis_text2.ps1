$files = @("index.html","remote_ronaldo.html","index.backup-20260524-120733.html","index.before-clone-remote.bak.html","index.before-text-fix.bak.html")
$pattern = '"top":"159.75px","left":"328.95001220703125px"'
$replace = '"top":"129.75px","left":"328.95001220703125px"'
foreach ($f in $files) {
    $p = Join-Path (Get-Location) $f
    if (Test-Path $p) {
        $content = Get-Content -LiteralPath $p -Raw -Encoding UTF8
        $newContent = $content -replace $pattern, $replace
        if ($newContent -ne $content) {
            Set-Content -LiteralPath $p -Value $newContent -Encoding UTF8
            Write-Output "Updated: $f"
        } else { Write-Output "No change: $f" }
    } else { Write-Output "Missing: $f" }
}
