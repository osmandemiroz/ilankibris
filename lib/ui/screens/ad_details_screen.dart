// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/report/fetch_item_report_reason_list.dart';
import 'package:eClassify/data/cubits/subscription/fetch_ads_listing_subscription_packages_cubit.dart';
import 'package:eClassify/ui/screens/home/home_screen.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/responsiveSize.dart';
import 'package:eClassify/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/chat/make_an_offer_item_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/item/create_featured_ad_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_my_item_cubit.dart';
import 'package:eClassify/data/cubits/item/item_total_click_cubit.dart';
import 'package:eClassify/data/cubits/item/related_item_cubit.dart';
import 'package:eClassify/data/cubits/renew_item_cubit.dart';
import 'package:eClassify/data/cubits/safety_tips_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/data/model/chat/chated_user_model.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/safety_tips_model.dart';
import 'package:eClassify/data/model/subscription_pacakage_model.dart';

import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/validator.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/cloudState/cloud_state.dart';
import 'package:eClassify/utils/customHeroAnimation.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/data/cubits/report/item_report_cubit.dart';
import 'package:eClassify/data/cubits/report/update_report_items_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/delete_message_cubit.dart';
import 'package:eClassify/data/cubits/chat/load_chat_messages.dart';
import 'package:eClassify/data/cubits/chat/send_message.dart';
import 'package:eClassify/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:eClassify/data/cubits/item/change_my_items_status_cubit.dart';
import 'package:eClassify/data/cubits/item/delete_item_cubit.dart';
import 'package:eClassify/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:eClassify/data/model/report_item/reason_model.dart';
import 'package:eClassify/ui/screens/ad_banner_screen.dart';
import 'package:eClassify/ui/screens/chat/chat_screen.dart';
import 'package:eClassify/ui/screens/home/widgets/grid_list_adapter.dart';
import 'package:eClassify/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:eClassify/ui/screens/subscription/widget/featured_ads_subscription_plan_item.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_internet.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:eClassify/ui/screens/widgets/video_view_screen.dart';
import 'package:eClassify/ui/screens/google_map_screen.dart';

class AdDetailsScreen extends StatefulWidget {
  final ItemModel model;

  const AdDetailsScreen({
    super.key,
    required this.model,
  });

  @override
  AdDetailsScreenState createState() => AdDetailsScreenState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
        builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => FetchMyItemsCubit(),
                ),
                BlocProvider(
                  create: (context) => CreateFeaturedAdCubit(),
                ),
                BlocProvider(
                  create: (context) => FetchItemReportReasonsListCubit(),
                ),
                BlocProvider(
                  create: (context) => ItemReportCubit(),
                ),
                BlocProvider(
                  create: (context) => MakeAnOfferItemCubit(),
                ),
              ],
              child: AdDetailsScreen(
                model: arguments?['model'],
                // from: arguments?['from'],
              ),
            ));
  }
}

class AdDetailsScreenState extends CloudState<AdDetailsScreen> {
  //ImageView
  int currentPage = 0;
  bool? isFeaturedLimit;
  List<String> selectedFeaturedAdsOptions = [];

  bool isShowReportAds = true;
  final PageController pageController = PageController();
  final List<String?> images = [];
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late final ScrollController _pageScrollController = ScrollController();
  List<ReportReason>? reasons = [];
  late int selectedId;
  final TextEditingController _reportmessageController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _makeAnOffermessageController =
      TextEditingController();
  final GlobalKey<FormState> _offerFormKey = GlobalKey();
  int? _selectedPackageIndex;

  //int? packageId;

  /* [
    "http://eclassify.thewrteam.in/storage/packages/M5t66y5DRVVOrxH7xjDoOg3PJnxavUqjZI1ILlHn.jpg",
    "http://eclassify.thewrteam.in/storage/custom_field/655c7b73c8952.jpg",
    "http://eclassify.thewrteam.in/storage/packages/M5t66y5DRVVOrxH7xjDoOg3PJnxavUqjZI1ILlHn.jpg",

  ]; */
  //ImageView

/*  late final String from =
      widget.from;*/ //"MyAds";//TODO: set it as an argument with Route

  late final ItemModel model = widget.model;

  late bool isAddedByMe = (widget.model.user?.id != null
          ? widget.model.user!.id.toString()
          : widget.model.userId) ==
      HiveUtils.getUserId();

  bool isFeaturedWidget = true;
  String youtubeVideoThumbnail = "";
  int? categoryId;
  FlickManager? flickManager;

