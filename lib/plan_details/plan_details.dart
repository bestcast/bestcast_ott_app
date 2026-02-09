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
import '../common_files/api_services.dart';
import '../common_files/app_default_colors.dart';
import '../common_files/common_widgets.dart';
import '../common_files/loading_widget.dart';
import '../main_screen.dart';

class PlanDetailsPage extends StatefulWidget {
  const PlanDetailsPage({super.key});

  @override
  State<PlanDetailsPage> createState() => _PlanDetailsPageState();
}

class _PlanDetailsPageState extends State<PlanDetailsPage> {

  final AppUtils appUtils = AppUtils();
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
            style: TextStyle(
                color: Colors.white,
                fontSize: 25.0,
                fontWeight: FontWeight.w700),
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
                        child:
                            getPlanDetailsWidget(subscriptionListModel[index]),
                      );
                    }),
              )
            : LoadingWidget(),
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
                        style: TextStyle(
                            fontSize: 30,
                            color: AppDefaultColors.black,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 30.0, right: 5.0),
                    child: Center(
                      child: Text(
                        "₹" +
                            subscriptionListModel.price.toString() +
                            '/' +
                            subscriptionListModel.duration_text.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            color: AppDefaultColors.thikRed,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                        top: 10.0, right: 5.0, left: 30.0),
                    child: Center(
                      child: Text(
                        // "- Video Quality : Best\n" +
                        //     "- Video Resolution : 1080p (HD)\n" +
                        //     "- Supported devices : Tv, Computer, Mobile and tablet\n" +
                        //     "- Devices to watch limit : 1\n" +
                        //     "- Ads free movies and shows\n",
                        _parseHtmlString(
                            subscriptionListModel.content.toString()),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 17,
                          color: AppDefaultColors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 20, left: 10, right: 10, bottom: 30),
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
                        var subscriptionAmount =
                            "${subscriptionListModel.price}00";
                        var description =
                            subscriptionListModel.title.toString();
                        var planID = subscriptionListModel.id.toString();

                        CreateSubscription(_token, planID, subscriptionAmount,
                            description, _phone);
                      },
                      child: Text(
                        'Buy Plan',
                        style: TextStyle(
                            color: AppDefaultColors.textLightGray,
                            fontSize: 15),
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

    getInitalValue();
  }

  Future<void> getInitalValue() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _phone = pref.getString(AppPreferences.phone) ?? '';
      _token = pref.getString(AppPreferences.token) ?? '';
    });

    if (await CommonWidget().isInternetConnectivity()) {
      print("_token: $_token");
      getPlanDetails(_token);
    } else {
      CommonWidget().showSnackBar(
          context, ContentType.warning, "Check your internet connection.", "");
    }
  }

  void payRazor(
      String amount, String description, String mobilenumber, orderId) {
    print("_gateWayKey:$_gateWayKey");
    print("logo_gateWay:$_logo");

    Razorpay razorpay = Razorpay();
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
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    razorpay.open(options);
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

    updatetransaction(_token, response.orderId.toString(),
        response.paymentId.toString(), response.signature.toString());
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void getPaymentgatewayinfo(String token) async {
    setState(() {
      isLoading = true;
    });
    ApiServices()
        .getRequestData(AppConfig.paymentgatewayinfo, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("paymentgatewayinfo_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);

          String status = jsonReponse['status'];

          if (status == "success") {
            var data = jsonReponse['results']['razorpay'];
            print("DataObject:$data");
            _gateWayKey = data["key"].toString();
            _logo = data["logo"].toString();
          }

          setState(() {
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print('PaymentInfoException:$e');
        }
      } else {
        print("PaymentInfoError: $response");
        isLoading = false;
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  void CreateSubscription(String token, String planID,
      String subscriptionAmount, String description, String phone) async {
    setState(() {
      isLoading = true;
    });
    ApiServices()
        .postRequestTokenWithoutBody(
            AppConfig.createsubscription + planID, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("createSubscription_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);

          String status = jsonReponse['status'];

          if (status == "success") {
            var orderId = jsonReponse['results']['razorpay_order_id'];
            print("DataObject:$orderId");

            payRazor(subscriptionAmount, description, phone, orderId);
          }

          setState(() {
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print('createSubscriptionException:$e');
        }
      } else {
        print("createSubscriptionError: $response");
        isLoading = false;
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  void getPlanDetails(String token) async {
    isLoading = true;
    context.loaderOverlay.show();
    subscriptionListModel.clear();
    ApiServices()
        .getRequestData(AppConfig.subscriptionlist, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("Subscription_Response: $jsonsDataString");
      if (response.statusCode == 200) {
        try {
          var jsonReponse = jsonDecode(jsonsDataString);
          var data = jsonReponse['data'];

          print("SubscriptionDataObject:$data");

          var responseData = json.decode(response.body);

          for (var plandetailsObject in responseData["data"]) {
            subscriptionListModel.add(SubscriptionListModel(
              id: plandetailsObject["id"].toString(),
              urlkey: plandetailsObject["urlkey"].toString(),
              title: plandetailsObject["title"].toString(),
              content: plandetailsObject["content"].toString(),
              before_price: plandetailsObject["before_price"].toInt(),
              price: plandetailsObject["price"].toInt(),
              tagtext: plandetailsObject["tagtext"].toString(),
              sortorder: plandetailsObject["sortorder"].toInt(),
              razorpay_id: plandetailsObject["razorpay_id"].toString(),
              duration_text: plandetailsObject["duration_text"].toString(),
            ));
          }

          getPaymentgatewayinfo(token);

          print("datachanged");
          setState(() {
            isLoading = false;
          });
          context.loaderOverlay.hide();
        } catch (e) {
          print('Exception:$e');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Error: $response");
        context.loaderOverlay.hide();
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }
      setState(() {
        isLoading = false;
      });
      context.loaderOverlay.hide();
    });
    setState(() {
      isLoading = false;
    });
    context.loaderOverlay.hide();
  }

  void updatetransaction(
      String token, String orderId, String paymentId, String signature) async {
    setState(() {
      isLoading = true;
    });
    context.loaderOverlay.show();
    final postValues = {
      'razorpay_order_id': orderId,
      'razorpay_payment_id': paymentId,
      'razorpay_signature': signature
    };

    ApiServices()
        .postRequestToken(AppConfig.updatetransaction, postValues, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("setuserprofile_Response: $jsonsDataString");
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {

          appUtils.showToast("Payment Successful");

          //

          verifypaymentstatus(token, orderId);
        } catch (e) {
          setState(() {
            isLoading = false;
            context.loaderOverlay.hide();
          });
          print('updatetransactionException:$e');
        }
      } else {
        setState(() {
          isLoading = false;
          context.loaderOverlay.hide();
        });
        print("TransactionError: $response");
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }
      setState(() {
        isLoading = false;
        context.loaderOverlay.hide();
      });
    });
    setState(() {
      context.loaderOverlay.hide();
      isLoading = false;
    });
  }

  void verifypaymentstatus(String token, String orderId) async {
    setState(() {
      isLoading = true;
      context.loaderOverlay.show();
    });
    final postValues = {'oid': orderId};

    ApiServices()
        .postRequestToken(AppConfig.verifypaymentstatus, postValues, token)
        .then((response) async {
      String jsonsDataString = response.body.toString();
      print("verifypaymentstatus_Response: $jsonsDataString");
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {

          appUtils.showToast("Payment Successful");

          final pref = await SharedPreferences.getInstance();
          await pref.setString(AppPreferences.plan_status, "1");

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainScreen()));

          context.loaderOverlay.hide();
        } catch (e) {
          print('updatetransactionException:$e');
        }
      } else {
        setState(() {
          context.loaderOverlay.hide();
        });
        print("TransactionError: $response");
        CommonWidget().showSnackBar(
            context, ContentType.failure, "Error", response.toString());
      }
      setState(() {
        isLoading = false;
        context.loaderOverlay.hide();
      });
    });
    setState(() {
      isLoading = false;
      context.loaderOverlay.hide();
    });
  }

  String _parseHtmlString(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }
}
