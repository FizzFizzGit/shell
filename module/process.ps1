#function
function PROCESS_GetProcessObject($name){
    return (Get-Process $name | Where-Object {$_.MainWindowTitle -ne ""})
}
