
class ErrorInterface {
  var errorMessage                   ;
  var code                    ;


  ErrorInterface({
        var errorMessage                   ,
        var code                    ,
     
        
  })
  {
        this.errorMessage     = errorMessage ;
        this.code      = code  ;
       
  }

  factory ErrorInterface.fromJSON(Map<String, dynamic> json)
  {
    return ErrorInterface(
        errorMessage    : json['message'],
        code     : json['code'],
       
    );
  }
}