  @override
  void initState() {
    super.initState();

    if (!isAddedByMe) {
      context.read<FetchItemReportReasonsListCubit>().fetch();
      context.read<FetchSafetyTipsListCubit>().fetchSafetyTips();
      context.read<FetchSellerRatingsCubit>().fetch(
          sellerId: (widget.model.user?.id != null
              ? widget.model.user!.id!
              : widget.model.userId!));
    } else {
      context.read<FetchAdsListingSubscriptionPackagesCubit>().fetchPackages();
    }
    categoryId = widget.model.category != null
        ? widget.model.category?.id
        : widget.model.categoryId;

    setItemClick();
    //ImageView
    combineImages();
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.round();
      });
    });
    context.read<FetchRelatedItemsCubit>().fetchRelatedItems(
        categoryId: categoryId!,
        city: HiveUtils.getCityName(),
        areaId: HiveUtils.getAreaId(),
        country: HiveUtils.getCountryName(),
        state: HiveUtils.getStateName());
    _pageScrollController.addListener(_pageScroll);
  }

  void _pageScroll() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchRelatedItemsCubit>().hasMoreData()) {
        context.read<FetchRelatedItemsCubit>().fetchRelatedItemsMore(
            categoryId: categoryId!,
            city: HiveUtils.getCityName(),
            areaId: HiveUtils.getAreaId(),
            country: HiveUtils.getCountryName(),
            state: HiveUtils.getStateName());
      }
    }
  }

  late final CameraPosition _kInitialPlace = CameraPosition(
    target: LatLng(
      model.latitude ?? 0,
      model.longitude ?? 0,
    ),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    super.dispose();
  }

  void combineImages() {
    images.add(model.image);
    if (model.galleryImages != null && model.galleryImages!.isNotEmpty) {
      for (var element in model.galleryImages!) {
        images.add(element.image);
      }
    }

    if (model.videoLink != null && model.videoLink!.isNotEmpty) {
      images.add(model.videoLink);
    }

    if (model.videoLink != "" &&
        model.videoLink != null &&
        !HelperUtils.isYoutubeVideo(model.videoLink ?? "")) {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(model.videoLink!),
        ),
      );
      flickManager?.onVideoEnd = () {};
    }
    if (model.videoLink != "" &&
        model.videoLink != null &&
        HelperUtils.isYoutubeVideo(model.videoLink ?? "")) {
      String? videoId = YoutubePlayer.convertUrlToId(model.videoLink!);
      if (videoId != null) {
        String thumbnail = YoutubePlayer.getThumbnail(videoId: videoId);

        youtubeVideoThumbnail = thumbnail;
      }
      setState(() {});
    }
  }

  /* void injectVideoInGallery() {
    ///This will inject video in image list just like another platforms
    if ((gallary?.length ?? 0) < 2) {
      if (model.videoLink != null) {
        gallary?.add(GalleryImages(

            id: 99999999999,

            image: property!.video ?? "",
            imageUrl: "",
            isVideo: true));
      }
    } else {
      gallary?.insert(
          0,
          GalleryImages(
              id: 99999999999,
              image: property!.video!,
              imageUrl: "",
              isVideo: true));
    }

    setState(() {});
  }*/

  void setItemClick() {
    if (!isAddedByMe) {
      context.read<ItemTotalClickCubit>().itemTotalClick(model.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: context.color.secondaryDetailsColor,
        ),
        child: Scaffold(
          appBar: UiUtils.buildAppBar(
            context,
            backgroundColor: context.color.secondaryDetailsColor,
            showBackButton: true,
            actions: [
              Padding(
                padding: EdgeInsetsDirectional.only(
                    end: isAddedByMe &&
                            (model.status != "sold out" &&
                                model.status != "review" &&
                                model.status != "inactive" &&
                                model.status != "rejected")
                        ? 30.0
                        : 15),
                child: IconButton(
                  onPressed: () {
                    HelperUtils.share(context, model.slug!);
                  },
                  icon: Icon(
                    Icons.share,
                    size: 24,
                    color: context.color.textDefaultColor,
                  ),
                ),
              ),
              if (isAddedByMe &&
                  (model.status != "sold out" &&
                      model.status != "review" &&
                      model.status != "inactive" &&
                      model.status != "rejected"))
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => DeleteItemCubit(),
                    ),
                    BlocProvider(
                      create: (context) => ChangeMyItemStatusCubit(),
                    ),
                  ],
                  child: Builder(builder: (context) {
                    return BlocListener<DeleteItemCubit, DeleteItemState>(
                      listener: (context, deleteState) {
                        if (deleteState is DeleteItemSuccess) {
                          HelperUtils.showSnackBarMessage(context,
                              "deleteItemSuccessMsg".translate(context));
                          context.read<FetchMyItemsCubit>().deleteItem(model);
                          Navigator.pop(context, "refresh");
                        } else if (deleteState is DeleteItemFailure) {
                          HelperUtils.showSnackBarMessage(
                              context, deleteState.errorMessage);
                        }
                      },
                      child: BlocListener<ChangeMyItemStatusCubit,
                          ChangeMyItemStatusState>(
                        listener: (context, changeState) {
                          if (changeState is ChangeMyItemStatusSuccess) {
                            HelperUtils.showSnackBarMessage(
                                context, changeState.message);
                            Navigator.pop(context, "refresh");
                          } else if (changeState is ChangeMyItemStatusFailure) {
                            HelperUtils.showSnackBarMessage(
                                context, changeState.errorMessage);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(end: 30.0),
                          child: Container(
                            height: 24,
                            width: 24,
                            alignment: AlignmentDirectional.center,
                            child: PopupMenuButton(
                              color: context.color.territoryColor,
                              offset: Offset(-12, 15),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(17),
                                  bottomRight: Radius.circular(17),
                                  topLeft: Radius.circular(17),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                              child: SvgPicture.asset(
                                AppIcons.more,
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                    context.color.textDefaultColor,
                                    BlendMode.srcIn),
                              ),
                              itemBuilder: (context) => [
                                if (model.status == "active" ||
                                    model.status == "approved")
                                  PopupMenuItem(
                                    onTap: () {
                                      Future.delayed(Duration.zero, () {
                                        /*if (Constant.isDemoModeOn) {
                                          HelperUtils.showSnackBarMessage(
                                              context,
                                              UiUtils.getTranslatedLabel(
                                                  context,
                                                  "thisActionNotValidDemo"));
                                          return;
                                        }*/
                                        context
                                            .read<ChangeMyItemStatusCubit>()
                                            .changeMyItemStatus(
                                                id: model.id!,
                                                status: 'inactive');
                                      });
                                    },
                                    child: Text("deactivate".translate(context))
                                        .color(context.color.buttonColor),
                                  ),
                                if (model.status == "active" ||
                                    model.status == "approved")
                                  PopupMenuItem(
                                    child: Text("lblremove".translate(context))
                                        .color(context.color.buttonColor),
                                    onTap: () async {
                                      var delete =
                                          await UiUtils.showBlurredDialoge(
                                        context,
                                        dialoge: BlurredDialogBox(
                                          title:
                                              "deleteBtnLbl".translate(context),
                                          content: Text(
                                            "deleteitemwarning"
                                                .translate(context),
                                          ),
                                        ),
                                      );
                                      if (delete == true) {
                                        Future.delayed(
                                          Duration.zero,
                                          () {
                                            context
                                                .read<DeleteItemCubit>()
                                                .deleteItem(model.id!);
                                          },
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
          backgroundColor: context.color.secondaryDetailsColor,
          bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: bottomButtonWidget()),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  setImageViewer(),
                  if (isAddedByMe) setLikesAndViewsCount(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(model.name!)
                        .size(context.font.large)
                        .setMaxLines(lines: 2)
                        .color(context.color.textDefaultColor),
                  ),
                  setPriceAndStatus(),
                  if (isAddedByMe) setRejectedReason(),
                  if (model.address != null) setAddress(isDate: true),

                  if (Constant.isGoogleBannerAdsEnabled == "1") ...[
                    Divider(
                        thickness: 1,
                        color: context.color.textDefaultColor.withOpacity(0.1)),
                    Container(
                      alignment: AlignmentDirectional.center,
                      child: AdBannerWidget(), // Custom widget for banner ad
                    ),
                  ],

                  if (isAddedByMe)
                    if (!model.isFeature!) createFeaturesAds(),
                  if (model.customFields!.isNotEmpty) customFields(),
                  //detailsContainer Widget
                  //Dynamic Ads here
                  Divider(
                      thickness: 1,
                      color: context.color.textDefaultColor.withOpacity(0.1)),
                  setDescription(),
                  Divider(
                      thickness: 1,
                      color: context.color.textDefaultColor.withOpacity(0.1)),
                  if (!isAddedByMe && model.user != null) setSellerDetails(),
                  //Dynamic Ads here
                  setLocation(),
                  if (Constant.isGoogleBannerAdsEnabled == "1") ...[
                    Divider(
                        thickness: 1,
                        color: context.color.textDefaultColor.withOpacity(0.1)),
                    Container(
                      alignment: AlignmentDirectional.center,
                      child: AdBannerWidget(), // Custom widget for banner ad
                    ),
                  ],

                  if (!isAddedByMe) reportedAdsWidget(),
                  /*if (model.isAlreadyReported != null &&
                        model.isAlreadyReported!)
                      setReportAd(),*/
                  relatedAds(),
                  // const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ));
  }

  Widget reportedAdsWidget() {
    return BlocBuilder<UpdatedReportItemCubit, UpdatedReportItemState>(
      builder: (context, state) {
        bool isItemInCubit =
            context.read<UpdatedReportItemCubit>().containsItem(model.id!);

        if (!isItemInCubit) {
          if (model.isAlreadyReported != null && !model.isAlreadyReported!) {
            return setReportAd();
          } else {
            return SizedBox(); // Return an empty widget if conditions are not met
          }
        } else {
          return SizedBox(); // Return an empty widget if item is not in cubit
        }
      },
    );
  }

  Widget relatedAds() {
    return BlocBuilder<FetchRelatedItemsCubit, FetchRelatedItemsState>(
        builder: (context, state) {
      if (state is FetchRelatedItemsInProgress) {
        return relatedItemShimmer();
      }
      if (state is FetchRelatedItemsFailure) {
        if (state.errorMessage is ApiException) {
          if (state.errorMessage == "no-internet") {
            return NoInternet(
              onRetry: () {
                context.read<FetchRelatedItemsCubit>().fetchRelatedItems(
                    categoryId: categoryId!,
                    city: HiveUtils.getCityName(),
                    areaId: HiveUtils.getAreaId(),
                    country: HiveUtils.getCountryName(),
                    state: HiveUtils.getStateName());
              },
            );
          }
        }

        return const SomethingWentWrong();
      }

      if (state is FetchRelatedItemsSuccess) {
        if (state.itemModel.isEmpty || state.itemModel.length == 1) {
          return SizedBox.shrink();
        }

        return buildRelatedListWidget(state);
      }

      return const SizedBox.square();
    });
  }

  Widget buildRelatedListWidget(FetchRelatedItemsSuccess state) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("relatedAds".translate(context))
              .size(context.font.large)
              .bold(weight: FontWeight.w600)
              .setMaxLines(lines: 1),
          SizedBox(
            height: 15,
          ),
          GridListAdapter(
            type: ListUiType.List,
            height: MediaQuery.of(context).size.height / 3.5.rh(context),
            controller: _pageScrollController,
            listAxis: Axis.horizontal,
            listSaperator: (BuildContext p0, int p1) => const SizedBox(
              width: 14,
            ),
            isNotSidePadding: true,
            builder: (context, int index, bool) {
              ItemModel? item = state.itemModel[index];

              if (item.id != model.id) {
                return ItemCard(
                  item: item,
                  width: 162,
                );
              } else {
                return SizedBox.shrink();
              }
            },
            total: state.itemModel.length,
          ),
        ],
      ),
    );
  }

  Widget relatedItemShimmer() {
    return SizedBox(
        height: 200,
        child: ListView.builder(
            itemCount: 5,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8),
                child: const CustomShimmer(
                  height: 200,
                  width: 300,
                ),
              );
            }));
  }

  Widget createFeaturesAds() {
    if (model.status == "active" || model.status == "approved") {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CreateFeaturedAdCubit(),
          ),
          BlocProvider(
            create: (context) => FetchUserPackageLimitCubit(),
          ),
        ],
        child: Builder(builder: (context) {
          return BlocListener<CreateFeaturedAdCubit, CreateFeaturedAdState>(
            listener: (context, state) {
              if (state is CreateFeaturedAdInSuccess) {
                HelperUtils.showSnackBarMessage(
                    context, state.responseMessage.toString(),
                    messageDuration: 3);

                Navigator.pop(context, "refresh");
              }
              if (state is CreateFeaturedAdFailure) {
                HelperUtils.showSnackBarMessage(context, state.error.toString(),
                    messageDuration: 3);
              }
            },
            child: BlocListener<FetchUserPackageLimitCubit,
                FetchUserPackageLimitState>(
              listener: (context, state) async {
                if (state is FetchUserPackageLimitFailure) {
                  UiUtils.noPackageAvailableDialog(context);
                }
                if (state is FetchUserPackageLimitInSuccess) {
                  await UiUtils.showBlurredDialoge(
                    context,
                    dialoge: BlurredDialogBox(
                        title: "createFeaturedAd".translate(context),
                        content: Text(
                          "areYouSureToCreateThisItemAsAFeaturedAd"
                              .translate(context),
                        ),
                        isAcceptContainesPush: true,
                        onAccept: () => Future.value().then((_) {
                              Future.delayed(
                                Duration.zero,
                                () {
                                  context
                                      .read<CreateFeaturedAdCubit>()
                                      .createFeaturedAds(
                                        itemId: model.id!,
                                      );
                                  Navigator.pop(context);
                                  return;
                                },
                              );
                            })),
                  );
                }
              },
              child: AnimatedCrossFade(
                duration: Duration(milliseconds: 500),
                crossFadeState: isFeaturedWidget
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(12),
                  //height: 116,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: context.color.territoryColor.withOpacity(0.1),
                    border:
                        Border.all(color: context.color.borderColor.darken(30)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: SvgPicture.asset(
                          AppIcons.createAddIcon,
                          height: 74,
                          width: 62,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${"featureYourAdsAttractMore".translate(context)}\n${"clientsAndSellFaster".translate(context)}",
                              style: TextStyle(
                                color: context.color.textDefaultColor
                                    .withOpacity(0.7),
                                fontSize: context.font.large,
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () {
                                context
                                    .read<FetchUserPackageLimitCubit>()
                                    .fetchUserPackageLimit(
                                        packageType: "advertisement");
                              },
                              child: Container(
                                height: 33,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: context.color.territoryColor,
                                ),
                                child: Text(
                                  "createFeaturedAd".translate(context),
                                  style: TextStyle(
                                    color: context.color.secondaryColor,
                                    fontSize: context.font.small,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                secondChild: SizedBox.shrink(),
              ),
            ),
          );
        }),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget customFields() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Wrap(
        children: [
          ...List.generate(model.customFields!.length, (index) {
            if (model.customFields![index].value!.isNotEmpty) {
              if (model.customFields![index].type != "textbox") {
                return SizedBox(
                  width: (context.screenWidth / 2) - (sidePadding / 2) - 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 33,
                        width: 33,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          /*border: Border.all(
                                color: context.color.textLightColor, width: 0.5)*/
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: UiUtils.imageType(
                              model.customFields![index].image!,
                              fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: model.customFields![index].name,
                              child:
                                  Text((model.customFields?[index].name) ?? "")
                                      .setMaxLines(lines: 1)
                                      .size(context.font.small)
                                      .color(context.color.textDefaultColor
                                          .withOpacity(0.5)),
                            ),
                            valueContent(model.customFields![index].value),
                            const SizedBox(
                              height: 12,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return SizedBox();
              }
            } else {
              return SizedBox();
            }
          }),
          ...List.generate(model.customFields!.length, (index) {
            if (model.customFields![index].value!.isNotEmpty) {
              if (model.customFields![index].type == "textbox") {
                return SizedBox(
                  width: (context.screenWidth / 2) - (sidePadding / 2) - 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 33,
                        width: 33,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          /*border: Border.all(
                                color: context.color.textLightColor, width: 0.5)*/
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: UiUtils.imageType(
                              model.customFields![index].image!,
                              fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(width: 7),
                      Expanded(
                          //padding: EdgeInsetsDirectional.only(start: 7.0),
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: model.customFields![index].name,
                            child: Text((model.customFields?[index].name) ?? "")
                                .setMaxLines(lines: 1)
                                .size(context.font.small)
                                .color(context.color.textDefaultColor
                                    .withOpacity(0.5)),
                          ),
                          valueContent(model.customFields![index].value),
                          const SizedBox(
                            height: 12,
                          )
                        ],
                      )),
                    ],
                  ),
                );
              } else {
                return SizedBox();
              }
            } else {
              return SizedBox();
            }
          })
        ],
      ),
    );
  }

  Widget valueContent(List<dynamic>? value) {
    if (((value![0].toString()).startsWith("http") ||
        (value[0].toString()).startsWith("https"))) {
      if ((value[0].toString()).toLowerCase().endsWith(".pdf")) {
        // Render PDF link as clickable text
        return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.pdfViewerScreen,
                  arguments: {"url": value[0]});
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: UiUtils.getSvg(AppIcons.pdfIcon,
                  color: context.color.textColorDark),
            ));
      } else if ((value[0]).toLowerCase().endsWith(".png") ||
          (value[0]).toLowerCase().endsWith(".jpg") ||
          (value[0]).toLowerCase().endsWith(".jpeg") ||
          (value[0]).toLowerCase().endsWith(".svg")) {
        // Render image
        return InkWell(
          onTap: () {
            UiUtils.showFullScreenImage(
              context,
              provider: NetworkImage(
                value[0],
              ),
            );
          },
          child: Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.color.territoryColor.withOpacity(0.1)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: UiUtils.imageType(
                  value[0],
                  color: context.color.territoryColor,
                  fit: BoxFit.cover,
                ),
              )),
        );
      }
    }

    // Default text if not a supported format or not a URL
    return Text(
      value.length == 1 ? value[0].toString() : value.join(','),
      //maxLines: 4,
      //overflow: TextOverflow.ellipsis,
      //softWrap: true,
    ).color(context.color.textDefaultColor);
  }

  Widget itemData(
      int index, SubscriptionPackageModel model, StateSetter stateSetter) {
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          if (model.isActive!)
            Padding(
              padding: EdgeInsetsDirectional.only(start: 13.0),
              child: ClipPath(
                clipper: CapShapeClipper(),
                child: Container(
                  color: context.color.territoryColor,
                  width: MediaQuery.of(context).size.width / 3,
                  height: 17,
                  padding: EdgeInsets.only(top: 3),
                  child: Text('activePlanLbl'.translate(context))
                      .color(context.color.secondaryColor)
                      .centerAlign()
                      .bold(weight: FontWeight.w500)
                      .size(12),
                ),
              ),
            ),
          InkWell(
            onTap: () {
              _selectedPackageIndex = index;
              stateSetter(() {});
              setState(() {});
            },
            child: Container(
              margin: EdgeInsets.only(top: 17),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                      color: index == _selectedPackageIndex
                          ? context.color.territoryColor
                          : context.color.textDefaultColor.withOpacity(0.1),
                      width: 1.5)),
              child:
                  !model.isActive! ? adsWidget(model) : activeAdsWidget(model),
            ),
          ),
        ],
      ),
    );
  }

  Widget adsWidget(SubscriptionPackageModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(model.name!)
                  .firstUpperCaseWidget()
                  .bold(weight: FontWeight.w600)
                  .size(context.font.large),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model.limit == "unlimited" ? "unlimitedLbl".translate(context) : model.limit.toString()}\t${"adsLbl".translate(context)}\t\t·\t\t',
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ).color(context.color.textDefaultColor.withOpacity(0.5)),
                  Flexible(
                    child: Text(
                      '${model.duration.toString()}\t${"days".translate(context)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ).color(context.color.textDefaultColor.withOpacity(0.5)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: 10.0),
          child: Text(
            model.finalPrice! > 0
                ? "${Constant.currencySymbol}${model.finalPrice.toString()}"
                : "free".translate(context),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget activeAdsWidget(SubscriptionPackageModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(model.name!)
                  .firstUpperCaseWidget()
                  .bold(weight: FontWeight.w600)
                  .size(context.font.large),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: model.limit == "unlimited"
                          ? "${"unlimitedLbl".translate(context)}\t${"adsLbl".translate(context)}\t\t·\t\t"
                          : '',
                      style: TextStyle(
                        color: context.color.textDefaultColor.withOpacity(0.5),
                      ),
                      children: [
                        if (model.limit != "unlimited")
                          TextSpan(
                            text:
                                '${model.userPurchasedPackages![0].remainingItemLimit}',
                            style: TextStyle(
                                color: context.color.textDefaultColor),
                          ),
                        if (model.limit != "unlimited")
                          TextSpan(
                            text:
                                '/${model.limit.toString()}\t${"adsLbl".translate(context)}\t\t·\t\t',
                          ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        text: model.duration == "unlimited"
                            ? "${"unlimitedLbl".translate(context)}\t${"days".translate(context)}"
                            : '',
                        style: TextStyle(
                          color:
                              context.color.textDefaultColor.withOpacity(0.5),
                        ),
                        children: [
                          if (model.duration != "unlimited")
                            TextSpan(
                              text:
                                  '${model.userPurchasedPackages![0].remainingDays}',
                              style: TextStyle(
                                  color: context.color.textDefaultColor),
                            ),
                          if (model.duration != "unlimited")
                            TextSpan(
                              text:
                                  '/${model.duration.toString()}\t${"days".translate(context)}',
                            ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: 10.0),
          child: Text(
            model.finalPrice! > 0
                ? "${Constant.currencySymbol}${model.finalPrice.toString()}"
                : "free".translate(context),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

/*  void selectPackageDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,

      // Set to false if you don't want the dialog to close by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.color.secondaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Center(child: Text("selectPackage".translate(context))),
          content: packageList(),
        );
      },
    );
  }*/

  showPackageSelectBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.85),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: context.color.borderColor,
                    ),
                    height: 6,
                    width: 60,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 17, horizontal: 20),
                child: Text(
                  'selectPackage'.translate(context),
                  textAlign: TextAlign.start,
                ).bold(weight: FontWeight.bold).size(context.font.large),
              ),

              Divider(height: 1), // Add some space between title and options
              Expanded(child: packageList()),
            ],
          ),
        );
      },
    );
  }

  Widget packageList() {
    return BlocBuilder<FetchAdsListingSubscriptionPackagesCubit,
        FetchAdsListingSubscriptionPackagesState>(
      builder: (context, state) {
        print("state package***$state");
        if (state is FetchAdsListingSubscriptionPackagesInProgress) {
          return Center(
            child: UiUtils.progress(),
          );
        }
        if (state is FetchAdsListingSubscriptionPackagesFailure) {
          if (state.errorMessage is ApiException) {
            if (state.errorMessage == "no-internet") {
              return NoInternet(
                onRetry: () {
                  context
                      .read<FetchAdsListingSubscriptionPackagesCubit>()
                      .fetchPackages();
                },
              );
            }
          }

          return const SomethingWentWrong();
        }
        if (state is FetchAdsListingSubscriptionPackagesSuccess) {
          print(
              "subscription plan list***${state.subscriptionPackages.length}");
          if (state.subscriptionPackages.isEmpty) {
            return NoDataFound(
              onTap: () {
                context
                    .read<FetchAdsListingSubscriptionPackagesCubit>()
                    .fetchPackages();
              },
            );
          }

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      itemBuilder: (context, index) {
                        return itemData(index,
                            state.subscriptionPackages[index], setStater);
                      },
                      itemCount: state.subscriptionPackages.length),
                ),
                Builder(builder: (context) {
                  return BlocListener<RenewItemCubit, RenewItemState>(
                    listener: (context, changeState) {
                      if (changeState is RenewItemInSuccess) {
                        HelperUtils.showSnackBarMessage(
                            context, changeState.responseMessage);
                        Future.delayed(Duration.zero, () {
                          Navigator.pop(context);
                          Navigator.pop(context, "refresh");
                        });
                      } else if (changeState is RenewItemFailure) {
                        Navigator.pop(context);
                        HelperUtils.showSnackBarMessage(
                            context, changeState.error);
                      }
                    },
                    child: UiUtils.buildButton(context, onPressed: () {
                      if (state.subscriptionPackages[_selectedPackageIndex!]
                          .isActive!) {
                        Future.delayed(Duration.zero, () {
                          context.read<RenewItemCubit>().renewItem(
                              packageId: state
                                  .subscriptionPackages[_selectedPackageIndex!]
                                  .id!,
                              itemId: model.id!);
                        });
                      } else {
                        Navigator.pop(context);
                        HelperUtils.showSnackBarMessage(context,
                            "pleasePurchasePackage".translate(context));
                        Navigator.pushNamed(
                            context, Routes.subscriptionPackageListRoute);
                      }
                    },
                        radius: 10,
                        height: 46,
                        disabled: _selectedPackageIndex == null,
                        disabledColor:
                            context.color.textLightColor.withOpacity(0.3),
                        fontSize: context.font.large,
                        buttonColor: context.color.territoryColor,
                        textColor: context.color.secondaryColor,
                        buttonTitle: "renewItem".translate(context),

                        //TODO: change title to Your Current Plan according to condition
                        outerPadding: const EdgeInsets.all(20)),
                  );
                })
              ],
            );
          });
        }

        return Container();
      },
    );
  }

  Widget bottomButtonWidget() {
    if (isAddedByMe) {
      final model = widget.model;
      final contextColor = context.color;

      if (model.status == "review") {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildButton("editBtnLbl".translate(context), () {
                  addCloudData("edit_request", model);
                  addCloudData("edit_from", model.status);
                  Navigator.pushNamed(context, Routes.addItemDetails,
                      arguments: {"isEdit": true});
                }, contextColor.secondaryColor, contextColor.territoryColor),
              ),
              SizedBox(width: 10.rw(context)),
              BlocProvider(
                create: (context) => DeleteItemCubit(),
                child: Builder(builder: (context) {
                  return BlocListener<DeleteItemCubit, DeleteItemState>(
                    listener: (context, deleteState) {
                      if (deleteState is DeleteItemSuccess) {
                        HelperUtils.showSnackBarMessage(
                            context, "deleteItemSuccessMsg".translate(context));
                        context.read<FetchMyItemsCubit>().deleteItem(model);
                        Navigator.pop(context, "refresh");
                      } else if (deleteState is DeleteItemFailure) {
                        HelperUtils.showSnackBarMessage(
                            context, deleteState.errorMessage);
                      }
                    },
                    child: Expanded(
                      child: _buildButton("lblremove".translate(context), () {
                        Future.delayed(
                          Duration.zero,
                          () {
                            /*  if (Constant.isDemoModeOn) {
                              HelperUtils.showSnackBarMessage(
                                  context,
                                  UiUtils.getTranslatedLabel(
                                      context, "thisActionNotValidDemo"));
                              return;
                            }*/
                            context
                                .read<DeleteItemCubit>()
                                .deleteItem(model.id!);
                          },
                        );
                      }, null, null),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      } else if (model.status == "active" || model.status == "approved") {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildButton("editBtnLbl".translate(context), () {
                addCloudData("edit_request", model);
                addCloudData("edit_from", model.status);
                Navigator.pushNamed(context, Routes.addItemDetails,
                    arguments: {"isEdit": true});
              }, contextColor.secondaryColor, contextColor.territoryColor),
            ),
            SizedBox(width: 10.rw(context)),
            Expanded(
              child: _buildButton("soldOut".translate(context), () async {
                Navigator.pushNamed(context, Routes.soldOutBoughtScreen,
                    arguments: {
                      "itemId": model.id,
                      "price": model.price,
                      "itemName": model.name,
                      "itemImage": model.image
                    });
              }, null, null),
            ),
          ],
        );
      } else if (model.status == "sold out" ||
          model.status == "inactive" ||
          model.status == "rejected") {
        return BlocProvider(
          create: (context) => DeleteItemCubit(),
          child: Builder(builder: (context) {
            return BlocListener<DeleteItemCubit, DeleteItemState>(
              listener: (context, deleteState) {
                if (deleteState is DeleteItemSuccess) {
                  HelperUtils.showSnackBarMessage(
                      context, "deleteItemSuccessMsg".translate(context));

                  context.read<FetchMyItemsCubit>().deleteItem(model);
                  Navigator.pop(context, "refresh");
                } else if (deleteState is DeleteItemFailure) {
                  HelperUtils.showSnackBarMessage(
                      context, deleteState.errorMessage);
                }
              },
              child: _buildButton("lblremove".translate(context), () {
                Future.delayed(
                  Duration.zero,
                  () {
                    context.read<DeleteItemCubit>().deleteItem(model.id!);
                  },
                );
              }, null, null),
            );
          }),
        );
      } else if (model.status == "expired") {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildButton("renew".translate(context), () {
                // selectPackageDialog();
                showPackageSelectBottomSheet();
              }, contextColor.secondaryColor, contextColor.territoryColor),
            ),
            SizedBox(width: 10.rw(context)),
            BlocProvider(
              create: (context) => DeleteItemCubit(),
              child: Builder(builder: (context) {
                return BlocListener<DeleteItemCubit, DeleteItemState>(
                  listener: (context, deleteState) {
                    if (deleteState is DeleteItemSuccess) {
                      HelperUtils.showSnackBarMessage(
                          context, "deleteItemSuccessMsg".translate(context));
                      context.read<FetchMyItemsCubit>().deleteItem(model);
                      Navigator.pop(context, "refresh");
                    } else if (deleteState is DeleteItemFailure) {
                      HelperUtils.showSnackBarMessage(
                          context, deleteState.errorMessage);
                    }
                  },
                  child: Expanded(
                    child: _buildButton("lblremove".translate(context), () {
                      Future.delayed(
                        Duration.zero,
                        () {
                          context.read<DeleteItemCubit>().deleteItem(model.id!);
                        },
                      );
                    }, null, null),
                  ),
                );
              }),
            ),
          ],
        );
      } else {
        return const SizedBox();
      }
    } else {
      return BlocBuilder<GetBuyerChatListCubit, GetBuyerChatListState>(
        bloc: context.read<GetBuyerChatListCubit>(),
        builder: (context, State) {
          ChatedUser? chatedUser = context.select(
              (GetBuyerChatListCubit cubit) =>
                  cubit.getOfferForItem(model.id!));

          return BlocListener<MakeAnOfferItemCubit, MakeAnOfferItemState>(
            listener: (context, state) {
              if (state is MakeAnOfferItemSuccess) {
                if (state.from == 'offer') {
                  HelperUtils.showSnackBarMessage(
                    context,
                    state.message.toString(),
                  );
                  dynamic data = state.data;

                  context.read<GetBuyerChatListCubit>().addNewChat(ChatedUser(
                      itemId: data['item_id'] is String
                          ? int.parse(data['item_id'])
                          : data['item_id'],
                      amount: double.parse(data['amount']),
                      buyerId: data['buyer_id'],
                      createdAt: data['created_at'],
                      id: data['id'],
                      sellerId: data['seller_id'],
                      updatedAt: data['updated_at'],
                      buyer: Buyer.fromJson(data['buyer']),
                      item: Item.fromJson(data['item']),
                      seller: Seller.fromJson(data['seller'])));
                }

                Navigator.push(context, BlurredRouter(
                  builder: (context) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => SendMessageCubit(),
                        ),
                        BlocProvider(
                          create: (context) => LoadChatMessagesCubit(),
                        ),
                        BlocProvider(
                          create: (context) => DeleteMessageCubit(),
                        ),
                      ],
                      child: ChatScreen(
                        profilePicture: widget.model.user!.profile ?? "",
                        userName: widget.model.user!.name!,
                        userId: widget.model.user!.id!.toString(),
                        from: "item",
                        itemImage: widget.model.image!,
                        itemId: widget.model.id.toString(),
                        date: widget.model.created!,
                        itemTitle: widget.model.name!,
                        itemOfferId: state.data['id'],
                        itemPrice: widget.model.price!,
                        status: widget.model.status!,
                        buyerId: HiveUtils.getUserId(),
                        itemOfferPrice: state.data['amount'] != null
                            ? double.parse(state.data['amount'])
                            : null,
                        isPurchased: widget.model.isPurchased!,
                        alreadyReview: widget.model.review == null
                            ? false
                            : widget.model.review!.isEmpty
                                ? false
                                : true,
                      ),
                    );
                  },
                ));
              }
              if (state is MakeAnOfferItemFailure) {
                HelperUtils.showSnackBarMessage(
                  context,
                  state.errorMessage.toString(),
                );
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //if(!model.isAlreadyOffered!)
                if (chatedUser == null /*!model.isAlreadyOffered!*/)
                  Expanded(
                    child: _buildButton("makeAnOffer".translate(context), () {
                      /* if (Constant.isDemoModeOn) {
                        HelperUtils.showSnackBarMessage(context,
                            "thisActionNotValidDemo".translate(context));
                        return;
                      }*/
                      UiUtils.checkUser(
                          onNotGuest: () {
                            safetyTipsBottomSheet();
                            //makeOfferBottomSheet(model);
                          },
                          context: context);
                    }, null, null),
                  ),
                if (chatedUser == null) SizedBox(width: 10.rw(context)),

                Expanded(
                  child: _buildButton("chat".translate(context), () {
                    UiUtils.checkUser(
                        onNotGuest: () {
                          if (chatedUser != null) {
                            Navigator.push(context, BlurredRouter(
                              builder: (context) {
                                return MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (context) => SendMessageCubit(),
                                    ),
                                    BlocProvider(
                                      create: (context) =>
                                          LoadChatMessagesCubit(),
                                    ),
                                    BlocProvider(
                                      create: (context) => DeleteMessageCubit(),
                                    ),
                                  ],
                                  child: ChatScreen(
                                    itemId: chatedUser.itemId.toString(),
                                    profilePicture: chatedUser.seller != null &&
                                            chatedUser.seller!.profile != null
                                        ? chatedUser.seller!.profile!
                                        : "",
                                    userName: chatedUser.seller != null &&
                                            chatedUser.seller!.name != null
                                        ? chatedUser.seller!.name!
                                        : "",
                                    date: chatedUser.createdAt!,
                                    itemOfferId: chatedUser.id!,
                                    itemPrice: chatedUser.item != null &&
                                            chatedUser.item!.price != null
                                        ? chatedUser.item!.price!
                                        : 0.0,
                                    itemOfferPrice: chatedUser.amount != null
                                        ? chatedUser.amount!
                                        : null,
                                    itemImage: chatedUser.item != null &&
                                            chatedUser.item!.image != null
                                        ? chatedUser.item!.image!
                                        : "",
                                    itemTitle: chatedUser.item != null &&
                                            chatedUser.item!.name != null
                                        ? chatedUser.item!.name!
                                        : "",
                                    userId: chatedUser.sellerId.toString(),
                                    buyerId: chatedUser.buyerId.toString(),
                                    status: chatedUser.item!.status,
                                    from: "item",
                                    isPurchased: widget.model.isPurchased!,
                                    alreadyReview: widget.model.review == null
                                        ? false
                                        : widget.model.review!.isEmpty
                                            ? false
                                            : true,
                                  ),
                                );
                              },
                            ));
                          } else {
                            context
                                .read<MakeAnOfferItemCubit>()
                                .makeAnOfferItem(
                                    id: widget.model.id!, from: "chat");
                          }
                        },
                        context: context);
                  }, null, null),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void safetyTipsBottomSheet() {
    List<SafetyTipsModel>? tipsList =
        context.read<FetchSafetyTipsListCubit>().getList();
    if (tipsList == null || tipsList.isEmpty) {
      makeOfferBottomSheet(model);
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: context.color.textColorDark.withOpacity(0.1),
                    ),
                    height: 6,
                    width: 60,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: UiUtils.getSvg(
                  AppIcons.safetyTipsIcon,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 5),
                child: Text(
                  'safetyTips'.translate(context),
                )
                    .bold(weight: FontWeight.w600)
                    .size(context.font.larger)
                    .centerAlign(),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: tipsList.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return checkmarkPoint(
                    context,
                    tipsList[index].translatedName!,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildButton(
                  "continueToOffer".translate(context),
                  () {
                    Navigator.pop(context);
                    makeOfferBottomSheet(model);
                  },
                  context.color.territoryColor,
                  context.color.secondaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget checkmarkPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiUtils.getSvg(
            AppIcons.active_mark,
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(
            text.firstUpperCase(),
            textAlign: TextAlign.start,
          )
                  .color(
                    context.color.textDefaultColor,
                  )
                  .size(context.font.large)),
        ],
      ),
    );
  }

  Widget _buildButton(String title, VoidCallback onPressed, Color? buttonColor,
      Color? textColor) {
    return UiUtils.buildButton(
      context,
      onPressed: onPressed,
      radius: 10,
      height: 46,
      border: buttonColor != null
          ? BorderSide(color: context.color.territoryColor)
          : null,
      buttonColor: buttonColor,
      textColor: textColor,
      buttonTitle: title,
      width: 50.rw(context),
    );
  }

