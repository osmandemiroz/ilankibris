import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';

import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  LocationPermissionScreenState createState() =>
      LocationPermissionScreenState();

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(builder: (_) => const LocationPermissionScreen());
  }
}

class LocationPermissionScreenState extends State<LocationPermissionScreen>
    with WidgetsBindingObserver {
  bool _openedAppSettings = false;
  double latitude = double.parse(Constant.defaultLatitude);
  double longitude = double.parse(Constant.defaultLongitude);

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _openedAppSettings) {
      _openedAppSettings = false;
      _getCurrentLocation();
      setState(() {});
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      if (Platform.isAndroid) {
        await Geolocator.openLocationSettings();
        _getCurrentLocation();
      }
      _showLocationServiceInstructions();
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setDefaultLocationAndNavigate();
      } else {
        _getCurrentLocation();
      }
    } else {
      _getCurrentLocationAndNavigate();
    }
  }

  Future<void> setDefaultLocationAndNavigate() async {
    try {
      if (Constant.isDemoModeOn) {
        UiUtils.setDefaultLocationValue(
            isCurrent: false, isHomeUpdate: false, context: context);
      } else {
        HiveUtils.setLocation(
          area: "Girne",
          city: "Girne",
          state: "Girne",
          country: "Cyprus",
          latitude: latitude,
          longitude: longitude,
        );
      }

      HelperUtils.killPreviousPages(context, Routes.main, {"from": "login"});
    } catch (e) {
      print("Error setting default location: $e");
    }
  }

  void _showLocationServiceInstructions() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('pleaseEnableLocationServicesManually'.translate(context)),
        action: SnackBarAction(
          label: 'ok'.translate(context),
          textColor: context.color.secondaryColor,
          onPressed: () {
            openAppSettings();
            setState(() {
              _openedAppSettings = true;
            });
          },
        ),
      ),
    );
  }

  Future<void> _getCurrentLocationAndNavigate() async {
    try {
      if (Constant.isDemoModeOn) {
        UiUtils.setDefaultLocationValue(
            isCurrent: false, isHomeUpdate: false, context: context);
      } else {
        HiveUtils.setLocation(
          area: "Girne",
          city: "Girne",
          state: "Girne",
          country: "Cyprus",
          latitude: latitude,
          longitude: longitude,
        );
      }

      HelperUtils.killPreviousPages(context, Routes.main, {"from": "login"});
    } catch (e) {
      print("Error setting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.backgroundColor,
      ),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UiUtils.getSvg(AppIcons.locationAccessIcon),
              const SizedBox(height: 19),
              Text(
                "whatsYourLocation".translate(context),
              ).size(context.font.extraLarge).bold(weight: FontWeight.w600),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Set default location or choose another location'
                      .translate(context),
                )
                    .size(context.font.larger)
                    .color(context.color.textDefaultColor.withOpacity(0.65))
                    .centerAlign(),
              ),
              const SizedBox(height: 58),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                child: UiUtils.buildButton(
                  context,
                  showElevation: false,
                  buttonColor: context.color.territoryColor,
                  textColor: context.color.secondaryColor,
                  onPressed: () {
                    _getCurrentLocation();
                  },
                  radius: 8,
                  height: 46,
                  buttonTitle: "continue".translate(context),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                child: UiUtils.buildButton(
                  context,
                  showElevation: false,
                  buttonColor: context.color.backgroundColor,
                  border: BorderSide(color: context.color.territoryColor),
                  textColor: context.color.territoryColor,
                  onPressed: () {
                    setDefaultLocationAndNavigate();
                  },
                  radius: 8,
                  height: 46,
                  buttonTitle: "Default Location".translate(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
