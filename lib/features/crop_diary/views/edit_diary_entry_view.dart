import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/crop_diary_controller.dart';

class EditDiaryEntryView extends StatefulWidget {
  final String farmId;
  final String cropId;
  final String entryId;

  const EditDiaryEntryView({
    super.key,
    required this.farmId,
    required this.cropId,
    required this.entryId,
  });

  @override
  State<EditDiaryEntryView> createState() => _EditDiaryEntryViewState();
}

class _EditDiaryEntryViewState extends State<EditDiaryEntryView> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedType = 'observation';
  DateTime selectedDate = DateTime.now();

  late final CropDiaryController controller;

  bool _formLoaded = false;

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

    controller.loadEntry(
      farmId: widget.farmId,
      cropId: widget.cropId,
      entryId: widget.entryId,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _loadFormData() {
    final entry = controller.selectedEntry.value;

    if (entry == null || _formLoaded) {
      return;
    }

    titleController.text = entry.title;
    descriptionController.text = entry.description;

    selectedType = entry.type;
    selectedDate = entry.date;

    _formLoaded = true;
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

  Future<void> _updateEntry() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final success = await controller.updateEntry(
      farmId: widget.farmId,
      cropId: widget.cropId,
      entryId: widget.entryId,
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
        title: const Text('Edit Diary Entry'),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.selectedEntry.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final entry = controller.selectedEntry.value;

        if (entry == null) {
          return const Center(
            child: Text('Diary entry not found'),
          );
        }

        _loadFormData();

        return Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Title',
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
                value: entryTypes.contains(selectedType)
                    ? selectedType
                    : 'other',
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
                onChanged: controller.isLoading.value
                    ? null
                    : (value) {
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
                onTap: controller.isLoading.value
                    ? null
                    : _selectDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDate(selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : _updateEntry,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Update Entry'),
                ),
              ),
            ],
          ),
        );
      }),
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