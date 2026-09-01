import 'package:flutter/material.dart';

import '../models/diary_entry_model.dart';

class DiaryEntryCard extends StatelessWidget {
  final DiaryEntryModel entry;
  final VoidCallback? onTap;

  const DiaryEntryCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypeIcon(type: entry.type),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      entry.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDate(entry.date),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                            ),
                            child: Text(
                              _formatType(entry.type),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
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

class _TypeIcon extends StatelessWidget {
  final String type;

  const _TypeIcon({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (type) {
      case 'sowing':
        icon = Icons.grass;

      case 'irrigation':
        icon = Icons.water_drop_outlined;

      case 'fertilizer':
        icon = Icons.science_outlined;

      case 'pesticide':
        icon = Icons.sanitizer_outlined;

      case 'pest':
        icon = Icons.bug_report_outlined;

      case 'disease':
        icon = Icons.coronavirus_outlined;

      case 'harvesting':
        icon = Icons.agriculture;

      case 'observation':
        icon = Icons.visibility_outlined;

      default:
        icon = Icons.note_outlined;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context)
            .colorScheme
            .primaryContainer,
      ),
      child: Icon(icon),
    );
  }
}