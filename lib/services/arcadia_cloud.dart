import 'dart:convert';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/structure/error_detail.dart';
import 'package:arcadia_mobile/src/structure/response_detail.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:http/http.dart' as http;

class ArcadiaCloud {
  final FirebaseService _firebaseService;

  ArcadiaCloud(this._firebaseService);

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final url =
          Uri.parse('${_firebaseService.arcadiaCloudAddress}/auth/loginUser');
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
        return {'success': true, 'message': json.decode(response.body)};
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
      final url =
          Uri.parse('${_firebaseService.arcadiaCloudAddress}/auth/createUser');
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

  Future<Map<String, dynamic>> checkPassword(
      String email, String password, String confirmPassword) async {
    try {
      final url =
          Uri.parse('${_firebaseService.arcadiaCloudAddress}/auth/passcheck');

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
        return {'success': true};
      } else {
        // Error response
        final Map<String, dynamic> res = json.decode(response.body);
        ResponseDetail parsedResponse = ResponseDetail.fromJson(res);

        List<ErrorDetail> errors = parsedResponse.errors;

        return {'success': false, 'errors': errors};
      }
    } catch (e) {
      // Return a failure response with the exception message
      return {'success': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> saveUserToDB(String email, String? token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/user/saveuser');

    print(token);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
      body: jsonEncode({
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      // Error response
      print(response.body);
      final Map<String, dynamic> res = json.decode(response.body);
      ResponseDetail parsedResponse = ResponseDetail.fromJson(res);

      List<ErrorDetail> errors = parsedResponse.errors;

      return {'success': false, 'errors': errors};
    }
  }

  Future<Map<String, dynamic>> updateUserToDB(
      String? gamertag,
      String? profileUrl,
      String? dob,
      String? fullName,
      String? gender,
      String? userType,
      String? token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/user/updateuser');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
      body: jsonEncode({
        "gamertag": gamertag,
        "dob": dob,
        'profileImageUrl': profileUrl,
        "fullName": fullName,
        "gender": gender,
        "userType": userType,
        'lastUpdate': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      // Error response
      final Map<String, dynamic> res = json.decode(response.body);
      ResponseDetail parsedResponse = ResponseDetail.fromJson(res);

      List<ErrorDetail> errors = parsedResponse.errors;

      return {'success': false, 'errors': errors};
    }
  }

  Future<UserProfile?> fetchUserProfile(String token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/user/getuser');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print(json.decode(response.body));
      return UserProfile.fromJson(data);
    } else {
      // Handle error
      print('Failed to load user profile');
      return null;
    }
  }
}
