// import 'dart:async';

import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/system/fetch_language_cubit.dart';
import 'package:eClassify/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:eClassify/data/cubits/system/language_cubit.dart';
import 'package:eClassify/settings.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_internet.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/responsiveSize.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/data/repositories/system_repository.dart';

// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import '../app/routes.dart';
import 'package:eClassify/data/model/system_settings_model.dart';

// import 'package:eClassify/main.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  //late OldAuthenticationState authenticationState;

  bool isTimerCompleted = false;
  bool isSettingsLoaded = false; //TODO: temp
  bool isLanguageLoaded = false;
  late StreamSubscription<List<ConnectivityResult>> subscription;
  bool hasInternet = true;

  @override
  void initState() {
    //locationPermission();
    super.initState();

    subscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        hasInternet = (!result.contains(ConnectivityResult.none));
        //hasInternet = result != ConnectivityResult.none;
      });
      if (hasInternet) {
        getDefaultLanguage();

        checkIsUserAuthenticated();
        startTimer();
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

/*  Future<void> locationPermission() async {
    if ((await Permission.location.status) == PermissionStatus.denied) {
      await Permission.location.request();
    }
  }*/

  Future getDefaultLanguage() async {
    try {
      Map result = await SystemRepository().fetchSystemSettings();

      var code = (result['data']['default_language']);

      if (HiveUtils.getLanguage() == null ||
          HiveUtils.getLanguage()?['data'] == null) {
        context.read<FetchLanguageCubit>().getLanguage(code);
      } else if (HiveUtils.isUserFirstTime() == true &&
          code != HiveUtils.getLanguage()?['code']) {
        context.read<FetchLanguageCubit>().getLanguage(code);
      } else {
        isLanguageLoaded = true;
        setState(() {});
      }
    } catch (e) {
      log("Error while load default language $e");
    }
  }

  void checkIsUserAuthenticated() async {
    context.read<FetchSystemSettingsCubit>().fetchSettings(forceRefresh: true);
  }

  Future<void> startTimer() async {
    Timer(const Duration(seconds: 1), () {
      isTimerCompleted = true;
      if (mounted) setState(() {});
    });
  }

  void navigateCheck() {
    if (isTimerCompleted && isSettingsLoaded && isLanguageLoaded) {
      navigateToScreen();
    }
  }

  void navigateToScreen() async {
    if (context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.maintenanceMode) ==
        "1") {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.maintenanceMode);
        }
      });
    } else if (HiveUtils.isUserFirstTime() == true) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.onboarding);
        }
      });
    } else if (HiveUtils.isUserAuthenticated()) {
      if ((HiveUtils.getUserDetails().name == null ||
              HiveUtils.getUserDetails().name == "") ||
          (HiveUtils.getUserDetails().email == null ||
              HiveUtils.getUserDetails().email == "")) {
        Future.delayed(
          const Duration(seconds: 1),
          () {
            Navigator.pushReplacementNamed(
              context,
              Routes.completeProfile,
              arguments: {
                "from": "login",
              },
            );
          },
        );
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context)
                .pushReplacementNamed(Routes.main, arguments: {'from': "main"});
          }
        });
      }
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          if (HiveUtils.isUserSkip() == true) {
            Navigator.of(context)
                .pushReplacementNamed(Routes.main, arguments: {'from': "main"});
          } else {
            Navigator.of(context).pushReplacementNamed(Routes.login);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /* SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );*/

    navigateCheck();

    return hasInternet
        ? BlocListener<FetchLanguageCubit, FetchLanguageState>(
            listener: (context, state) {
              if (state is FetchLanguageSuccess) {
                Map<String, dynamic> map = state.toMap();

                var data = map['file_name'];
                map['data'] = data;
                map.remove("file_name");

                HiveUtils.storeLanguage(map);
                context.read<LanguageCubit>().emit(LanguageLoader(map));
                isLanguageLoaded = true;
                if (mounted) {
                  setState(() {});
                }
              }
            },
            child: BlocListener<FetchSystemSettingsCubit,
                FetchSystemSettingsState>(
              listener: (context, state) {
                if (state is FetchSystemSettingsSuccess) {
                  Constant.isDemoModeOn = context
                      .read<FetchSystemSettingsCubit>()
                      .getSetting(SystemSetting.demoMode);

                  isSettingsLoaded = true;
                  setState(() {});
                }
                if (state is FetchSystemSettingsFailure) {}
              },
              child: AnnotatedRegion(
                value: SystemUiOverlayStyle(
                  statusBarColor: context.color.territoryColor,
                ),
                child: Scaffold(
                  backgroundColor: context.color.territoryColor,
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                        width: 20.rw(context),
                        height: 20.rh(context),
                        child: UiUtils.getSvg(AppIcons.companyLogo)),
                  ),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.center,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0.rh(context)),
                          child: SizedBox(
                            width: 350.rw(context),
                            height: 350.rh(context),
                            child: UiUtils.getSvg(AppIcons.splashLogo),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : NoInternet(
            onRetry: () {
              setState(() {});
            },
          );
  }
}
