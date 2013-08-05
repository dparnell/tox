var flag = false;
function add_message(from, message, when) {
    when = when || new Date();

    var div = document.createElement('div');
    if(from) {
        var from_span = document.createElement('span');
        from_span.className = 'from';
        from_span.appendChild(document.createTextNode(from));
        div.appendChild(from_span);
    }
    var date_span = document.createElement('span');
    date_span.className = 'when';
    date_span.appendChild(document.createTextNode(when.toString()));
    div.appendChild(date_span);
    
    var msg = document.createElement('span');
    msg.className = 'msg';
    msg.appendChild(document.createTextNode(message));
    div.appendChild(msg);
    
    if(flag) {
        div.className = 'message alt';
    } else {
        div.className = 'message';
    }
    
    flag = !flag;
    document.body.appendChild(div);
    window.setTimeout(function() {
      window.scrollTo(0,document.body.scrollHeight);
    }, 10);
}