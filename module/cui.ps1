[string[]]$script:header = ""
[string[]]$script:body = ""
[string[]]$script:footer = ""

function CUI_SetHeader($header){$script:header = $header}
function CUI_SetBody($body){$script:body = $body}
function CUI_SetFooter($footer){$script:footer = $footer}
function CUI_ModHeader($index,$str){$script:header[$index] = $str}
function CUI_Modfooter($index,$str){$script:footer[$index] = $str}
function CUI_Refresh(){
    Clear-Host
    if($null -ne $script:header){Write-Output $script:header}
    if($null -ne $script:body){Write-Output $script:body}
    if($null -ne $script:footer){Write-Output $script:footer}
}
