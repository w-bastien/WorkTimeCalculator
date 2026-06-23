Set-StrictMode -Version 2.0

function Get-PVSObjectPropertyValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [object] $InputObject,

        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    if ($null -eq $InputObject) {
        return $null
    }

    $property = $InputObject.PSObject.Properties[$Name]
    if ($property) {
        return $property.Value
    }

    return $null
}

function Import-PVSOperationsConfig {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string] $Path = (Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath 'config/config.json')
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Configuration file not found: $Path"
    }

    $raw = Get-Content -LiteralPath $Path -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) {
        throw "Configuration file is empty: $Path"
    }

    return $raw | ConvertFrom-Json
}

function Write-PVSOperationLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message,

        [ValidateSet('Debug', 'Info', 'Warning', 'Error')]
        [string] $Level = 'Info',

        [string] $Path
    )

    $entry = [pscustomobject]@{
        Timestamp = (Get-Date).ToString('o')
        Level     = $Level
        Message   = $Message
    }

    $line = '{0} [{1}] {2}' -f $entry.Timestamp, $entry.Level.ToUpperInvariant(), $entry.Message
    if ($Path) {
        $directory = Split-Path -Parent $Path
        if ($directory -and -not (Test-Path -LiteralPath $directory)) {
            New-Item -Path $directory -ItemType Directory -Force | Out-Null
        }
        Add-Content -LiteralPath $Path -Value $line
    }

    Write-Verbose $line
    return $entry
}

function Invoke-PVSCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $CommandName,

        [hashtable] $Parameters = @{},

        [string] $ComputerName,

        [pscredential] $Credential,

        [string] $ConfigurationName = 'Microsoft.PowerShell',

        [scriptblock] $Fallback
    )

    if ($ComputerName) {
        $invokeParameters = @{
            ComputerName      = $ComputerName
            ConfigurationName = $ConfigurationName
            ScriptBlock       = {
                param($RemoteCommandName, $RemoteParameters)
                & $RemoteCommandName @RemoteParameters
            }
            ArgumentList      = @($CommandName, $Parameters)
        }

        if ($Credential) {
            $invokeParameters.Credential = $Credential
        }

        return Invoke-Command @invokeParameters
    }

    $command = Get-Command -Name $CommandName -ErrorAction SilentlyContinue
    if ($command) {
        return & $command @Parameters
    }

    if ($Fallback) {
        return & $Fallback
    }

    throw "Citrix PVS command '$CommandName' is not available. Install the Citrix PVS PowerShell snap-in/module or run from a PVS administration server."
}

function Get-PVSFarmInfo {
    [CmdletBinding()]
    param(
        [hashtable] $Parameters = @{},
        [string] $ComputerName,
        [pscredential] $Credential,
        [string] $ConfigurationName = 'Microsoft.PowerShell'
    )
    Invoke-PVSCommand -CommandName 'Get-PvsFarm' -Parameters $Parameters -ComputerName $ComputerName -Credential $Credential -ConfigurationName $ConfigurationName -Fallback { [pscustomobject]@{ Name = 'Unknown'; SiteCount = 0 } }
}

function Get-PVSServerInfo {
    [CmdletBinding()]
    param(
        [hashtable] $Parameters = @{},
        [string] $ComputerName,
        [pscredential] $Credential,
        [string] $ConfigurationName = 'Microsoft.PowerShell'
    )
    Invoke-PVSCommand -CommandName 'Get-PvsServer' -Parameters $Parameters -ComputerName $ComputerName -Credential $Credential -ConfigurationName $ConfigurationName -Fallback { @() }
}

function Get-PVSvDiskInfo {
    [CmdletBinding()]
    param(
        [hashtable] $Parameters = @{},
        [string] $ComputerName,
        [pscredential] $Credential,
        [string] $ConfigurationName = 'Microsoft.PowerShell'
    )
    Invoke-PVSCommand -CommandName 'Get-PvsDisk' -Parameters $Parameters -ComputerName $ComputerName -Credential $Credential -ConfigurationName $ConfigurationName -Fallback { @() }
}

function Get-PVSStoreInfo {
    [CmdletBinding()]
    param(
        [hashtable] $Parameters = @{},
        [string] $ComputerName,
        [pscredential] $Credential,
        [string] $ConfigurationName = 'Microsoft.PowerShell'
    )
    Invoke-PVSCommand -CommandName 'Get-PvsStore' -Parameters $Parameters -ComputerName $ComputerName -Credential $Credential -ConfigurationName $ConfigurationName -Fallback { @() }
}

