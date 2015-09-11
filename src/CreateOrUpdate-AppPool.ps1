function CreateOrUpdate-AppPool {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string] $poolName,
        [Parameter(Mandatory=$true)][string] $username,
        [Parameter(Mandatory=$true)][string] $password
    )

    Import-Module WebAdministration

    $poolPath = "IIS:\AppPools\$poolName"
    $pool = Get-Item $poolPath -ErrorAction SilentlyContinue

    if ($pool -eq $null) {
        $pool = New-WebAppPool -Name $poolName -Force

        if ($pool -eq $null) {
            Write-Host "$poolName pool failed to create." 
            return
        }
        else {
            Write-Host "$poolName pool was successfully created."
        }
    }
    else {
        Write-Host "$poolName pool already exists."
    }

    $pool.processModel.userName = $username
    $pool.processModel.password = $password
    $pool.processModel.identityType = 'SpecificUser'
    $pool.managedRuntimeVersion = 'v4.0'
    $pool | Set-Item $poolPath

    Write-Host "$poolName pool credentials updated successfully."
}