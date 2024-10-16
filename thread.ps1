param(
    [string]$charactors
)
function keyinput {
    while ($true) {
        $keyInfo = Start-ThreadJob -ScriptBlock {[Console]::ReadKey($true)} | Wait-Job | Receive-Job
        if ($keyInfo.Key -eq "Enter") {
            return
        }
        elseif ($keyInfo.Key -eq "Backspace") {
            if (![string]::IsNullOrEmpty($charactors)) {
                $charactors = $charactors.Substring(0, $charactors.Length - 1)
            }
        }
        else {
            $charactors = $charactors + $keyInfo.KeyChar
        }
        Clear-Host
        Write-Host -NoNewline $(">" + $charactors)
    }
}

keyinput