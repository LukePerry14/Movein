
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ConnectSendbird 
{
   Future<User> connect(String appId, String userId, String nickname) async {
    // Init Sendbird SDK and connect with current user id
    try {
      final sendbird = SendbirdSdk(appId: appId);
      final user = await sendbird.connect(userId,nickname:nickname);
      return user;
    } catch (e) {
      print('login_view: connect: ERROR: $e');
      rethrow;
    }
  }


Future<String> findChannel(String channelUrl) async
{
  try
  {
    final channel = await GroupChannel.getChannel(channelUrl);
    return 'success';
  }
  catch(e){return 'Error';}
}

Future<GroupChannel> returnChannel(String channelUrl) async
  {
    
    {
      final channel =   await GroupChannel.getChannel(channelUrl);
      return channel;
    }
    
  }
}