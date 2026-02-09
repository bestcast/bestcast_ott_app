import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:bestcaststudios/app_config/appconfig.dart';
import '../app_config/app_preferences.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/loading_widget.dart';

// Import for Android features.

// Import for iOS features.

// ignore: must_be_immutable
class BestcastWebView extends StatefulWidget {
  String url = "";

  BestcastWebView({super.key, required this.url});

  @override
  State<BestcastWebView> createState() => _BestcastWebViewState();
}

class _BestcastWebViewState extends State<BestcastWebView> {

  late Timer _timer;

  String _loadUrl = "";
  String _token = "";

  bool isLoading = true;
  bool isWebviewEnabled = false;
  WebViewController? controller;

  @override
  void initState() {
    getInitalValue();
    _startTimer();
    super.initState();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        isLoading = false;
        _timer.cancel();
      });
    });
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _token = pref.getString(AppPreferences.token) ?? '';

      print("TokenValue$_token");

      if (widget.url == "account") {
        _loadUrl = AppConfig.myAccountLoginUrl + _token;
        print("TokenValueURL: $_loadUrl");
      } else if (widget.url == "help") {
        _loadUrl = AppConfig.helpUrl;
      } else if (widget.url == "privacy") {
        _loadUrl = AppConfig.privacyPolicy;
      } else if (widget.url == "terms-conditions") {
        _loadUrl = AppConfig.termsConditions;
      } else if (widget.url == "forgotpassword") {
        _loadUrl = AppConfig.forgotPassword;
      }
      print("_loadUrl$_loadUrl");
    });

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..clearCache()
      ..clearLocalStorage()
      ..enableZoom(false)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            print('onNavigationRequest');
            //I first had this line to prevent redirection to anywhere on the internet via hrefs
            //but this prevented ANYTHING from being displayed

            return NavigationDecision
                .navigate; //changed it to this, and it works now
          },
          onProgress: (int progress) {
            LoadingWidget();
            controller!
                .runJavaScript("javascript:(function() { "
                    "var head = document.getElementsByTagName('header')[0];"
                    "head.parentNode.removeChild(head);"
                    "var footer = document.getElementsByTagName('footer')[0];"
                    "footer.parentNode.removeChild(footer);"
                    "var backbtn = document.getElementsByClassName('backbtn')[0];"
                    "backbtn.parentNode.removeChild(backbtn);"
                    "})()")
                .then((value) => debugPrint('Page finished loading Javascript'))
                .catchError((onError) => debugPrint('$onError'));
          },
          onPageStarted: (String url) {
            LoadingWidget();
          },
          onPageFinished: (String url) {
            setState(() {
              isWebviewEnabled = true;
            });
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(_loadUrl));
  }

  @override
  Widget build(BuildContext context) {
    print("RunloadUrl: $_loadUrl");
    return SafeArea(
      child: Scaffold(
          backgroundColor: AppDefaultColors.appColor,
          appBar: AppBar(
            title: SizedBox(
              height: 30,
              child: const Image(image: AssetImage("images/logo_bestcast.png")),
            ),
            backgroundColor: AppDefaultColors.appColor,
            leading: const BackButton(color: Colors.white),
          ),
          body: Stack(children: [
            if (controller != null)
              isWebviewEnabled
                  ? WebViewWidget(controller: controller!)
                  : LoadingWidget(),
            if (isLoading)
              Center(
                child: LoadingWidget(),
              ),
          ])),
    );
  }
}
