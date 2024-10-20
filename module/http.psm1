class HTTP{
    [System.Net.HttpListener]$Private:Listener
    [System.Net.HttpListenerContext]$Private:Context

    HTTP($url){
        $this.Listener = [HttpListenerService]::Create($url)
        $this.Listener.Start()
    }

    [string]GetProtocolVersion(){return $this.Context.request.ProtocolVersion.ToString()}
    [string]GetHttpMethod(){return $this.Context.request.HttpMethod}
    [string]GetRawURL(){return $this.Context.request.RawUrl}
    [string]GetStatusDescription(){return $this.Context.response.StatusDescription}
    [string]GetStatusCode(){return $this.Context.response.StatusCode}

    Listen(){
        $this.Context = $this.Listener.GetContext()
        return
    }

    Update(){
        $this.Context.response.Close()
        return
    }

    Stop(){
        $this.Listener.Stop()
        return
    }

    Close(){
        $this.Listener.Dispose()
        return
    }

    WriteNomal($content,$mimeType){
        try{
            [HttpResponseWriter]::WriteResponse($this.Context,$content,$mimeType,' OK',200)
        }
        catch{
            throw $PSItem
        }
    }

    WriteError404($errorDoc){
        try{
            [HttpResponseWriter]::WriteResponse($this.Context,$errorDoc,"",' Not Found',404)
        }
        catch{
            throw $PSItem
        }
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
        try{
            $response = $context.response
            $response.StatusCode = $status
            $response.StatusDescription = $description
            $response.ContentLength64 = $content.Length
            $response.ContentEncoding = [Text.Encoding]::UTF8
            $response.ContentType = $mimeType + 'charset=' + $response.ContentEncoding.HeaderName
            $response.OutputStream.Write($content, 0, $content.Length)
            return
        }
        catch{
            throw $PSItem
        }
    }

}

Export-ModuleMember -Function HTTP