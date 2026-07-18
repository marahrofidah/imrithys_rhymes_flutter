import 'package:flutter/material.dart';
import '../services/download_service.dart';

class GlobalDownloadOverlay extends StatelessWidget {
  const GlobalDownloadOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<DownloadTask>>(
      valueListenable: DownloadService().activeDownloads,
      builder: (context, activeTasks, _) {
        if (activeTasks.isEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                color: const Color(0xFF1E293B), // Slate 800 for contrast
                elevation: 6,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: activeTasks.map((task) {
                      IconData statusIcon = Icons.download_rounded;
                      Color iconColor = const Color(0xFF65A6F1); // App light blue
                      if (task.isDone) {
                        statusIcon = Icons.check_circle_rounded;
                        iconColor = Colors.green;
                      } else if (task.isFailed) {
                        statusIcon = Icons.error_rounded;
                        iconColor = Colors.redAccent;
                      }

                      return Padding(
                        key: ValueKey(task.id),
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: iconColor.withAlpha(38),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                statusIcon,
                                color: iconColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: task.isFailed ? 0.0 : task.progress,
                                      backgroundColor: Colors.white10,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        iconColor,
                                      ),
                                      minHeight: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              task.isFailed
                                  ? '!'
                                  : '${(task.progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
