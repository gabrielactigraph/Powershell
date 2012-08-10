#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.2.0.2'
<#
Comments
    Download Audio stream to local drive
	Requires access to a copy of mplayer.exe
	#mplayer's homepage is http://www.mplayerhq.hu
#>

#########################################################
#Load config from file
#########################################################
[xml]$configFile = get-ScriptConfig
if ($configFile -eq $null) {
  	Write-Error "Failed to load config`nExiting"
	Exit}

#Local path to mplayer.exe
[string]$Script:MplayerPath = $configFile.Configuration.MplayerPath

function Get-Web($url, 
    [switch]$self,
    $credential, 
    $toFile,
    [switch]$bytes)
{
    #.Synopsis
    #    Downloads a file from the web
    #.Description
    #    Uses System.Net.Webclient (not the browser) to download data
    #    from the web.
    #.Parameter self
    #    Uses the default credentials when downloading that page (for downloading intranet pages)
    #.Parameter credential
    #    The credentials to use to download the web data
    #.Parameter url
    #    The page to download (e.g. www.msn.com)    
    #.Parameter toFile
    #    The file to save the web data to
    #.Parameter bytes
    #    Download the data as bytes   
    #.Example
    #    # Downloads www.live.com and outputs it as a string
    #    Get-Web http://www.live.com/
    #.Example
    #    # Downloads www.live.com and saves it to a file
    #    Get-Web http://wwww.msn.com/ -toFile www.msn.com.html
    #.source
    #    http://blogs.msdn.com/b/mediaandmicrocode/archive/2008/12/01/microcode-powershell-scripting-tricks-scripting-the-web-part-1-get-web.aspx
    $webclient = New-Object Net.Webclient
    if ($credential) {
        $webClient.Credential = $credential
    }
    if ($self) {
        $webClient.UseDefaultCredentials = $true
    }
    if ($toFile) {
        if (-not "$toFile".Contains(":")) {
            $toFile = Join-Path $pwd $toFile
        }
        $webClient.DownloadFile($url, $toFile)
    } else {
        if ($bytes) {
            $webClient.DownloadData($url)
        } else {
            $webClient.DownloadString($url)
        }
    }
}

function Save-Stream([string]$asxUrl, 
    [string]$saveFolder, 
    [string]$pathofUrl)
	#.Synopsis
    #    Downloads a file from the web
    #.Description
    #    Saves a stream to a file if it does not already exist locally.
    #.Parameter $asxUrl
    #    Url of asx file
    #.Parameter $saveFolder
    #    Folder path to save to
    #.Parameter $pathofUrl
    #    Xpath to the node with the href. the value of the first item is used
    #.Example
    #    # Downloads www.live.com and outputs it as a string
    #    Save-Stream http://www.test.com/test.asx c:\test\ "asx/entry/ref/@href"
{

    # Verify we can access mplayer.EXE .
	if ([string]::IsNullOrEmpty($MplayerPath) -or (Test-Path -LiteralPath $MplayerPath) -ne $true)
	{
	    Write-Error "mplayer.exe path does not exist '$MplayerPath'."
        return
    }
	
    CreateDirectoryIfNeeded $saveFolder
    
    #get urls to streams
    [xml]$asxXml = Get-Web $asxUrl  
    $streams = $null
    if ($asxXml -ne $null)
    {
        #$sourceStream = $asxXml.asx.entry.ref[0].href 
        $streams = $asxXml.SelectNodes($pathofUrl)
    }

    #Save first stream
    if($streams -ne $null -and $streams.Count -gt 0)
    {
        $sourceStream = $streams.Item(0).Value
        $fileName = "$($sourceStream.split('/')[-1])"
        $targetPath = Join-Path $SaveFolder $fileName

        #download file if it does not exist locally
        if((Test-Path $targetPath) -eq $false)
        {
            Write-Host "Downloading stream '$sourceStream' to '$targetPath'"
            &$MplayerPath -dumpstream -dumpfile $targetPath -cache 4096 $sourceStream 
        }
    }
}