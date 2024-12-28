import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/ui/screens/widgets/dynamic_field/dynamic_field.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';

class CustomFieldDropdown extends CustomField {
  @override
  String type = "dropdown";
  String? selected;

  @override
  void init() {
    if (parameters['isEdit'] == true) {
      if (parameters['value'] != null) {
        if ((parameters['value'] as List).isNotEmpty) {
          selected = parameters['value'][0].toString();
        }
      }
    } else {
      /* selected = parameters['values'][0];
      AbstractField.fieldsData.addAll({
        parameters['id'].toString(): [selected],
      });*/

      selected = ""; // Ensure selected is null initially
      // Ensure blank option is included in the values
      /* if (!(parameters['values'] as List).contains("")) {
        (parameters['values'] as List).insert(0, "");
      }*/
    }

    update(() {});
    super.init();
  }

  @override
  Widget render() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.rh(context),
        ),
        Row(
          children: [
            Text(
              parameters['name'],
            )
                .size(
                  context.font.large,
                )
                .bold(weight: FontWeight.w500)
                .color(
                  context.color.textColorDark,
                )
          ],
        ),
        SizedBox(
          height: 14.rh(context),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
          ),
          child: Container(
            decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(
                  10,
                ),
                border: Border.all(
                  width: 1,
                  color: context.color.borderColor.darken(30),
                )),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField(
                  hint: Text(
                    "— Seçiniz —",
                    style: TextStyle(
                      color: context.color.textDefaultColor.withOpacity(0.5),
                      fontSize: context.font.large,
                    ),
                  ),
                  validator: (value) {
                    if (parameters['required'] == 1 &&
                        (selected == "" || selected == null)) {
                      return "This field is required"; // Return validation message if not selected
                    }
                    return null;
                  },

                  value: selected?.isEmpty == true ? null : selected,
                  dropdownColor: context.color.secondaryColor,
                  isExpanded: true,
                  //padding: const EdgeInsets.symmetric(vertical: 5),
                  icon: SvgPicture.asset(
                    AppIcons.downArrow,
                    colorFilter: ColorFilter.mode(
                        context.color.textDefaultColor, BlendMode.srcIn),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  //underline: SizedBox.shrink(),
                  isDense: true,
                  borderRadius: BorderRadius.circular(10),
                  style: TextStyle(
                    color: context.color.textDefaultColor.withOpacity(0.5),
                    fontSize: context.font.large,
                  ),
                  items: (parameters['values'] as List<dynamic>)
                      .map<DropdownMenuItem<dynamic>>((dynamic e) {
                    return DropdownMenuItem<dynamic>(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (v) {
                    selected = v.toString();
                    update(() {});
                    AbstractField.fieldsData.addAll({
                      parameters['id'].toString(): [selected],
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
