import 'dart:convert';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/structure/badrequest_exception.dart';
import 'package:arcadia_mobile/src/structure/error_detail.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
import 'package:arcadia_mobile/src/structure/news_article.dart';
import 'package:arcadia_mobile/src/structure/response_detail.dart';
import 'package:arcadia_mobile/src/structure/user_activity.dart';
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
      return UserProfile.fromJson(data);
    } else {
      // Handle error
      print('Failed to load user profile');
      return null;
    }
  }

  Future<UserActivity?> validateQRCode(String qrCode, String token) async {
    final response = await http.post(
      Uri.parse(
          '${_firebaseService.arcadiaCloudAddress}/mission/validate'), // Replace with your actual endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add the Firebase ID token here
        'x-api-key': _firebaseService.xApiKey,
      },
      body: jsonEncode({
        'qrcode': qrCode,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return UserActivity.fromJson(data, "idsir");
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      throw BadRequestException(errorResponse['errors'][0]['message']);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchUserActivity(String token,
      {String? startAfter}) async {
    final url = Uri.parse(
      '${_firebaseService.arcadiaCloudAddress}/activity/getuseractivity'
      '?limit=10${startAfter != null ? '&startAfter=$startAfter' : ''}',
    );

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
      List<UserActivity> activities =
          (data['activities'] as List<dynamic>).map((activityJson) {
        return UserActivity.fromJson(activityJson, activityJson['id']);
      }).toList();

      return {
        'activities': activities,
        'lastKey': data['lastKey'],
      };
    } else {
      // Handle error
      print('Failed to load user activity');
      return null;
    }
  }

  //Missions
  Future<List<MissionDetails>?> fetchArcadiaMissions(String token) async {
    final url = Uri.parse(
        '${_firebaseService.arcadiaCloudAddress}/mission/getmissions');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
    );

    if (response.statusCode == 200) {
      // final Map<String, dynamic> data = json.decode(response.body);
      // List<MissionDetails> missions = [];
      // data.forEach((key, value) {
      //   missions.add(MissionDetails.fromJson(value, key));
      // });
      final List<dynamic> data = json.decode(response.body);
      List<MissionDetails> missions = [];
      missions = data.map((missionJson) {
        return MissionDetails.fromJson(missionJson, missionJson['id']);
      }).toList();

      return missions;
    } else {
      // Handle error
      print(
        'Failed to load arcadia missions ${response.statusCode}',
      );
      return null;
    }
  }

  //News
  Future<List<NewsArticle>?> fetchNews(String token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/news/getnews');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
    );

    if (response.statusCode == 200) {
      // final List<dynamic> data = json.decode(response.body);
      // List<NewsArticle> newsArticles = data.map((item) {
      //   return NewsArticle.fromJson(item, "1");
      // }).toList();

      final Map<String, dynamic> data = json.decode(response.body);
      List<NewsArticle> newsArticles = [];
      data.forEach((key, value) {
        newsArticles.add(NewsArticle.fromJson(value, key));
      });
      return newsArticles;
    } else {
      // Handle error
      print('Failed to load news');
      return null;
    }
  }

  Future<Map<String, dynamic>> isGamertagAvailable(
      String gamertag, String token) async {
    final Uri url = Uri.parse(
        '${_firebaseService.arcadiaCloudAddress}/user/isgamertag?gamertag=$gamertag');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      return errorResponse;
    } else {
      throw Exception('Failed to check gamertag');
    }
  }
}
