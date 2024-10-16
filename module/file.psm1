class FILE{

    static [string]GetFilePath($root,$filename,$extention){
        $fn = $filename + "." + $extention
        return $(Join-Path -Path $root -ChildPath $fn -Resolve) #todo
    }

    static [byte[]]Read($path){
        $file = [byte[]]@()
        $file = [System.IO.File]::ReadAllBytes($path)
        return $file
    }

    static [string]ReadAllFile($path){
        $files = Get-ChildItem -File $path
        $buf = $null
        ForEach($file In $files){
            $buf = $buf + ([FILE]::Read($path + $file))
        }
        return [System.Text.Encoding]::UTF8.GetString($buf)
    }
    
    static [bool]FileExists($path){
        return [System.IO.File]::Exists($path)
    }
    
    static [bool]DirectoryExists($path){
        return [System.IO.Directory]::Exists($path)
    }
    
    static [bool]IsDirectory($path){
        $item = Get-Item $path
        return $item.PSIsContainer
    }

}








