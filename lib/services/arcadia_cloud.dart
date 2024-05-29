import 'dart:convert';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:http/http.dart' as http;

class ArcadiaCloud {
  final FirebaseService _firebaseService;

  ArcadiaCloud(this._firebaseService);

  static const String _baseUrl =
      'https://us-central1-arcadia-46604.cloudfunctions.net/api';

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/loginUser');
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-api-key': _firebaseService.xApiKey,
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        //TO-DO:TRY AND FIND CONSISTENCIES ON THESE RESPONSES
        return json.decode(response.body);
      } else {
        final Map<String, dynamic> res = json.decode(response.body);
        return {'success': false, 'message': res['message']};
      }
    } catch (e) {
      // Return a failure response with the exception message
      return {'success': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> createUser(
      String email, String password, String confirmPassword) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/createUser');
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-api-key': _firebaseService.xApiKey,
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword
        }),
      );

      if (response.statusCode == 200) {
        //TO-DO:TRY AND FIND CONSISTENCIES ON THESE RESPONSES
        //TO-DO:STORE USER INFORMATION
        return {'success': true};
      } else {
        //IMPROVE ERROR MESSAGE WHEN THE EMAIL IS ALREADY TAKEN
        // Error response
        final Map<String, dynamic> res = json.decode(response.body);
        List<dynamic> errors = res['errors'] ?? [];

        // Extracting error messages
        List errorMessages = errors.map((error) {
          return error['message'] ?? 'An unknown error occurred';
        }).toList();

        return {'success': false, 'message': errorMessages.join(', ')};
      }
    } catch (e) {
      // Return a failure response with the exception message
      return {'success': false, 'message': '$e'};
    }
  }
}
