import 'dart:convert';
import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/item/manage_item_cubit.dart';
import 'package:eClassify/data/helper/widgets.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/select_category.dart';
import 'package:eClassify/ui/screens/item/my_item_tab_screen.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/responsiveSize.dart';
import 'package:eClassify/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:eClassify/data/model/custom_field/custom_field_model.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:flutter/material.dart';
import 'package:eClassify/utils/cloudState/cloud_state.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/ui/screens/widgets/dynamic_field/dynamic_field.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddMoreDetailsScreen extends StatefulWidget {
  final bool? isEdit;
  final File? mainImage;
  final List<File>? otherImage;

  const AddMoreDetailsScreen({
    super.key,
    this.isEdit,
    this.mainImage,
    this.otherImage,
  });

  static BlurredRouter route(RouteSettings settings) {
    Map? args = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: (args?['context'] as BuildContext)
                  .read<FetchCustomFieldsCubit>(),
            ),
            BlocProvider<ManageItemCubit>(
              create: (context) => ManageItemCubit(),
            ),
          ],
          child: AddMoreDetailsScreen(
            isEdit: args?['isEdit'],
            mainImage: args?['mainImage'],
            otherImage: args?['otherImage'],
          ),
        );
      },
    );
  }

  @override
  CloudState<AddMoreDetailsScreen> createState() =>
      _AddMoreDetailsScreenState();
}

class _AddMoreDetailsScreenState extends CloudState<AddMoreDetailsScreen> {
  List<CustomFieldBuilder> moreDetailDynamicFields = [];
  final _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      moreDetailDynamicFields =
          context.read<FetchCustomFieldsCubit>().getFields().map((field) {
        Map<String, dynamic> fieldData = field.toMap();

        if (widget.isEdit == true) {
          ItemModel item = getCloudData('edit_request') as ItemModel;
          CustomFieldModel? matchingField =
              item.customFields!.any((e) => e.id == field.id)
                  ? item.customFields?.firstWhere((e) => e.id == field.id)
                  : null;
          if (matchingField != null) {
            fieldData['value'] = matchingField.value;
          }
        }

        fieldData['isEdit'] = widget.isEdit == true;
        CustomFieldBuilder customFieldBuilder = CustomFieldBuilder(fieldData);
        customFieldBuilder.stateUpdater(setState);
        customFieldBuilder.init();
        return customFieldBuilder;
      }).toList();

      setState(() {});
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      FocusScope.of(context).unfocus();
    }
  }

  void _handlePostNow() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      Map<String, dynamic> itemData = getCloudData("item_details");

      itemData['custom_fields'] = json.encode(AbstractField.fieldsData);
      itemData.addAll(AbstractField.files);
      addCloudData("with_more_details", itemData);

      context.read<ManageItemCubit>().manage(
            widget.isEdit == true ? ManageItemType.edit : ManageItemType.add,
            itemData,
            widget.mainImage,
            widget.otherImage,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: UiUtils.buildAppBar(context,
            showBackButton: true, title: "AdDetails".translate(context)),
        bottomNavigationBar: Container(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: UiUtils.buildButton(
              context,
              onPressed: _handlePostNow,
              height: 48.rh(context),
              fontSize: context.font.large,
              buttonTitle: "postNow".translate(context),
            ),
          ),
        ),
        body: BlocListener<ManageItemCubit, ManageItemState>(
          listener: (context, state) {
            if (state is ManageItemInProgress) {
              Widgets.showLoader(context);
            } else if (state is ManageItemSuccess) {
              Widgets.hideLoder(context);
              if (widget.isEdit == true) {
                myAdsCubitReference[getCloudData("edit_from")]
                    ?.edit(state.model);
              }
              Navigator.pushNamed(
                context,
                Routes.successItemScreen,
                arguments: {'model': state.model, 'isEdit': widget.isEdit},
              );
            } else if (state is ManageItemFail) {
              Widgets.hideLoder(context);
              HelperUtils.showSnackBarMessage(context, state.error);
            }
          },
          child: BlocBuilder<FetchCustomFieldsCubit, FetchCustomFieldState>(
            builder: (context, state) {
              if (state is FetchCustomFieldFail) {
                return Center(child: Text(state.error.toString()));
              }

              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("giveMoreDetailsAboutYourAds".translate(context))
                            .size(context.font.large)
                            .bold(weight: FontWeight.w600),
                        ...moreDetailDynamicFields.map(
                          (field) {
                            field.stateUpdater(setState);
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 9.0),
                              child: field.build(context),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
