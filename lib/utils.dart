import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/app_contants.dart';
import 'constants/widgets.dart';

String? selectedLocation = '';
bool? serviceEnabled;
LocationPermission? permission;
SharedPreferences? sharedPreferences;
Future<String?> getLocationAndAddress(context) async {
  Position? position =
      await getCurrentLocation(context, serviceEnabled, permission);
  if (kDebugMode) {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!
        .setString(AppConstants.USER_LONGITUDE, position!.longitude.toString());
    await sharedPreferences!
        .setString(AppConstants.USER_LATITUDE, position.latitude.toString());
    print('positions are $position');
  }
  selectedLocation = await getFetchedAddress(context, position);
  if (selectedLocation != null) {
    return selectedLocation;
  }
  return null;
}

Future<String?> getFetchedAddress(
    BuildContext context, Position? position) async {
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position!.latitude, position.longitude);
  Placemark place = placemarks[0];
  if (kDebugMode) {
    print(place);
  }
  return '${place.locality}, ${place.postalCode}';
}

Future<dynamic> getCurrentLocation(context, serviceEnabled, permission) async {
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled!) {
    await Geolocator.openLocationSettings();
    return customSnackBar(
        context: context, content: 'Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return customSnackBar(
          context: context,
          content: 'Please Enable Location Service to continue');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return permission_handler.openAppSettings();
  }
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}
/*
Future<String> uploadFile(BuildContext context, String filePath) async {
  String imageName = 'product_images/${DateTime.now().microsecondsSinceEpoch}';
  String downloadUrl = '';
  final file = File(filePath);
  try {
    await FirebaseStorage.instance.ref(imageName).putFile(file);
    downloadUrl =
        await FirebaseStorage.instance.ref(imageName).getDownloadURL();
    print(downloadUrl);
  } on FirebaseException catch (e) {
    customSnackBar(context: context, content: e.code);
  }
  return downloadUrl;
}*/

class Command {
  static final all = [email, browser1, browser2];

  static const email = 'write email';
  static const browser1 = 'open';
  static const browser2 = 'go to';
}

class Utils {
  static void scanText(String rawText) {
    final text = rawText.toLowerCase();

    if (text.contains(Command.email)) {
      final body = _getTextAfterCommand(text: text, command: Command.email);

      openEmail(body: body);
    } else if (text.contains(Command.browser1)) {
      final url = _getTextAfterCommand(text: text, command: Command.browser1);

      openLink(url: url);
    } else if (text.contains(Command.browser2)) {
      final url = _getTextAfterCommand(text: text, command: Command.browser2);

      openLink(url: url);
    }
  }

  static String _getTextAfterCommand({
    required String text,
    required String command,
  }) {
    final indexCommand = text.indexOf(command);
    final indexAfter = indexCommand + command.length;

    if (indexCommand == -1) {
      return " ";
    } else {
      return text.substring(indexAfter).trim();
    }
  }

  static Future openLink({
    required String url,
  }) async {
    if (url.trim().isEmpty) {
      await _launchUrl('https://google.com');
    } else {
      await _launchUrl('https://$url');
    }
  }

  static Future openEmail({
    required String body,
  }) async {
    final url = 'mailto: ?body=${Uri.encodeFull(body)}';
    await _launchUrl(url);
  }

  static Future _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}

launch(String url) {}

canLaunch(String url) {}
