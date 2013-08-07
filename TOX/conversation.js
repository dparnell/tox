var flag = false;

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
    
    var div = document.createElement('div');
    
    var date_span = document.createElement('div');
    date_span.className = 'when cell';
    date_span.appendChild(document.createTextNode(format_datetime(when)));
    div.appendChild(date_span);
    
    var content = document.createElement('div');
    
    if(from) {
        content.className = 'cell theirs';
    } else {
        content.className = 'cell ours';
    }
    
    var from_div = document.createElement('div');
    from_div.className = 'from';
    from_div.appendChild(document.createTextNode(from || 'Me'));
    content.appendChild(from_div);
    
    var msg = document.createElement('div');
    msg.className = 'msg';
    msg.appendChild(document.createTextNode(message));
    content.appendChild(msg);
    
    div.appendChild(content);
    
    if(flag) {
        div.className = 'message alt';
    } else {
        div.className = 'message';
    }
    
    flag = !flag;
    document.body.appendChild(div);
    emojify.run(div);
    
    window.setTimeout(function() {
      window.scrollTo(0,document.body.scrollHeight);
    }, 10);
}