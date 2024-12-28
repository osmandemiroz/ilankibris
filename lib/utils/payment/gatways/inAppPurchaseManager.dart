/*
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class InAppPurchaseManager {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> initialize(List<String> productIds) async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      debugPrint('In-app purchases not available');
      return;
    }

    if (Platform.isIOS) {
      var iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    await _getProducts(productIds);
    _listenToPurchaseUpdated();
  }

  Future<void> _getProducts(List<String> productIds) async {
    final ProductDetailsResponse response =
    await _inAppPurchase.queryProductDetails(productIds.toSet());

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Some products were not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
  }

  void _listenToPurchaseUpdated() {
    _subscription = _inAppPurchase.purchaseStream.listen((purchases) {
      for (var purchase in purchases) {
        _handlePurchase(purchase);
      }
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      debugPrint('Error in purchase stream: $error');
    });
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
      // Here you would typically validate the purchase with your server
      // and update the user's subscription status
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      debugPrint('Error purchasing: ${purchaseDetails.error}');
    }
  }

  Future<bool> purchaseSubscription(String productId) async {
    ProductDetails? productDetails = _products.firstWhere((product) => product.id == productId);
    if (productDetails == null) {
      debugPrint('Product not found');
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    try {
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      return success;
    } catch (e) {
      debugPrint('Error purchasing subscription: $e');
      return false;
    }
  }

  List<ProductDetails> get products => _products;

  void dispose() {
    _subscription?.cancel();
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}*/

import 'dart:async';

import 'package:eClassify/ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/data/cubits/subscription/in_app_purchase_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:eClassify/utils/ui_utils.dart';

class InAppPurchaseManager {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  String? packageId;
  String? productId;
  static Set<String> processedPurchaseIds = {};
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<void> close() async {
    // Cancel the subscription when closing.
    await _subscription.cancel();
  }

  // Make sure to call this method when you are done with the instance
  // to avoid memory leaks and dangling subscriptions.
  void dispose() {
    close();
  }

  Future<ProductDetails> getProductByProductId(String productId) async {
    ProductDetailsResponse productDetailsResponse =
        await _inAppPurchase.queryProductDetails({productId});

    return productDetailsResponse.productDetails.first;
  }

  void onSuccessfulPurchase(
      BuildContext context, PurchaseDetails purchase) async {
    purchaseCompleteDialog(purchase);
  }

  void onPurchaseCancel(BuildContext context, PurchaseDetails purchase) async {
    paymentCancelDialog(context);
  }

  void onErrorPurchase(BuildContext context, PurchaseDetails purchase) async {
    paymentErrorDialog(context, purchase);
  }

  void onPendingPurchase(PurchaseDetails purchase) async {
    if (purchase.purchaseID != null && purchase.pendingCompletePurchase) {
      try {
        await Future.delayed(Duration(seconds: 1));
        await _inAppPurchase.completePurchase(purchase);
      } catch (e) {
      }
    }
  }

  void onRestoredPurchase(PurchaseDetails purchase) async {}

  Future completePending(event) async {
    for (var _purchaseDetails in event) {
      if (_purchaseDetails.purchaseID != null &&
          _purchaseDetails.pendingCompletePurchase) {
        try {
          await Future.delayed(Duration(seconds: 1));
          await _inAppPurchase.completePurchase(_purchaseDetails);
        } catch (e) {
          print('Error completing purchase: $e');
          // Handle the error appropriately
        }
      }
    }
  }

  static getPendings() {
    _inAppPurchase.purchaseStream.listen((event) {
      ;
    });
  }

