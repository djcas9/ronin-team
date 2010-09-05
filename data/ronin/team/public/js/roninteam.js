var RoninTeam = {

	growl: function(){
		$("#growl").notify({
		    speed: 500,
		    expires: 3000
		});
	},

	helpers: function(){
		$('ul.chat').scrollTo('100%', 1);
		$('ul.chat li').css('opacity', 1);
	},

  currentTime: function() {   return new Date().getTime(); },

  flashMessages: function() {
    $('<div id="flash-messages"></div>').appendTo('body');
  },

  flashMessage: function(message) {
    $('<p class="flash-message" />').text(message).appendTo("#flash-messages");
  },

  ChatRoom: {
    newMessage: function() {
      return $('<li style="opacity:0.1;" />').attr('id', RoninTeam.currentTime());
    },

    addMessage: function(mesgNode) {
      $('ul.chat').append(mesgNode);

			$('ul.chat').scrollTo('100%', 1);
      mesgNode.animate({opacity: 1}, 500);
      return mesgNode;
    },

    addStatusMessage: function(message,user) {
      var mesgNode = RoninTeam.ChatRoom.newMessage();
			
			if (user != undefined) {
				var MessageTitle = user + ' said:';
			} else {
				var MessageTitle = 'System Message:';
			};
			
			$('#growl').notify("create", {
					    title: MessageTitle,
					    text: message
					},{
					    expires: 3000,
					    speed: 500
					});
    },

    addUserMessage: function(chat) {
      var mesgNode = RoninTeam.ChatRoom.newMessage();
      var classes = ['message'];

      if (roninteam_user == chat.user)
      {
        classes.push('me');
      }
      else if (chat.message.match(roninteam_user))
      {
        classes.push('highlight');
      }

      mesgNode.attr('class', classes.join(' '));

      $('<span class="user-name" />').text(chat.user).appendTo(mesgNode);
      $('<span class="user-message" />').text(chat.message).appendTo(mesgNode);
      $('<span class="datetime" />').text(chat.timestamp).appendTo(mesgNode);

      return RoninTeam.ChatRoom.addMessage(mesgNode);
    },

    messageHandler: function(chat) {
      RoninTeam.ChatRoom.addUserMessage(chat);
			localStorage.setItem('chat', $('ul.chat').html());
      return true;
    },

    commands: {
      'clear': function() { 
				$('ul.chat > li').remove(); 
				localStorage.setItem('chat', '');
			},

      'nick': function(nick) {
        // stub for nick command
      },

			'notice': function(notice) {
				RoninTeamServer.publish('/sysmsg', {message: notice, user: roninteam_user});
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
          else
          {
            RoninTeam.ChatRoom.addStatusMessage('unknown command: ' + chatInput);
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
	RoninTeam.growl();
  RoninTeam.helpers();
  RoninTeam.flashMessages();
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

RoninTeamServer.addExtension(Logger);

var chatsub = RoninTeamServer.subscribe('/chat', RoninTeam.ChatRoom.messageHandler);

var users = RoninTeamServer.subscribe('/users', function(users) {
	//var users = localStorage(users);
  var TitleData = 'IP Address: '+users.addr+''
  var UserData = '<img src="../images/user.png" width="16px" height="16px" alt="User"> '+ users.user
  if ($('ul.user-list li.'+users.user).length == 0) {
    if (roninteam_user == users.user) {
			RoninTeamServer.publish('/sysmsg', {message: users.user + ' joined the chat.'});
			$('ul.user-list').append('<li class="me '+users.user+'"><span title="'+TitleData+'" class="tooltip">'+UserData+'</span></li>');
			// $('ul.chat').append('<li>'+users.user+' entered the chat.</li>');
    } else {
			$('ul.user-list').append('<li class="'+users.user+'"><span title="'+TitleData+'" class="tooltip">'+UserData+'</span></li>');
    };
  };
});

var sysmsg = RoninTeamServer.subscribe('/sysmsg', function(system) {
	RoninTeam.ChatRoom.addStatusMessage(system.message,system.user);
});

var announce = RoninTeamServer.subscribe('/announce', function(announce) {
  RoninTeamServer.publish('/users', {user: roninteam_user, agent: roninteam_agent, lang: roninteam_lang, addr: roninteam_addr});
});

var privmsg = RoninTeamServer.subscribe('/chat/'+roninteam_user, function(privmsg) {
  $('ul.chat').append('<li><pre>'+privmsg.message+'</pre></li>');
});

var commandsub = RoninTeamServer.subscribe('/ls', function(comm) {
  $('ul.chat').append('<li><pre>'+comm.data+'</pre></li>');
});


if (roninteam_user.length != 0) { RoninTeamServer.publish('/announce', {}) };
if (localStorage.getItem('chat')) {
	$('ul.chat').html(localStorage.getItem('chat'));
};
