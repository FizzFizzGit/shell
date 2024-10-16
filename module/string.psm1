class STR{

    static [string]LimitLength($str,$lim,$ellipsis){
        if($str.length -gt $lim){
            $substr = $str.substring(0,$lim - $ellipsis.length)
            $str = $substr + $ellipsis
        }else{
            $padding = " "
            $str = $str + $padding.PadRight($lim-$str.length - 1)
        }
        return $str
    }
    
    static [System.Collections.Generic.List[string]]NewList(){
      return [System.Collections.Generic.List[string]]::new()
    }
    
    static [string]JoinString($str,$addstr,$delimiter){
        if([string]::IsNullOrEmpty($str)){
            $str = $addstr
        }else{
            $str = $($str + $delimiter + $addstr)
        }
        return $str
    }

}