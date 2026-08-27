import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
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

                TextFormField(
                  controller: villageController,
                  decoration: const InputDecoration(
                    labelText: 'Village',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter village';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: districtController,
                  decoration: const InputDecoration(
                    labelText: 'District',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter district';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter state';
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
