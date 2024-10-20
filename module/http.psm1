#Data transfer class definition
class ContentsBuffer{
    [byte[]]$content
    [Text.Encoding]$encoding
    [string]$mimeType
    [string]$description
    [int]$status

    ContentsBuffer($content,$encoding,$mimeType,$description,$status){
        $this.content = $content
        $this.encoding = $encoding
        $this.mimeType = $mimeType
        $this.description = $description
        $this.status = $status
        return
    }

}

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

    Write($contentsBuffer){
        try{
            [HttpResponseWriter]::WriteResponse($this.Context,$contentsBuffer)
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
    
    static WriteResponse($context,$contentsBuffer){
        try{
            $response = $context.response
            $response.StatusCode = $contentsBuffer.status
            $response.StatusDescription = $contentsBuffer.description
            $response.ContentLength64 = $contentsBuffer.content.Length
            $response.ContentEncoding = $contentsBuffer.encoding
            $response.ContentType = $contentsBuffer.mimeType
            $response.OutputStream.Write($contentsBuffer.content, 0, $contentsBuffer.content.Length)
            return
        }
        catch{
            #Crappy exception handling. I'll fix it someday.
            #throw $PSItem
        }
    }

}

Export-ModuleMember -Function HTTP