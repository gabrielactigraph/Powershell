#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.2.0.1'
<#
Comments
    gets the folder size recursive

Change History
version 0.2.0.0
    Added comments 
version 0.1.0.0
    First version
#>

function Get-FolderSize([string]$FolderPath) {
<#
    .Synopsis
        gets the folder size recursive
    .Example
        [long]$result = Get-FolderSize "C:\temp"
    .Parameter Source
    .INPUTS
        None. You cannot pipe objects to Get-FolderSize.
    .OUTPUTS
        None.
    .Notes
        NAME: Get-FolderSize
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-Verbose("$($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")

    [long]$FolderLength = (Get-ChildItem -LiteralPath $FolderPath -Recurse | Measure-Object -Property Length -Sum).Sum
    return $FolderLength 
}