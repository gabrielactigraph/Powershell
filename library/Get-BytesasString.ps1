#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.1.0.1'

function Get-BytesasString([long]$Bytes) {
<#
    .Synopsis
        Displays the bytes in a pretty way
    .INPUTS
        None. You cannot pipe objects to Get-BytesasString.
    .OUTPUTS
        None.
    .Notes
        NAME: Get-BytesasString
        AUTHOR: max
        LASTEDIT: 12/31/2010 14:33:31
        KEYWORDS:
    .Link
        Http://www.ostat.com
#>
    Write-Verbose("$($MyInvocation.MyCommand.Name) v$Version [Bytes $Bytes]")

    if ($Bytes -gt 1073741823)
    {
        [Decimal]$size = $Bytes / 1073741824
        return "{0:##.##} GB" -f $size 
    }
    elseif ($Bytes -gt 1048575)
    {
        [Decimal]$size = $Bytes / 1048576
        return "{0:##.##} MB" -f $size
    }
    elseif ($Bytes  -gt 1023)
    {
        [Decimal]$size  = $Bytes / 1024
        return "{0:##.##} KB" -f $size
    }
    elseif ($Bytes -gt 0)
    {
        [Decimal]$size = $Bytes
        return "{0:##.##} bytes" -f $size
    }
    else
    {
        return "0 bytes";
    }

}