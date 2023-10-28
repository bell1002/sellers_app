
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sellers_app/functions/functions.dart';
import 'package:sellers_app/global/global.dart';

class PushNotificationsSystem
{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //notifications arrived/received
  Future whenNotificationReceived(context) async
  {
    //1. Terminated
    //when the app is completely closed directly from the push notifications
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage)
        {
          if(remoteMessage != null){
            //show notification data when open app

            showNotificationWhenOpenApp(
                remoteMessage!.data["userOrderId"],
              context
            );
          }
        });

    //2. Foreground
    //when the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if(remoteMessage != null){
        //show notification data
        showNotificationWhenOpenApp(
            remoteMessage!.data["userOrderId"],
            context
        );
      }
    });
    //3. Background
    //when the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if(remoteMessage != null){
        // directly show notification data
        showNotificationWhenOpenApp(
            remoteMessage!.data["userOrderId"],
            context
        );
      }
    });
  }
  //device recognition token
Future generateDeviceRecognitionToken() async
{
  String? registrationDeviceToken = await messaging.getToken();

  FirebaseFirestore.instance
      .collection("sellers")
      .doc(sharedPreferences!.getString("uid"))
      .update(
      {
    "sellerDeviceToken": registrationDeviceToken,
  });
  messaging.subscribeToTopic("allSellers");
  messaging.subscribeToTopic("allUsers");
}

  showNotificationWhenOpenApp(orderID, context) async{
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(orderID)
        .get()
        .then((snapshot) {
          if(snapshot.data()!["status"] == "ended"){
            showReusableSnackBar(context, "Order ID # $orderID \n\n has delivered & received by the user.");
          }
          else{
            showReusableSnackBar(context, " you have new Order. \n Order ID # $orderID \n\n Please check now.");

          }
    });
  }
}