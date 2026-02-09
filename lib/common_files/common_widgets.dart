import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CommonWidget extends StatelessWidget {
  const CommonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void showDialogBox(context, titleText, contentText) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(titleText),
            content: Text(contentText),
          );
        });
  }

  void showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(strokeWidth: 5, color: Colors.red),
          Container(
              color: Colors.transparent,
              margin: EdgeInsets.only(left: 7),
              child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showSnackBar(context, contentType, titleText, contentText) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: titleText,
        message: contentText,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Future<bool> isInternetConnectivity() async {
    final Connectivity connectivity = Connectivity();
    try {
      final List<ConnectivityResult> results =
          await connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      debugPrint("Couldn't check connectivity status. Error: $e");
      return false;
    }
  }


  Future<bool> isWifiConnectivity() async {
    final Connectivity connectivity = Connectivity();
    try {
      final List<ConnectivityResult> results =
          await connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.wifi);
    } on PlatformException catch (e) {
      debugPrint("Couldn't check connectivity status. Error: $e");
      return false;
    }
  }
}
