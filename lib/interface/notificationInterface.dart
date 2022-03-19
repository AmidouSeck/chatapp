
class NotificationInterface {
  var message;
  var sender;
  var receiver;
  var amount;
  var type;
  var date;
  var time;


  NotificationInterface({
        var message                  ,
        var sender                    ,
        var receiver                 ,
        var amount                     ,
        var type                    ,
        var date                 ,
        var time                     ,
        
  })
  {
        this.message     = message;
        this.sender      = sender  ;
        this.receiver    = receiver ;
        this.amount       = amount   ;
        this.type       = type   ;
        this.date       = date   ;
        this.time       = time   ;
  }

  factory NotificationInterface.fromJSON(Map<String, dynamic> json)
  {
    return NotificationInterface(
        message    : json['message'] as int,
        sender     : json['sender'],
        receiver   : json['receiver'],              
        amount     : json['amount'] as int,
        type     : json['type'],
        date   : json['date'],              
        time     : json['time'],
    );
  }
}