import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:halo/providers/discover_provider.dart';
import 'package:halo/utils/constants.dart';
import 'package:halo/utils/theme.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _selectedCity;
  RangeValues _ageRange = const RangeValues(18, 50);

  @override
  void initState() {
    super.initState();
    final discover = context.read<DiscoverProvider>();
    _selectedCity = discover.cityFilter;
    _ageRange = RangeValues(
      (discover.minAgeFilter ?? 18).toDouble(),
      (discover.maxAgeFilter ?? 50).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCity = null;
                    _ageRange = const RangeValues(18, 50);
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // City filter
          const Text(
            'City',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: const InputDecoration(
              hintText: 'All cities',
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All cities')),
              ...AppConstants.sriLankanCities.map(
                (city) => DropdownMenuItem(value: city, child: Text(city)),
              ),
            ],
            onChanged: (value) => setState(() => _selectedCity = value),
          ),
          const SizedBox(height: 20),

          // Age range
          Text(
            'Age Range: ${_ageRange.start.toInt()} - ${_ageRange.end.toInt()}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          RangeSlider(
            values: _ageRange,
            min: 18,
            max: 60,
            divisions: 42,
            activeColor: AppTheme.primaryColor,
            labels: RangeLabels(
              _ageRange.start.toInt().toString(),
              _ageRange.end.toInt().toString(),
            ),
            onChanged: (values) => setState(() => _ageRange = values),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              context.read<DiscoverProvider>().setFilters(
                    city: _selectedCity,
                    minAge: _ageRange.start.toInt(),
                    maxAge: _ageRange.end.toInt(),
                  );
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