//ImageView
  Widget setImageViewer() {
    return Container(
      height: 250.rh(context),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.symmetric(vertical: 10),
      // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(children: [
          PageView.builder(
            itemCount: images.length,
            // Increase itemCount if videoLink is present
            controller: pageController,
            itemBuilder: (context, index) {
              if (index == images.length - 1 &&
                  model.videoLink != "" &&
                  model.videoLink != null) {
                return Stack(
                  children: [
                    // Thumbnail Image
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return VideoViewScreen(
                                videoUrl: model.videoLink ?? "",
                                flickManager: flickManager,
                              );
                            },
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: UiUtils.getImage(
                          youtubeVideoThumbnail,
                          fit: BoxFit.cover,
                          height: 250.rh(context),
                          width: double.maxFinite,
                        ),
                      ),
                    ),
                    // Play Button
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return VideoViewScreen(
                                  videoUrl: model.videoLink ?? "",
                                  flickManager: flickManager,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );

                /*  if (model.videoLink!.contains("youtube.com"))
                  return buildYouTubePlayer(model.videoLink!);
                else
                  return buildVideoPlayer(model.videoLink!);*/
              } else {
                // Display image
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00FFFFFF),
                        Color(0x7F060606)

                        /*Colors.black.withOpacity(0.01),
                        Colors.black.withOpacity(0.30),
                        Colors.black.withOpacity(0.55)*/
                      ],
                    ).createShader(bounds);
                    //TODO: change black color to some other app color if required
                  },
                  blendMode: BlendMode.darken,
                  child: InkWell(
                    child: UiUtils.getImage(
                      images[index]!,
                      fit: BoxFit.cover,
                      height: 250.rh(context),
                    ),
                    onTap: () {
                      UiUtils.imageGallaryView(context,
                          images: images, initalIndex: index);
                    },
                  ),
                );
              }
            },
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  // Increase number of dots if videoLink is present
                  (index) => buildDot(index),
                ),
              ),
            ),
          ),
          if (widget.model.isFeature != null)
            if (widget.model.isFeature!)
              setTopRowItem(
                  alignment: AlignmentDirectional.topStart,
                  marginVal: 15,
                  cornerRadius: 5,
                  backgroundColor: context.color.territoryColor,
                  childWidget: Text("featured".translate(context))
                      .size(context.font.small)
                      .color(context.color.backgroundColor)),
          favouriteButton()
        ]),
      ),
    );
  }

