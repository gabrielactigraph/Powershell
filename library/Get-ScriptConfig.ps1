#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '1.0.0.1'

function Get-ScriptConfig () {
<#
    .Synopsis
        gets the scripts config file
    .Example
        [xml]$result = Get-ScriptConfig "$($MyInvocation.MyCommand.ScriptName)"
    .Parameter Source
    .INPUTS
        None. You cannot pipe objects to get-ScriptConfig.
    .OUTPUTS
        None.
    .Notes
        NAME: Get-ScriptConfig
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
	#Get Calling scripts file name
	
	[string]$scriptPath = $MyInvocation.ScriptName
	$ParentFolder = Split-Path -Path $scriptPath -Parent 
	$ConfigFile = Join-Path $ParentFolder "$([System.IO.Path]::GetFileNameWithoutExtension($scriptPath)).config"
	
    if ([string]::IsNullOrEmpty($ConfigFile) -eq $true -or (Test-Path $ConfigFile) -eq $false) {
	  	Write-Error "Cound not find the config file $($ConfigFile)"
	}
  	else
	{
  		[xml]$config = Get-Content $ConfigFile
		return $config
  	}

}