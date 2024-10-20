class FILE{

    static [byte[]]Read($path){
        $file = [byte[]]@()
        $file = [System.IO.File]::ReadAllBytes($path)
        return $file
    }

    static [byte[]]ReadAllFile($path){
        $files = Get-ChildItem -File $path
        $buf = [byte[]]@()
        ForEach($file In $files){
            $buf = $buf + [FILE]::Read($path + $file)
        }
        return $buf
    }
    
    static [bool]FileExists($path){
        return [System.IO.File]::Exists($path)
    }
    
    static [bool]TestPath($path){
        return Test-Path $path
    }
    
    static [bool]IsDirectory($path){
        $item = Get-Item $path
        return $item.PSIsContainer
    }

}








