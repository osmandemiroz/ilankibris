import 'package:eClassify/utils/helper_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PaymentGateway {
  final String name;
  final String key;
  final String currency;
  final int status;
  final String type;

  PaymentGateway({
    required this.name,
    required this.key,
    required this.currency,
    required this.status,
    required this.type,
  });
}

class AppSettings {
  /// Basic Settings
  static const String applicationName = 'IlanKıbrıs';
  static const String andoidPackageName = 'com.bahasoftware.ilankibris';
  static const String shareAppText = "Share this App";

  static const String hostUrl =
      "https://ilankibris-2.bahasoftware.com"; //don't add / at end but https:// is required

  ///API Setting

  static const int apiDataLoadLimit = 99999;
  static const int maxCategoryShowLengthInHomeScreen = 99999;

  static final String baseUrl =
      "${HelperUtils.checkHost(hostUrl)}api/"; //don't change this

  static const int hiddenAPIProcessDelay = 1;

  /* this is for load data when open app if old data is already available so
it will call API in background without showing the process and when data available it will replace it with new data */

  ///Google ADMOB
  ///Please make sure to add app ids into the platform files. for the android you have to add into AndroidManifest.xml and for the ios you will have to add it in the info.plist file.

  ///Set type here
  static const DeepLinkType deepLinkingType = DeepLinkType.native;

  ///Native deep link
  //static const String shareNavigationWebUrl = "eclassify.thewrteam.in";

  //static const String shareNavigationWebUrl = "eclassify.wrteam.me";
  static const String shareNavigationWebUrl = "eclassify-dev.vercel.app";

  /// You will find this prefix from firebase console in dynamic link section
  static const String deepLinkPrefix =
      "https://eclassify.page.link"; //demo.page.link

  //set anything you want
  static const String deepLinkName = "eclassify.com"; //deeplink demo.com

  static const MapType googleMapType =
      MapType.normal; //none , normal , satellite , terrain , hybrid

  ///Firebase authentication OTP timer.
  static const int otpResendSecond = 60 * 2;
  static const int otpTimeOutSecond = 60 * 2;

  ///This code will show on login screen [Note: don't add  + symbol]
  static const String defaultCountryCode = "90";
  static const bool disableCountrySelection = true;

  ///Lottie animation
  ///Put your loading json file in [lib/assets/lottie/] folder
  static const String successLoadingLottieFile = "loading_success.json";
  static const String successCheckLottieFile = "success_check.json";
  static const String progressLottieFileWhite =
      "loading_white.json"; //When there is dark background and you want to show progress so it will be used

  static const String maintenanceModeLottieFile = "maintenancemode.json";

  static const bool useLottieProgress =
      true; //if you don't want to use lottie progress then set it to false'

  ///Other settings
  static const String notificationChannel = "basic_channel"; //
  static int uploadImageQuality = 50; //0 to 100th
  static const Set additionalRTLlanguages =
      {}; //Add language code in brackat  {"ab","bc"}

/////Advance settings
//This file is located in assets/riveAnimations
  static const String riveAnimationFile = "rive_animation.riv";

  static const Map<String, dynamic> riveAnimationConfigurations = {
    "add_button": {
      "artboard_name": "Add",
      "state_machine": "click",
      "boolean_name": "isReverse",
      "boolean_initial_value": true,
      "add_button_shape_name": "shape",
    },
  };

  static List<PaymentGateway> paymentGateways = [];

  static void updatePaymentGateways() {
    paymentGateways = [
      PaymentGateway(
        name: "Stripe",
        key: stripePublishableKey,
        currency: stripeCurrency,
        status: stripeStatus,
        type: "stripe",
      ),
      PaymentGateway(
        name: "Paystack",
        key: payStackKey,
        currency: payStackCurrency,
        status: payStackStatus,
        type: "paystack",
      ),
      PaymentGateway(
        name: "Razorpay",
        key: razorpayKey,
        currency: razorpayCurrency,
        // Replace with actual currency if needed
        status: razorpayStatus,
        type: "razorpay",
      ),
      PaymentGateway(
        name: "PhonePe",
        key: phonePeKey,
        currency: phonePeCurrency,
        // Replace with actual currency if needed
        status: phonePeStatus,
        type: "phonepe",
      ),
    ];
  }

  //// Don't change these
  //// Payment gatway API keys
  ///Here is for only reference you have to change it from panel
  static String enabledPaymentGateway = "";
  static String razorpayKey = "";
  static int razorpayStatus = 1;
  static String razorpayCurrency = "";
  static String payStackKey = ""; // public key
  static String payStackCurrency = "";
  static int payStackStatus = 1;
  static String paypalClientId = "";
  static String paypalServerKey = ""; //secrete
  static bool isSandBoxMode = true; //testing mode
  static String paypalCancelURL = "";
  static String paypalReturnURL = "";
  static String stripeCurrency = "";
  static String stripePublishableKey = "";
  static int stripeStatus = 1;
  static int phonePeStatus = 1;
  static String phonePeKey = ""; // public key
  static String phonePeCurrency = "";

  static List<PaymentGateway> getEnabledPaymentGateways() {
    return paymentGateways.where((gateway) => gateway.status == 1).toList();
  }
}

enum DeepLinkType { native }
