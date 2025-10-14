// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:bestcaststudios/app_config/appconfig.dart';
import '../app_config/app_preferences.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/loading_widget.dart';

// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// Import for Android features.

// Import for iOS features.

class BestcastWebView extends StatefulWidget {
  String url = "";

  BestcastWebView({super.key, required this.url});

  @override
  State<BestcastWebView> createState() => _BestcastWebViewState();
}

class _BestcastWebViewState extends State<BestcastWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  late Timer _timer;
  late WebViewController _webViewController;

  // final Completer<InAppWebViewController> _InAppController = Completer<InAppWebViewController>();
  // late InAppWebViewController _InAppWebViewController;

  String _loadUrl = "";
  String _id = "";
  final String _email = "";
  final String _phone = "";
  final String _name = "";
  final String _firstname = "";
  final String _lastname = "";
  final String _dob = "";
  final String _gender = "";
  final String _plan = "";
  final String _plan_expiry = "";
  final String _photo = "";
  final String _otp = "";
  final String _tvcode = "";
  final String _referal_code = "";
  final String _credits_used = "";
  final String _refferer = "";
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
      _id = pref.getString(AppPreferences.id) ?? '';
      _token = pref.getString(AppPreferences.token) ?? '';

      print("TokenValue$_token");

      if (widget.url == "account") {
        _loadUrl = AppConfig.myAccountLoginUrl + _token;
        // _loadUrl="https://moviesdev.harikaran.com/accountlogin/"+_token.toString();
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

      // isWebviewEnabled = true;
    });

    // if (isWebviewEnabled) {
    //   await Future.delayed(
    //       Duration(seconds: 3));
    //   setState(() {
    //     isWebviewEnabled = true;
    //   });
    // } else {
    //   setState(() {
    //     isWebviewEnabled = true;
    //   });
    // }

    controller = WebViewController()
      // ..setJavaScriptMode(JavaScriptMode.disabled)
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
            // return NavigationDecision.prevent;

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

//----Webview_2.0.13-----
// @override
// Widget build(BuildContext context) {
//   print("RunloadUrl" + _loadUrl);
//   return SafeArea(
//     child: Scaffold(
//       backgroundColor: AppDefaultColors.appColor,
//       appBar: AppBar(
//         title: Container(
//           child: const Image(image: AssetImage("images/logo_bestcast.png")),
//           height: 30,
//         ),
//         backgroundColor: AppDefaultColors.appColor,
//         leading: const BackButton(color: Colors.white),
//       ),
//       body: isWebviewEnabled
//           ? Stack(children: [
//               WebView(
//                 initialUrl: _loadUrl,
//                 javascriptMode: JavascriptMode.unrestricted,
//                 onWebViewCreated: (WebViewController webViewController) {
//                   _webViewController = webViewController;
//                   _controller.complete(webViewController);
//                   _webViewController.clearCache();
//                 },
//                 onPageStarted: (String url) {
//                   LoadingWidget();
//                   // _webViewController.runJavascript("document.getElementsByTagName('header')[0].style.display='none'");
//                   // _webViewController.runJavascript("document.getElementsByTagName('footer')[0].style.display='none'");
//                   // CircularProgressIndicator(strokeWidth: 5, color: Colors.red);
//                   print('Page started loading: $url');
//                 },
//                 onPageFinished: (String url) async {
//                   print('Page finished loading: $url');
//                   // await Future.delayed(Duration(milliseconds: 500));
//                   // _webViewController
//                   //     .runJavascript("javascript:(function() { " +
//                   //     "var head = document.getElementsByTagName('header')[0];" +
//                   //     "head.parentNode.removeChild(head);" +
//                   //     "head.removeChild(head);" +
//                   //     "var footer = document.getElementsByTagName('footer')[0];" +
//                   //     "footer.parentNode.removeChild(footer);" +
//                   //     "footer.removeChild(footer);" +
//                   //     "var leftsidebar = document.getElementsByClassName('backbtn')[0];" +
//                   //     "leftsidebar.parentNode.removeChild(leftsidebar);" +
//                   //     "leftsidebar.removeChild(leftsidebar);" +
//                   //     "})()")
//                   //     .then((value) => debugPrint('Page finished loading Javascript'))
//                   //     .catchError((onError) => debugPrint('$onError'));
//
//                   _webViewController
//                       .evaluateJavascript("javascript:(function() { " +
//                           "var head = document.getElementsByTagName('header')[0];" +
//                           "head.parentNode.removeChild(head);" +
//                           "var footer = document.getElementsByTagName('footer')[0];" +
//                           "footer.parentNode.removeChild(footer);" +
//                           "var backbtn = document.getElementsByClassName('backbtn')[0];" +
//                           "backbtn.parentNode.removeChild(backbtn);" +
//                           "})()")
//                       .then((value) => debugPrint('Page finished loading Javascript'))
//                       .catchError((onError) => debugPrint('$onError'));
//
//                   await Future.delayed(Duration(seconds: 1));
//                   setState(() {
//                     isLoading = false;
//                   });
//                 },
//               ),
//               if (isLoading)
//                 Center(
//                   child: LoadingWidget(),
//                 ),
//             ])
//           : LoadingWidget(),
//     ),
//   );
// }

// -------InAppWebView----
// @override
// Widget build(BuildContext context) {
//   print("RunloadUrl" + _loadUrl);
//   return SafeArea(
//     child: Scaffold(
//       backgroundColor: AppDefaultColors.appColor,
//       appBar: AppBar(
//         title: Container(
//           child: const Image(image: AssetImage("images/logo_bestcast.png")),
//           height: 30,
//         ),
//         backgroundColor: AppDefaultColors.appColor,
//         leading: const BackButton(color: Colors.white),
//       ),
//       body: isWebviewEnabled?Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(_loadUrl)),
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptEnabled: true,
//               ),
//             ),
//             onWebViewCreated: (InAppWebViewController controller){
//               _InAppWebViewController = controller;
//             },
//             onLoadStart: (controller, url) {
//               setState(() {
//                 isLoading = true;
//               });
//             },
//             onLoadStop: (controller, url) {
//               _InAppWebViewController
//                   .evaluateJavascript(source: "javascript:(function() { " +
//                   "var head = document.getElementsByTagName('header')[0];" +
//                   "head.parentNode.removeChild(head);" +
//                   "var footer = document.getElementsByTagName('footer')[0];" +
//                   "footer.parentNode.removeChild(footer);" +
//                   "var backbtn = document.getElementsByClassName('backbtn')[0];" +
//                   "backbtn.parentNode.removeChild(backbtn);" +
//                   "})()")
//                   .then((value) => debugPrint('Page finished loading Javascript'))
//                   .catchError((onError) => debugPrint('$onError'));
//               setState(() {
//                 isLoading = false;
//               });
//             },
//           ),
//           if (isLoading)
//             Center(
//               child: LoadingWidget(),
//             ),
//         ],
//       ):LoadingWidget(),
//     ),
//   );
// }
}
