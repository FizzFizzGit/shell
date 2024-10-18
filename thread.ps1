param(
    [string]$charactors
)

function keyinput {
    [Console]::CursorVisible = $false
    while ($true){
        Clear-Host
        Write-Host -NoNewline $("$" + $charactors)
        $keyInfo = Start-ThreadJob -ScriptBlock {[Console]::ReadKey($true)} | Wait-Job | Receive-Job
        if ($keyInfo.Key -eq "Enter"){
            if($charactors.ToLower() -eq "exit"){return}
            $charactors = ""
        }elseif($keyInfo.Key -eq "Backspace"){
            if(![string]::IsNullOrEmpty($charactors)){
                $charactors = $charactors.Substring(0, $charactors.Length - 1)
            }
        }else{
            $charactors = $charactors + $keyInfo.KeyChar
        }
    }
}

keyinput