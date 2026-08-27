import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../controllers/farm_controller.dart';
import '../widgets/farm_card.dart';

class MyFarmView extends GetView<FarmController> {
  const MyFarmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Farm')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.farmSetup);
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.farms.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.farms.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.agriculture_outlined, size: 70),

                  const SizedBox(height: 20),

                  const Text(
                    'No farms added yet',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Add your first farm to get started.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: () {
                      context.push(AppRoutes.farmSetup);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Farm'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadFarms,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.farms.length,
            itemBuilder: (context, index) {
              final farm = controller.farms[index];

              return FarmCard(
                farm: farm,
                onTap: () {
                  context.push('${AppRoutes.farmDetails}/${farm.id}');
                },
              );
            },
          ),
        );
      }),
    );
  }
}