/*  Widget buildYouTubePlayer(String videoLink) {
    // Implement YouTube video player widget here
    // Example:
    return YouTubePlayer(
        controller: // your controller,
      // other properties...
    );
  }

  Widget buildVideoPlayer(String videoLink) {
    // Implement normal video player widget here
    // Example:
    return VideoPlayer(
      // Your video player initialization code...
    );
  }*/

  Widget favouriteButton() {
    if (!isAddedByMe) {
      return BlocBuilder<FavoriteCubit, FavoriteState>(
        bloc: context.read<FavoriteCubit>(),
        builder: (context, favState) {
          bool isLike = context
              .select((FavoriteCubit cubit) => cubit.isItemFavorite(model.id!));

          return BlocConsumer<UpdateFavoriteCubit, UpdateFavoriteState>(
            bloc: context.read<UpdateFavoriteCubit>(),
            listener: (context, state) {
              if (state is UpdateFavoriteSuccess) {
                if (state.wasProcess) {
                  context.read<FavoriteCubit>().addFavoriteitem(state.item);
                } else {
                  context.read<FavoriteCubit>().removeFavoriteItem(state.item);
                }
              }
            },
            builder: (context, state) {
              return setTopRowItem(
                  alignment: AlignmentDirectional.topEnd,
                  marginVal: 10,
                  backgroundColor: context.color.backgroundColor,
                  cornerRadius: 30,
                  childWidget: InkWell(
                    onTap: () {
                      UiUtils.checkUser(
                          onNotGuest: () {
                            context.read<UpdateFavoriteCubit>().setFavoriteItem(
                                  item: model,
                                  type: isLike ? 0 : 1,
                                );
                          },
                          context: context);
                    },
                    child: state is UpdateFavoriteInProgress
                        ? UiUtils.progress(
                            height: 22,
                            width: 22,
                          )
                        : UiUtils.getSvg(
                            isLike ? AppIcons.like_fill : AppIcons.like,
                            color: context.color.territoryColor,
                            width: 22,
                            height: 22),
                  ));
            },
          );
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget setTopRowItem(
      {required AlignmentDirectional alignment,
      required double marginVal,
      required double cornerRadius,
      required Color backgroundColor,
      required Widget childWidget}) {
    return Align(
        alignment: alignment,
        child: Container(
            margin: EdgeInsets.all(marginVal),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cornerRadius),
                color: backgroundColor),
            child: childWidget)
        //TODO: swap icons according to liked and non-liked -- favorite_border_rounded and favorite_rounded
        );
  }

  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      width: currentPage == index ? 12.0 : 8.0,
      height: 8.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: currentPage == index ? Colors.white : Colors.grey),
    );
  }

