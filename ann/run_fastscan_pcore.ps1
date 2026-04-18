$proc = Start-Process -FilePath ".\main_fs.exe" -PassThru -NoNewWindow `
    -RedirectStandardOutput "bench_results\windows_i9_13900h\fastscan\stdout.txt" `
    -RedirectStandardError  "bench_results\windows_i9_13900h\fastscan\stderr.txt"
Start-Sleep -Milliseconds 100
$proc.ProcessorAffinity = [IntPtr]0xFFFF   # P-core only
$proc.PriorityClass = 'High'
$proc.WaitForExit()
Write-Host "done, exit=$($proc.ExitCode)"
Get-Content "bench_results\windows_i9_13900h\fastscan\stdout.txt"