import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../controllers/crop_planner_controller.dart';

class AddCropView extends StatefulWidget {
  final String farmId;

  const AddCropView({super.key, required this.farmId});

  @override
  State<AddCropView> createState() => _AddCropViewState();
}

class _AddCropViewState extends State<AddCropView> {
  final controller = Get.find<CropPlannerController>();

  final formKey = GlobalKey<FormState>();

  final cropNameController = TextEditingController();

  final areaController = TextEditingController();

  final varietyController = TextEditingController();

  final notesController = TextEditingController();

  String season = 'Kharif';
  String areaUnit = 'acres';

  DateTime? plannedDate;
  DateTime? plantingDate;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Add Crop')),

      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextFormField(
                controller: cropNameController,
                decoration: const InputDecoration(
                  labelText: 'Crop Name',
                  hintText: 'e.g. Paddy',
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Variety',
                  hintText: 'Optional',
                ),
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
                  hintText: 'Optional',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _saveCrop,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Crop'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCrop() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final success = await controller.createCrop(
      farmId: widget.farmId,
      cropName: cropNameController.text,
      season: season,
      area: double.parse(areaController.text.trim()),
      areaUnit: areaUnit,
      plannedDate: plannedDate,
      plantingDate: plantingDate,
      variety: varietyController.text,
      notes: notesController.text,
    );

    if (success && mounted) {
      context.pop();
    }
  }

  Future<DateTime?> _selectDate(BuildContext context) {
    return showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
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
