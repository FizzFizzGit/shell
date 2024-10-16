using module ".\file.psm1"
using module ".\string.psm1"

class Server{
    [string]$Private:Root
    [string]$Private:Parent
    [string]$Private:Default
    [string]$Private:ErrorDoc
    [LogFormatter]$Private:Logger
    [HttpListenerService]$Private:Listener

    Server($root,$parent,$default,$errordocuments){
        $this.Root = $root
        $this.Parent = $parent
        $this.ErrorDoc = $errordocuments
        $this.Default = $default
    }

    Open(){
        $this.Listener = [HttpListenerService]::new($this.Root)
        $this.Logger = [LogFormatter]::new()
        $this.Listener.Start()
        $context = $this.Listener.GetContext()
        $this.Logger.AppendToRequestLog('HTTP/' + $($context.request.ProtocolVersion).ToString())
        $this.Logger.AppendToRequestLog($context.request.HttpMethod)
        $this.Logger.AppendToRequestLog($context.request.RawUrl)
        $this.HandleRequest($context)
        $this.Logger.AppendToResponseLog($context.response.StatusCode)
        $this.Logger.AppendToResponseLog($context.response.StatusDescription)
        $context.response.Close()
        return
    }
    
    Close(){
        $this.Listener.Stop()
        return
    }

    [string]GetRequestMessage(){
        return $this.Logger.GetRequestLog()
    }

    [string]GetResponseMessage(){
        return $this.Logger.GetResponseLog()
    }

    hidden HandleRequest($context){
        $path = [PathResolver]::GetPath($context,$this.Default)
        $physicalPath = [System.IO.Path]::Combine($this.Parent,$path)
        if(!(Test-Path $physicalPath)){
            $context = [HttpResponseWriter]::WriteError404($context,$this.Parent,$this.ErrorDoc)
        }else{
            [string]$mimeType = $null #Must-have
            if([FILE]::IsDirectory($physicalPath)){
                $content = [ContentProvider]::FromDirectory($physicalPath)
            }else{
                $content = [ContentProvider]::FromFile($physicalPath)
                $mimeType = [MimeTypeResolver]::GetMimeType($([PathResolver]::GetPath($context,$this.Default)))
            }
            $context = [HttpResponseWriter]::WriteResponse($context,$content,$mimeType,' OK',200)
        }
        return
    }

}

class LogFormatter{
    [string]$Private:Request
    [string]$Private:Response
    
    [string]GetRequestLog(){
        $this.Request = " " + $this.Request
        return $this.Request
    }

    [string]GetResponseLog(){
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

class HttpListenerService{
    [System.Net.HttpListener]$Private:Listener

    HttpListenerService([string]$prefix){
        $this.Listener = [System.Net.HttpListener]::new()
        $this.Listener.Prefixes.Add($prefix)
        return
    }

    Start(){
        $this.Listener.Start()
        return
    }

    Stop(){
        $this.Listener.Stop()
        $this.Listener.Close()
        return
    }

    [System.Net.HttpListenerContext]GetContext(){
        return $this.Listener.GetContext()
    }

}

class PathResolver{

    static [string]GetPath($context,$default){
        $path = ($context.request.RawUrl.TrimStart('/').split("?")[0])
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

class HttpResponseWriter{

    static [object]WriteError404($context,$parent,$errordoc){
        $physicalPath = [System.IO.Path]::Combine($parent, $errordoc)
        $context = [HttpResponseWriter]::WriteResponse($context,$([FILE]::Read($physicalPath)),"",' Not Found',404)
        return $context
    }

    static [object]WriteResponse($context,$content,$mimeType,$description,$status){
        $response = $context.response
        $response.StatusCode = $status
        $response.StatusDescription = $description
        $response.ContentLength64 = $content.Length
        $response.ContentEncoding = [Text.Encoding]::UTF8
        $response.ContentType = $mimeType + 'charset=' + $response.ContentEncoding.HeaderName
        $response.OutputStream.Write($content, 0, $content.Length)
        return $context
    }

}

class MimeTypeResolver{

    static [string]GetMimeType($path){
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