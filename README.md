# PVSOperations

PVSOperations is a PowerShell project skeleton for Citrix Provisioning Services (PVS) operations, assessment, alerting, reporting, and Microsoft Teams integration.

The modules target both Windows PowerShell 5.1 and PowerShell 7. The core module exposes assessment functions and thin wrappers around official Citrix PVS cmdlets so they can be mocked during tests or invoked from an administration server.

## Structure

```text
src/
  PVSOperations.Core/
  PVSOperations.Alerting/
  PVSOperations.Reporting/
  PVSOperations.Teams/
config/
data/
reports/
```

## Core functions

`PVSOperations.Core` exports these base functions:

- `Import-PVSOperationsConfig`
- `Write-PVSOperationLog`
- `Invoke-PVSFarmAssessment`
- `Get-PVSFarmSummary`
- `Get-PVSServerAssessment`
- `Get-PVSvDiskAssessment`
- `Get-PVSStoreAssessment`
- `Get-PVSTargetDeviceAssessment`
- `Get-PVSFarmConsistencyAssessment`

It also exports Citrix PVS wrapper functions:

- `Invoke-PVSCommand`
- `Get-PVSFarmInfo`
- `Get-PVSServerInfo`
- `Get-PVSvDiskInfo`
- `Get-PVSStoreInfo`
- `Get-PVSTargetDeviceInfo`

## Quick start

```powershell
Import-Module ./src/PVSOperations.Core/PVSOperations.Core.psd1
$config = Import-PVSOperationsConfig -Path ./config/config.json
$assessment = Invoke-PVSFarmAssessment
```

Run the core module from a machine where the official Citrix PVS PowerShell cmdlets are available, or mock the wrapper functions in tests.

## Remote execution

Wrapper functions accept `-ComputerName`, `-Credential`, and `-ConfigurationName` parameters. This keeps assessment logic independent from the official Citrix PVS cmdlets and allows execution through PowerShell remoting from an administration server.

```powershell
Get-PVSServerInfo -ComputerName 'pvs-admin-01'
```
