@{
    RootModule        = 'PVSOperations.Core.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '4a7aa2cc-829e-46d6-b75d-4e9218461a21'
    Author            = 'PVS Operations'
    CompanyName       = 'PVS Operations'
    Copyright         = '(c) PVS Operations. All rights reserved.'
    Description       = 'Core assessment and Citrix PVS wrapper functions for PVS Operations.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Import-PVSOperationsConfig',
        'Write-PVSOperationLog',
        'Invoke-PVSFarmAssessment',
        'Get-PVSFarmSummary',
        'Get-PVSServerAssessment',
        'Get-PVSvDiskAssessment',
        'Get-PVSStoreAssessment',
        'Get-PVSTargetDeviceAssessment',
        'Get-PVSFarmConsistencyAssessment',
        'Invoke-PVSCommand',
        'Get-PVSFarmInfo',
        'Get-PVSServerInfo',
        'Get-PVSvDiskInfo',
        'Get-PVSStoreInfo',
        'Get-PVSTargetDeviceInfo'
    )
    CmdletsToExport   = @()
    VariablesToExport = '*'
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags       = @('Citrix', 'PVS', 'Operations', 'Monitoring')
            ProjectUri = 'https://example.invalid/PVSOperations'
        }
    }
}
