import 'dart:convert';
import 'dart:io';
import 'package:chatapp/constants/network.dart';
import 'package:chatapp/interface/transactionInterface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TransactionService {
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

  static List<TransactionInterface> parsedData(
      String responseBody, String nameBody) {
    final Map<String, dynamic> parsed = json.decode(responseBody);
    print("list test $parsed");
    var listParsed = List<TransactionInterface>.from(
        parsed[nameBody].map((x) => TransactionInterface.fromJSON(x)));
    print("list test $listParsed");
    return listParsed;
  }

  Future<List<TransactionInterface>> getAllTransactions({required String month,required String year}) async {
    await _readToken();
     print("access ");
    final response = await http.get(
        Uri.parse(apiUrl + "/users/getUserTransactionListByMonthByYear/$month/$year"),
        headers: await _headersAuth(token));
    
    print("res status ${response.statusCode}");
    print("res statusn ${response.body}");
    if (response.statusCode == 200) {
      var transList = parsedData(response.body, "data");

      print("list $transList");

      return transList;
    } else {
      throw Exception('Failed to load the transaction');
    }
  }
  Future<dynamic> getListFavoryAireTime() async {
    await _readToken();

    final response = await http.get(
        Uri.parse(apiUrl + "/favorite-users/getByTransferType/AIRTIME"),
        headers: await _headersAuth(token));
    
    print("res status ${response.statusCode}");
    print("res statusn ${response.body}");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load the transaction');
    }
  }
  Future<dynamic> getListFavoryTransfer() async {
    await _readToken();

    final response = await http.get(
        Uri.parse(apiUrl + "/favorite-users/getByTransferType/TRANSFER"),
        headers: await _headersAuth(token));
    
    print("get ${response.statusCode}");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load the transaction');
    }
  }
  Future<dynamic> setQrCode({required String qrCode}) async {
    await _readToken();

    final response = await http.get(
        Uri.parse(apiUrl + "/qrcode/$qrCode"),
        headers: await _headersAuth(token));
    
   print("response.statusCode ${response.statusCode}");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load the transaction');
    }
  }
  static dynamic makeTransfert(
      {
      required String tomsisdn,
      required String amount,
      required String transferService}) async {
    await _readToken();
    final response = await http.post(
        Uri.parse(apiUrl + '/wizall/transfer-transaction/makeTransfert'),
        body: {
          'tomsisdn': tomsisdn,
          'amount': amount,
          'transferService': transferService
        },
        headers: await _headersAuth(token));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200)
      return response.body;
    else {
      throw Exception("Could not make transfert");
    }
  }
  static dynamic makeRepayment(
      {
    
      required String amount,
      }) async {
    await _readToken();
    final response = await http.post(
        Uri.parse(apiUrl + '/nano/remboursement'),
        body: {
          'amount': amount,
        },
        headers: await _headersAuth(token));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200)
      return response.body;
    else {
      throw Exception("Could not make repayment");
    }
  }

  static dynamic makeTransfertAireTime(
      {
      required String receiverMsisdn,
      required String amount,
      required String network}) async {
    await _readToken();
    final response = await http.post(
        Uri.parse(apiUrl + '/wizall/airtime-transaction/makeTransaction'),
        body: {
          'receiverMsisdn': receiverMsisdn,
          'amount': amount,
          'network': network
        },
        headers: await _headersAuth(token));

    if (response.statusCode == 200)
      return response.body;
    else {
      throw Exception("Could not make transfert aire time");
    }
  }

  static dynamic makeTransfertRapido(
      {required String amount, required String  badgeNum}) async {
    await _readToken();
    final response = await http.post(
        Uri.parse(apiUrl + '/wizall/rapido-transaction/makeTransaction'),
        body: {
          'badge_num': badgeNum,
          'amount': amount,
        },
        headers: await _headersAuth(token));

    if (response.statusCode == 200)
      return response.body;
    else {
      throw Exception("Could not make transfert  rapido");
    }
  }

  Future<dynamic> getListFavoryRapido() async {
    await _readToken();

    final response = await http.get(
        Uri.parse(apiUrl + "/favorite-users/getByTransferType/RAPIDO"),
        headers: await _headersAuth(token));
    
    //print("res status rapido list ${response.statusCode}");
    //print("res statusn rapido list ${response.body}");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load favourite rapido list');
    }
  }

  static dynamic makeTransfertWoyofal(
      {required String msisdn,
      required String amount,
      required String compteur}) async {
    await _readToken();
    final response = await http.post(
        Uri.parse(apiUrl + '/wizall/woyofal-transaction/makeTransaction'),
        body: {
          'msisdn': msisdn,
          'amount': amount,
          'compteur': compteur,
        },
        headers: await _headersAuth(token));

    if (response.statusCode == 200)
      return response.body;
    else {
      throw Exception("Could not make transfert  woyofal");
    }
  }
}
