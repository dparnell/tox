var flag = false;
var last_from = null;

function leading_zeros(s) {
    s = s.toString();
    if(s.length == 1) {
        s = '0' + s;
    }
    
    return s;
}

function format_datetime(time) {
    return leading_zeros(time.getHours()) + ':' + leading_zeros(time.getMinutes());
}

function add_message(from, message, when) {
    when = when || new Date();

    if(last_from && from != last_from) {
        var sep = document.createElement('div');
        sep.className = 'sep';
        document.body.appendChild(sep);
    }
    
    var div = document.createElement('div');
    if(from) {
        var from_span = document.createElement('span');
        from_span.className = 'from';
        from_span.appendChild(document.createTextNode(from));
        div.appendChild(from_span);
    }
    var date_span = document.createElement('span');
    date_span.className = 'when';
    date_span.appendChild(document.createTextNode(format_datetime(when)));
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