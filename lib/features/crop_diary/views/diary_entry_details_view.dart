import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:khetiq/app/app_routes.dart';

import '../controllers/crop_diary_controller.dart';

class DiaryEntryDetailsView extends StatefulWidget {
  final String farmId;
  final String cropId;
  final String entryId;

  const DiaryEntryDetailsView({
    super.key,
    required this.farmId,
    required this.cropId,
    required this.entryId,
  });

  @override
  State<DiaryEntryDetailsView> createState() =>
      _DiaryEntryDetailsViewState();
}

class _DiaryEntryDetailsViewState
    extends State<DiaryEntryDetailsView> {
  late final CropDiaryController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.find<CropDiaryController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadEntry(
        farmId: widget.farmId,
        cropId: widget.cropId,
        entryId: widget.entryId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Entry'),
        actions: [
          Obx(() {
            if (controller.selectedEntry.value == null) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push(
                  '${AppRoutes.editDiaryEntry}/'
                  '${widget.farmId}/'
                  '${widget.cropId}/'
                  '${widget.entryId}',
                );
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EntryTypeIcon(type: entry.type),

              const SizedBox(height: 24),

              Text(
                entry.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _formatDate(entry.date),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.category_outlined),
                    const SizedBox(width: 12),
                    Text(
                      _formatType(entry.type),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                entry.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Entry'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Entry?'),
          content: const Text(
            'This diary entry will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final success = await controller.deleteEntry(
      farmId: widget.farmId,
      cropId: widget.cropId,
      entryId: widget.entryId,
    );

    if (!mounted) return;

    if (success) {
      context.pop();
    }
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

class _EntryTypeIcon extends StatelessWidget {
  final String type;

  const _EntryTypeIcon({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (type) {
      case 'sowing':
        icon = Icons.grass;
        break;

      case 'irrigation':
        icon = Icons.water_drop_outlined;
        break;

      case 'fertilizer':
        icon = Icons.science_outlined;
        break;

      case 'pesticide':
        icon = Icons.sanitizer_outlined;
        break;

      case 'pest':
        icon = Icons.bug_report_outlined;
        break;

      case 'disease':
        icon = Icons.coronavirus_outlined;
        break;

      case 'harvesting':
        icon = Icons.agriculture;
        break;

      case 'observation':
        icon = Icons.visibility_outlined;
        break;

      default:
        icon = Icons.note_outlined;
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context)
            .colorScheme
            .primaryContainer,
      ),
      child: Icon(
        icon,
        size: 36,
      ),
    );
  }
}