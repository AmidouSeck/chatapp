
class UserInterface {
  var firstname                   ;
  var lastname                    ;
  var phoneNumber                 ;
  var userFiles                       ;
  var id                          ;

  UserInterface({
        var firstname                   ,
        var lastname                    ,
        var phoneNumber                 ,
        var balance                     ,
        var userFiles,
        var id,
        
  })
  {
        this.firstname     = firstname ;
        this.lastname      = lastname  ;
        this.phoneNumber    = phoneNumber ;
        this.id       = id   ;
        this.userFiles     = userFiles;
  }

  factory UserInterface.fromJSON(Map<String, dynamic> json)
  {
    return UserInterface(
        firstname    : json['firstname'],
        lastname     : json['lastname'],
        phoneNumber   : json['phoneNumber'],              
        userFiles     : json['userFiles'],
        id: json['_id']
    );
  }
}