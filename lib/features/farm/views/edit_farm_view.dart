import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

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

              TextFormField(
                controller: villageController,
                decoration: const InputDecoration(labelText: 'Village'),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: districtController,
                decoration: const InputDecoration(labelText: 'District'),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: stateController,
                decoration: const InputDecoration(labelText: 'State'),
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
