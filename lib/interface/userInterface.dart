
class UserInterface {
  var firstname                   ;
  var lastname                    ;
  var phoneNumber                 ;
  var balance                       ;
  var userStatus                    ;
  var staticCodeQr                  ;
  var loan                          ;
  var recipient                     ;
  var idService                     ;
  var paymentCreditInfos            ;

  UserInterface({
        var firstname                   ,
        var lastname                    ,
        var phoneNumber                 ,
        var balance                     ,
        var userStatus                  ,
        var staticCodeQr                ,
        var loan                   ,
        var recipient             ,
        var idService                     ,
        var paymentCreditInfos            ,

        
  })
  {
        this.firstname     = firstname ;
        this.lastname      = lastname  ;
        this.phoneNumber    = phoneNumber ;
        this.balance       = balance   ;
        this.staticCodeQr   = staticCodeQr ;
        this.loan            = loan;
        this.recipient       = recipient;
        this.idService       = idService;
        this.paymentCreditInfos = paymentCreditInfos;
        this.userStatus         = userStatus;
  }

  factory UserInterface.fromJSON(Map<String, dynamic> json)
  {
    return UserInterface(
        firstname    : json['firstname'],
        lastname     : json['lastname'],
        phoneNumber   : json['phoneNumber'],              
        balance     : json['balance'],
        staticCodeQr  : json['staticCodeQr'],
        loan           : json['credit'],
        recipient:      json['recipient'],
        idService:      json['idService'],
        paymentCreditInfos: json['paymentCreditInfos'],
        userStatus: json['userStatus']
    );
  }
}