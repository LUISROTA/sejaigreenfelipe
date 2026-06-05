param([int]$port = 8000)
$prefix = "http://localhost:$port/"
$cwd = Get-Location
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Output "Listening on $prefix"
$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.htm'  = 'text/html; charset=utf-8'
  '.js'   = 'application/javascript; charset=utf-8'
  '.mjs'  = 'text/javascript; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.gif'  = 'image/gif'
  '.svg'  = 'image/svg+xml'
  '.wasm' = 'application/wasm'
  '.txt'  = 'text/plain; charset=utf-8'
  '.map'  = 'application/json; charset=utf-8'
}
while($listener.IsListening){
  try {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $path = $req.Url.AbsolutePath.TrimStart('/')
    if([string]::IsNullOrEmpty($path)){ $path='index.html' }
    $path = $path -replace '\.\.', ''
    $full = Join-Path $cwd $path
    if($path -like 'cheetah*'){
      $json = '[]'
      $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
      $ctx.Response.ContentType = 'application/json; charset=utf-8'
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.AddHeader('Access-Control-Allow-Origin','*')
      $ctx.Response.OutputStream.Write($bytes,0,$bytes.Length)
      $ctx.Response.OutputStream.Close()
      continue
    }
    if(Test-Path $full -PathType Leaf){
      $ext = [System.IO.Path]::GetExtension($full).ToLower()
      $type = $mime[$ext]
      if(-not $type){ $type='application/octet-stream' }
      $bytes = [System.IO.File]::ReadAllBytes($full)
      $ctx.Response.ContentType = $type
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.AddHeader('Access-Control-Allow-Origin','*')
      $ctx.Response.OutputStream.Write($bytes,0,$bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
      $msg = 'Not Found'
      $buf = [System.Text.Encoding]::UTF8.GetBytes($msg)
      $ctx.Response.ContentType = 'text/plain; charset=utf-8'
      $ctx.Response.OutputStream.Write($buf,0,$buf.Length)
    }
    $ctx.Response.OutputStream.Close()
  } catch { Write-Error $_; break }
}
$listener.Stop()