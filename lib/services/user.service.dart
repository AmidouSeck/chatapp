import 'dart:convert';
import 'dart:io';
import 'package:chatapp/constants/network.dart';
import 'package:chatapp/interface/userInterface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserService {
  String token = '';
  _headersAuth(String tokens) async {
    var headers = {
     HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
     HttpHeaders.authorizationHeader: "$tokens"
    };
    return headers;
  }

  _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.getString(key) ?? '';
    token = value;
  }

  static List<UserInterface> parsedData(
      String responseBody, String nameBody) {
    final Map<String, dynamic> parsed = json.decode(responseBody);
    //print("list test $parsed");
    var listParsed = List<UserInterface>.from(
        parsed[nameBody].map((x) => UserInterface.fromJSON(x)));
    //print("list test $listParsed");
    return listParsed;
  }

  Future<List<UserInterface>> getUsers() async {
   await _readToken();

    final response = await http.get(
        Uri.parse(apiUrl + "/users"));
     
     //print(response.body);
    if (response.statusCode == 201) {
      final Map<String, dynamic> parsed = json.decode(response.body);
      //print(parsed)
      var data = parsedData(response.body, "user");
      //var user = UserInterface.fromJSON(data);
      print(data.length);
      return data;
    } else {
      throw Exception('Failed to load the users');
    }
  }
}
