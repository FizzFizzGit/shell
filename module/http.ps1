$script:root
$script:parent
$script:default
$script:errorhtml
$script:listener
$script:request
$script:response

function HTTP_ServerInit($root,$parent,$default,$errorhtml){
    $script:root = $root
    $script:parent = $parent
    $script:errorhtml = $errorhtml
    $script:default = $default
    return
}

function HTTP_ServerClose {
    $script:listener.Dispose()
}

function HTTP_Listen(){
    HTTP_CreateListener
    $context = HTTP_WaitCallBack
    HTTP_RequestMessage $context
    $response = HTTP_Receive $context
    if(!$response){$response = HTTP_Error404 $context}
    HTTP_ResponseMessage $context
    $response.Close()
    return
}

function HTTP_Receive($context){
    $content = HTTP_GetContents (HTTP_GetPath $context)
    if(!$content){return $null}
    $response = $context.response
    $response.ContentLength64 = $content.Length
    $response.ContentEncoding = [Text.Encoding]::UTF8
    $response.OutputStream.Write($content, 0, $content.Length)
    return $response
}

function HTTP_GetPath($context){
    $path = ($context.request.RawUrl.TrimStart('/').split("?")[0])
    if(!$path){$path = $script:default}
    return $path
}

function HTTP_GetContents($path) {
    $fullPath = [System.IO.Path]::Combine($script:parent, $path)
    if(!(Test-Path $fullPath)){return $null}
    if(FILE_IsDirectory $fullpath){
        $content = HTTP_FromDirectory($fullpath)
    }else{
        $content = HTTP_FromFile($fullpath)
    }
    return $content
}

function HTTP_FromFile($fullpath){
    if(!(FILE_FileExists $fullPath)){return $null}
    if($fullpath.Contains('xdir.txt')){return $null}
    $content = FILE_Read $fullpath
    return $content
}

function HTTP_FromDirectory($fullpath){
    if(!(FILE_DirectoryExists $fullPath)){return $null}
    if(!(FILE_FileExists($fullPath + '/xdir.txt'))){return $null}
    $fullpath = $fullPath + '/'
    $file = FILE_ReadAllFile $fullpath
    $contents = [System.Text.Encoding]::UTF8.GetBytes($file)
    return $contents
}

function HTTP_CreateListener(){
    if($null -ne $script:listener){$script:listener.Dispose()}
    $script:listener = New-Object System.Net.HttpListener
    return
}

function HTTP_WaitCallBack(){
    $script:listener.Prefixes.Add($script:root)
    $script:listener.Start()
    return $($script:listener.GetContext())
}

function HTTP_Error404($context){
    $fullPath = [System.IO.Path]::Combine($script:parent, $script:errorhtml)
    $content = FILE_Read $fullPath
    $context.response.ContentType = "text/html"
    HTTP_WriteStream $context $content
    $context.response.StatusCode = 404
    $context.response.StatusDescription = 'Not Found'
    return $context.response
}

function HTTP_WriteStream($context,$content){
    $stream = $context.response.OutputStream
    $stream.Write($content, 0, $content.Length)
    $stream.Close()
    return
}

function HTTP_RequestMessage($context){
    $req = $context.request
    $script:request = (" " + $req.HttpMethod + " " + $req.RawUrl + " " + $req.ProtocolVersion + " " + $req.UserAgent)
    return
}

function HTTP_GetRequestMessage{
    return $script:request
}

function HTTP_ResponseMessage($context){
    $res = $context.response
    $script:response = (":" + $res.ProtocolVersion + " " + $res.StatusCode + " " + $res.StatusDescription )
    return
}

function HTTP_GetResponseMessage{
    return $script:response
}
