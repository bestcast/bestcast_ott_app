import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bestcaststudios/common_files/card_view_background.dart';
import 'package:bestcaststudios/plan_details/subscription_list_model.dart';
import '../app_config/app_preferences.dart';
import '../app_config/app_utils.dart';
import '../app_config/appconfig.dart';
import '../authendication/login_page.dart';
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/shimmer/shimmer_skeletons.dart';
import '../main_screen.dart';

class PlanDetailsPage extends StatefulWidget {
  final String? refCode;
  const PlanDetailsPage({super.key, this.refCode});

  @override
  State<PlanDetailsPage> createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> {
  final AppUtils appUtils = AppUtils();
  late final Razorpay _razorpay;
  bool isLoading = false;
  List<SubscriptionListModel> subscriptionListModel = [];
  String _phone = "";
  String _token = "";
  String _gateWayKey = "";
  String _logo = "";

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Pricing plan",
            style: TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.w700),
          ),
          backgroundColor: AppDefaultColors.appColor,
          leading: const BackButton(color: Colors.white),
        ),
        backgroundColor: AppDefaultColors.appColor,
        body: isLoading == false
            ? SingleChildScrollView(
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subscriptionListModel.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {},
                        child: getPlanDetailsWidget(subscriptionListModel[index]),
                      );
                    }),
              )
            : const PlanDetailsSkeleton(),
      ),
    );
  }

  Widget getPlanDetailsWidget(SubscriptionListModel subscriptionListModel) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CardViewBackground(
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 30.0, right: 5.0),
                    child: Center(
                      child: Text(
                        subscriptionListModel.title.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30, color: AppDefaultColors.black, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 30.0, right: 5.0),
                    child: Center(
                      child: Text(
                        "₹" + subscriptionListModel.price.toString() + '/' + subscriptionListModel.duration_text.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30, color: AppDefaultColors.thikRed, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 10.0, right: 5.0, left: 30.0),
                    child: Center(
                      child: Text(
                        // "- Video Quality : Best\n" +
                        //     "- Video Resolution : 1080p (HD)\n" +
                        //     "- Supported devices : Tv, Computer, Mobile and tablet\n" +
                        //     "- Devices to watch limit : 1\n" +
                        //     "- Ads free movies and shows\n",
                        _parseHtmlString(subscriptionListModel.content.toString()),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 17,
                          color: AppDefaultColors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 30),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size.fromHeight(50),
                        foregroundColor: AppDefaultColors.appRed,
                        backgroundColor: AppDefaultColors.appRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        var subscriptionAmount = "${subscriptionListModel.price}00";
                        var description = subscriptionListModel.title.toString();
                        var planID = subscriptionListModel.id.toString();

                        CreateSubscription(_token, planID, subscriptionAmount, description, _phone);
                      },
                      child: Text(
                        'Buy Plan',
                        style: TextStyle(color: AppDefaultColors.textLightGray, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);

    getInitalValue();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    final isLoggedIn = pref.getBool(AppPreferences.loggedStatus) ?? false;

    if (!isLoggedIn) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
      return;
    }

    setState(() {
      _phone = pref.getString(AppPreferences.phone) ?? '';
      _token = pref.getString(AppPreferences.token) ?? '';
    });

    if (await CommonWidget().isInternetConnectivity()) {
      print("_token: $_token");
      getPlanDetails(_token);
    } else {
      if (mounted) {
        CommonWidget().showSnackBar(context, ContentType.warning, "Check your internet connection.", "");
      }
    }
  }

  void payRazor(String amount, String description, String mobilenumber, dynamic orderId) {
    print("_gateWayKey:$_gateWayKey");
    print("logo_gateWay:$_logo");

    try {
      var options = {
        'key': _gateWayKey,
        'amount': amount,
        'name': 'BESTCAST',
        'image': _logo,
        'description': description,
        'order_id': orderId,
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {'contact': mobilenumber, 'email': ''},
        'external': {
          'wallets': ['paytm']
        }
      };
      _razorpay.open(options);
    } catch (e) {
      print("payRazor exception: $e");
      if (mounted) {
        CommonWidget().showSnackBar(context, ContentType.failure, "Payment Error", "Unable to launch payment gateway: $e");
      }
    }
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    appUtils.showToast("Payment Failed.");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    updatetransaction(_token, response.orderId.toString(), response.paymentId.toString(), response.signature.toString());
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {}

  void showAlertDialog(BuildContext context, String title, String message) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showPaymentRecoveryDialog(String token, String orderId, String errorMessage) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AppDefaultColors.hardDarkGray,
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Verification Pending",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            "Your payment may have succeeded, but verification encountered a network issue:\n\n$errorMessage\n\nPlease tap 'Retry Verification' to complete your subscription activation.",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("Later", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDefaultColors.appColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                verifypaymentstatus(token, orderId);
              },
              child: const Text("Retry Verification"),
            ),
          ],
        );
      },
    );
  }

  Future<void> getPaymentgatewayinfo(String token) async {
    try {
      final response = await ApiServices()
          .getRequestData(AppConfig.paymentgatewayinfo, token)
          .timeout(const Duration(seconds: 15));
      String jsonsDataString = response.body.toString();
      print("paymentgatewayinfo_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        var jsonReponse = jsonDecode(jsonsDataString);
        String status = jsonReponse['status'] ?? "";
        if (status == "success") {
          var data = jsonReponse['results']?['razorpay'];
          if (data != null) {
            _gateWayKey = data["key"]?.toString() ?? "";
            _logo = data["logo"]?.toString() ?? "";
          }
        }
      }
    } catch (e) {
      print('PaymentInfoException:$e');
    }
  }

  Future<void> CreateSubscription(String token, String planID, String subscriptionAmount, String description, String phone) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      context.loaderOverlay.show();
    } catch (_) {}

    try {
      final pref = await SharedPreferences.getInstance();
      final refCode = (widget.refCode != null && widget.refCode!.isNotEmpty)
          ? widget.refCode
          : (pref.getString(AppPreferences.bmpReferralCode) ?? pref.getString(AppPreferences.refferer));

      final response = (refCode != null && refCode.isNotEmpty)
          ? await ApiServices().postRequestToken(AppConfig.createsubscription + planID, {'ref': refCode, 'bmp_referral_code': refCode}, token).timeout(const Duration(seconds: 15))
          : await ApiServices().postRequestTokenWithoutBody(AppConfig.createsubscription + planID, token).timeout(const Duration(seconds: 15));

      String jsonsDataString = response.body.toString();
      print("createSubscription_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        var jsonReponse = jsonDecode(jsonsDataString);
        String status = jsonReponse['status'] ?? "";
        if (status == "success") {
          var orderId = jsonReponse['results']?['razorpay_order_id'];
          print("DataObject:$orderId");
          payRazor(subscriptionAmount, description, phone, orderId);
        } else {
          if (mounted) {
            CommonWidget().showSnackBar(context, ContentType.failure, "Order Creation Failed", jsonReponse['message']?.toString() ?? "Could not initiate payment order.");
          }
        }
      } else {
        print("createSubscriptionError: $response");
        if (mounted) {
          CommonWidget().showSnackBar(context, ContentType.failure, "Error", response.toString());
        }
      }
    } catch (e) {
      print('createSubscriptionException:$e');
      if (mounted) {
        CommonWidget().showSnackBar(context, ContentType.failure, "Network Error", "Failed to initiate subscription: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        try {
          context.loaderOverlay.hide();
        } catch (_) {}
      }
    }
  }

  Future<void> getPlanDetails(String token) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      context.loaderOverlay.show();
    } catch (_) {}
    subscriptionListModel.clear();

    try {
      final response = await ApiServices()
          .getRequestData(AppConfig.subscriptionlist, token)
          .timeout(const Duration(seconds: 15));

      String jsonsDataString = response.body.toString();
      print("Subscription_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData["data"] != null && responseData["data"] is List) {
          for (var plandetailsObject in responseData["data"]) {
            subscriptionListModel.add(SubscriptionListModel(
              id: plandetailsObject["id"].toString(),
              urlkey: plandetailsObject["urlkey"].toString(),
              title: plandetailsObject["title"].toString(),
              content: plandetailsObject["content"].toString(),
              before_price: (plandetailsObject["before_price"] is num) ? plandetailsObject["before_price"].toInt() : 0,
              price: (plandetailsObject["price"] is num) ? plandetailsObject["price"].toInt() : 0,
              tagtext: plandetailsObject["tagtext"].toString(),
              sortorder: (plandetailsObject["sortorder"] is num) ? plandetailsObject["sortorder"].toInt() : 0,
              razorpay_id: plandetailsObject["razorpay_id"].toString(),
              duration_text: plandetailsObject["duration_text"].toString(),
            ));
          }
        }
        await getPaymentgatewayinfo(token);
      } else {
        print("Error: $response");
        if (mounted) {
          CommonWidget().showSnackBar(context, ContentType.failure, "Error", response.toString());
        }
      }
    } catch (e) {
      print('getPlanDetails Exception:$e');
      if (mounted) {
        CommonWidget().showSnackBar(context, ContentType.failure, "Network Error", "Unable to load subscription plans. Please check your connection.");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        try {
          context.loaderOverlay.hide();
        } catch (_) {}
      }
    }
  }

  Future<void> updatetransaction(String token, String orderId, String paymentId, String signature) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      context.loaderOverlay.show();
    } catch (_) {}

    try {
      final pref = await SharedPreferences.getInstance();
      final refCode = (widget.refCode != null && widget.refCode!.isNotEmpty)
          ? widget.refCode
          : (pref.getString(AppPreferences.bmpReferralCode) ?? pref.getString(AppPreferences.refferer));

      final Map<String, dynamic> postValues = {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      };
      if (refCode != null && refCode.isNotEmpty) {
        postValues['ref'] = refCode;
        postValues['bmp_referral_code'] = refCode;
      }

      final response = await ApiServices()
          .postRequestToken(AppConfig.updatetransaction, postValues, token)
          .timeout(const Duration(seconds: 20));

      String jsonsDataString = response.body.toString();
      print("updatetransaction_Response: $jsonsDataString");

      if (response.statusCode == 200 || response.statusCode == 201) {
        appUtils.showToast("Payment Successful");
        await verifypaymentstatus(token, orderId);
      } else {
        print("TransactionError: $response");
        if (mounted) {
          _showPaymentRecoveryDialog(
            token,
            orderId,
            "Could not update transaction details on server (${response.statusCode}). Please verify your payment.",
          );
        }
      }
    } catch (e) {
      print('updatetransactionException:$e');
      if (mounted) {
        _showPaymentRecoveryDialog(
          token,
          orderId,
          "Network connection error: $e. You can retry verifying your payment status.",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        try {
          context.loaderOverlay.hide();
        } catch (_) {}
      }
    }
  }

  Future<void> verifypaymentstatus(String token, String orderId) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      context.loaderOverlay.show();
    } catch (_) {}

    try {
      final pref = await SharedPreferences.getInstance();
      final refCode = (widget.refCode != null && widget.refCode!.isNotEmpty)
          ? widget.refCode
          : (pref.getString(AppPreferences.bmpReferralCode) ?? pref.getString(AppPreferences.refferer));

      final Map<String, dynamic> postValues = {
        'oid': orderId,
        'razorpay_order_id': orderId,
        'order_id': orderId,
      };
      if (refCode != null && refCode.isNotEmpty) {
        postValues['ref'] = refCode;
        postValues['bmp_referral_code'] = refCode;
      }

      final response = await ApiServices()
          .postRequestToken(AppConfig.verifypaymentstatus, postValues, token)
          .timeout(const Duration(seconds: 20));

      String jsonsDataString = response.body.toString();
      print("verifypaymentstatus_Response: $jsonsDataString");

      if (response.statusCode == 200 || response.statusCode == 201) {
        appUtils.showToast("Payment Successful");
        await pref.setString(AppPreferences.plan_status, "1");

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false,
          );
        }
      } else {
        print("TransactionError: $response");
        if (mounted) {
          _showPaymentRecoveryDialog(
            token,
            orderId,
            "Server returned status ${response.statusCode}. If your account was debited, retrying will activate your plan.",
          );
        }
      }
    } catch (e) {
      print('verifypaymentstatusException:$e');
      if (mounted) {
        _showPaymentRecoveryDialog(
          token,
          orderId,
          "Network connection issue: $e. Your transaction ID is saved.",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        try {
          context.loaderOverlay.hide();
        } catch (_) {}
      }
    }
  }

  String _parseHtmlString(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }
}