//ImageView

  Widget setLikesAndViewsCount() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 1,
                          color:
                              context.color.textDefaultColor.withOpacity(0.1))),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  height: 46.rh(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UiUtils.getSvg(AppIcons.eye,
                          color: context.color.textDefaultColor),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(model.views != null ? model.views!.toString() : "0")
                          .color(
                              context.color.textDefaultColor.withOpacity(0.8))
                          .size(context.font.large)
                    ],
                  ))),
          SizedBox(width: 20.rw(context)),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 1,
                          color:
                              context.color.textDefaultColor.withOpacity(0.1))),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  height: 46.rh(context),
                  //alignment: AlignmentDirectional.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UiUtils.getSvg(AppIcons.like,
                          color: context.color.textDefaultColor),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(model.totalLikes == null
                              ? "0"
                              : model.totalLikes.toString())
                          .color(
                              context.color.textDefaultColor.withOpacity(0.8))
                          .size(context.font.large)
                    ],
                  ))),
        ],
      ),
    );
  }

  Widget setRejectedReason() {
    if (model.status == "rejected" &&
        (model.rejectedReason != null || model.rejectedReason != "")) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: context.color.textDefaultColor.withOpacity(0.1)),

          // Background color
        ),
        margin: const EdgeInsets.symmetric(vertical: 15),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
            //crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.report,
                size: 20,
                color: Colors.red, // Icon color can be adjusted
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  '${"rejection_reason".translate(context)}: ${model.rejectedReason}',
                )
                    .color(context.color.textDefaultColor)
                    .size(context.font.large),
              ),
            ]),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget setPriceAndStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text("${Constant.currencySymbol} ${model.price.toString()}")
              .size(context.font.larger)
              .color(context.color.territoryColor)
              .bold(),
        ),
        if (model.status != null && isAddedByMe)
          Container(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _getStatusColor(model.status),
            ),
            child: Text(
              _getStatusText(model.status)!,
            ).size(context.font.normal).color(
                  _getStatusTextColor(model.status),
                ),
          )

        //TODO: change color according to status - confirm,pending,etc..
      ],
    );
  }

  String? _getStatusText(String? status) {
    switch (status) {
      case "review":
        return "underReview".translate(context);
      case "active":
        return "active".translate(context);
      case "approved":
        return "approved".translate(context);
      case "inactive":
        return "deactivate".translate(context);
      case "sold out":
        return "soldOut".translate(context);
      case "rejected":
        return "rejected".translate(context);
      case "expired":
        return "expired".translate(context);
      default:
        return status;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "review":
        return pendingButtonColor.withOpacity(0.1);
      case "active" || "approved":
        return activateButtonColor.withOpacity(0.1);
      case "inactive":
        return deactivateButtonColor.withOpacity(0.1);
      case "sold out":
        return soldOutButtonColor.withOpacity(0.1);
      case "rejected":
        return deactivateButtonColor.withOpacity(0.1);
      case "expired":
        return deactivateButtonColor.withOpacity(0.1);
      default:
        return context.color.territoryColor.withOpacity(0.1);
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case "review":
        return pendingButtonColor;
      case "active" || "approved":
        return activateButtonColor;
      case "inactive":
        return deactivateButtonColor;
      case "sold out":
        return soldOutButtonColor;
      case "rejected":
        return deactivateButtonColor;
      case "expired":
        return deactivateButtonColor;
      default:
        return context.color.territoryColor;
    }
  }

  Widget setAddress({required bool isDate}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment:
            (isDate) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            AppIcons.location,
            colorFilter:
                ColorFilter.mode(context.color.territoryColor, BlendMode.srcIn),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 5.0),
              child: Text(model.address!)
                  .color(context.color.textDefaultColor.withOpacity(0.5)),
            ),
          ),
          (isDate)
              ? Expanded(
                  child: Text(model.created!.formatDate(format: "d MMM yyyy"))
                      .setMaxLines(lines: 1)
                      .color(context.color.textDefaultColor.withOpacity(0.5)))
              : const SizedBox.shrink()
          //TODO: add DATE from model
        ],
      ),
    );
  }

  Widget setDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("aboutThisItemLbl".translate(context)).bold().size(context
            .font.large), //TODO: replace label with your own - aboutThisPropLbl
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(model.description!)
              .color(context.color.textDefaultColor.withOpacity(0.5)),
        ),
      ],
    );
  }

  void _navigateToGoogleMapScreen(BuildContext context) {
    Navigator.push(
      context,
      BlurredRouter(
        barrierDismiss: true,
        builder: (context) {
          return GoogleMapScreen(
            item: model,
            kInitialPlace: _kInitialPlace,
            controller: _controller,
          );
        },
      ),
    );
  }

  Widget setLocation() {
    final LatLng currentPosition = LatLng(model.latitude!, model.longitude!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("locationLbl".translate(context)).bold().size(context.font.large),
        setAddress(isDate: false),
        SizedBox(
          height: 5,
        ),
        /*  ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 200.rh(context),
            child: GoogleMap(
              zoomControlsEnabled: false,
              zoomGesturesEnabled: false,
              onTap: (latLng) {
                _navigateToGoogleMapScreen(context);
              },
              initialCameraPosition:
                  CameraPosition(target: currentPosition, zoom: 13),
              mapType: MapType.normal,
              markers: {
                Marker(
                  markerId: MarkerId('currentPosition'),
                  position: currentPosition,
                  onTap: () {
                    // Navigate on marker tap
                    _navigateToGoogleMapScreen(context);
                  },
                )
              },
            ),
          ),
        ),*/
      ],
    );
  }

