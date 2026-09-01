import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/crop_diary_controller.dart';

class AddDiaryEntryView extends StatefulWidget {
  final String farmId;
  final String cropId;

  const AddDiaryEntryView({
    super.key,
    required this.farmId,
    required this.cropId,
  });

  @override
  State<AddDiaryEntryView> createState() => _AddDiaryEntryViewState();
}

class _AddDiaryEntryViewState extends State<AddDiaryEntryView> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedType = 'observation';
  DateTime selectedDate = DateTime.now();

  late final CropDiaryController controller;

  final List<String> entryTypes = [
    'sowing',
    'irrigation',
    'fertilizer',
    'pesticide',
    'pest',
    'disease',
    'harvesting',
    'observation',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<CropDiaryController>();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final success = await controller.createEntry(
      farmId: widget.farmId,
      cropId: widget.cropId,
      title: titleController.text,
      description: descriptionController.text,
      type: selectedType,
      date: selectedDate,
    );

    if (success && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Diary Entry'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Fertilizer Applied',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a title';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Entry Type',
                border: OutlineInputBorder(),
              ),
              items: entryTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(_formatType(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe what happened...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a description';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(selectedDate),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : _saveEntry,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Entry'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatType(String type) {
    return type
        .split('_')
        .map(
          (word) =>
              word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}