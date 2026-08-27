import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../controllers/crop_planner_controller.dart';
import '../models/crop_model.dart';

class EditCropView extends StatefulWidget {
  final String farmId;
  final String cropId;

  const EditCropView({super.key, required this.farmId, required this.cropId});

  @override
  State<EditCropView> createState() => _EditCropViewState();
}

class _EditCropViewState extends State<EditCropView> {
  late final CropPlannerController controller;

  final formKey = GlobalKey<FormState>();

  late final TextEditingController cropNameController;
  late final TextEditingController areaController;
  late final TextEditingController varietyController;
  late final TextEditingController notesController;

  late String season;
  late String areaUnit;

  DateTime? plannedDate;
  DateTime? plantingDate;

  CropModel? crop;

  @override
  void initState() {
    super.initState();

    controller = Get.find<CropPlannerController>();

    crop = controller.selectedCrop.value;

    if (crop != null) {
      cropNameController = TextEditingController(text: crop!.cropName);

      areaController = TextEditingController(text: crop!.area.toString());

      varietyController = TextEditingController(text: crop!.variety ?? '');

      notesController = TextEditingController(text: crop!.notes ?? '');

      season = crop!.season;
      areaUnit = crop!.areaUnit;

      plannedDate = crop!.plannedDate;
      plantingDate = crop!.plantingDate;
    } else {
      cropNameController = TextEditingController();

      areaController = TextEditingController();

      varietyController = TextEditingController();

      notesController = TextEditingController();

      season = 'Kharif';
      areaUnit = 'acres';
    }
  }

  @override
  void dispose() {
    cropNameController.dispose();
    areaController.dispose();
    varietyController.dispose();
    notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (crop == null) {
      return const Scaffold(body: Center(child: Text('Crop not found')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Crop')),

      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextFormField(
                controller: cropNameController,
                decoration: const InputDecoration(labelText: 'Crop Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter crop name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: season,
                decoration: const InputDecoration(labelText: 'Season'),
                items: const [
                  DropdownMenuItem(value: 'Kharif', child: Text('Kharif')),
                  DropdownMenuItem(value: 'Rabi', child: Text('Rabi')),
                  DropdownMenuItem(value: 'Zaid', child: Text('Zaid')),
                  DropdownMenuItem(
                    value: 'Year-round',
                    child: Text('Year-round'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      season = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: areaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Crop Area'),
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
                controller: varietyController,
                decoration: const InputDecoration(labelText: 'Variety'),
              ),

              const SizedBox(height: 20),

              _DateField(
                label: 'Planned Date',
                date: plannedDate,
                onTap: () async {
                  final date = await _selectDate(context);

                  if (date != null) {
                    setState(() {
                      plannedDate = date;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              _DateField(
                label: 'Planting Date',
                date: plantingDate,
                onTap: () async {
                  final date = await _selectDate(context);

                  if (date != null) {
                    setState(() {
                      plantingDate = date;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _saveChanges,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
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

  Future<void> _saveChanges() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final updatedCrop = CropModel(
      id: crop!.id,
      farmId: crop!.farmId,
      cropName: cropNameController.text,
      season: season,
      area: double.parse(areaController.text.trim()),
      areaUnit: areaUnit,
      plannedDate: plannedDate,
      plantingDate: plantingDate,
      variety: varietyController.text,
      notes: notesController.text,
      createdAt: crop!.createdAt,
      updatedAt: DateTime.now(),
    );

    final success = await controller.updateCrop(crop: updatedCrop);

    if (success && mounted) {
      context.pop();
    }
  }

  Future<DateTime?> _selectDate(BuildContext context) {
    return showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: plannedDate ?? plantingDate ?? DateTime.now(),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          date == null
              ? 'Select date'
              : '${date!.day}/'
                    '${date!.month}/'
                    '${date!.year}',
        ),
      ),
    );
  }
}
