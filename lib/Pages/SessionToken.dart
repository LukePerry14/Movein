 import 'dart:convert';

import 'package:http/http.dart' as http;
 import 'package:sendbird_sdk/sendbird_sdk.dart';
 import 'package:movein/Pages/Sendbird.dart';
 
 class SessionToken
 {

 
  
  Future<String> generateToken(String userID, String nickname)
  async{
    //User user = await ConnectSendbird().findUserViaId(userID);
    String app = "33BDBE40-0D0C-4529-BA3B-74C0916D2682";
    final response = await http.post(Uri.parse(
      'https://api-${app}.sendbird.com/v3/users'),
      body:
      jsonEncode(
      {

        "user_id":userID,
        "nickname":nickname,
        "profile_url":'',
        "issue_access_token":true,
        
        

      }),
      headers:
      {
        "Api-Token": '93105a021966bf8582f776513998364b68e6fd3e',
        //"Content-Type":
      }
    );
                                if (response.statusCode == 200)
                                {
                                  final jsonResponse = jsonDecode(response.body);

                                  String accessToken = ((jsonResponse['access_token']));
                                  return accessToken;
                                }
                                else
                                {
                                  
                                  throw Exception(response.body);
                                  
                                }
                                
  }

 }