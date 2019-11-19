. .\Get-Session.ps1

function Get-ProcessList ()
{
    Param (
        $Processes
    )

    $Sessions = Get-Session  # JNPSFunctions Required

    Foreach ($Proc in $Processes) {
        [PSCustomObject]@{
            Name = $Proc.ProcessName
            ProcessId = $Proc.Id
            SessionName = ($Sessions|Where-Object {$_.Id -eq $Proc.SessionId}).SessionName
            SessionId = $Proc.SessionId
            MemoryUsage = "{0:N0} KB" -f $($Proc.WS/1kb)
            Description = $Proc.Description
            Company = $Proc.Company
            Product = $Proc.Product
            Version = $Proc.ProductVersion
            Module = $Proc.ModuleName
            FileName = $Proc.FileName
        }
    }
}


$Processes = Get-Process|Select-Object "ProcessName", 
"Id", 
"WS",
"SessionId",
@{N="FileName"; E={$_.MainModule.FileName}}, 
@{N="Description"; E={$_.MainModule.Description}},
@{N="Company"; E={$_.MainModule.Company}},
@{N="Product"; E={$_.MainModule.Product}},
@{N="ProductVersion"; E={$_.MainModule.ProductVersion}},
@{N="ModuleName"; E={$_.MainModule.ModuleName}}

Get-ProcessList -Processes $Processes