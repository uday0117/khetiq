import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:khetiq/app/app_routes.dart';

import '../controllers/crop_planner_controller.dart';
import '../widgets/crop_card.dart';

class CropPlannerView extends StatefulWidget {
  final String farmId;

  const CropPlannerView({super.key, required this.farmId});

  @override
  State<CropPlannerView> createState() => _CropPlannerViewState();
}

class _CropPlannerViewState extends State<CropPlannerView> {
  late final CropPlannerController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.find<CropPlannerController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCrops(widget.farmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Planner')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('${AppRoutes.addCrop}/${widget.farmId}');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Crop'),
      ),

      body: Obx(() {
        if (controller.isLoading.value && controller.crops.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.crops.isEmpty) {
          return _EmptyCropState(
            onAddCrop: () {
              context.push('${AppRoutes.addCrop}/${widget.farmId}');
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadCrops(widget.farmId),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.crops.length,
            itemBuilder: (context, index) {
              final crop = controller.crops[index];

              return CropCard(
                crop: crop,
                onTap: () {
                  context.push(
                    '${AppRoutes.cropDetails}/'
                    '${widget.farmId}/'
                    '${crop.id}',
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _EmptyCropState extends StatelessWidget {
  final VoidCallback onAddCrop;

  const _EmptyCropState({required this.onAddCrop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grass, size: 80),

            const SizedBox(height: 20),

            const Text(
              'No crops added yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add your first crop to start planning your farm.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: onAddCrop,
              icon: const Icon(Icons.add),
              label: const Text('Add Crop'),
            ),
          ],
        ),
      ),
    );
  }
}
