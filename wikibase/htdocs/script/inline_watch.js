/*time*/
function InnlineWatch(){
  div = document.getElementById("t1")
  div.innerHTML=getTimeString();
  setInterval(function(){
    div.innerHTML = getTimeString();
  },1000);
}

function getTimeString(){
  var dd = new Date();
  return dd.toLocaleString();
}
