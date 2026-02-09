import 'dart:core';

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class AppUtils {
  String getDateDayString() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMM d y').format(now);
    return formattedDate;
  }

  String getTimeString() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss').format(now);
    return formattedDate;
  }

  String getDateTimeToYear(String dateStr) {
    DateTime parseDate =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(dateStr);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat('yyyy');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  String getTimeScheduleString() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('hh:mm:ss a').format(now);
    return formattedDate;
  }

  String getDbDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('y-M-d').format(now);
    return formattedDate;
  }

  void showToast(String messageText) {
    Fluttertoast.showToast(
        msg: messageText,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  void showLoaderDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return LoaderDialog();
      },
    );
  }

  void hideLoaderDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  bool validateEmail(String email) {
    bool isvalid = EmailValidator.validate(email);
    return isvalid;
  }

  bool isNumericUsing_tryParse(String string) {
    // Null or empty string is not a number
    if (string.isEmpty) {
      return false;
    }

    // Try to parse input string to number.
    // Use int.tryParse if you want to check integer only.
    final number = num.tryParse(string);

    if (number == null) {
      return false;
    }

    if (number < 10) {
      return false;
    }

    return true;
  }
}

class LoaderDialog extends StatelessWidget {
  const LoaderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 10,
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 5, color: Colors.red),
      ),
    );
  }
}
