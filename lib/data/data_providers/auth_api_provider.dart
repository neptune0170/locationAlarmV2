import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthApiProvider {
  final String baseUrl = 'http://192.168.1.4:8080';

  Future<bool> signup(String email, String password, String fullName) async {
    print("here--------------------------------------------");
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'fullName': fullName,
      }),
    );
   print("here 2 =================================================");
    return response.statusCode == 200;

  }

  Future<Map<String,dynamic>?>login(String email,String password)async{
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
     if(response.statusCode==200)
       {
         return jsonDecode(response.body);
       }else{
       return null;
     }
  }
}