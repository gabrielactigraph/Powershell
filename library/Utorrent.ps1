#*******************************************************************
# Global Variables
#*******************************************************************
$Script:Version      = '0.1.0.3'
<#
Comments
    Enables easier comunication with utorrent via the webapi

Change History
	version 0.1.0.0
	    initial version
#>

#########################################################
#Load config from file
#########################################################
[xml]$configFile = get-ScriptConfig
if ($configFile -eq $null) {
  	Write-Error "Failed to load config`nExiting"
	Exit}

[String]$Script:Server = $configFile.Configuration.Server 
[String]$Script:Port = $configFile.Configuration.Port
[String]$Script:User = $configFile.Configuration.User 
[String]$Script:Pass = $configFile.Configuration.Pass

[String]$Script:UtorrentUrl = "http://$server`:$port/gui/"
[String]$Script:token = ""
$Script:webClient = $null

function Utorrent-HttpGet([string]$Comand)
{
    if ([string]::IsNullOrEmpty($token) -eq $true -or $Script:webClient -eq $null) 
    {
        $webClient = new-object System.Net.WebClient
        $webClient.Headers.Add("user-agent", "PowerShell Script")
    
        Write-Verbose "utorrent address $UtorrentUrl"
        if ([string]::IsNullOrEmpty($User) -eq $false) 
        {
            $webClient.Credentials = new-object System.Net.NetworkCredential($User, $Pass)
            Write-Verbose "credentials added to webclient "
        }

        $responce = $webClient.DownloadString($UtorrentUrl + "token.html")
        [string]$cookies =  $webClient.ResponseHeaders["Set-Cookie"]

        if ($responce -match ".*<div[^>]*id=[`"`']token[`"`'][^>]*>([^<]*)</div>.*")
        {
            $token = $matches[1]
            $webClient.Headers.Add("Cookie", $cookies)
	    }
    }
    $url = "$($UtorrentUrl)?$($Comand)&token=$($token)"
    Write-Host ("Calling url`t$url")
    $response = $webClient.DownloadString($url)
    $json = ConvertFrom-JSON $response
    if($json.build -ne $null)
    {
        Write-Host ("Success $($json.build)")
    }
    return $json
}

function Utorrent-GetList() 
{
    Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
	$dict = @{};
    $json = Utorrent-HttpGet "list=1"
    $json.torrents | Foreach-Object {
        $dict.add($_[2],$_)
    } 
    $dict 
}

function Utorrent-GetSettings() 
{
	Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
	$dict = @{};
    $json = Utorrent-HttpGet "action=getsettings"
    $json.settings | Foreach-Object {
        $dict.add($_[0],$_)
    } 
    $dict
}

function Utorrent-SetSettings([string]$setting, [string]$value) 
{
	Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
    $json = Utorrent-HttpGet "action=setsetting&s=$setting&v=$value"
}

function Utorrent-GetTorrentFiles([string]$torrentHash) 
{
	Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
	$dict = @{};
    $json = Utorrent-HttpGet "action=getfiles&hash=$torrentHash"
    $json.files | Foreach-Object {
        $dict.add($_[0],$_)
    } 
    $dict
}

function Utorrent-GetTorrentProps([string]$torrentHash) 
{
	Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
	$dict = @{};
    $json = Utorrent-HttpGet "action=getprops&hash=$torrentHash"
    $json.props | Foreach-Object {
        $dict.add($_[0],$_)
    } 
    $dict
}

function Utorrent-SetTorrentProps([string]$torrentHash, [string]$property, [string]$value) 
{
	Write-verbose ("$($MyInvocation.MyCommand.Name) v$Version")
	$json = Utorrent-HttpGet "action=setprops&hash=$torrentHash&s=$property&v=$value"
}

function Utorrent-ParseSettings([string]$json) 
{
	if ([string]::IsNullOrEmpty($json) -eq $false -and $jayson[0] -eq "{")
    {
        return ConvertFrom-Json $json
    }
}

