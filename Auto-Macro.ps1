#Auto-Macro by Fizz

#references https://qiita.com/nimzo6689/items/488467dbe0c4e5645745

#paramater
param(
    $script:RootDirectory = (Split-Path $MyInvocation.MyCommand.path),
    $script:TargetFile = "notepad",
    $script:Macros = @("Hello","World!"),
    $script:StartWait = 3000,
    $script:Wait = 1000
)

#declare assembly
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

#main
function main{
    $pobj = GetProcessObject $script:TargetFile
    if($null -eq $pobj){
        try{
            Start-Process -FilePath $(GetFilePath $script:TargetFile "exe")
            Start-Sleep -m $script:StartWait
            $pobj = GetProcessObject $script:TargetFile
        }catch{
            Pause
            throw
        }
    }
    AppActivate $pobj
    SendKeysMacro $script:Macros
}

#functions
function GetFilePath($filename,$extention){
    $fn = $filename + "." + $extention
    return $(Join-Path -Path $script:RootDirectory -ChildPath $fn -Resolve)
}

function SendKeysMacro($macros){
    foreach($command in $macros){
        Start-Sleep -m $script:Wait
        [System.Windows.Forms.SendKeys]::SendWait($command)
    }
}

function AppActivate($pobj){
    [Microsoft.VisualBasic.Interaction]::AppActivate($pobj.ID)
}

function GetProcessObject($name){
    return (Get-Process $name | Where-Object {$_.MainWindowTitle -ne ""})
}

#entry
main