function Get-PVSTargetDeviceInfo {
    [CmdletBinding()]
    param(
        [hashtable] $Parameters = @{},
        [string] $ComputerName,
        [pscredential] $Credential,
        [string] $ConfigurationName = 'Microsoft.PowerShell'
    )
    Invoke-PVSCommand -CommandName 'Get-PvsDevice' -Parameters $Parameters -ComputerName $ComputerName -Credential $Credential -ConfigurationName $ConfigurationName -Fallback { @() }
}

function Get-PVSFarmSummary {
    [CmdletBinding()]
    param()

    $farm = Get-PVSFarmInfo
    $servers = @(Get-PVSServerInfo)
    $vDisks = @(Get-PVSvDiskInfo)
    $stores = @(Get-PVSStoreInfo)
    $devices = @(Get-PVSTargetDeviceInfo)

    [pscustomobject]@{
        Farm          = $farm
        ServerCount   = $servers.Count
        VDiskCount    = $vDisks.Count
        StoreCount    = $stores.Count
        DeviceCount   = $devices.Count
        AssessedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    }
}

function Get-PVSServerAssessment {
    [CmdletBinding()]
    param()
    @(Get-PVSServerInfo) | ForEach-Object {
        [pscustomobject]@{
            Name   = Get-PVSObjectPropertyValue -InputObject $_ -Name 'Name'
            Status = if (Get-PVSObjectPropertyValue -InputObject $_ -Name 'Status') { Get-PVSObjectPropertyValue -InputObject $_ -Name 'Status' } else { 'Unknown' }
            Object = $_
        }
    }
}

function Get-PVSvDiskAssessment {
    [CmdletBinding()]
    param()
    @(Get-PVSvDiskInfo) | ForEach-Object {
        [pscustomobject]@{
            Name        = if (Get-PVSObjectPropertyValue -InputObject $_ -Name 'Name') { Get-PVSObjectPropertyValue -InputObject $_ -Name 'Name' } else { Get-PVSObjectPropertyValue -InputObject $_ -Name 'DiskLocatorName' }
            Size        = Get-PVSObjectPropertyValue -InputObject $_ -Name 'Size'
            AccessMode  = Get-PVSObjectPropertyValue -InputObject $_ -Name 'AccessMode'
            CacheType   = Get-PVSObjectPropertyValue -InputObject $_ -Name 'CacheType'
            Object      = $_
        }
    }
}

function Get-PVSStoreAssessment {
    [CmdletBinding()]
    param()
    @(Get-PVSStoreInfo) | ForEach-Object {
        [pscustomobject]@{
            Name   = Get-PVSObjectPropertyValue -InputObject $_ -Name 'Name'
            Path   = Get-PVSObjectPropertyValue -InputObject $_ -Name 'Path'
            Status = 'Unknown'
            Object = $_
        }
    }
}

function Get-PVSTargetDeviceAssessment {
    [CmdletBinding()]
    param()
    @(Get-PVSTargetDeviceInfo) | ForEach-Object {
        [pscustomobject]@{
            Name       = Get-PVSObjectPropertyValue -InputObject $_ -Name 'Name'
            Collection = Get-PVSObjectPropertyValue -InputObject $_ -Name 'CollectionName'
            VDisk      = Get-PVSObjectPropertyValue -InputObject $_ -Name 'DiskLocatorName'
            Status     = if (Get-PVSObjectPropertyValue -InputObject $_ -Name 'Status') { Get-PVSObjectPropertyValue -InputObject $_ -Name 'Status' } else { 'Unknown' }
            Object     = $_
        }
    }
}

function Get-PVSFarmConsistencyAssessment {
    [CmdletBinding()]
    param()

    $summary = Get-PVSFarmSummary
    [pscustomobject]@{
        IsConsistent = $true
        Findings     = @()
        Summary      = $summary
    }
}

function Invoke-PVSFarmAssessment {
    [CmdletBinding()]
    param()

    [pscustomobject]@{
        Summary       = Get-PVSFarmSummary
        Servers       = @(Get-PVSServerAssessment)
        VDisks        = @(Get-PVSvDiskAssessment)
        Stores        = @(Get-PVSStoreAssessment)
        TargetDevices = @(Get-PVSTargetDeviceAssessment)
        Consistency   = Get-PVSFarmConsistencyAssessment
    }
}
