import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/farm_controller.dart';

class FarmSetupView extends GetView<FarmController> {
  FarmSetupView({super.key});

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final areaController = TextEditingController();
  final villageController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();

  final selectedAreaUnit = 'acres'.obs;
  final selectedState = Rxn<String>();
  final selectedDistrict = Rxn<String>();
  final selectedVillage = Rxn<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up Your Farm')),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tell us about your farm',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'This information will help KhetIQ personalize your farming experience.',
                ),

                const SizedBox(height: 32),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Farm Name',
                    hintText: 'Example: My Farm',
                    prefixIcon: Icon(Icons.agriculture),
                  ),
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
                  decoration: const InputDecoration(
                    labelText: 'Farm Area',
                    hintText: 'Example: 5',
                    prefixIcon: Icon(Icons.square_foot),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter farm area';
                    }

                    final area = double.tryParse(value.trim());

                    if (area == null || area <= 0) {
                      return 'Enter a valid area';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: selectedAreaUnit.value,
                    decoration: const InputDecoration(
                      labelText: 'Area Unit',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'acres', child: Text('Acres')),
                      DropdownMenuItem(
                        value: 'hectares',
                        child: Text('Hectares'),
                      ),
                      DropdownMenuItem(value: 'cents', child: Text('Cents')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        selectedAreaUnit.value = value;
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20),

                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: selectedState.value,
                    key: ValueKey('state-${selectedState.value}'),
                    decoration: const InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                    items: locationData.keys.map((state) {
                      return DropdownMenuItem(value: state, child: Text(state));
                    }).toList(),
                    onChanged: (value) {
                      selectedState.value = value;
                      selectedDistrict.value = null;
                      selectedVillage.value = null;
                      stateController.text = value ?? '';
                      districtController.text = '';
                      villageController.text = '';
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Select state';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                Obx(
                  () {
                    final state = selectedState.value;
                    final districts = state != null ? locationData[state]?.keys.toList() ?? [] : <String>[];
                    return DropdownButtonFormField<String>(
                      initialValue: selectedDistrict.value,
                      key: ValueKey('district-${selectedState.value}-${selectedDistrict.value}'),
                      disabledHint: const Text('Select a state first'),
                      decoration: const InputDecoration(
                        labelText: 'District',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      items: districts.map((district) {
                        return DropdownMenuItem(value: district, child: Text(district));
                      }).toList(),
                      onChanged: state == null
                          ? null
                          : (value) {
                              selectedDistrict.value = value;
                              selectedVillage.value = null;
                              districtController.text = value ?? '';
                              villageController.text = '';
                            },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Select district';
                        }
                        return null;
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                Obx(
                  () {
                    final state = selectedState.value;
                    final district = selectedDistrict.value;
                    List<String> villages = [];
                    if (state != null && district != null) {
                      final districtsMap = locationData[state];
                      if (districtsMap != null) {
                        villages = districtsMap[district] ?? [];
                      }
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: selectedVillage.value,
                      key: ValueKey('village-${selectedState.value}-${selectedDistrict.value}-${selectedVillage.value}'),
                      disabledHint: const Text('Select a district first'),
                      decoration: const InputDecoration(
                        labelText: 'Village',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: villages.map((village) {
                        return DropdownMenuItem(value: village, child: Text(village));
                      }).toList(),
                      onChanged: district == null
                          ? null
                          : (value) {
                              selectedVillage.value = value;
                              villageController.text = value ?? '';
                            },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Select village';
                        }
                        return null;
                      },
                    );
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

                              final area = double.parse(
                                areaController.text.trim(),
                              );

                              final success = await controller.createFarm(
                                name: nameController.text,
                                area: area,
                                areaUnit: selectedAreaUnit.value,
                                village: villageController.text,
                                district: districtController.text,
                                state: stateController.text,
                              );

                              if (success && context.mounted) {
                                context.go(AppRoutes.myFarm);
                              }
                            },
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Continue'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
