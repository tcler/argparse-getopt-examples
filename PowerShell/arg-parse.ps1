<#
# enable execution of powershell scripts, if first run on your system
Set-ExecutionPolicy Bypass -Force
#>

param (
	[string]$server = "http://defaultserver",
	[Parameter(Mandatory=$true)][string]$username,
	[switch]$force = $false,

	[Parameter(Position = 0, ValueFromRemainingArguments = $true)]
	[string]$oargs
)

"server = $server, username = $username, force = $force, oargs = $oargs"
