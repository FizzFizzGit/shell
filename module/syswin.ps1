#declare assembly
Add-Type -AssemblyName System.Windows.Forms

#function
function SendKeysMacro($macros){
    foreach($command in $macros){
        Start-Sleep -m $script:Wait
        [System.Windows.Forms.SendKeys]::SendWait($command)
    }
}
