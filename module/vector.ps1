function VECTOR_New($list){
    return @{
        list = $list
        top = 0
    }
}

function VECTOR_Enqueue($vector,$item){
    $vector.list.Add($item)
    return $vector
}

function VECTOR_Dequeue($vector){
    ++$vector.top
    return
}

function VECTOR_QueueSize($vector){
    return $vector.list.Count - $vector.top
}

function VECTOR_GetQueue($vector){
    $range = $vector.list.Count - $vector.top
    $queue = $vector.list.GetRange($vector.top,$range)
    return $queue
}
