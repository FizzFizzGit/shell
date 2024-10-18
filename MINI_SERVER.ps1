#MINI-SERVER
using module ".\module\webserver.psm1"
using module ".\module\cui.psm1"

#paramater
param(
    [string]$Port = 8080,
    [string]$Default = 'index.html',
    [string]$DocumentRoot = (Split-Path $MyInvocation.MyCommand.path) +'/wikibase/htdocs',
    [string]$URL = "http://localhost:$Port/",
    [string]$ErrorDocuments = 'html/404.html',
    [int]$RequestCount = 0
)

#module
. .\module\vector.ps1

#main
function main{
    [string[]]$head = @(
        "----------MINI-SERVER Write by FizzFizz----------"
        "*Port=$Port",
        "*Default=$Default",
        "*DocumentRoot=$DocumentRoot",
        "*URL=$URL",
        "*RequestCount=$RequestCount",
        "-------------------------------------------------"
    )
    [string[]]$foot = @(
        "-------------------------------------------------"
    )
    $cui = [CUI]::new($head,$foot)
    $cui.Refresh()
    $server = [Server]::new($URL,$DocumentRoot,$Default,$ErrorDocuments,100,3,"[hh:mm:ss]","...")
    while($true){
        $server.Listen()
        $cui.ModHeader(5,$("*RequestCount=" + ++$RequestCount))
        $cui.SetBody($server.GetLog())
        $cui.Refresh()
    }
    
}

#entry
main
