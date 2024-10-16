using module ".\string.psm1"

$script:vector
$script:width
$script:colmun
$script:limit
$script:tformat
$script:ellipsis

function LOG_Init($width,$colmun,$tformat,$ellipsis){
    $vector = [STR]::NewList()
    $script:vector = VECTOR_New $vector
    $script:width = $width
    $script:colmun = $colmun
    $script:limit = LOG_CalcWidth
    $script:tformat = $tformat
    $script:ellipsis = $ellipsis
}

function LOG_Input($str){
    $script:vector = VECTOR_Enqueue $script:vector $str
}

function LOG_Output($length){
    $len = VECTOR_QueueSize $script:vector
    if($len -gt $length){$(VECTOR_Dequeue $script:vector)}
    return @(VECTOR_GetQueue $script:vector)
}

function LOG_GetTimestamp(){return Get-Date -Format $script:tformat}

function LOG_CalcWidth(){return ($script:width - $script:tformat.length) / $script:colmun}

function LOG_LimitWidth($list){
    foreach($a in $list){
      $str += [STR]::LimitLength($a,$script:limit,$script:ellipsis)
    }
    return $str
}
