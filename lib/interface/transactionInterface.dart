
class TransactionInterface {
  var transactionId;
  var transactionType;
  var sender;
  var debitorPhoneNumber;
  var creditorPhoneNumber;
  var amount;
  var fees;
  var commission;
  var excutionDate;
  List<TransactionDocInterface> transactionDoc = [];


  TransactionInterface({
        var transactionId,
  var transactionType,
  var sender,
  var debitorPhoneNumber,
  var creditorPhoneNumber,
  var amount,
  var fees,
  var commission,
  var excutionDate,
        required List<TransactionDocInterface> transactionDoc,
        
  })
  {
        this.transactionId     = transactionId ;
        this.transactionType      = transactionType  ;
        this.sender    = sender ;
        this.amount       = amount   ;
        this.debitorPhoneNumber       = debitorPhoneNumber   ;
        this.creditorPhoneNumber       = creditorPhoneNumber   ;
        this.amount       = amount   ;
        this.fees       = fees   ;
        this.commission       = commission   ;
        this.excutionDate = excutionDate;
        this.transactionDoc = transactionDoc;
  }

  factory TransactionInterface.fromJSON(Map<String, dynamic> json)
  {
    var transactionDocs = json['transactions_docs'];
    print("transactionDocs $transactionDocs");
    return TransactionInterface(
        transactionId    : json['wizallTransactionId'] ,
        sender     : json['sender'],
        transactionType   : json['transactionType'],              
        amount     : json['amount'] ,
        debitorPhoneNumber     : json['debitorPhoneNumber'],
        creditorPhoneNumber   : json['creditorPhoneNumber'],              
        fees     : json['fees'],
        commission : json['commission'],
        excutionDate : json['executionDate'],
        transactionDoc: new List<TransactionDocInterface>.from(
          transactionDocs.map((x) => TransactionDocInterface.fromJSON(x))),
    );
  }
}
class TransactionDocInterface {
  var id;
   var transactionType;
  var transactionChannel;
 
  

  TransactionDocInterface(
      {var id, var transactionChannel, var transactionType}) {
    this.id = id;
    this.transactionType = transactionType;
    this.transactionChannel = transactionChannel;
  }
  factory TransactionDocInterface.fromJSON(Map<String, dynamic> json) {
    
    return TransactionDocInterface(
      id: json['_id'] ?? "",
      transactionType: json['transactionType'] ?? "",
      transactionChannel: json['TransactionChannel'] ?? "",

    );
  }
}