#MINI-SERVER

#paramater
param(
    [string]$Port = 8080,
    [string]$Default = 'index.html',
    [string]$DocumentRoot = (Split-Path $MyInvocation.MyCommand.path) +'/wikibase/htdocs',
    [string]$Root = "http://localhost:$Port/",
    [string]$ErrorHTML = 'html/404.html',
    [int]$RequestCount = 0
)

#module
. .\module\http.ps1
. .\module\file.ps1
. .\module\log.ps1
. .\module\string.ps1
. .\module\vector.ps1
. .\module\cui.ps1

#main
function main{
    [string[]]$head = @(
        "----------MINI-SERVER Write by FizzFizz----------"
        "*Port=$Port",
        "*Default=$Default",
        "*LocalRoot=$DocumentRoot",
        "*TryListen=$Root",
        "*RequestCount=$RequestCount",
        "-------------------------------------------------"
    )
    [string[]]$foot = @(
        "-------------------------------------------------"
    )
    HTTP_ServerInit $Root $DocumentRoot $Default $ErrorHTML
    CUI_SetHeader $head
    CUI_SetFooter $foot
    CUI_Refresh
    LOG_Init 100 3 "[hh:mm:ss]" "..."
    try{
        while($true){
            HTTP_Listen
            LOG_Input $($(LOG_GetTimestamp) + $(LOG_LimitWidth @($(HTTP_GetRequestMessage),$(HTTP_GetResponseMessage))))
            CUI_RewriteHeader 5 $("*RequestCount=" + ++$RequestCount)
            CUI_Refresh $(LOG_Output 30)
        }
    }catch{
        Pause
        HTTP_ServerClose
    }
}

#entry
main
