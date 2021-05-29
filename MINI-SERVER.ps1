#MINI-SERVER

#paramater
param(
    [string]$script:Port = 8080,
    [string]$script:Default = 'index.html',
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
        "-----MINI-SERVER Write by FizzFizz-----"
        "*Port=$script:Port",
        "*Default=$script:Default",
        "*LocalRoot=$DocumentRoot",
        "*TryListen=$Root",
        "*RequestCount=$RequestCount",
        "---------------------------------------"
    )
    [string[]]$foot = @(
        "---------------------------------------"
    )
    HTTP_ServerInit $Root $DocumentRoot $script:Default $ErrorHTML
    CUI_SetHeader $head
    CUI_SetFooter $foot
    CUI_Refresh
    LOG_Init 100 3 "[hh:mm:ss]" "..."
    try{
        while($true){
            HTTP_Listen
            LOG_Input (logset)
            CUI_RewriteHeader 5 ("*RequestCount=" + ++$RequestCount)
            CUI_Refresh(LOG_Output 30)
        }
    }catch{
        Pause
        HTTP_ServerClose
    }
}

function logset(){
    $timestamp = LOG_GetTimestamp 
    $str = LOG_LimitWidth @($(HTTP_GetRequestMessage),$(HTTP_GetResponseMessage))
    $str = $timestamp + $str
    return $str
}

#entry
main
