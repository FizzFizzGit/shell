using module ".\log.psm1"
using module ".\file.psm1"
using module ".\http.psm1"

class Server{
    [string]$Private:URL
    [string]$Private:Parent
    [string]$Private:Default
    [string]$Private:ErrorDoc
    [HTTP]$Private:Http
    [Logger]$Private:Logger

    Server($url,$parent,$default,$errorDoc,$width,$column,$tFormat,$elipsis){
        $this.URL = $url
        $this.Parent = $parent
        $this.ErrorDoc = $errorDoc
        $this.Default = $default
        $this.logger = [Logger]::new($width,$column,$tFormat,$elipsis)
    }

    Listen(){
        try{
            $this.Http = [HTTP]::new()
            $this.Http.Open($this.URL)
            $this.HandleRequest()
            $this.Http.Close()
            $this.logger.Input($this.LogBuilder())
            return
        }
        catch{
            Write-Host "InternalServerError."
            Pause
            $this.Close()
            exit
        }
    }
    
    Close(){
        $this.Http.Stop()
        return
    }

    [string[]]GetLog(){
        return $this.logger.Output(30)
    }

    hidden [string]LogBuilder(){
        $log = $this.logger.GetTimestamp()
        $list = @($this.http.RequestMessage,$this.http.ResponseMessage)
        $log = $log + $this.logger.LimitWidth($list)
        return $log
    }

    hidden HandleRequest(){
        try{
            $path = [PathResolver]::GetPath($this.http.RawUrl,$this.Default)
            $physicalPath = [System.IO.Path]::Combine($this.Parent,$path)
            if(!(Test-Path $physicalPath)){
                $physicalPath = [System.IO.Path]::Combine($this.parent, $this.ErrorDoc)
                $content = [ContentProvider]::FromFile($physicalPath)
                $this.http.WriteError404($content)
            }else{
                [string]$mimeType = $null
                if([FILE]::IsDirectory($physicalPath)){
                    $content = [ContentProvider]::FromDirectory($physicalPath)
                }else{
                    $content = [ContentProvider]::FromFile($physicalPath)
                    $mimeType = [MimeTypeResolver]::GetMimeType($path)
                }
                $this.http.WriteNomal($content,$mimeType)
            }
            return
        }
        catch{
            Write-Host "HandleRequestError."
            Pause
            exit
        }
    }

}

class PathResolver{

    static [string]GetPath([string]$rawUrl,$default){
        $path = ($rawUrl.TrimStart('/').split("?")[0])
        if(!$path){$path = $default}
        return $path
    }
    
}

class ContentProvider{

    static [object]FromFile($physicalPath){
        if($physicalPath.Contains('xdir.txt')){return $null}
        return $([FILE]::Read($physicalPath))
    }
    
    static [object]FromDirectory($physicalPath){
        if(!([FILE]::FileExists($physicalPath + '/xdir.txt'))){return $null}
        $file = [FILE]::ReadAllFile($($physicalPath + "/"))
        return $([System.Text.Encoding]::UTF8.GetBytes($file))
    }

}

class MimeTypeResolver{

    static [string]GetMimeType([string]$path){
        $extention = [System.IO.Path]::GetExtension($path)
        if($extention -eq '.html'){
            return 'text/html;'
        }elseif($extention -eq '.css'){
            return 'text/css;'
        }elseif($extention -eq '.js'){
            return 'text/javascript;'
        }else{
            return 'application/octet-stream;'
        }
    }
    
}

Export-ModuleMember -Function Server