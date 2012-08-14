#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.3.0.2'
<#
Comments
    copys an item (the source) to a new destination, then deletes the source if copy was successful
#>

function CopyRemove-FileSystemItem([string]$Source, [string]$Target) 
{
<#
    .Synopsis
        Moves an item from one location to another. If move-item fails performs copy and delete.
    .Description
        Move-item is the same as rename, and only works when source and destination are the same drive.
		
		Function will attempt to use Move-Item, if this fails it will perform a copy and remove.
        
    .Example
        CopyRemove-FileSystemItem  c:\temp\testMove c:\temp\testMoveDest -verbose
        moves testMove to c:\temp\testMoveDest\testMove
    .Parameter Source
        Source folder to be moved
    .Parameter Target
        Targettarget location (will become source folders parent)
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS Destination
        destination path
    .Notes
        NAME: CopyRemove-FileSystemItem
        AUTHOR: max
        LASTEDIT: 12/31/2010 16:00:59
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version [Source $Source, Target $Target]")

    if ([string]::IsNullOrEmpty($Source) -eq $true -or (test-path -LiteralPath $Source) -ne $True)
    {
        Write-Error("Source does not exist or is blank : '$source'")
        return
    }  
    
    #Create Target folder if needed
    if ([string]::IsNullOrEmpty($Target) -eq $true)
    {
        Write-Error("Target is blank : '$Target'")
        return
    }  
    
    CreateDirectoryIfNeeded($Target)
    if ([string]::IsNullOrEmpty($Target) -eq $true -or (test-path -LiteralPath $Target) -ne $True)
    {
        Write-Error("Target Could not be created : '$Target'")
        return
    }
    
    $SourceItem = get-item -LiteralPath $Source -Force
    
    #Check what type of item it is 
    if ($SourceItem.GetType().Name -eq 'DirectoryInfo')
    {
        Write-verbose ("item is a folder")
        
        #New folder for moved item 
        $Destination = join-path -path $Target -childpath $SourceItem.Name
          
        #Create new folder if needed
        Write-Host("Destination folder : '$Destination'")
        CreateDirectoryIfNeeded($Destination)
        if ((test-path -LiteralPath $Destination) -ne $True)
        {
            Write-error ("unable to create Destination folder : '$Destination'")
            return
        }
        
        #loop all items in the folder
        foreach ($ChildItem in get-Childitem -LiteralPath $SourceItem -Force)
        {
            Write-verbose ("Processing item: " +  $ChildItem.FullName)
            
            #move child item
            CopyRemove-FileSystemItem $ChildItem.FullName $Destination | out-null
       
            Write-verbose ("Item complete : " +  $ChildItem.FullName)
        }
            
        #Remove what should be an empty folder    
        #if target folder exists and source folder is empty, remove source
        if ((test-path -LiteralPath $SourceItem.FullName) -eq $True)
        {
            Write-verbose ("Found target folder. Number of children remaining in source (expected 0) : '$($SourceItem.GetFiles().Count)'")
            
            if ($SourceItem.GetFiles().Count -eq 0)
            {
                write-verbose ("removing '$($SourceItem.FullName)'")
                remove-item -LiteralPath $SourceItem.FullName -Force | out-null
            }
            else
            {
                Write-error ("Source is not empty, skipping source removal")
           }
        }
        else
        {
            Write-verbose ("Expected target folder does not exist, skipping source removal")
        }
    }     
    else
    {
        Write-verbose("copying file : " + $SourceItem.FullName)

        #expected new file name
        $targetName = join-path -path $Target -childpath $SourceItem.Name
                
        #try moving the item (move is really rename) and is the fastest method
        move-item -LiteralPath $SourceItem.FullName -destination $Target -Force 
        
        #confirm that the file moved successfully
        if ((test-path -LiteralPath $targetName) -eq $False -or (test-path -LiteralPath $SourceItem.FullName) -eq $True )
        {
            #if the move failed copy and remove the copy file to new location        
            copy-item -LiteralPath $SourceItem.FullName -destination $Target -Force 
            
            #confirm that the file copied successfully
            if ((test-path -LiteralPath $targetName) -ne $True)
            {
                Write-Error ("Target file does not exist, skipping source file removal")
            }
            else
            {
                #TODO : check size, hash, date
                
                #del old file
                Write-verbose ("removing " + $SourceItem.FullName)
                remove-item -LiteralPath $SourceItem.FullName -Force | out-null
            }
        }
    }  
    
    Write-verbose ("Task - Move completed, new name '$Destination'")
    
    return $Destination 
}


function CopyRemove-Folder([string]$Source, [string]$Target) 
{
<#
    .Synopsis
        copies a folder to a new location and removes original
        not really needed, could call CopyRemove-FileSystemItem directly (supports legacy scripts)
        
    .Example
        CopyRemove-Folder  c:\temp\testMove c:\temp\testMoveDest -verbose
        moves testMove to c:\temp\testMoveDest\testMove
    .Parameter Source
        Source folder to be moved
    .Parameter Target
        Targettarget location (will become source folders parent)
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: CopyRemove-Folder
        AUTHOR: max
        LASTEDIT: 12/31/2010 16:00:59
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version [Source $Source, Target $Target]")

    if ([string]::IsNullOrEmpty($Source) -eq $true -or (test-path -LiteralPath $Source) -ne $True)
    {
        Write-Error("Source does not exist : '$Source'")
        return
    }  
    
    $SourceItem = get-item -LiteralPath $Source 

    #Check what type of item it is 
    if ($SourceItem.GetType().Name -eq 'DirectoryInfo')
    {
        Write-verbose ("Confirmed source is a folder")
        CopyRemove-FileSystemItem $SourceItem.FullName $Target | out-null
    }     
    else
    {
         Write-Error("Source is not a folder, Ending")
         return
    }  
    
}

function CopyRemove-ChildFolders([string]$Source, [string]$Destination) 
{
<#
    .Synopsis
        Copies all the folders in the source to the destination
        
    .Example
       CopyRemove-ChildFolders  c:\temp\testMove c:\temp\testMoveDest -verbose
       all folders in testMove will be moved to to c:\temp\testMoveDest\
    .Parameter Source
        Source folder to be moved
    .Parameter Target
        Targettarget location (will become source folders parent)
    .INPUTS
        None. You cannot pipe objects to Add-Extension.
    .OUTPUTS
        None.
    .Notes
        NAME: CopyRemove-Folder
        AUTHOR: max
        LASTEDIT: 12/31/2010 16:00:59
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version [Source $Source, Target $Destination]")
  
    Write-Host("Task - Moving folder :  '$Source'")
    if ([string]::IsNullOrEmpty($Source) -eq $true -or (test-path -LiteralPath $Source) -ne $True)
    {
        Write-Error("Source does not exist or is blank : '$Source'")
        return
    }  
    
    $SourceItem = get-item -LiteralPath $Source 

    #loop all items in the folder
    foreach ($ChildItem in get-Childitem -LiteralPath $SourceItem)
    {
        #Check what type of item it is 
        if ($ChildItem.GetType().Name -eq 'DirectoryInfo')
        {
            Write-verbose ("Processing item : '$($ChildItem.FullName)'")
            
            #move contence of folder
            CopyRemove-FileSystemItem $ChildItem.FullName $Destination | out-null
       
            Write-verbose ("Item complete : '$($ChildItem.FullName)'")
        }
    }
    
}