import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/network.dart';
import 'package:google_sign_in/google_sign_in.dart';

String token = '';
_headersAuth(String tokens) async {
  var headers = {
    HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
    HttpHeaders.authorizationHeader: "$tokens"
  };
  return headers;
}
_savePhoneImei(String imei) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'imei';
    final value = imei;
    prefs.setString(key, value);
  }

_readToken() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'token';
  final value = prefs.getString(key) ?? '';
  token = value;
}

class AuthService {
  static dynamic login(
      {required String phoneNumber,
      required String pinCode,
      //required String imei
      }) async {
    final response = await http.post(Uri.parse(apiUrl + '/auth/signin'),
        body: {"phoneNumber": phoneNumber, "pinCode": pinCode});

    if (response.statusCode == 200 || response.statusCode == 201)
      return "${response.statusCode}" + "${response.body}";
    else
      throw Exception(response.body);
  }

  static dynamic signup(
      {required String lastname,
      required String firstname,
      required String phoneNumber,
      required String pinCode,
      required String gender,
      required var profilePhoto,
      }) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(apiUrl + '/auth/signup'));

    request.fields['pinCode'] = pinCode;
    request.fields['phoneNumber'] = phoneNumber;
    request.fields['firstname'] = firstname;
    request.fields['lastname'] = lastname;
    request.fields['gender'] = gender;
    
    if (profilePhoto != null) {
      request.files.add(
          await http.MultipartFile.fromPath('profilePhoto', profilePhoto.path));
    }

    print("Contenu de request : $request");
    var response = await request.send();

    final res = await http.Response.fromStream(response);

    print("res status ${res.statusCode}");
    print("res status ${res.body}");
    if (res.statusCode == 201)
      return res.body;
    else {
      return res.body;
    }
  }

  static dynamic forgotPassword({required String phoneNumber}) async {
    final response = await http.post(Uri.parse(apiUrl + '/auth/forgotPassword'),
        body: {'phoneNumber': phoneNumber});
    if (response.statusCode == 200)
      return response.body;
    else {
      throw Exception("Could not get phone number");
    }
  }

  static dynamic reinitPassword({required String newPassword}) async {
    await _readToken();
    final response = await http.post(
        Uri.parse(apiUrl + '/users/reinitPassword'),
        body: {'newPassword': newPassword},
        headers: await _headersAuth(token));
    if (response.statusCode == 202)
      return response.body;
    else {
      throw Exception("Could not change password");
    }
  }

  static dynamic verifyCode(
      {required String phoneNumber,
      required String smsCode,
      required String imei}) async {
    final response = await http.post(
      Uri.parse(apiUrl + '/auth/smsCodeVerification/$phoneNumber'),
      body: {'smsCode': smsCode, 'imei': imei},
    );
    print("imei $imei");
    print("phone $phoneNumber");
    print("smsCode $smsCode");

     print("state ${response.statusCode}");

    if (response.statusCode == 201 || response.statusCode == 200)
      return response.body;
    else {
      throw Exception("Le code entré est invalide");
    }
  }

  static dynamic resendCode(
      {required String phoneNumber, required String imei}) async {
    final response = await http.post(
      Uri.parse(apiUrl + '/auth/resendSmsCodeVerification'),
      body: {'phoneNumber': phoneNumber, 'imei': imei},
    );
    if (response.statusCode == 200)
      return response.body;
    else {
      throw Exception("Code invalide");
    }
  }
}

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
  static Future logout() => _googleSignIn.disconnect();
}
