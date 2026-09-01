import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../controllers/farm_controller.dart';

class EditFarmView extends StatefulWidget {
  final String farmId;

  const EditFarmView({super.key, required this.farmId});

  @override
  State<EditFarmView> createState() => _EditFarmViewState();
}

class _EditFarmViewState extends State<EditFarmView> {
  final controller = Get.find<FarmController>();

  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController areaController;
  late final TextEditingController villageController;
  late final TextEditingController districtController;
  late final TextEditingController stateController;

  late String areaUnit;
  String? selectedState;
  String? selectedDistrict;
  String? selectedVillage;

  @override
  void initState() {
    super.initState();

    final farm = controller.farms.firstWhere(
      (farm) => farm.id == widget.farmId,
    );

    nameController = TextEditingController(text: farm.name);

    areaController = TextEditingController(text: farm.area.toString());

    villageController = TextEditingController(text: farm.village);

    districtController = TextEditingController(text: farm.district);

    stateController = TextEditingController(text: farm.state);

    areaUnit = farm.areaUnit;
    selectedState = farm.state.isNotEmpty ? farm.state : null;
    selectedDistrict = farm.district.isNotEmpty ? farm.district : null;
    selectedVillage = farm.village.isNotEmpty ? farm.village : null;
  }

  @override
  void dispose() {
    nameController.dispose();
    areaController.dispose();
    villageController.dispose();
    districtController.dispose();
    stateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Farm')),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Farm Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter farm name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: areaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Farm Area'),
                validator: (value) {
                  final area = double.tryParse(value?.trim() ?? '');

                  if (area == null || area <= 0) {
                    return 'Enter valid area';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: areaUnit,
                decoration: const InputDecoration(labelText: 'Area Unit'),
                items: const [
                  DropdownMenuItem(value: 'acres', child: Text('Acres')),
                  DropdownMenuItem(value: 'hectares', child: Text('Hectares')),
                  DropdownMenuItem(value: 'cents', child: Text('Cents')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      areaUnit = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedState,
                key: ValueKey('state-$selectedState'),
                decoration: const InputDecoration(
                  labelText: 'State',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                items: () {
                  final states = locationData.keys.toList();
                  if (selectedState != null && selectedState!.isNotEmpty && !states.contains(selectedState)) {
                    states.add(selectedState!);
                  }
                  return states.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList();
                }(),
                onChanged: (value) {
                  setState(() {
                    selectedState = value;
                    selectedDistrict = null;
                    selectedVillage = null;
                    stateController.text = value ?? '';
                    districtController.text = '';
                    villageController.text = '';
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Select state';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedDistrict,
                key: ValueKey('district-$selectedState-$selectedDistrict'),
                disabledHint: const Text('Select a state first'),
                decoration: const InputDecoration(
                  labelText: 'District',
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: () {
                  if (selectedState == null) return <DropdownMenuItem<String>>[];
                  final districts = locationData[selectedState]?.keys.toList() ?? <String>[];
                  if (selectedDistrict != null && selectedDistrict!.isNotEmpty && !districts.contains(selectedDistrict)) {
                    districts.add(selectedDistrict!);
                  }
                  return districts.map((district) => DropdownMenuItem(value: district, child: Text(district))).toList();
                }(),
                onChanged: selectedState == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedDistrict = value;
                          selectedVillage = null;
                          districtController.text = value ?? '';
                          villageController.text = '';
                        });
                      },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Select district';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedVillage,
                key: ValueKey('village-$selectedState-$selectedDistrict-$selectedVillage'),
                disabledHint: const Text('Select a district first'),
                decoration: const InputDecoration(
                  labelText: 'Village',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                items: () {
                  if (selectedState == null || selectedDistrict == null) return <DropdownMenuItem<String>>[];
                  final villages = locationData[selectedState]?[selectedDistrict]?.toList() ?? <String>[];
                  if (selectedVillage != null && selectedVillage!.isNotEmpty && !villages.contains(selectedVillage)) {
                    villages.add(selectedVillage!);
                  }
                  return villages.map((village) => DropdownMenuItem(value: village, child: Text(village))).toList();
                }(),
                onChanged: selectedDistrict == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedVillage = value;
                          villageController.text = value ?? '';
                        });
                      },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Select village';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            final success = await controller.updateFarm(
                              id: widget.farmId,
                              name: nameController.text,
                              area: double.parse(areaController.text.trim()),
                              areaUnit: areaUnit,
                              village: villageController.text,
                              district: districtController.text,
                              state: stateController.text,
                            );

                            if (success && context.mounted) {
                              context.pop();
                            }
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
