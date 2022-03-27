
class MessageInterface {
  var user1;
  var sender;
  var user2;
  var messageContent;
  var date;
  var time;
  var created_at;


  MessageInterface({
        var user1                  ,
        var sender                    ,
        var user2                 ,
        var messageContent                     ,
        var date                 ,
        var time                     ,
        var created_at,
  })
  {
        this.user1     = user1;
        this.sender      = sender  ;
        this.user2    = user2 ;
        this.messageContent       = messageContent   ;
        this.date       = date   ;
        this.time       = time   ;
        this.created_at = created_at;
  }

  factory MessageInterface.fromJSON(Map<String, dynamic> json)
  {
    return MessageInterface(
        user1    : json['message'] ,
        sender     : json['sender'],
        user2   : json['receiver'],              
        messageContent     : json['messageContent'],
        date   : json['date'],              
        time     : json['time'],
        created_at: json['created_at']
    );
  }
}