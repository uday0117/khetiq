import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:khetiq/app/app_routes.dart';

import '../controllers/farm_controller.dart';

class FarmDetailsView extends StatefulWidget {
  final String farmId;

  const FarmDetailsView({super.key, required this.farmId});

  @override
  State<FarmDetailsView> createState() => _FarmDetailsViewState();
}

class _FarmDetailsViewState extends State<FarmDetailsView> {
  late final FarmController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.find<FarmController>();

    controller.loadFarm(widget.farmId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Details'),
        actions: [
          Obx(() {
            final farm = controller.selectedFarm.value;

            if (farm == null) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('${AppRoutes.editFarm}/${farm.id}');
              },
            );
          }),

          Obx(() {
            final farm = controller.selectedFarm.value;

            if (farm == null) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showDeleteDialog(context, farm.id);
              },
            );
          }),
        ],
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final farm = controller.selectedFarm.value;

        if (farm == null) {
          return const Center(child: Text('Farm not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.agriculture, size: 70),

              const SizedBox(height: 20),

              Text(
                farm.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              _DetailRow(title: 'Area', value: '${farm.area} ${farm.areaUnit}'),

              _DetailRow(title: 'Village', value: farm.village),

              _DetailRow(title: 'District', value: farm.district),

              _DetailRow(title: 'State', value: farm.state),
            ],
          ),
        );
      }),
    );
  }

  void _showDeleteDialog(BuildContext context, String farmId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Farm?'),
          content: const Text('Are you sure you want to delete this farm?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final success = await controller.deleteFarm(farmId);

                if (success && context.mounted) {
                  context.go(AppRoutes.myFarm);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
            width: 100,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
