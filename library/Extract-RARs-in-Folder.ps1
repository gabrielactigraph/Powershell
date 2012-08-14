#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.2.0.1'

<#
Comments
    Extracts all the rar files in the folder
#>
function Extract-RARs-in-Folder([string]$Folder) {
<#
    .Synopsis
        Extracts all the rar files in the folder
    .Description
    .Example
        Extract-RARs-in-Folder C:\temp\
        would extract C:\temp\foo.rar and C:\temp\bar.rar
    .Parameter Folder
        Path of folder to be processed 
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None
    .Notes
        NAME: Extract-RARs-in-Folder
        AUTHOR: max
        LASTEDIT: 2011-01-01 08:42:12
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version : [Folder $Folder]")
    Log_Message("Action - Extract-RARs-in-Folder $Folder")
      
    #refrence to source folder
    $BasketFolder = get-item -LiteralPath $Folder   

    $rarFiles = get-Childitem -LiteralPath $BasketFolder.FullName -recurse |  
    where{$_.Name -match ".*(?:(?<!\.part\d\d\d|\.part\d\d|\.part\d)\.rar|\.part0*1\.rar)"} 
    
    foreach ($rarfile in $rarFiles){ 
        #if none are foung an empty object is returned filter these by checking if the object exists
        if ($rarfile.Exists -eq $true)
        {
            write-verbose "processing matched rar : $($rarfile.Name)"
            if ($rarfile.Directory.Name -ne "Trash" -and $rarfile.Directory.Name -ne "subs"  -and $rarfile.Directory.Name -ne "Subtitles" )
            { 
                #this is a hack needed because we remove rar files in the loop.
                #regexp should only match on  rar 1 riles
                if (Test-Path $rarfile.Fullname  ) 
                {
                    
                    #refrence to source folder
                    $logFolder = join-path -path $rarfile.Directory.Fullname -childpath "Log"
                    
                    #$logPath = Prepaire-New-logFile $logFolder "Extract-RAR-File"
                    $logPath = Create-TempLogFile "Extract-RAR-File"
            
                    Start-Transcript $logPath
                    
                    $result =  Extract-RAR-File $rarfile.FullName $true -debug 
                    
                    Stop-Transcript
                }
            }
            else
            {
                write-verbose "skipping item due to folder name$($_.FullName)"
            }
        }
    }
    
    Log_Message("Action End - Extract-RARs-in-Folder : $($BasketFolder.Name)")
}
