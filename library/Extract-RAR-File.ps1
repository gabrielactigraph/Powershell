#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.3.1.4'
<#
Comments
    unrars a rar file or set of rar files, then if "all ok" removes the rar files
#>


#########################################################
#Load config from file
#########################################################
[xml]$configFile = get-ScriptConfig
if ($configFile -eq $null) {
  	Write-Error "Failed to load config`nExiting"
	Exit}

#path to unrar.exe I.E. c:\bin\unrar\unrar.exe
$Script:unrarName =  $configFile.Configuration.UnRarExePath 
	
function Extract-RAR-File([string]$FilePath, [bool]$RemoveSuccessfull = $false) 
{
<#
    .Synopsis
        unrars a file or set of rar files, then if "all ok" removes the rar files
    .Description
    .Example
        Extract-RAR-File c:\temp\foo.rar
        Extracts contence of foo.rar to folder temp.
    .Parameter FilePath
        path to rar file 
    .Parameter RemoveSuccessfull
        remove rar files if successfull
    .INPUTS
        None. You cannot pipe objects to Extract-RAR-File.
    .OUTPUTS
        System.String.
    .Notes
        NAME: Extract-RAR-File
        AUTHOR: max
        LASTEDIT: 2011-01-01 08:11:03
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version : [FilePath $FilePath, RemoveSuccessfull $RemoveSuccessfull]")
    
    # Verify we can access UNRAR.EXE .
	if ([string]::IsNullOrEmpty($unrarName) -or (Test-Path -LiteralPath $unrarName) -ne $true)
	{
	    Write-Error "Unrar.exe path does not exist '$unrarPath'."
        return
    }
	
    [string]$unrarPath = $(Get-Command $unrarName).Definition
    if ( $unrarPath.Length -eq 0 )
    {
        Write-Error "Unable to access unrar.exe at location '$unrarPath'."
        return
    }

   # Verify we can access to the compressed file.
	if ([string]::IsNullOrEmpty($FilePath) -or (Test-Path -LiteralPath $FilePath) -ne $true)
	{
	    Write-Error "Compressed file does not exist '$FilePath'."
        return
    }
	
    [System.IO.FileInfo]$Compressedfile = get-item -LiteralPath $FilePath 
    
    #set Destination to basepath folder
    #$fileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($Compressedfile.Name)
    #$DestinationFolder = join-path -path $Compressedfile.DirectoryName -childpath $fileBaseName
    
    #set Destination to parent folder
    $DestinationFolder = $Compressedfile.DirectoryName 

    # If the extract directory does not exist, create it.
    CreateDirectoryIfNeeded ( $DestinationFolder ) | out-null

    Write-Output "Extracting files into $DestinationFolder"
    &$unrarPath x -y  $FilePath $DestinationFolder | tee-object -variable unrarOutput 
    
    #display the output of the rar process as verbose
    $unrarOutput | ForEach-Object {Write-Verbose $_ }
     
    if ( $LASTEXITCODE -ne 0 )
    { 
        # There was a problem extracting. 
        #Get-Content $unrarOutput 
        #Display errror
        Write-Error "Error extracting the .RAR file" 
    }
    else
    {
        # check $SevenZipOutput to remove files
        #"^All OK$"
        Write-Verbose "Checking output for OK tag"  
        if ($unrarOutput -match "^All OK$" -ne $null) {
            if ($RemoveSuccessfull) {
                Write-Verbose "Removing files"  
                
                #remove rar files listed in output.
                $unrarOutput -match "(?<=Extracting\sfrom\s)(?<rarfile>.*)$" | 
                ForEach-Object {$_ -replace 'Extracting from ', ''} | 
                foreach-object { get-item -LiteralPath $_ } | 
                remove-item
                
            } else {
                Write-Verbose "Moving files to trash folder`n$trashPath"  
        
                [string]$trashPath = join-path -path $DestinationFolder "Trash"
                
                #create trash folder to move rars to
                CreateDirectoryIfNeeded ($trashPath)
                
                #move rar files listed in output.
                $unrarOutput -match "(?<=Extracting\sfrom\s)(?<rarfile>.*)$" | 
                ForEach-Object {$_ -replace 'Extracting from ', ''} | 
                foreach-object { get-item -LiteralPath $_ } | 
                move-item -destination $trashPath
            }
        }
    }
}