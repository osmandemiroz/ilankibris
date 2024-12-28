import 'package:flutter/material.dart';

class CurrencySelector extends StatefulWidget {
  final void Function(String)? onChanged;
  final List<String> currencies;
  final String? initialCurrency;
  final CurrencyController controller;
  const CurrencySelector({
    Key? key,
    this.onChanged,
    this.currencies = const ['€', '\$', '₺', '£'],
    this.initialCurrency,
    required this.controller,
  }) : super(key: key);

  @override
  State<CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> {
  late String selectedCurrency;

  @override
  void initState() {
    super.initState();
    selectedCurrency = widget.initialCurrency ?? widget.currencies.first;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: ValueListenableBuilder<String>(
                valueListenable: widget.controller.selectedCurrency,
                builder: (context, selectedCurrency, _) {
                  return DropdownButton<String>(
                    value: selectedCurrency,
                    items: widget.currencies.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? selectedCurrency) {
                      if (selectedCurrency != null) {
                        setState(() {
                          selectedCurrency = selectedCurrency;
                        });
                        if (widget.onChanged != null) {
                          widget.onChanged!(selectedCurrency!);
                        }
                      }
                    },
                  );
                }),
          ),
        ),
      ),
    );
  }
}

class CurrencyController {
  final ValueNotifier<String> selectedCurrency = ValueNotifier<String>('€');
}
