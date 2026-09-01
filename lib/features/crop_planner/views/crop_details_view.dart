import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:khetiq/app/app_routes.dart';

import '../controllers/crop_planner_controller.dart';

class CropDetailsView extends StatefulWidget {
  final String farmId;
  final String cropId;

  const CropDetailsView({
    super.key,
    required this.farmId,
    required this.cropId,
  });

  @override
  State<CropDetailsView> createState() => _CropDetailsViewState();
}

class _CropDetailsViewState extends State<CropDetailsView> {
  late final CropPlannerController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.find<CropPlannerController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCrop(farmId: widget.farmId, cropId: widget.cropId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Details'),
        actions: [
          Obx(() {
            final crop = controller.selectedCrop.value;

            if (crop == null) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push(
                  '${AppRoutes.editCrop}/'
                  '${widget.farmId}/'
                  '${crop.id}',
                );
              },
            );
          }),

          Obx(() {
            final crop = controller.selectedCrop.value;

            if (crop == null) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showDeleteDialog(context, crop.id);
              },
            );
          }),
        ],
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final crop = controller.selectedCrop.value;

        if (crop == null) {
          return const Center(child: Text('Crop not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.grass, size: 80),

              const SizedBox(height: 20),

              Text(
                crop.cropName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              _DetailRow(title: 'Season', value: crop.season),

              _DetailRow(title: 'Area', value: '${crop.area} ${crop.areaUnit}'),

              if (crop.variety != null && crop.variety!.isNotEmpty)
                _DetailRow(title: 'Variety', value: crop.variety!),

              if (crop.plannedDate != null)
                _DetailRow(
                  title: 'Planned Date',
                  value: _formatDate(crop.plannedDate!),
                ),

              if (crop.plantingDate != null)
                _DetailRow(
                  title: 'Planting Date',
                  value: _formatDate(crop.plantingDate!),
                ),

              if (crop.notes != null && crop.notes!.isNotEmpty)
                _DetailRow(title: 'Notes', value: crop.notes!),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, String cropId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Crop?'),
          content: const Text('Are you sure you want to delete this crop?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
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

    final success = await controller.deleteCrop(
      farmId: widget.farmId,
      cropId: cropId,
    );

    if (success && context.mounted) {
      context.pop();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }}