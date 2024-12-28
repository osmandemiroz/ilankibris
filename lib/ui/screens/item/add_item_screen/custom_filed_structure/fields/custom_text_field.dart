import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/responsiveSize.dart';
import 'package:flutter/material.dart';

import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/ui/screens/widgets/dynamic_field/dynamic_field.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';

class CustomFieldText extends CustomField {
  @override
  String type = "textbox";
  String initialValue = "";

  @override
  void init() {
    //
    if (parameters['isEdit'] == true) {
      if (parameters['value'] != null) {
        if ((parameters['value'] as List).isNotEmpty) {
          initialValue = parameters['value'][0].toString();
          update(() {});
        }
      }
    }
    super.init();
  }

  @override
  Widget render() {
    return Column(
      children: [
        SizedBox(
          height: 10.rh(context),
        ),
        Row(
          children: [
            Text(parameters['name'])
                .size(context.font.large)
                .bold(weight: FontWeight.w500)
                .color(context.color.textColorDark)
          ],
        ),
        SizedBox(
          height: 14.rh(context),
        ),
        CustomTextFieldDynamic(
          action: TextInputAction.newline,
          initController: parameters['value'] != null ? true : false,
          value: initialValue,
          hintText: "",
          //"writeSomething".translate(context),
          required: parameters['required'] == 1 ? true : false,
          id: parameters['id'],
          maxLen: parameters['max_length'],
          maxLine: 3,
          minLen: parameters['min_length'],
          validator: CustomTextFieldValidator.minAndMixLen,
          keyboardType: TextInputType.multiline,
          capitalization: TextCapitalization.sentences,
        )
      ],
    );
  }
}
