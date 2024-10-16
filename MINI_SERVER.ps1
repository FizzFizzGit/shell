#MINI-SERVER
using module ".\module\http.psm1"

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
. .\module\log.ps1
. .\module\vector.ps1
. .\module\cui.ps1

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
    CUI_SetHeader $head
    CUI_SetFooter $foot
    CUI_Refresh
    LOG_Init 100 3 "[hh:mm:ss]" "..."
    $http = [Server]::new($Root,$DocumentRoot,$Default,$ErrorDocuments)
    try{
        while($true){
            $http.Open()
            LOG_Input $($(LOG_GetTimestamp) + $(LOG_LimitWidth @($http.GetRequestMessage(),$http.GetResponseMessage())))
            CUI_ModHeader 5 $("*RequestCount=" + ++$RequestCount)
            CUI_SetBody $(LOG_Output 30)
            CUI_Refresh
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
