var RoninTeam = {

	helpers: function(){
		//...
	},

  ChatRoom: {
    commands: {
      'clear': function() { $('ul.chat > li').remove(); },

      'nick': function() {
        // stub for nick command
      },

      'help': function() {
        // stub for help command
      }
    },

    inputHandler: function() {
 			var chatInput = $('input#chat-input').val();

      if (chatInput.length > 0)
      {
        if (chatInput[0] == '/')
        {
          // chat command
          var commandName = chatInput.substr(1,chatInput.length);

          if (RoninTeam.ChatRoom.commands[commandName] != null)
          {
            RoninTeam.ChatRoom.commands[commandName]();
          }
        }
        else
        {
  			  RoninTeamServer.publish('/chat', {user: roninteam_user, message: chatInput, timestamp: Date.now()});
        }

        $('input#chat-input').val('');
 			}

  		return false;
    }
  },

  chat: function() {
		$('ul.chat li').livequery(function() {
 		  $(this).autolink();
 		  $(this).mailto();
			//$('span.user-message', this).highlight(roninteam_user, '<span style="background-color:#FFFF7F;">$1</span>');
 	  });
		
		$('input#chat-input').focus();
		
    $('form.chat-form').livequery(function() {
			$(this).submit(RoninTeam.ChatRoom.inputHandler);
    });
  },
	
	tooltip: function(){
		$('.tooltip').tipsy({
			live: true,
			gravity: 'sw',
			html: false
		});
	}
};

jQuery(document).ready(function($) {
	RoninTeam.helpers();
	RoninTeam.chat();
	RoninTeam.tooltip();
});


jQuery.fn.highlight = function (text, o) {
	return this.each( function(){
		var replace = o || '<span class="highlight">$1</span>';
		$(this).html( $(this).html().replace( new RegExp('('+text+'(?![\\w\\s?&.\\/;#~%"=-]*>))', "ig"), replace) );
	});
};

jQuery.fn.autolink = function () {
	return this.each( function(){
		var re = /((http|https|ftp):\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~%"=-]*>))/g;
		$(this).html( $(this).html().replace(re, '<a href="$1" target="_blank">$1</a>') );
	});
};

jQuery.fn.mailto = function () {
	return this.each( function() {
		var re = /(([a-z0-9*._+]){1,}\@(([a-z0-9]+[-]?){1,}[a-z0-9]+\.){1,}([a-z]{2,4}|museum)(?![\w\s?&.\/;#~%"=-]*>))/g
		$(this).html( $(this).html().replace( re, '<a href="mailto:$1">$1</a>' ) );
	});
};

function prettyDate(datetime) {
	return Date.now();
};


var RoninTeamServer = new Faye.Client('http://'+roninteam_server+'/share', { timeout: 120 });

Logger = {
  incoming: function(message, callback) {
    console.log('incoming', message);
    callback(message);
  },
  outgoing: function(message, callback) {
    console.log('outgoing', message);
    callback(message);
  }
};

//RoninTeamServer.addExtension(Logger);

var chatsub = RoninTeamServer.subscribe('/chat', function(chat) {
  var TimeStampId = new Date().getTime();
  var mesgNode = $('<li style="opacity:0.1;" />').attr('id', TimeStampId);

  if (roninteam_user == chat.user)
  {
    mesgNode.attr('class', 'me message');
  }
  else
  {
    if (chat.message.match(roninteam_user))
    {
      mesgNode.attr('class', 'highlight message');
    }
    else
    {
      mesgNode.attr('class', 'message');
    }
  }

  $('<span class="user-name" />').text(chat.user).appendTo(mesgNode);
  $('<span class="user-message" />').text(chat.message).appendTo(mesgNode);
  $('<span class="datetime" />').text(chat.timestamp).appendTo(mesgNode);

  $('ul.chat').append(mesgNode);

  $('li#' + TimeStampId).animate({'opacity': 1}, 500);
  $('ul.chat').scrollTo('100%', 1);
});

var users = RoninTeamServer.subscribe('/users', function(users) {
  var TitleData = 'IP Address: '+users.addr+''
  var UserData = '<img src="../images/user.png" width="16px" height="16px" alt="User"> '+ users.user
  if (!$('ul.user-list li.'+users.user).is(':visible')) {
    if (roninteam_user == users.user) {
       $('ul.user-list').append('<li class="me '+users.user+'"><span title="'+TitleData+'" class="tooltip">'+UserData+'</span></li>');
    } else {
       $('ul.user-list').append('<li class="'+users.user+'"><span title="'+TitleData+'" class="tooltip">'+UserData+'</span></li>');
    };
  };
  if (users.newpush == true) { $('ul.chat').append('<li>'+users.user+' entered the chat.</li>'); };
});

var announce = RoninTeamServer.subscribe('/announce', function(announce) {
  RoninTeamServer.publish('/users', {user: roninteam_user, newpush: announce.newpush});
});

var commandsub = RoninTeamServer.subscribe('/ls', function(comm) {
  $('ul.chat').append('<li><pre>'+comm.data+'</pre></li>');
});


if (roninteam_user.length != 0) {
  RoninTeamServer.publish('/users', {user: roninteam_user, agent: roninteam_agent, lang: roninteam_lang, addr: roninteam_addr});
  RoninTeamServer.publish('/announce', {newpush: false});
};
