import 'package:flutter/material.dart';
import '../models/district_model.dart';
import '../services/district_service.dart';

class DistrictWardPicker extends StatefulWidget {
  final String? initialDistrict;
  final String? initialWard;
  final void Function(String district, String ward) onChanged;

  const DistrictWardPicker({
    Key? key,
    this.initialDistrict,
    this.initialWard,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<DistrictWardPicker> createState() => _DistrictWardPickerState();
}

class _DistrictWardPickerState extends State<DistrictWardPicker> {
  List<District> _districts = [];
  District? _selectedDistrict;
  Ward? _selectedWard;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    final districts = await DistrictService.loadDistricts();
    setState(() {
      _districts = districts;
      // Set initial values if provided
      if (widget.initialDistrict != null) {
        _selectedDistrict = _districts.firstWhere(
          (d) => d.name == widget.initialDistrict,
          orElse: () => _districts.first,
        );
        if (widget.initialWard != null && _selectedDistrict != null) {
          _selectedWard = _selectedDistrict!.wards.firstWhere(
            (w) => w.name == widget.initialWard,
            orElse: () => _selectedDistrict!.wards.first,
          );
        }
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        // District Dropdown
        DropdownButtonFormField<District>(
          value: _selectedDistrict,
          decoration: const InputDecoration(
            labelText: 'Quận/Huyện *',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true, // 🔧 FIX: Ensure full width usage
          items: _districts
              .map((d) => DropdownMenuItem(
                    value: d,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        d.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (district) {
            setState(() {
              _selectedDistrict = district;
              _selectedWard = null;
            });
            if (district != null) {
              widget.onChanged(district.name, '');
            }
          },
          validator: (value) => value == null ? 'Vui lòng chọn quận/huyện' : null,
        ),
        const SizedBox(height: 16),
        
        // Ward/Commune Dropdown
        DropdownButtonFormField<Ward>(
          value: _selectedWard,
          decoration: const InputDecoration(
            labelText: 'Phường/Xã *',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true, // 🔧 FIX: Ensure full width usage
          items: (_selectedDistrict?.wards ?? [])
              .map((w) => DropdownMenuItem(
                    value: w,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        w.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (ward) {
            setState(() {
              _selectedWard = ward;
            });
            if (_selectedDistrict != null && ward != null) {
              widget.onChanged(_selectedDistrict!.name, ward.name);
            }
          },
          validator: (value) => value == null ? 'Vui lòng chọn phường/xã' : null,
        ),
      ],
    );
  }
} 