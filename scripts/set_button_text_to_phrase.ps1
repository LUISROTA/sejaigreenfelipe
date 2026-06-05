$files = @("index.html","remote_ronaldo.html","index.backup-20260524-120733.html","index.before-clone-remote.bak.html","index.before-text-fix.bak.html")
foreach ($f in $files) {
    $p = Join-Path (Get-Location) $f
    if (Test-Path $p) {
        $content = Get-Content -LiteralPath $p -Raw -Encoding UTF8
        $new = $content -replace '"text":"Contato"','"text":"Contacte igreen max no WhatsApp."'
        if ($new -ne $content) {
            Set-Content -LiteralPath $p -Value $new -Encoding UTF8
            Write-Output "Updated: $f"
        } else {
            Write-Output "No change: $f"
        }
    } else {
        Write-Output "Missing: $f"
    }
}
