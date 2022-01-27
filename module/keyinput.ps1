param(
    [string]$script:charactors = ""
)
function keyinput(){
    while ($true) {
        $keyInfo = [Console]::ReadKey($true)
        if ($keyInfo.Key -eq "Enter") {
            return "Enter"
        }
        elseif ($keyInfo.Key -eq "Backspace") {
            if (![string]::IsNullOrEmpty($script:charactors)) {
                $script:charactors = $script:charactors.Substring(0, $script:charactors.Length - 1)
            }
        }
        else {
            $script:charactors = $script:charactors + $keyInfo.KeyChar
        }
    }
}

Clear-Host
if(keyinput -eq "Enter"){
    Write-Host $script:charactors
}