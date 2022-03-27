import 'dart:convert';
import 'dart:io';
import 'package:chatapp/constants/network.dart';
import 'package:chatapp/interface/userInterface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../interface/messageInterface.dart';

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

  static List<MessageInterface> parsedDataMessage(
      String responseBody, String nameBody) {
    final Map<String, dynamic> parsed = json.decode(responseBody);
    //print("list test $parsed");
    var listParsed = List<MessageInterface>.from(
        parsed[nameBody].map((x) => MessageInterface.fromJSON(x)));
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


static dynamic postMessage(
      {required String messageContent,
      required String user1,
      required String user2,
      required String sender,
      required var img,
      }) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(apiUrl + '/chat/postmessage'));

    request.fields['messageContent'] = messageContent;
    request.fields['user1'] = user1;
    request.fields['user2'] = user2;
    request.fields['sender'] = sender;
    if (img != null) {
      request.files.add(
          await http.MultipartFile.fromPath('img', img.path));
    }

    //print("Contenu de request : $request");
    var response = await request.send();

    final res = await http.Response.fromStream(response);

    //print("res status ${res.statusCode}");
    //print("res status ${res.body}");
    if (res.statusCode == 201)
      return res.body;
    else {
      return res.body;
    }
  }

  Future<List<MessageInterface>> getMessage(String user1, String user2) async {
    print("PARAMS ENDPOINT "+user1+" "+user2);
    final response = await http.get(
        Uri.parse(apiUrl + "/chat/getmessage/$user1/$user2"));
     
     print(response.body);
    if (response.statusCode == 201) {
      final Map<String, dynamic> parsed = json.decode(response.body);
      //print(parsed)
      var data = parsedDataMessage(response.body, "message");
      //var user = UserInterface.fromJSON(data);
      print(data.length);
      return data;
    } else {
      throw Exception('Failed to load the users messages');
    }
  }

}
