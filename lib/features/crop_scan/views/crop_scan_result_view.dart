import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../controllers/crop_scan_controller.dart';
import '../models/crop_scan_result_model.dart';

class CropScanResultView extends StatefulWidget {
  const CropScanResultView({super.key});

  @override
  State<CropScanResultView> createState() => _CropScanResultViewState();
}

class _CropScanResultViewState extends State<CropScanResultView>
    with SingleTickerProviderStateMixin {
  late final CropScanController controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CropScanController>();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diagnosis & Remedies',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        final result = controller.scanResult.value;

        if (result == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'No Scan Result Available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        final healthColor = _getHealthColor(result.healthStatus);

        return Column(
          children: [
            // Top Overview Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: healthColor.withAlpha(100), width: 1.5),
              ),
              child: Row(
                children: [
                  // Image Preview
                  if (result.imagePath != null && File(result.imagePath!).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(result.imagePath!),
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.grass, color: Colors.green, size: 40),
                    ),

                  const SizedBox(width: 14),

                  // Health Status & Disease info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: healthColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getHealthIcon(result.healthStatus), size: 14, color: healthColor),
                              const SizedBox(width: 4),
                              Text(
                                result.healthStatus.toUpperCase(),
                                style: TextStyle(
                                  color: healthColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          result.diseaseName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Crop: ${result.cropName} • Confidence: ${(result.confidenceScore * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: Colors.green.shade800,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.green.shade700,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Symptoms'),
                Tab(text: 'Organic'),
                Tab(text: 'Chemical'),
              ],
            ),

            // Tab Bar Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Symptoms & Causes
                  _buildSymptomsTab(result),

                  // Tab 2: Organic Control
                  _buildRemediesTab(
                    title: 'Organic & Biological Treatments',
                    items: result.organicTreatments,
                    icon: Icons.eco,
                    iconColor: Colors.green,
                    accentColor: Colors.green.shade50,
                  ),

                  // Tab 3: Chemical Control
                  _buildRemediesTab(
                    title: 'Chemical Treatments & Advisory',
                    items: result.chemicalTreatments,
                    icon: Icons.science,
                    iconColor: Colors.blue.shade700,
                    accentColor: Colors.blue.shade50,
                    disclaimer:
                        'Always wear protective gear and follow safety guidelines on chemical product labels.',
                  ),
                ],
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.clearImage();
                        context.pop();
                      },
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('Scan Another Crop'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSymptomsTab(CropScanResultModel result) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Identified Symptoms', Icons.remove_red_eye_outlined),
        const SizedBox(height: 8),
        if (result.symptoms.isEmpty)
          const Text('No specific symptoms recorded.')
        else
          ...result.symptoms.map((s) => _buildBulletPoint(s, Colors.amber.shade800)),

        const SizedBox(height: 20),

        _buildSectionHeader('Probable Causes', Icons.help_outline),
        const SizedBox(height: 8),
        if (result.causes.isEmpty)
          const Text('No specific causes documented.')
        else
          ...result.causes.map((c) => _buildBulletPoint(c, Colors.orange.shade800)),

        const SizedBox(height: 20),

        _buildSectionHeader('Preventive Steps', Icons.shield_outlined),
        const SizedBox(height: 8),
        if (result.preventiveMeasures.isEmpty)
          const Text('No preventive measures available.')
        else
          ...result.preventiveMeasures.map((p) => _buildBulletPoint(p, Colors.teal.shade800)),
      ],
    );
  }

  Widget _buildRemediesTab({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color iconColor,
    required Color accentColor,
    String? disclaimer,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (disclaimer != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade900, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    disclaimer,
                    style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (items.isEmpty)
          const Text('No specific treatment steps provided for this category.')
        else
          ...items.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0.5,
              color: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, color: iconColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 14, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade800),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'mild issue':
        return Colors.orange;
      case 'severe issue':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  IconData _getHealthIcon(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return Icons.check_circle;
      case 'mild issue':
        return Icons.warning;
      case 'severe issue':
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}
