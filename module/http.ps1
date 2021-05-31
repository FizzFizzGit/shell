$script:root
$script:parent
$script:default
$script:errordocuments
$script:listener
$script:request
$script:response

function HTTP_ServerInit($root,$parent,$default,$errordocuments){
    $script:root = $root
    $script:parent = $parent
    $script:errordocuments = $errordocuments
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
    $content = HTTP_GetContents $(HTTP_GetPath $context)
    if($null -ne $content){
        $ctype = HTTP_GetCType $(HTTP_GetPath $context)
        $context = $(HTTP_WriteStream $context $content $ctype)
    }else{
        $context = HTTP_Error404 $context
    }
    HTTP_ResponseMessage $context
    $context.response.Close()
    return
}

function HTTP_WriteStream($context,$content,$ctype){
    $response = $context.response
    $response.ContentLength64 = $content.Length
    $response.ContentEncoding = [Text.Encoding]::UTF8
    $response.ContentType = $ctype + 'charset=' + $response.ContentEncoding.HeaderName
    $stream = $context.response.OutputStream
    $stream.Write($content, 0, $content.Length)
    $stream.Close()
    return $context
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
    return $(FILE_Read $fullpath)
}

function HTTP_FromDirectory($fullpath){
    if(!(FILE_DirectoryExists $fullPath)){return $null}
    if(!(FILE_FileExists($fullPath + '/xdir.txt'))){return $null}
    $file = FILE_ReadAllFile $($fullpath + "/")
    return $([System.Text.Encoding]::UTF8.GetBytes($file))
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

function HTTP_GetCType($path){
    $extention = [System.IO.Path]::GetExtension($path)
    if($extention -eq '.html'){
        $ctype = 'text/html;'
    }elseif($extention -eq '.css'){
        $ctype = 'text/css;'
    }elseif($extention -eq '.js'){
        $ctype = 'text/javascript;'
    }
    return $ctype
}

function HTTP_Error404($context){
    $fullPath = [System.IO.Path]::Combine($script:parent, $script:errordocuments)
    $context = HTTP_WriteStream $context $(FILE_Read $fullPath)
    $context.response.ContentType = "text/html"
    $context.response.StatusCode = 404
    $context.response.StatusDescription = 'Not Found'
    return $context
}

function HTTP_RequestMessage($context){
    $req = $context.request
    foreach($str in @($req.HttpMethod,$($req.ProtocolVersion).ToString(),$req.RawUrl)){
        $reqstr = STR_JoinString $reqstr $str " "
    }
    $script:request = " " + $reqstr
    return
}

function HTTP_GetRequestMessage{
    return $script:request
}

function HTTP_ResponseMessage($context){
    $res = $context.response
    foreach($str in @($($res.ProtocolVersion).ToString(),$res.StatusCode,$res.StatusDescription)){
        $resstr = STR_JoinString $resstr $str " "
    }
    $script:response = ":" + $resstr
    return
}

function HTTP_GetResponseMessage{
    return $script:response
}
