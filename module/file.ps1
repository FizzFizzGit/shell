#functions
function FILE_GetFilePath($filename,$extention){
    $fn = $filename + "." + $extention
    return $(Join-Path -Path $script:RootDirectory -ChildPath $fn -Resolve)
}

function FILE_Read($path){
    $file = [byte[]]@()
    $file = [System.IO.File]::ReadAllBytes($path)
    return $file
}

function FILE_ReadAllFile($path){
    $files = Get-ChildItem -File $path
    ForEach($file In $files){
        $buf = $buf + (FILE_Read ($path + $file))
    }
    return [System.Text.Encoding]::UTF8.GetString($buf)
}

function FILE_FileExists($path){
    return [System.IO.File]::Exists($path)
}

function FILE_DirectoryExists($path){
    return [System.IO.Directory]::Exists($path)
}

function FILE_IsDirectory($path){
    $item = Get-Item $path
    return $item.PSIsContainer
}
