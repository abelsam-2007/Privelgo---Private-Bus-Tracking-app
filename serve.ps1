# PowerShell Simple HTTP Web Server
# Serves static files from the dashboard directory on http://localhost:5000/

$port = 5000
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")

try {
    $listener.Start()
    Write-Host "===================================================="
    Write-Host " Privelgo Dashboard Server running at http://localhost:$port/"
    Write-Host " Press Ctrl+C in PowerShell to stop"
    Write-Host "===================================================="
    
    $baseDir = "c:\Users\LOQ\OneDrive\Documents\ABELSAM\dashboard"
    
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $localPath = $request.Url.LocalPath
        if ($localPath -eq "/") {
            $localPath = "/index.html"
        }
        
        # Sanitize path to prevent directory traversal
        $sanitizedPath = $localPath.Replace("..", "").TrimStart('/')
        $filePath = [System.IO.Path]::Combine($baseDir, $sanitizedPath)
        
        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            
            # Content Type mappings
            if ($filePath -like "*.html") { $response.ContentType = "text/html; charset=utf-8" }
            elseif ($filePath -like "*.css") { $response.ContentType = "text/css; charset=utf-8" }
            elseif ($filePath -like "*.js") { $response.ContentType = "application/javascript; charset=utf-8" }
            elseif ($filePath -like "*.png") { $response.ContentType = "image/png" }
            elseif ($filePath -like "*.jpg" -or $filePath -like "*.jpeg") { $response.ContentType = "image/jpeg" }
            
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $errBytes = [System.Text.Encoding]::UTF8.GetBytes("File Not Found: $localPath")
            $response.ContentLength64 = $errBytes.Length
            $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
        }
        $response.Close()
    }
}
catch {
    Write-Error "Error starting listener: $_"
}
finally {
    $listener.Stop()
}
