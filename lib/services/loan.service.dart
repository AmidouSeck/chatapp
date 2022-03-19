import 'dart:convert';
import 'dart:io';
import 'package:chatapp/constants/network.dart';
import 'package:chatapp/interface/transactionInterface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoanService {
  static String token = '';
  static _headersAuth(String tokens) async {
    var headers = {
      HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: "$tokens"
    };
    return headers;
  }

  static _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.getString(key) ?? '';
    token = value;
  }

 Future<dynamic> getDetailsLoan(String idLoan) async {
    await _readToken();

    final response = await http.get(
        Uri.parse(apiUrl + "/nano/loanInfos/$idLoan"),
        headers: await _headersAuth(token));
    

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load the loan details');
    }
  }

Future<dynamic> saveLoan(
      {required String recipientId,
      required String amount,
      required String idService,
      required String signature}) async {
    await _readToken();
  
    print(recipientId);
    print(amount);
    print(idService);
    print(signature);
   final response = await http.post(Uri.parse(apiUrl + '/nano/demande-credit'),body: {
      'recipient_id': recipientId,
      'amount': amount,
      'idService': idService,
      'signature': signature
    }, headers: await _headersAuth(token));

   
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200)
      return response.body;
    else {
     return response.body;
    }
  }
}