  void listenIAP(BuildContext context) {
    _subscription = _inAppPurchase.purchaseStream.listen(
      (event) async {
        //await completePending(event);
        for (PurchaseDetails inAppPurchaseEvent in event) {
          if (inAppPurchaseEvent.error != null) {}
          if (inAppPurchaseEvent.purchaseID != null &&
              inAppPurchaseEvent.pendingCompletePurchase) {
            try {
              await Future.delayed(Duration(seconds: 1));
              await _inAppPurchase.completePurchase(inAppPurchaseEvent);
            } catch (e) {
              print('Error completing purchase: $e');
              // Handle the error appropriately
            }
          }

          Future.delayed(
            Duration.zero,
            () async {
              if (inAppPurchaseEvent.status == PurchaseStatus.purchased ||
                  inAppPurchaseEvent.status == PurchaseStatus.restored) {
                await _inAppPurchase.completePurchase(inAppPurchaseEvent);
                onSuccessfulPurchase(context, inAppPurchaseEvent);
              } else if (inAppPurchaseEvent.status == PurchaseStatus.canceled) {
                onPurchaseCancel(context, inAppPurchaseEvent);
              } else if (inAppPurchaseEvent.status == PurchaseStatus.error) {
                onErrorPurchase(context, inAppPurchaseEvent);
              }
              /*else if (inAppPurchaseEvent.status == PurchaseStatus.pending) {
                onPendingPurchase(inAppPurchaseEvent);
              } else if (inAppPurchaseEvent.status == PurchaseStatus.restored) {
                onRestoredPurchase(inAppPurchaseEvent);
              }*/

              if (inAppPurchaseEvent.pendingCompletePurchase) {
                await _inAppPurchase.completePurchase(inAppPurchaseEvent);
              }
            },
          );
        }
      },
      onDone: () {
        // Cancel the subscription when the stream is done
        _subscription.cancel();

      },
      onError: (error) {
        // Handle stream errors here
        print('Purchase stream error: $error');
        // Optionally perform additional error handling
      },
    );
  }

  Future<void> buy(String productId, String packageId) async {
    bool _isAvailable = await _inAppPurchase.isAvailable();
    if (_isAvailable) {

      ProductDetails productDetails = await getProductByProductId(productId);

      this.packageId = packageId;
      this.productId = productId;
      await _inAppPurchase.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
      );
    }
  }

  void purchaseCompleteDialog(PurchaseDetails purchase) async {
    final context = Constant.navigatorKey.currentContext!;

    if (packageId != null) {
      // Trigger the in-app purchase
      context.read<InAppPurchaseCubit>().inAppPurchase(
          packageId: int.parse(packageId!),
          method: "apple",
          purchaseToken: purchase.purchaseID!);

      // Show the dialog
      UiUtils.showBlurredDialoge(context,
          dialoge: BlurredDialogBox(
            title: "Purchase completed",
            showCancleButton: false,
            acceptTextColor: context.color.buttonColor,
            content: const Text("Your purchase has completed successfully"),
            isAcceptContainesPush: true,
            onAccept: () => Future.value().then(
              (_) {
                // Close the dialog

                // Listen to the cubit state after the dialog is dismissed
                final cubitState = context.read<InAppPurchaseCubit>().state;
                if (cubitState is InAppPurchaseInSuccess) {
                  HelperUtils.showSnackBarMessage(
                      context, cubitState.responseMessage);
                  Navigator.pop(Constant.navigatorKey.currentContext!);
                } else if (cubitState is InAppPurchaseFailure) {
                  HelperUtils.showSnackBarMessage(context, cubitState.error);
                }
                Navigator.pop(Constant.navigatorKey.currentContext!);
                return;
              },
            ),
          ));
    }
  }

  void paymentCancelDialog(BuildContext context) {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: "Purchase canceled",
        showCancleButton: false,
        acceptTextColor: context.color.buttonColor,
        content: const Text("Your purchase has been canceled"),
        isAcceptContainesPush: true,
        onAccept: () => Future.value().then((_) {
          Navigator.pop(Constant.navigatorKey.currentContext!);
          return;
        }),
      ),
    );
  }

  void paymentErrorDialog(BuildContext context, PurchaseDetails purchase) {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: "Purchase error",
        showCancleButton: false,
        acceptTextColor: context.color.buttonColor,
        content: Text("${purchase.error?.message}"),
        isAcceptContainesPush: true,
        onAccept: () => Future.value().then((_) {
          Navigator.pop(Constant.navigatorKey.currentContext!);
          return;
        }),
      ),
    );
  }
}
