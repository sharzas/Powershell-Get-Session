. .\Get-Session.ps1

$Sessions = Get-Session
$Processes = Get-Process

$a=Foreach ($Proc in $Processes[0..10]) {
    Write-Host $Proc.ProcessName
    [PSCustomObject]@{
        Name = $Proc.ProcessName
        ProcessId = $Proc.Id
        SessionName = ($Sessions|Where-Object {$_.Id -eq $Proc.SessionId}).SessionName
        SessionId = $Proc.SessionId
        MemoryUsage = "{0:N0} KB" -f $($Proc.WS/1kb)
        Description = $Proc.MainModule.Description
        Company = $Proc.MainModule.Company
        Product = $Proc.MainModule.Product
        Version = $Proc.MainModule.ProductVersion
        Module = $Proc.MainModule.ModuleName
        FileName = $Proc.MainModule.FileName
    }
}

$a|ft *