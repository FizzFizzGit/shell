#MINI-SERVER
using module ".\module\http.psm1"
using module ".\module\log.psm1"
using module ".\module\cui.psm1"

#paramater
param(
    [string]$Port = 8080,
    [string]$Default = 'index.html',
    [string]$DocumentRoot = (Split-Path $MyInvocation.MyCommand.path) +'/wikibase/htdocs',
    [string]$Root = "http://localhost:$Port/",
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
        "*Root=$Root",
        "*RequestCount=$RequestCount",
        "-------------------------------------------------"
    )
    [string[]]$foot = @(
        "-------------------------------------------------"
    )
    $cui = [CUI]::new($head,$foot)
    $cui.Refresh()
    $logger = [Logger]::new(100,3,"[hh:mm:ss]","...")
    $http = [Server]::new($Root,$DocumentRoot,$Default,$ErrorDocuments)
    try{
        while($true){
            $http.Open()
            $logger.Input($($($logger.GetTimestamp()) + $($logger.LimitWidth(@($http.GetRequestMessage(),$http.GetResponseMessage())))))
            $cui.ModHeader(5,$("*RequestCount=" + ++$RequestCount))
            $cui.SetBody($($logger.Output(30)))
            $cui.Refresh()
            $http.Close()
        }
    }catch{
        Write-Host "ServerError."
        Pause
    }finally{
        $http.Close()
        exit
    }
    
}

#entry
main
