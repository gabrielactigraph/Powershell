#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.4.0.4'

<#
Comments
    creates a back up of a folder
#> 

function Backup-Folder([string]$FolderPath)
{
<#
    .Synopsis
        Creates a back up of a folder
    .Description
    .Example
        Backup-Folder "C:\temp\folder1"
        creates a folder "C:\temp\folder1-backupyyyyMMdd-hhmm"
    .Parameter FolderPath
        Path of folder that will be backed up
    .INPUTS
        None. You cannot pipe objects to Backup-Folder.
    .OUTPUTS
        None.
    .Notes
        AUTHOR: max
        LASTEDIT: 19/04/2011
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
  if (test-path -LiteralPath $FolderPath) {
	$FolderToCopy = Get-Item $FolderPath
	$newPath = Join-Path "$($FolderToCopy.Parent.FullName)" "$($FolderToCopy.Name)-backup_$((get-date).toString('yyyyMMdd-hhmm'))"
    
	write-host "copy $($FolderToCopy.FullName) to $newPath"
    
    copy -LiteralPath $FolderPath -Destination "$newPath" -Recurse -Force
  }
}

function Backup-FolderAsZip([string]$FolderPath)
{
  #TODO complete
  if (test-path -LiteralPath $FolderPath) {
	$FolderToCopy = Get-Item $FolderPath
	$newPath = Join-Path "$($FolderToCopy.Parent.FullName)" "$($FolderToCopy.Name)-backup_$((get-date).toString('yyyyMMdd-hhmm')).zip"
	Out-Zip $newPath $FolderToCopy
	#"copy $($FolderToCopy.FullName) to $newPath"
    #copy -LiteralPath $FolderPath -Destination "$newPath" -Recurse -Force
  }
}