/*  Widget setLocation() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("locationLbl".translate(context)).bold().size(context.font.large),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Text("${"addressLbl".translate(context)} :")
            .color(context.color.textDefaultColor),
      ),
      setAddress(isDate: false),
      SizedBox(
        height: 5,
      ),
      InkWell(
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  "assets/map.png",
                  fit: BoxFit.cover,
                  height: 200.rh(context),
                ),
              ),
              Center(
                child: Icon(
                  Icons.location_on,
                  size: 40,
                  color: context
                      .color.territoryColor, // Change to your desired color
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              BlurredRouter(
                barrierDismiss: true,
                builder: (context) {
                  return GoogleMapScreen(
                      item: model,
                      kInitialPlace: _kInitialPlace,
                      controller: _controller);
                },
              ),
            );
          })
    ]);
  }*/

  Widget setReportAd() {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 500),
      crossFadeState: isShowReportAds
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: context.color.textDefaultColor.withOpacity(0.1)),

          // Background color
        ),
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.report,
                    size: 20,
                    color: Colors.red, // Icon color can be adjusted
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      "didYouFindAnyProblemWithThisItem".translate(context),
                      maxLines: 2,
                    )
                        .color(context.color.textDefaultColor)
                        .size(context.font.large),
                  ),
                ]),
            SizedBox(height: 15),
            BlocListener<ItemReportCubit, ItemReportState>(
              listener: (context, state) {
                if (state is ItemReportFailure) {
                  HelperUtils.showSnackBarMessage(
                      context, state.error.toString());
                }
                if (state is ItemReportInSuccess) {
                  HelperUtils.showSnackBarMessage(
                      context, state.responseMessage.toString());
                  context.read<UpdatedReportItemCubit>().addItem(model);
                }

                if (!Constant.isDemoModeOn)
                  setState(() {
                    isShowReportAds = false;
                  });
              },
              child: GestureDetector(
                onTap: () {
                  UiUtils.checkUser(
                      onNotGuest: () {
                        _bottomSheet(model.id!);
                      },
                      context: context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: context.color.territoryColor
                        .withOpacity(0.1), // Button color can be adjusted
                  ),
                  child: Text(
                    "reportThisAd".translate(context),
                  )
                      .color(context.color.territoryColor)
                      .size(context.font.normal),
                ),
              ),
            )
          ],
        ),
      ),
      secondChild: SizedBox.shrink(),
    );
  }

  void makeOfferBottomSheet(ItemModel model) async {
    await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        content: makeAnOffer(),
        onCancel: () {
          _makeAnOffermessageController.clear();
        },
        acceptButtonName: "send".translate(context),
        isAcceptContainesPush: true,
        onAccept: () => Future.value().then((_) {
          if (_offerFormKey.currentState!.validate()) {
            context.read<MakeAnOfferItemCubit>().makeAnOfferItem(
                id: widget.model.id!,
                from: "offer",
                amount:
                    double.parse(_makeAnOffermessageController.text.trim()));
            Navigator.pop(context);
            return;
          }
        }),
      ),
    );
    /* if (offer == true) {
      if (_offerFormKey.currentState!.validate()) {
        context.read<MakeAnOfferItemCubit>().makeAnOfferItem(widget.model.id!,
            int.parse(_makeAnOffermessageController.text.trim()));
      }
    }*/
    /*UiUtils.showBlurredDialoge(context,
        dialoge: EmptyDialogBox(
            child: AlertDialog(
          backgroundColor: context.color.secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: MakeAnOfferItemScreen(
            model: model,
          ),
        )));*/
  }

  Widget makeAnOffer() {
    double bottomPadding = (MediaQuery.of(context).viewInsets.bottom - 50);
    bool isBottomPaddingNagative = bottomPadding.isNegative;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Form(
          key: _offerFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("makeAnOffer".translate(context))
                  .size(context.font.larger)
                  .centerAlign()
                  .bold(),
              Divider(
                thickness: 1,
                color: context.color.borderColor.darken(30),
              ),
              const SizedBox(
                height: 15,
              ),
              RichText(
                text: TextSpan(
                  text: "sellerPrice".translate(context),
                  style: TextStyle(
                      color: context.color.textDefaultColor.withOpacity(0.5),
                      fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                      text: "\t${Constant.currencySymbol}${widget.model.price}",
                      style: TextStyle(
                          color: context.color.textDefaultColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                    bottom: isBottomPaddingNagative ? 0 : bottomPadding,
                    start: 20,
                    end: 20,
                    top: 18),
                child: TextFormField(
                  maxLines: null,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: context.color.textDefaultColor),
                  controller: _makeAnOffermessageController,
                  cursorColor: context.color.territoryColor,
                  //autovalidateMode: AutovalidateMode.always,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return Validator.nullCheckValidator(val,
                          context: context);
                    } else {
                      double parsedVal = double.parse(val);
                      if (parsedVal <= 0.0) {
                        return "valueMustBeGreaterThanZeroLbl"
                            .translate(context);
                      } else if (parsedVal > widget.model.price!) {
                        return "offerPriceWarning".translate(context);
                      }
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      fillColor: context.color.borderColor.darken(20),
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      hintText: "yourOffer".translate(context),
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color:
                              context.color.textDefaultColor.withOpacity(0.3)),
                      focusColor: context.color.territoryColor,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: context.color.borderColor.darken(60))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: context.color.borderColor.darken(60))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: context.color.territoryColor))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _bottomSheet(int itemId) async {
    await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
          title: "reportItem".translate(context),
          content: reportReason(),
          isAcceptContainesPush: true,
          onAccept: () => Future.value().then((_) {
                if (selectedId.isNegative) {
                  if (_formKey.currentState!.validate()) {
                    context.read<ItemReportCubit>().report(
                          item_id: model.id!,
                          reason_id: selectedId,
                          message: _reportmessageController.text,
                        );
                    Navigator.pop(context);
                    return;
                  }
                } else {
                  context.read<ItemReportCubit>().report(
                        item_id: model.id!,
                        reason_id: selectedId,
                      );
                  Navigator.pop(context);
                  return;
                }
              })),
    );
  }

  String formatPhoneNumber(String fullNumber, String countryCode) {
    // Normalize the country code (remove '+' if present)
    countryCode = countryCode.replaceAll('+', '');

    // Remove '+' from fullNumber if present
    fullNumber = fullNumber.replaceAll('+', '');

    // Check if the fullNumber already starts with the country code
    if (!fullNumber.startsWith(countryCode)) {
      // If not, prepend the country code
      fullNumber = countryCode + fullNumber;
    }

    // Add '+' to the beginning of the full number
    fullNumber = '+' + fullNumber;

    return fullNumber;
  }

  Widget setSellerDetails() {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(children: [
          SizedBox(
              height: 60.rh(context),
              width: 60.rw(context),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: model.user!.profile != null &&
                          model.user!.profile != ""
                      ? UiUtils.getImage(model.user!.profile!, fit: BoxFit.fill)
                      : UiUtils.getSvg(
                          AppIcons.defaultPersonLogo,
                          color: context.color.territoryColor,
                          fit: BoxFit.none,
                        ))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (model.user!.isVerified == 1)
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: context.color.forthColor),
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UiUtils.getSvg(AppIcons.verifiedIcon,
                                width: 14, height: 14),
                            /*Icon(
                              Icons.verified_user_rounded,
                              color: context.color.secondaryColor,
                              size: 14,
                            ),*/
                            SizedBox(
                              width: 4,
                            ),
                            Text("verifiedLbl".translate(context))
                                .color(context.color.secondaryColor)
                                .bold(weight: FontWeight.w500)
                          ],
                        ),
                      ),
                    Text(model.user!.name!).bold().size(context.font.large),
                    if (context.watch<FetchSellerRatingsCubit>().sellerData() !=
                        null)
                      if (context
                              .watch<FetchSellerRatingsCubit>()
                              .sellerData()!
                              .averageRating !=
                          null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(Icons.star_rounded,
                                      size: 17,
                                      color: context
                                          .color.textDefaultColor), // Star icon
                                ),
                                TextSpan(
                                  text:
                                      '\t${context.watch<FetchSellerRatingsCubit>().sellerData()!.averageRating!.toStringAsFixed(2).toString()}',
                                  // Rating value
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.color.textDefaultColor,
                                  ),
                                ),
                                TextSpan(
                                  text: '  |  ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.color.textDefaultColor
                                        .withOpacity(0.5),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '${context.watch<FetchSellerRatingsCubit>().totalSellerRatings()}\t${"ratings".translate(context)}',
                                  // Rating count text
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.color.textDefaultColor
                                        .withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    if (widget.model.user!.showPersonalDetails == 1)
                      if (model.user!.email != null || model.user!.email != "")
                        Text(model.user!.email!)
                            .color(context.color.textLightColor)
                            .size(context.font.small)
                  ]),
            ),
          ),
          if (widget.model.user!.showPersonalDetails == 1)
            if (model.user!.mobile != null || model.user!.mobile != "")
              setIconButtons(
                  assetName: AppIcons.message,
                  onTap: () {
                    HelperUtils.launchPathURL(
                        isTelephone: false,
                        isSMS: true,
                        isMail: false,
                        value: formatPhoneNumber(
                            model.user!.mobile!, Constant.defaultCountryCode),
                        context: context);
                  }),
          SizedBox(width: 10.rw(context)),
          if (widget.model.user!.showPersonalDetails == 1)
            if (model.user!.mobile != null || model.user!.mobile != "")
              setIconButtons(
                  assetName: AppIcons.call,
                  onTap: () {
                    HelperUtils.launchPathURL(
                        isTelephone: true,
                        isSMS: false,
                        isMail: false,
                        value: formatPhoneNumber(
                            model.user!.mobile!, Constant.defaultCountryCode),
                        context: context);
                  })
        ]),
      ),
      onTap: () {
        Navigator.pushNamed(context, Routes.sellerProfileScreen, arguments: {
          "model": model.user!,
          "total":
              context.read<FetchSellerRatingsCubit>().totalSellerRatings() ?? 0,
          "rating": context
                  .read<FetchSellerRatingsCubit>()
                  .sellerData()!
                  .averageRating ??
              null
        });
      },
    );
  }

  Widget setIconButtons({
    required String assetName,
    required void Function() onTap,
    Color? color,
    double? height,
    double? width,
  }) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.color.borderColor.darken(30))),
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: InkWell(
                onTap: onTap,
                child: SvgPicture.asset(
                  assetName,
                  colorFilter: color == null
                      ? ColorFilter.mode(
                          context.color.territoryColor, BlendMode.srcIn)
                      : ColorFilter.mode(color, BlendMode.srcIn),
                ))));
  }

  Widget reportReason() {
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom - 50;
    bool isBottomPaddingNegative = bottomPadding.isNegative;
    reasons = context.read<FetchItemReportReasonsListCubit>().getList() ?? [];

    if (reasons?.isEmpty ?? true) {
      selectedId = -10;
    } else {
      selectedId = reasons!.first.id;
    }
    setState(() {});
    return StatefulBuilder(builder: (context, setState) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: reasons?.length ?? 0,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          selectedId = reasons![index].id;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.color.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedId == reasons![index].id
                                ? context.color.territoryColor
                                : context.color.borderColor,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Text(
                            reasons![index].reason.firstUpperCase() ?? "",
                          ).color(
                            selectedId == reasons![index].id
                                ? context.color.territoryColor
                                : context.color.textColorDark,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (selectedId.isNegative)
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      bottom: isBottomPaddingNegative ? 0 : bottomPadding,
                      start: 0,
                      end: 0,
                    ),
                    child: TextFormField(
                      maxLines: null,
                      controller: _reportmessageController,
                      cursorColor: context.color.territoryColor,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "addReportReason".translate(context);
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "writeReasonHere".translate(context),
                        focusColor: context.color.territoryColor,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: context.color.territoryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                /*  const SizedBox(
                    height: 14,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MaterialButton(
                          height: 40,
                          minWidth: 104.rw(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: context.color.borderColor,
                              width: 1.5,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("cancelLbl".translate(context))
                              .color(context.color.territoryColor),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        MaterialButton(
                          height: 40,
                          minWidth: 104.rw(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          color: context.color.territoryColor,
                          onPressed: () async {
                            if (selectedId.isNegative) {
                              if (_formKey.currentState!.validate()) {
                                context.read<ItemReportCubit>().report(
                                      item_id: model.id!,
                                      reason_id: selectedId,
                                      message: _reportmessageController.text,
                                    );
                              }
                            } else {
                              context.read<ItemReportCubit>().report(
                                    item_id: model.id!,
                                    reason_id: selectedId,
                                  );
                              Navigator.pop(context);
                            }
                          },
                          child: Text("report".translate(context))
                              .color(context.color.buttonColor),
                        ),
                      ],
                    ),
                  )*/
              ],
            ),
          ),
        ),
      );
    });
  }
}
