#declare assembly
Add-Type -AssemblyName Microsoft.VisualBasic

#function
function AppActivate($pobj){
    [Microsoft.VisualBasic.Interaction]::AppActivate($pobj.ID)
}
