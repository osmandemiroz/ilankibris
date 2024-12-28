import 'package:flutter/material.dart';

class SelectionWidget extends StatefulWidget {
  final SelectionController controller;

  const SelectionWidget({
    super.key,
    required this.controller,
  });

  @override
  _SelectionWidgetState createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<SelectionWidget> {
  final List<String> states = [
    'Girne',
    'Lefkoşa',
    'Mağusa',
    'Güzelyurt',
    'İskele'
  ];
  final Map<String, List<String>> cities = {
    'Girne': ['Alsancak', 'Çatalköy', 'Lapta'],
    'Lefkoşa': ['Küçükkaymaklı', 'Haspolat', 'Gönyeli'],
    'Mağusa': ['Gazimağusa', 'Yeniboğaziçi', 'Geçitkale'],
    'Güzelyurt': ['Bostancı', 'Zümrütköy', 'Yuvacık'],
    'İskele': ['Bafra', 'Boğaz', 'Kumyalı'],
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<String?>(
          valueListenable: widget.controller.selectedState,
          builder: (context, selectedState, _) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.42,
              height: MediaQuery.of(context).size.height * 0.07,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Bir eyalet seçin',
                  border: OutlineInputBorder(),
                ),
                value: selectedState,
                items: states.map((state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (value) {
                  widget.controller.selectedState.value = value;
                  widget.controller.selectedCity.value = null;
                },
              ),
            );
          },
        ),
        SizedBox(height: 16.0),
        ValueListenableBuilder<String?>(
          valueListenable: widget.controller.selectedCity,
          builder: (context, selectedCity, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: widget.controller.selectedState,
              builder: (context, selectedState, _) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.42,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Bir şehir seçin',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCity,
                    items: (selectedState != null ? cities[selectedState]! : [])
                        .map((city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (value) {
                      widget.controller.selectedCity.value = value;
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class SelectionController {
  final ValueNotifier<String?> selectedState = ValueNotifier<String?>(null);
  final ValueNotifier<String?> selectedCity = ValueNotifier<String?>(null);
}
