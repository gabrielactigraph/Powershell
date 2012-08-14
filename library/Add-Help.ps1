#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '1.0.0.1'
<#
Comments
    Common helper scripts
#>

Function Add-Help
{
<#
    .Synopsis
        creates the a help template where the cursor is 
		Saves time adding help
    .Example
        Add-Help
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: Add-Help
        AUTHOR: blog i cant recal
        LASTEDIT: 12/14/2010 20:53:20
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
 $helpText = @"
<#
    .Synopsis
        This the script does? 
    .Description
    .Example
        Example
        Example accomplishes 
    .Parameter 
        parameterDeets 
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        System.String.
    .Notes
        NAME: Example-
        AUTHOR: $env:username
        LASTEDIT: $(Get-Date -f "yyyy-MM-dd HH:mm:ss")
        KEYWORDS:
    .Link
        Http://www.ostat.com
#Requires -Version 2.0
#>
    Write-verbose ("`$(`$MyInvocation.MyCommand.Name) v`$Version : [Param `$Param]")
"@
 $psise.CurrentFile.Editor.InsertText($helpText)
}