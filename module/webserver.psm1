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
        $this.Logger = [Logger]::new($width,$column,$tFormat,$elipsis)
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
            $this.Logger.Input($this.LogBuilder($formatter))
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
        return $this.Logger.Output(30)
    }

    hidden [string]LogBuilder($formatter){
        $log = $this.Logger.GetTimestamp()
        $list = @($formatter.GetRequestMessage(),$formatter.GetResponseMessage())
        $log = $log + $this.Logger.LimitWidth($list)
        return $log
    }

    hidden HandleRequest(){
        try{
            $path = [PathResolver]::GetPath($this.Http.GetRawURL(),$this.Default)
            $physicalPath = [System.IO.Path]::Combine($this.Parent,$path)
            if(!([FILE]::TestPath($physicalPath))){
                $physicalPath = [System.IO.Path]::Combine($this.parent, $this.ErrorDoc)
                $content = [ContentProvider]::FromFile($physicalPath)
                $buffer = [ContentsBuffer]::new($content,[Text.Encoding]::UTF8,$null,' Not Found',404)
            }else{
                if([FILE]::IsDirectory($physicalPath)){
                    $content = [ContentProvider]::FromDirectory($physicalPath)
                    $buffer = [ContentsBuffer]::new($content,[Text.Encoding]::UTF8,$null,' OK',200)
                }else{
                    $content = [ContentProvider]::FromFile($physicalPath)
                    $buffer = [ContentsBuffer]::new($content,$null,$null,' OK',200)
                    [ContentsTypeResolver]::GetContentsType($buffer,$path)
                }
            }
            $this.Http.Write($buffer)
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

    static [byte[]]FromFile($physicalPath){
        if($physicalPath.Contains('xdir.txt')){return $null}
        return [FILE]::Read($physicalPath)
    }
    
    static [byte[]]FromDirectory($physicalPath){
        if(!([FILE]::FileExists($physicalPath + '/xdir.txt'))){return $null}
        return [FILE]::ReadAllFile($($physicalPath + "/"))
    }

}

class ContentsTypeResolver{

    static GetContentsType($buffer,$path){
        $extention = [System.IO.Path]::GetExtension($path)
        if($extention -eq '.html'){
            $buffer.encoding = [Text.Encoding]::UTF8
            $buffer.mimeType = 'text/html;'
            return
        }elseif($extention -eq '.css'){
            $buffer.encoding = [Text.Encoding]::UTF8
            $buffer.mimeType = 'text/css;'
            return
        }elseif($extention -eq '.js'){
            $buffer.encoding = [Text.Encoding]::UTF8
            $buffer.mimeType = 'text/javascript;'
            return
        }elseif($extention -eq '.ico'){
            $buffer.encoding = $null
            $buffer.mimeType = 'image/vnd.microsoft.icon'
            return
        }else{
            $buffer.encoding = $null
            $buffer.mimeType = 'application/octet-stream;'
            return
        }
    }
    
}

Export-ModuleMember -Function Server