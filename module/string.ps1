function STR_LimitLength(){
    param($str,$lim,$ellipsis)
    if($str.length -gt $lim){
        $substr = $str.substring(0,$lim - $ellipsis.length)
        $str = $substr + $ellipsis
    }else{
        $padding = " "
        $str = $str + $padding.PadRight($lim-$str.length - 1)
    }
    return $str
}

function STR_NewList(){
  return @(New-Object System.Collections.Generic.List[string])
}
