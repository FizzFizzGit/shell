class Server{
    [string]$Private:Root
    [string]$Private:Parent
    [string]$Private:Default
    [string]$Private:ErrorDoc
    [System.Net.HttpListener]$Private:Listener
    [System.Net.HttpListenerContext]$Private:Context
    [string]$Private:Request
    [string]$Private:Response

    Open($root,$parent,$default,$errordocuments){
        $this.Root = $root
        $this.Parent = $parent
        $this.ErrorDoc = $errordocuments
        $this.Default = $default
        $this.GetContents()
        return
    }
    
    Close(){
        $this.Request = $null
        $this.Response = $null
        $this.Listener.Dispose()
    }

    [string]GetRequestMessage(){
        return $this.Request
    }

    [string]GetResponseMessage(){
        return $this.Response
    }

    hidden GetContents(){
        $this.Listen()
        $this.Requestlog()
        $path = [Alias]::GetPath($this.Context,$this.Default)
        $fullPath = [System.IO.Path]::Combine($this.Parent,$path)
        if(!(Test-Path $fullPath)){
            $this.Context = [HTTP]::Error404($this.Context,$this.Parent,$this.ErrorDoc)
        }else{
            if(FILE_IsDirectory $fullpath){
                $content = [Alias]::FromDirectory($fullpath)
            }else{
                $content = [Alias]::FromFile($fullpath)
            }
            $ctype = [HTTP]::GetCType($([Alias]::GetPath($this.Context,$this.Default)))
            $this.Context = [HTTP]::WriteStream($this.Context,$content,$ctype)
        }
        $this.Responselog()
        $this.Context.response.Close()
        return
    }

    hidden Listen(){
        if($null -ne $this.Listener){$this.Listener.Dispose()}
        $this.Listener = [HTTP]::Create()
        $this.Listener.Prefixes.Add($this.Root)
        $this.Listener.Start()
        $this.Context = $this.Listener.GetContext()
        return
    }

    hidden Requestlog(){
        $local:request = $this.Context.request
        $this.Request = STR_JoinString $this.Request $request.HttpMethod " "
        $this.Request = STR_JoinString $this.Request $($request.ProtocolVersion).ToString() " "
        $this.Request = STR_JoinString $this.Request $request.RawUrl ''
        $this.Request = " " + $this.Request
        return
    }

    hidden Responselog(){
        $local:response = $this.Context.response
        $this.Response = STR_JoinString $this.Response $($response.ProtocolVersion).ToString() " "
        $this.Response = STR_JoinString $this.Response $response.StatusCode " "
        $this.Response = STR_JoinString $this.Response $response.StatusDescription ''
        $this.Response = ":" + $this.Response
        return
    }

}

class Alias{

    static [string]GetPath($context,$default){
        $path = ($context.request.RawUrl.TrimStart('/').split("?")[0])
        if(!$path){$path = $default}
        return $path
    }
    
    static [object]FromFile($fullpath){
        if($fullpath.Contains('xdir.txt')){return $null}
        return $(FILE_Read $fullpath)
    }
    
    static [object]FromDirectory($fullpath){
        if(!(FILE_FileExists($fullpath + '/xdir.txt'))){return $null}
        $file = FILE_ReadAllFile $($fullpath + "/")
        return $([System.Text.Encoding]::UTF8.GetBytes($file))
    }

}

class HTTP{

    static [System.Net.HttpListener]Create(){
        return New-Object System.Net.HttpListener
    }

    static [object]Error404($context,$parent,$errordoc){
        $fullPath = [System.IO.Path]::Combine($parent, $errordoc)
        $context = [HTTP]::WriteStream($context,$(FILE_Read $fullPath),"")
        $context.response.StatusCode = 404
        $context.response.StatusDescription = ' Not Found'
        return $context
    }

    static [object]WriteStream($context,$content,$ctype){
        $response = $context.response
        $response.StatusDescription = ' OK'
        $response.ContentLength64 = $content.Length
        $response.ContentEncoding = [Text.Encoding]::UTF8
        $response.ContentType = $ctype + 'charset=' + $response.ContentEncoding.HeaderName
        $stream = $context.response.OutputStream
        $stream.Write($content, 0, $content.Length)
        return $context
    }

    static [string]GetCType($path){
        $extention = [System.IO.Path]::GetExtension($path)
        if($extention -eq '.html'){
            return 'text/html;'
        }elseif($extention -eq '.css'){
            return 'text/css;'
        }elseif($extention -eq '.js'){
            return 'text/javascript;'
        }else{
            return ''
        }
    }
    
}