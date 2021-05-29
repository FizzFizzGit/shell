function loadHTMLByID(_html,id){
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.open("GET",_html,true);
  xmlhttp.onreadystatechange = function(){
    if(xmlhttp.readyState == 4 && xmlhttp.status == 200){
      var data = xmlhttp.responseText;
      var elem = document.getElementById(id);
      elem.innerHTML = data;
      return data;
    }
  }
  xmlhttp.send(null);
}

loadHTMLByID('/html/footer.html','footer');