using module ".\string.psm1"

class Logger{
    $Private:vector
    $Private:width
    $Private:colmun
    $Private:limit
    $Private:tformat
    $Private:ellipsis

    Logger($width,$colmun,$tformat,$ellipsis){
        $this.vector = VECTOR_New([STR]::NewList())
        $this.width = $width
        $this.colmun = $colmun
        $this.tformat = $tformat
        $this.ellipsis = $ellipsis
        $this.limit = $this.CalcWidth()
    }

    Input($str){
        $this.vector = VECTOR_Enqueue $this.vector $str
    }
    
    [string[]]Output($length){
        $len = VECTOR_QueueSize $this.vector
        if($len -gt $length){$(VECTOR_Dequeue $this.vector)}
        return VECTOR_GetQueue $this.vector
    }
    
    [string]GetTimestamp(){return Get-Date -Format $this.tformat}
    
    [int]CalcWidth(){return ($this.width - $this.tformat.length) / $this.colmun}
    
    [string]LimitWidth($list){
        $str = $null
        foreach($a in $list){
          $str += [STR]::LimitLength($a,$this.limit,$this.ellipsis)
        }
        return $str
    }

}