class STR{

    static [string]LimitLength($str,$lim,$ellipsis){
        if($str.length -gt $lim){
            $substr = $str.SubString(0,$lim - $ellipsis.length)
            return $($substr + $ellipsis)
        }else{
            return $str.PadRight($lim)
        }
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