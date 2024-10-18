using module ".\string.psm1"

class HTTP{
    [string]$RequestMessage
    [string]$ResponseMessage
    [string]$RawUrl
    [LogFormatter]$Private:LogFormatter
    [System.Net.HttpListener]$Private:Listener
    [System.Net.HttpListenerContext]$Private:Context

    Open($url){
        $this.LogFormatter = [LogFormatter]::new()
        $this.Listener = [HttpListenerService]::Create($url)
        $this.Listener.Start()
        $this.Context = $this.Listener.GetContext()
        $this.RawUrl = $this.Context.request.RawUrl
        $this.LogFormatter.AppendToRequestLog('HTTP/' + $this.Context.request.ProtocolVersion.ToString())
        $this.LogFormatter.AppendToRequestLog($this.Context.request.HttpMethod)
        $this.LogFormatter.AppendToRequestLog($this.RawUrl)
        $this.RequestMessage = $this.LogFormatter.GetRequestMessage()
        return
    }

    Close(){
        $this.LogFormatter.AppendToResponseLog($this.Context.response.StatusCode)
        $this.LogFormatter.AppendToResponseLog($this.Context.response.StatusDescription)
        $this.ResponseMessage = $this.LogFormatter.GetResponseMessage()
        $this.Context.response.Close()
        $this.Listener.Close()
    }

    Stop(){
        $this.Listener.Stop()
        $this.Listener.Dispose()
    }

    WriteNomal($content,$mimeType){
        [HttpResponseWriter]::WriteResponse($this.Context,$content,$mimeType,' OK',200)
    }

    WriteError404($errorDoc){
        [HttpResponseWriter]::WriteResponse($this.Context,$errorDoc,"",' Not Found',404)
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

class HttpListenerService{

    static [System.Net.HttpListener]Create([string]$prefix){
        $Listener = [System.Net.HttpListener]::new()
        $Listener.Prefixes.Add($prefix)
        return $Listener
    }

}

class HttpResponseWriter{
    
    static WriteResponse($context,$content,$mimeType,$description,$status){
        $response = $context.response
        $response.StatusCode = $status
        $response.StatusDescription = $description
        $response.ContentLength64 = $content.Length
        $response.ContentEncoding = [Text.Encoding]::UTF8
        $response.ContentType = $mimeType + 'charset=' + $response.ContentEncoding.HeaderName
        $response.OutputStream.Write($content, 0, $content.Length)
        return
    }

}

Export-ModuleMember -Function HTTP