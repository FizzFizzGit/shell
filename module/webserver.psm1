using module ".\log.psm1"
using module ".\file.psm1"
using module ".\string.psm1"
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
        $this.Http = [HTTP]::new($url)
        $this.logger = [Logger]::new($width,$column,$tFormat,$elipsis)
    }

    Listen(){
        try{
            $formatter = [LogFormatter]::new()
            $this.Http.Listen()
            $formatter.AppendToRequestLog('HTTP/' + $this.Http.GetProtocolVersion())
            $formatter.AppendToRequestLog($this.Http.GetHttpMethod())
            $formatter.AppendToRequestLog($this.Http.GetRawURL())
            $this.HandleRequest()
            $formatter.AppendToResponseLog($this.Http.GetStatusCode())
            $formatter.AppendToResponseLog($this.Http.GetStatusDescription())
            $this.Http.Update()
            $this.logger.Input($this.LogBuilder($formatter))
            return
        }
        catch{
            Write-Host "InternalServerError."
            Write-Host $PSItem
            Pause
            $this.Http.Close()
            exit
        }
    }
    
    Stop(){
        $this.Http.Stop()
        return
    }

    Close(){
        $this.Http.Close()
        return
    }

    [string[]]GetLog(){
        return $this.logger.Output(30)
    }

    hidden [string]LogBuilder($formatter){
        $log = $this.logger.GetTimestamp()
        $list = @($formatter.GetRequestMessage(),$formatter.GetResponseMessage())
        $log = $log + $this.logger.LimitWidth($list)
        return $log
    }

    hidden HandleRequest(){
        try{
            $path = [PathResolver]::GetPath($this.Http.GetRawURL(),$this.Default)
            $physicalPath = [System.IO.Path]::Combine($this.Parent,$path)
            if(!(Test-Path $physicalPath)){
                $physicalPath = [System.IO.Path]::Combine($this.parent, $this.ErrorDoc)
                $content = [ContentProvider]::FromFile($physicalPath)
                $this.Http.WriteError404($content)
            }else{
                [string]$mimeType = $null
                if([FILE]::IsDirectory($physicalPath)){
                    $content = [ContentProvider]::FromDirectory($physicalPath)
                }else{
                    $content = [ContentProvider]::FromFile($physicalPath)
                    $mimeType = [MimeTypeResolver]::GetMimeType($path)
                }
                $this.Http.WriteNomal($content,$mimeType)
            }
            return
        }
        catch{
            throw $PSItem
        }
    }

}

class LogFormatter{
    [string]$Private:Request
    [string]$Private:Response
    
    [string]GetRequestMessage(){
        $this.Request = " " + $this.Request
        return $this.Request
    }

    [string]GetResponseMessage(){
        $this.Response = ": " + $this.Response
        return $this.Response
    }

    AppendToRequestLog([string]$log){
        $this.Request = [STR]::JoinString($this.Request,$log," ")
        return
    }

    AppendToResponseLog([string]$log){
        $this.Response = [STR]::JoinString($this.Response,$log," ")
        return
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