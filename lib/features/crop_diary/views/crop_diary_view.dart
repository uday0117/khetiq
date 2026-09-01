import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:khetiq/app/app_routes.dart';

import '../controllers/crop_diary_controller.dart';
import '../widgets/diary_entry_card.dart';

class CropDiaryView extends StatefulWidget {
  final String farmId;
  final String cropId;

  const CropDiaryView({
    super.key,
    required this.farmId,
    required this.cropId,
  });

  @override
  State<CropDiaryView> createState() => _CropDiaryViewState();
}

class _CropDiaryViewState extends State<CropDiaryView> {
  late final CropDiaryController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.find<CropDiaryController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadEntries(
        farmId: widget.farmId,
        cropId: widget.cropId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Diary'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(
            '${AppRoutes.addDiaryEntry}/'
            '${widget.farmId}/'
            '${widget.cropId}',
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),

      body: Obx(() {
        if (controller.isLoading.value &&
            controller.entries.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.entries.isEmpty) {
          return _EmptyDiaryState(
            onAddEntry: () {
              context.push(
                '${AppRoutes.addDiaryEntry}/'
                '${widget.farmId}/'
                '${widget.cropId}',
              );
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () {
            return controller.loadEntries(
              farmId: widget.farmId,
              cropId: widget.cropId,
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.entries.length,
            itemBuilder: (context, index) {
              final entry = controller.entries[index];

              return DiaryEntryCard(
                entry: entry,
                onTap: () {
                  context.push(
                    '${AppRoutes.diaryEntryDetails}/'
                    '${widget.farmId}/'
                    '${widget.cropId}/'
                    '${entry.id}',
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

class _EmptyDiaryState extends StatelessWidget {
  final VoidCallback onAddEntry;

  const _EmptyDiaryState({
    required this.onAddEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 80,
            ),

            const SizedBox(height: 20),

            const Text(
              'No diary entries yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Record important activities and observations '
              'about your crop.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: onAddEntry,
              icon: const Icon(Icons.add),
              label: const Text('Add First Entry'),
            ),
          ],
        ),
      ),
    );
  }
}