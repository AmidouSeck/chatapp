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

  Future<UserInterface> getUserInfo() async {
   await _readToken();

    final response = await http.get(
        Uri.parse(apiUrl + "/users/getUserInfos"),headers: await _headersAuth(token));
     
     print(response.body);
    if (response.statusCode == 201) {
      final Map<String, dynamic> parsed = json.decode(response.body);
      var user = UserInterface.fromJSON(parsed['user']);
      return user;
    } else {
      throw Exception('Failed to load the users infos');
    }
  }
   Future<UserInterface> getUserInfoNano() async {
   await _readToken();

    final response = await http.get(
        Uri.parse(apiUrl + "/users/getNanoInfos"),headers: await _headersAuth(token));
     
     print(response.body);
    if (response.statusCode == 201) {
      final Map<String, dynamic> parsed = json.decode(response.body);
      var user = UserInterface.fromJSON(parsed['user']);
      return user;
    } else {
      throw Exception('Failed to load the users infos');
    }
  }
}
