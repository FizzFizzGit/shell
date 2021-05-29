[string[]]$script:header = ""
[string[]]$script:footer = ""

function CUI_SetHeader($header){$script:header = $header}

function CUI_SetFooter($footer){$script:footer = $footer}

function CUI_RewriteHeader($index,$str){$script:header[$index] = $str}

function CUI_Rewritefooter($index,$str){$script:footer[$index] = $str}

function CUI_Refresh($body){
    Clear-Host
    if($null -ne $script:header){Write-Output $script:header}
    if($null -ne $body){Write-Output $body}
    if($null -ne $script:footer){Write-Output $script:footer}
}
