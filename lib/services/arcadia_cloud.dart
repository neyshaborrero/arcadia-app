import 'dart:convert';
import 'package:arcadia_mobile/services/firebase.dart';
import 'package:arcadia_mobile/src/structure/ads_details.dart';
import 'package:arcadia_mobile/src/structure/badrequest_exception.dart';
import 'package:arcadia_mobile/src/structure/bounty.dart';
import 'package:arcadia_mobile/src/structure/error_detail.dart';
import 'package:arcadia_mobile/src/structure/hub.dart';
import 'package:arcadia_mobile/src/structure/hub_checkin.dart';
import 'package:arcadia_mobile/src/structure/hub_checkout.dart';
import 'package:arcadia_mobile/src/structure/location.dart';
import 'package:arcadia_mobile/src/structure/match_details.dart';
import 'package:arcadia_mobile/src/structure/match_player.dart';
import 'package:arcadia_mobile/src/structure/mission_details.dart';
import 'package:arcadia_mobile/src/structure/news_article.dart';
import 'package:arcadia_mobile/src/structure/prize_details.dart';
import 'package:arcadia_mobile/src/structure/raffle_purchase.dart';
import 'package:arcadia_mobile/src/structure/response_detail.dart';
import 'package:arcadia_mobile/src/structure/success_response.dart';
import 'package:arcadia_mobile/src/structure/survey_details.dart';
import 'package:arcadia_mobile/src/structure/user_activity.dart';
import 'package:arcadia_mobile/src/structure/user_profile.dart';
import 'package:flutter/material.dart';
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

  Future<Map<String, dynamic>> deleteUser(String? token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/user/deleteuser');

    print(token);

    final response = await http.post(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'x-api-key': _firebaseService.xApiKey,
    });

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
      String? token,
      String? city,
      String? fcmToken,
      bool? isProfileComplete) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/user/updateuser');

    Map<String, dynamic> bodyCall = {};

    if (gamertag != null) bodyCall['gamertag'] = gamertag;
    if (dob != null) bodyCall['dob'] = dob;
    if (profileUrl != null) bodyCall['profileImageUrl'] = profileUrl;
    if (fullName != null) bodyCall['fullName'] = fullName;
    if (gender != null) bodyCall['gender'] = gender;
    if (userType != null) bodyCall['userType'] = userType;
    if (city != null) bodyCall['city'] = city;
    if (fcmToken != null) bodyCall['fcmToken'] = fcmToken;
    if (isProfileComplete != null) {
      bodyCall['profileComplete'] = isProfileComplete;
    }

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
      body: jsonEncode(bodyCall),
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
      print(data);
      return UserProfile.fromJson(data);
    } else {
      print("error getting profile ${response.body}");
      // Handle error
      return null;
    }
  }

  Future<String> fetchUserUID(String qrcode, String token) async {
    final url = Uri.parse(
        '${_firebaseService.arcadiaCloudAddress}/user/getuid/$qrcode');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      // Handle error
      return '';
    }
  }

  Future<List<Bounty>> getBounties(String token) async {
    final url = Uri.parse('${_firebaseService.arcadiaCloudAddress}/bounty/get');

    print("URL $url");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['bounties'];

      return data.map((bountyJson) => Bounty.fromJson(bountyJson)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('No Bounties Available');
    } else {
      // Handle error appropriately
      throw Exception('Failed to load bounties');
    }
  }

  Future<String> requestBountyChallenge(
      String token, String bountyId, String challengerId) async {
    final url = Uri.parse(
        '${_firebaseService.arcadiaCloudAddress}/bounty/requestChallenge');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
      body: jsonEncode({
        'bountyId': bountyId,
        'challengerId': challengerId,
      }),
    );

    if (response.statusCode == 200) {
      // Decode the JSON response
      final data = json.decode(response.body);

      // Retrieve the expirationTimestamp
      final expirationTimestamp = data['expirationTimestamp'].toString();

      //final String data = json.decode(response.body)['bounties'];
      return expirationTimestamp;
    } else if (response.statusCode == 404) {
      throw Exception('No Bounties Available');
    } else {
      // Handle error appropriately
      throw Exception('Failed to load bounties');
    }
  }

  Future<UserActivity?> validateQRCode(
      String qrCode, String token, AppLocation location) async {
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
        'latitude': location.latitude,
        'longitude': location.longitude,
        'userLocalDatetime': DateTime.now().toIso8601String()
      }),
    );

    print("Validating response ${response.statusCode}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print("Validating response $data");
      return UserActivity.fromJson(data, "idsir");
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      print(errorResponse['errors'][0]['message']);
      throw BadRequestException(errorResponse['errors'][0]['message']);
    } else {
      return null;
    }
  }

  Future<HubCheckin> validateOperatorQRCode(String qrCode, String token) async {
    final response = await http.post(
      Uri.parse(
          '${_firebaseService.arcadiaCloudAddress}/operator/scan'), // Replace with your actual endpoint
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
      return HubCheckin.fromJson(data);
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      throw BadRequestException(errorResponse['errors'][0]['message']);
    } else {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      throw BadRequestException(errorResponse['errors'][0]['message']);
    }
  }

  Future<HubCheckOut> checkoutOperator(String hubId, String token) async {
    final response = await http.post(
      Uri.parse(
          '${_firebaseService.arcadiaCloudAddress}/hubs/activity/$hubId'), // Replace with your actual endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add the Firebase ID token here
        'x-api-key': _firebaseService.xApiKey,
      },
      body: jsonEncode({
        'type': "checkout",
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print("Validating response $data");
      return HubCheckOut.fromJson(data);
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      print(errorResponse['errors'][0]['message']);
      throw BadRequestException(errorResponse['errors'][0]['message']);
    } else {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      throw BadRequestException(errorResponse['errors'][0]['message']);
    }
  }

  Future<bool> checkinEventPlayer(
      String userId, String hubId, String token) async {
    final response = await http.post(
      Uri.parse(
          '${_firebaseService.arcadiaCloudAddress}/events/qr-check-in'), // Replace with your actual endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add the Firebase ID token here
        'x-api-key': _firebaseService.xApiKey,
      },
      body: jsonEncode({'qrcode': userId, 'hubId': hubId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['success'];
      //return HubCheckOut.fromJson(data);
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      print(errorResponse['errors'][0]['message']);
      throw BadRequestException(errorResponse['errors'][0]['message']);
    } else {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      throw BadRequestException(errorResponse['errors'][0]['message']);
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

  Future<List<AdsDetails>> fetchAds() async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/sponsor/getAds');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _firebaseService.xApiKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<AdsDetails> adsDetails = [];

      data.forEach((key, value) {
        adsDetails.add(AdsDetails.fromJson(key, value));
      });

      return adsDetails;
    } else {
      // Handle error
      print('Failed to load ads');
      return [];
    }
  }

  Future<List<SurveyDetails>> fetchSurveys(String token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/survey/active');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<SurveyDetails> surveyDetails = [];

      for (var value in data) {
        surveyDetails.add(SurveyDetails.fromJson(value['id'], value));
      }

      return surveyDetails;
    } else {
      // Handle error
      print('Failed to load surveys');
      return [];
    }
  }

  Future<List<SurveyDetails>> fetchSurveyDetails(
      String token, String surveyId) async {
    final url = Uri.parse(
        '${_firebaseService.arcadiaCloudAddress}/survey/active?surveyId=$surveyId');

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
      List<SurveyDetails> surveyDetails = [];
      surveyDetails.add(SurveyDetails.fromJson(data['id'], data));

      return surveyDetails;
    } else {
      // Handle error
      print('Failed to load survey');
      return [];
    }
  }

  Future<bool> submitSurveyAnswer(
      String surveyId, List<String> answers, String token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/survey/answer');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
      body: json.encode({
        'surveyId': surveyId,
        'answers': answers,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // Handle error
      print('Failed to submit survey answer');
      return false;
    }
  }

  Future<MatchDetails?> createArcadiaMatch(String? gameId, String eventId,
      String hubId, String? stationId, String? matchType, String token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/match/create');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
      body: json.encode({
        'gameId': gameId,
        'eventId': eventId,
        'hubId': hubId,
        'stationId': stationId,
        'matchType': matchType,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final MatchDetails data = MatchDetails.fromJson(null, jsonData);
      return data;
    } else {
      // Handle error
      print('Failed to create arcadia match');
      return null;
    }
  }

  Future<MatchPlayer?> addPlayerArcadiaMatch(
      String gameId,
      String matchId,
      String playerSlot,
      String userId,
      String matchType,
      String stationId,
      String hubId,
      String token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/match/addPlayer');

    print("token, $token");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
      body: json.encode({
        'gameId': gameId,
        'matchId': matchId,
        'playerSlot': playerSlot,
        'userId': userId,
        'matchType': matchType,
        'stationId': stationId,
        'hubId': hubId
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final MatchPlayer data = MatchPlayer.fromJson(jsonData);
      return data;
    } else {
      // Handle error
      print('Failed to add player ${response.body}');
      return null;
    }
  }

  Future<bool> changeMatchStatus(
      String matchStatus, String matchId, String hubId, String token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/match/setStatus');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
      body: json.encode(
          {'matchId': matchId, 'matchStatus': matchStatus, 'hubId': hubId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // Handle error
      print('Failed to change match status ${response.body}');
      return false;
    }
  }

  Future<bool> setMatchWinner(
      String winner, String matchId, String hubId, String token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/match/setWinner');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
      body: json.encode({
        'matchId': matchId,
        'winner': winner,
        'hubId': hubId,
      }),
    );

    print("statusCode ${response.statusCode}");

    if (response.statusCode == 200) {
      return true;
    } else {
      // Handle error
      print('Failed set match winner ${response.body}');
      return false;
    }
  }

  Future<bool> deleteArcadiaMatch(
      String matchId, String hubId, String token) async {
    final url = Uri.parse(
        '${_firebaseService.arcadiaCloudAddress}/match/$hubId/$matchId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final SuccessResponse data = SuccessResponse.fromJson(jsonData);
      return data.success;
    } else {
      // Handle error
      print('Failed to delete arcadia match');
      return false;
    }
  }

  Future<List<MatchDetails>> getArcadiaMatches(
      String hubId, String token) async {
    // Construct the API URL
    final url = Uri.parse(
        '${_firebaseService.arcadiaCloudAddress}/match/get?hubId=$hubId&status=in%20progress&status=ready');

    // Send the GET request to the server
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
    );

    // If the response is successful (status code 200)
    if (response.statusCode == 200) {
      try {
        // Decode the response body into a Map<String, dynamic>
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Initialize an empty list to store MatchDetails objects
        List<MatchDetails> matches = [];

        jsonData.forEach((key, item) {
          try {
            // Parse the item into MatchDetails and add it to the list
            matches
                .add(MatchDetails.fromJson(key, item as Map<String, dynamic>));
          } catch (e) {
            // Print specific error message for this item
            print("Error parsing item with key: $key. Error: $e");
          }
        });

        // Return the list of matches
        return matches;
      } catch (e) {
        // Catch and print any errors during the response decoding or processing
        print("Error decoding or processing the response: $e");
        return [];
      }
    } else {
      // Handle the error case (non-200 response status)
      print(
          'Failed to get Arcadia matches. Status code: ${response.statusCode}');
      return [];
    }
  }

  Future<Hub?> getHubDetails(String hubId, String token) async {
    // Construct the API URL
    final url = Uri.parse(
        '${_firebaseService.arcadiaCloudAddress}/hubs/get/$hubId'); // Update with your actual API endpoint

    // Send the GET request to the server
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key':
            _firebaseService.xApiKey, // Replace with actual API key if needed
      },
    );

    // If the response is successful (status code 200)
    if (response.statusCode == 200) {
      try {
        // Decode the response body into a Map<String, dynamic>
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Parse the response into HubDetails object
        Hub hubDetails = Hub.fromJson(jsonData);

        // Return the hub details
        return hubDetails;
      } catch (e) {
        // Catch and print any errors during the response decoding or processing
        print("Error decoding or processing the response: $e");
        return null;
      }
    } else {
      // Handle the error case (non-200 response status)
      print('Failed to get hub details. Status code: ${response.statusCode}');
      return null;
    }
  }

  Future<List<PrizeDetails>?> fetchArcadiaPrizes(String token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/raffle/prizes');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _firebaseService.xApiKey,
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<PrizeDetails> prizes =
          (data['prizes'] as List<dynamic>).map((activityJson) {
        return PrizeDetails.fromJson(activityJson, activityJson['id']);
      }).toList();

      return prizes;
    } else {
      // Handle error
      print('Failed to load prizes ${response.body}');
      return null;
    }
  }

  Future<List<PrizeDetails>?> fetchArcadiaLoot(String token) async {
    final url =
        Uri.parse('${_firebaseService.arcadiaCloudAddress}/raffle/lootPrizes');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _firebaseService.xApiKey,
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<PrizeDetails> prizes =
          (data['prizes'] as List<dynamic>).map((activityJson) {
        return PrizeDetails.fromJson(activityJson, activityJson['id']);
      }).toList();

      return prizes;
    } else {
      // Handle error
      print('Failed to load prizes ${response.body}');
      return null;
    }
  }

  Future<RafflePurchase> buyRaffleTickets({
    required String prizeId,
    required int ticketCount,
    required String eventId,
    required int tokenCost,
    required String token,
  }) async {
    final url = Uri.parse(
        '${_firebaseService.arcadiaCloudAddress}/raffle/buy-raffle-tickets');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-api-key': _firebaseService.xApiKey,
        },
        body: json.encode({
          'prizeId': prizeId,
          'ticketCount': ticketCount,
          'eventId': eventId,
          'tokenCost': tokenCost,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['success'] == true) {
          return RafflePurchase(
            entries: responseBody['ticketsPurchased'],
            remainingTokens: responseBody['remainingTokens'],
            dayOne: responseBody['raffleEntriesDayOnePur'] ?? 0,
            dayTwo: responseBody['raffleEntriesDayTwoPur'] ?? 0,
          );
        } else {
          throw Exception('API Error: ${responseBody['message']}');
        }
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error purchasing raffle tickets: $e');
      rethrow; // Re-throw the error for upstream handling
    }
  }

  //Missions
  Future<List<MissionDetails>?> fetchArcadiaMissions(
      String token, String? userDate, String? timeZone) async {
    final baseUrl =
        '${_firebaseService.arcadiaCloudAddress}/mission/getmissions';

    // Add query parameters to the base URL
    final url = Uri.parse(baseUrl).replace(queryParameters: {
      if (userDate != null)
        'date': userDate, // Add date as a query parameter if it's not null
      if (timeZone != null)
        'timeZone':
            timeZone, // Add timeZone as a query parameter if it's not null
    });

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-api-key': _firebaseService.xApiKey,
      },
    );

    if (response.statusCode == 200) {
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

  Future<Map<String, dynamic>> isUserReferral(String code, String token) async {
    final Uri url = Uri.parse(
        '${_firebaseService.arcadiaCloudAddress}/referral/isUserReferral?code=$code');
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
      throw Exception('Failed to check user referral code');
    }
  }

  void postReferral(String code, String rewardIdReferrer,
      String rewardIdReferee, String token) async {
    final response = await http.post(
      Uri.parse(
          '${_firebaseService.arcadiaCloudAddress}/referral/redeemUserReferral'), // Replace with your actual endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add the Firebase ID token here
        'x-api-key': _firebaseService.xApiKey,
      },
      body: jsonEncode({
        'code': code,
        'rewardIdReferrer': rewardIdReferrer,
        'rewardIdReferee': rewardIdReferee
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print("referral data, $data");
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      print("referral data $errorResponse");
      //throw BadRequestException(errorResponse['errors'][0]['message']);
    }
  }

  Future<UserActivity?> recordNews(
      bool earn, String qrId, String newsId, String token) async {
    final response = await http.post(
      Uri.parse(
          '${_firebaseService.arcadiaCloudAddress}/news/read'), // Replace with your actual endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add the Firebase ID token here
        'x-api-key': _firebaseService.xApiKey,
      },
      body: jsonEncode({'newsId': newsId, 'qrId': qrId, 'earn': earn}),
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

  void recordAdView(
      String view, String partnerId, String adId, String token) async {
    final response = await http.post(
      Uri.parse(
          '${_firebaseService.arcadiaCloudAddress}/sponsor/adview'), // Replace with your actual endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add the Firebase ID token here
        'x-api-key': _firebaseService.xApiKey,
      },
      body: jsonEncode({'adId': adId, 'partnerId': partnerId, 'view': view}),
    );

    if (response.statusCode == 400) {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      throw BadRequestException(errorResponse['errors'][0]['message']);
    }
  }

  void recordAdClick(
      String view, String partnerId, String adId, String token) async {
    final response = await http.post(
      Uri.parse(
          '${_firebaseService.arcadiaCloudAddress}/sponsor/adclick'), // Replace with your actual endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add the Firebase ID token here
        'x-api-key': _firebaseService.xApiKey,
      },
      body: jsonEncode({'adId': adId, 'partnerId': partnerId, 'view': view}),
    );

    if (response.statusCode == 400) {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      throw BadRequestException(errorResponse['errors'][0]['message']);
    }
  }

  Future<Map<String, dynamic>> fetchReadNews(String token) async {
    final response = await http.get(
      Uri.parse(
          '${_firebaseService.arcadiaCloudAddress}/user/reads'), // Replace with your actual endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add the Firebase ID token here
        'x-api-key': _firebaseService.xApiKey,
      },
    );

    if (response.statusCode == 200) {
      // final Map<String, dynamic> data = json.decode(response.body);
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      throw BadRequestException(errorResponse['errors'][0]['message']);
    } else {
      return {};
    }
  }
}
