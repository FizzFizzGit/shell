#MINI-SERVER

#paramater
param(
    [string]$Port = 8080,
    [string]$Default = 'index.html',
    [string]$DocumentRoot = (Split-Path $MyInvocation.MyCommand.path) + '/wikibase/htdocs',
    [string]$Root = "http://localhost:$Port/",
    [string]$ErrorDocuments = 'html/404.html'
)

#module
. .\module\http.ps1
. .\module\file.ps1
. .\module\log.ps1
. .\module\string.ps1
. .\module\vector.ps1
. .\module\cui.ps1

#main
function main {
    [string[]]$head = @(
        "----------MINI-SERVER Write by FizzFizz----------"
        "*Port=$Port",
        "*Default=$Default",
        "*DocumentRoot=$DocumentRoot",
        "*Root=$Root",
        "-------------------------------------------------"
    )
    [string[]]$foot = @(
        "-------------------------------------------------"
    )
    HTTP_ServerInit $Root $DocumentRoot $Default $ErrorDocuments
    CUI_SetHeader $head
    CUI_SetFooter $foot
    CUI_Refresh
    LOG_Init 100 3 "[hh:mm:ss]" "..."
    servercore
}
function servercore {
    try {
        Start-ThreadJob -ScriptBlock { HTTP_Listen } | Wait-Job | Receive-Job
        LOG_Input $($(LOG_GetTimestamp) + $(LOG_LimitWidth @($(HTTP_GetRequestMessage), $(HTTP_GetResponseMessage))))
    }
    catch {
        Pause
        HTTP_ServerClose
    }
}
function cuiref {
    CUI_SetBody $(LOG_Output 30)
    CUI_Refresh
}
#entry
main
