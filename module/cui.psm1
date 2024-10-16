class CUI{
    [string[]]$Private:header
    [string[]]$Private:body
    [string[]]$Private:footer

    CUI($head,$foot){
        $this.header = $head
        $this.footer = $foot
    }

    SetBody($body){$this.body = $body}
    ModHeader($index,$str){$this.header[$index] = $str}
    Modfooter($index,$str){$this.footer[$index] = $str}
    Refresh(){
        Clear-Host
        if($null -ne $this.header){$this.header -join "`n" | Write-Host}
        if($null -ne $this.body){$this.body -join "`n" | Write-Host}
        if($null -ne $this.footer){$this.footer -join "`n" | Write-Host}
    }

}