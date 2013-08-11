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

function add_row(from, message, when, is_action) {
    when = when || new Date();
    
    var div = document.createElement('div');
    
    var date_span = document.createElement('div');
    date_span.className = 'when cell';
    date_span.appendChild(document.createTextNode('Sent ' + format_datetime(when)));
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
    if(!from && !is_action) {
        var pending = document.createElement('span');
        pending.className = 'pending';
        pending.appendChild(document.createTextNode(' Pending...'));
        msg.appendChild(pending);
    }
    
    content.appendChild(msg);
    
    div.appendChild(content);
    
    if(is_action) {
        if(flag) {
            div.className = 'action alt';
        } else {
            div.className = 'action';
        }
    } else {
        var klass = (from ? 'unread ' : '') + 'message';
        if(flag) {
            klass = klass + ' alt';
        }
        
        div.className = klass;
    }
    
    flag = !flag;
    document.body.appendChild(div);
    emojify.run(div);
    
    window.setTimeout(function() {
      window.scrollTo(0,document.body.scrollHeight);
    }, 10);
    
    return div;
}

function add_message(from, message, when, msg_num) {
    var div = add_row(from, message, when, false);

    div.id = 'msg-' + msg_num;
}

function add_action(from, action, when) {
    add_row(from, action, when, true);
}

function message_read(num) {
    var div = document.getElementById('msg-' + num);
    if(div) {
        var pending = div.querySelector('.pending');
        if(pending) {
            var msg = pending.parentNode;
            msg.removeChild(pending);
        }
        
        div.className = div.className.replace('unread ', '');        
    }
}