#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.2.0.1'

function Collapse-Folder([string]$FolderPath) 
{
<#
    .Synopsis
        moves the contence of a folder in to its parent and removes the folder
    .Description
    .Example
        Collapse-Folder C:\foo\bar\
        The contence of bar will be moved in to foo, and folder bar deleted.
    .Parameter Folder
       The folder to process
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: Collapse-Folder
        AUTHOR: max
        LASTEDIT: 12/31/2010 15:48:55
        KEYWORDS:
        Dev:this could alse be called demote (to fit with promote)
    .Link
        Http://www.ostat.com

#>
    Log_Message("$($MyInvocation.MyCommand.Name) v$Version [FolderPath $FolderPath]")
        
    if ([string]::IsNullOrEmpty($FolderPath)) {
        write-error "input value is null. Exiting" 
        break
    }
    
    if ((test-path -LiteralPath $FolderPath -pathtype container) -eq $False) {
        write-error "folder path is invalid : $Folder. Exiting"
        break
    }
              
    #refrence to source folder, and parent folder
    $sourceFolder = get-item -LiteralPath $FolderPath   
    if ($sourceFolder -eq $Null) {
        write-error "cound not get refrence to source folder. Exiting"
        break
    }
    
    $parentFolder = get-item -LiteralPath $sourceFolder.Parent.FullName
    if ($parentFolder -eq $Null) {
        write-error "cound not get refrence to parent folder. Exiting"
        break
    }
    

    #loop all items in the folder that is to be processed
    foreach ($actionItem in get-Childitem -LiteralPath $sourceFolder) 
    {
        Log_Message "moving item to parent folder: $($actionItem.FullName)"
        
        CopyRemove-FileSystemItem $actionItem.FullName $parentFolder.FullName
        
    }
    
    #confirm folder is empty
    if ($sourceFolder.GetDirectories().count -gt 0 -or $sourceFolder.GetFiles().count -gt 0 ) 
    {
        write-error "Source still not not empty. Exiting" 
        Break
    } 
    else 
    {
        write-verbose "removing source folder"
    
        remove-Item -LiteralPath $sourceFolder.FullName ?Force
    }
    
    Log_Message("End - $($MyInvocation.MyCommand.Name)")
}