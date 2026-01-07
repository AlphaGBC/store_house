import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:store_house/controller/order_cards_controller.dart';
import 'package:store_house/core/functions/fancy_snackbar.dart';

requestPermissionNotification() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}

fcmconfig() {
  FirebaseMessaging.onMessage.listen((message) {
    FlutterRingtonePlayer player =
        FlutterRingtonePlayer(); // create an instance
    player.playNotification(); // now you can access the instance method

    FancySnackbar.show(
      title: message.notification!.title!,
      message: message.notification!.body!,
    );

    refreshorders(message.data);
  });
}

refreshorders(data) {
  if (data['pagename'] == "refreshorders") {
    OrderCardsController controller = Get.find();
    controller.refreshOrders();
  }
}
