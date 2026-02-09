import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:loader_overlay/loader_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_config/appconfig.dart';
import '../common_files/app_default_colors.dart';

class PlanExpiredScreen extends StatefulWidget {
  const PlanExpiredScreen({super.key});

  @override
  State<PlanExpiredScreen> createState() => _PlanExpiredScreenState();
}

class _PlanExpiredScreenState extends State<PlanExpiredScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: AppDefaultColors.appColor,
        body: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                width: 300,
                'images/plan_expired.png',
                fit: BoxFit.cover,
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 30.0, right: 5.0),
                child: Center(
                  child: const Text(
                    'Plan has expired',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        color: AppDefaultColors.white,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 10.0, right: 5.0),
                child: Center(
                  child: const Text(
                    'Plan has expired renew your account on bestcast to watch unlimited entertaiment movies.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: AppDefaultColors.textLightGray,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: false,
                child: Container(
                  margin:
                      EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 30),
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
                      launchUrlStart(url: AppConfig.BaseUrl);
                    },
                    child: Text(
                      'Renew Account',
                      style: TextStyle(
                          color: AppDefaultColors.textLightGray, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> launchUrlStart({required String url}) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }
}
