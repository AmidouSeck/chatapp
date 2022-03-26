
class MessageInterface {
  var user1;
  var sender;
  var user2;
  var messageContent;
  var date;
  var time;


  MessageInterface({
        var user1                  ,
        var sender                    ,
        var user2                 ,
        var messageContent                     ,
        var date                 ,
        var time                     ,
        
  })
  {
        this.user1     = user1;
        this.sender      = sender  ;
        this.user2    = user2 ;
        this.messageContent       = messageContent   ;
        this.date       = date   ;
        this.time       = time   ;
  }

  factory MessageInterface.fromJSON(Map<String, dynamic> json)
  {
    return MessageInterface(
        user1    : json['message'] as int,
        sender     : json['sender'],
        user2   : json['receiver'],              
        messageContent     : json['messageContent'] as String,
        date   : json['date'],              
        time     : json['time'],
    );
  }
}