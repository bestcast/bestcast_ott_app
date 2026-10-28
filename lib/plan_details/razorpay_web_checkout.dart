import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../common_files/app_default_colors.dart';
import '../common_files/loading_widget.dart';

class RazorpayWebResult {
  final bool isSuccess;
  final bool isDismissed;
  final String? orderId;
  final String? paymentId;
  final String? signature;
  final String? errorMessage;

  const RazorpayWebResult._({
    required this.isSuccess,
    required this.isDismissed,
    this.orderId,
    this.paymentId,
    this.signature,
    this.errorMessage,
  });

  factory RazorpayWebResult.success({
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    return RazorpayWebResult._(
      isSuccess: true,
      isDismissed: false,
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
    );
  }

  factory RazorpayWebResult.dismissed() {
    return const RazorpayWebResult._(
      isSuccess: false,
      isDismissed: true,
    );
  }

  factory RazorpayWebResult.failed(String message) {
    return RazorpayWebResult._(
      isSuccess: false,
      isDismissed: false,
      errorMessage: message,
    );
  }
}

class RazorpayWebCheckoutPage extends StatefulWidget {
  final String apiKey;
  final String amount;
  final String description;
  final String phone;
  final String orderId;
  final String logo;

  const RazorpayWebCheckoutPage({
    super.key,
    required this.apiKey,
    required this.amount,
    required this.description,
    required this.phone,
    required this.orderId,
    required this.logo,
  });

  @override
  State<RazorpayWebCheckoutPage> createState() => _RazorpayWebCheckoutPageState();
}

class _RazorpayWebCheckoutPageState extends State<RazorpayWebCheckoutPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _finishWithResult(RazorpayWebResult result) {
    if (_hasResult || !mounted) return;
    _hasResult = true;
    Navigator.of(context).pop(result);
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppDefaultColors.appColor)
      ..addJavaScriptChannel(
        'RazorpayWebHandler',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            final status = data['status']?.toString();
            if (status == 'success') {
              final paymentId = data['paymentId']?.toString() ?? '';
              final orderId = data['orderId']?.toString() ?? widget.orderId;
              final signature = data['signature']?.toString() ?? '';
              _finishWithResult(RazorpayWebResult.success(
                orderId: orderId,
                paymentId: paymentId,
                signature: signature,
              ));
            } else if (status == 'dismissed') {
              _finishWithResult(RazorpayWebResult.dismissed());
            } else {
              final errMsg = data['description']?.toString() ??
                  data['message']?.toString() ??
                  'Payment was not completed.';
              _finishWithResult(RazorpayWebResult.failed(errMsg));
            }
          } catch (e) {
            _finishWithResult(RazorpayWebResult.failed('Unexpected payment response: $e'));
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('Razorpay WebView resource error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            // Handle non-HTTP deep links (UPI apps, wallets, etc.)
            final scheme = uri.scheme.toLowerCase();
            if (scheme != 'http' && scheme != 'https' && scheme != 'about' && scheme != 'data') {
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  debugPrint('Could not launch deep link: ${request.url}');
                }
              } catch (e) {
                debugPrint('Deep link launch error: $e');
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    _loadRazorpayHtml();
  }

  void _loadRazorpayHtml() {
    final String htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Bestcast Payment</title>
  <style>
    * { box-sizing: border-box; }
    body, html {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      background-color: #0d0d0d;
      color: #ffffff;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }
    .loader-container {
      text-align: center;
      padding: 24px;
    }
    .spinner {
      width: 44px;
      height: 44px;
      margin: 0 auto 16px auto;
      border: 3px solid rgba(255, 255, 255, 0.12);
      border-top-color: #E50914;
      border-radius: 50%;
      animation: spin 0.9s linear infinite;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    .title {
      font-size: 15px;
      font-weight: 600;
      color: #f1f1f1;
      letter-spacing: 0.3px;
    }
    .subtitle {
      font-size: 12px;
      color: #888888;
      margin-top: 6px;
    }
  </style>
  <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
</head>
<body>
  <div class="loader-container">
    <div class="spinner"></div>
    <div class="title">Connecting to Secure Payment Gateway...</div>
    <div class="subtitle">Please do not press back or close the app</div>
  </div>

  <script>
    function notifyFlutter(payload) {
      if (window.RazorpayWebHandler && typeof window.RazorpayWebHandler.postMessage === 'function') {
        window.RazorpayWebHandler.postMessage(JSON.stringify(payload));
      }
    }

    var options = {
      "key": ${jsonEncode(widget.apiKey)},
      "amount": ${jsonEncode(widget.amount)},
      "name": "BESTCAST",
      "description": ${jsonEncode(widget.description)},
      "image": ${jsonEncode(widget.logo)},
      "order_id": ${jsonEncode(widget.orderId)},
      "prefill": {
        "contact": ${jsonEncode(widget.phone)},
        "email": ""
      },
      "theme": {
        "color": "#E50914"
      },
      "modal": {
        "ondismiss": function() {
          notifyFlutter({
            "status": "dismissed",
            "message": "Payment dismissed"
          });
        }
      },
      "handler": function(response) {
        notifyFlutter({
          "status": "success",
          "orderId": response.razorpay_order_id || ${jsonEncode(widget.orderId)},
          "paymentId": response.razorpay_payment_id,
          "signature": response.razorpay_signature
        });
      }
    };

    window.onload = function() {
      try {
        var rzp = new Razorpay(options);
        rzp.on('payment.failed', function(response) {
          var err = response && response.error ? response.error : {};
          notifyFlutter({
            "status": "failed",
            "code": err.code || "",
            "description": err.description || "Payment failed",
            "reason": err.reason || ""
          });
        });
        rzp.open();
      } catch (e) {
        notifyFlutter({
          "status": "error",
          "message": e.toString()
        });
      }
    };
  </script>
</body>
</html>
''';

    _controller.loadHtmlString(htmlContent, baseUrl: 'https://bestcast.co');
  }

  Future<bool> _handleWillPop() async {
    final bool shouldCancel = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text(
              "Cancel Payment?",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "Are you sure you want to cancel the payment process?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("Continue", style: TextStyle(color: Color(0xFFFFD700))),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text("Cancel Payment", style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldCancel) {
      _finishWithResult(RazorpayWebResult.dismissed());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleWillPop();
        }
      },
      child: Scaffold(
        backgroundColor: AppDefaultColors.appColor,
        appBar: AppBar(
          backgroundColor: AppDefaultColors.appColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: _handleWillPop,
          ),
          title: const Text(
            "Complete Payment",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: LoadingWidget(),
              ),
          ],
        ),
      ),
    );
  }
}
