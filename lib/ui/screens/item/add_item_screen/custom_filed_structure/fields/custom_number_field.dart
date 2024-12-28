import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/ui/screens/widgets/dynamic_field/dynamic_field.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';

class CustomNumberField extends CustomField {
  @override
  String type = "number";
  String initialValue = "";

  @override
  void init() {
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
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: Column(
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
              initController: parameters['value'] != null ? true : false,
              value: initialValue,
              validator: CustomTextFieldValidator.minAndMixLen,
              maxLen: parameters['max_length'],
              minLen: parameters['min_length'],
              hintText: "",
              //"addNumerical".translate(context),
              formaters: [
                FilteringTextInputFormatter.allow(
                  RegExp("[0-9]"),
                ),
              ],
              action: TextInputAction.next,
              keyboardType: TextInputType.number,
              required: parameters['required'] == 1 ? true : false,
              id: parameters['id'],
            ),
          ],
        ));
  }
}
