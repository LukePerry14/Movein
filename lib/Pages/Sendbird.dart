
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

  Future<GroupChannel> createChannel(String userId, String groupName, String? groupIcon, String channelURL) async
  {
      try {

        final params = GroupChannelParams()
        .. userIds = [userId]
        ..channelUrl = channelURL
        ..name = groupName;
        final groupChannel = await GroupChannel.createChannel(params);
        return groupChannel;
        //..coverImage = groupIcon;
      }
      catch(e)
      {
              print('createChannel: ERROR: $e');
              throw e;
      }
      
  }

    Future<GroupChannel> createDM(List <String> userIds, String groupName, String? groupIcon) async
  {
      try {

        userIds.sort();
        final params = GroupChannelParams()
        .. userIds = userIds
        ..channelUrl = userIds[0] + userIds[1]
        ..isDistinct = true
        ..name = groupName;
        final groupChannel = await GroupChannel.createChannel(params);
        return groupChannel;
        //..coverImage = groupIcon;
      }
      catch(e)
      {
              print('createChannel: ERROR: $e');
              throw e;
      }
      
  }
  void leaveChannel(String userId, String groupId) async
    {
      try 
      {

         final channel = await returnChannel(groupId);
         await channel.leave();

      }
      catch(e)
      {print('Error');}
    }
}