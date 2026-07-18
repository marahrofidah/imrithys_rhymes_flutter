import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DownloadTask {
  final String id;
  final String title;
  final double progress;
  final bool isDone;
  final bool isFailed;

  DownloadTask({
    required this.id,
    required this.title,
    this.progress = 0.0,
    this.isDone = false,
    this.isFailed = false,
  });

  DownloadTask copyWith({
    double? progress,
    bool? isDone,
    bool? isFailed,
  }) {
    return DownloadTask(
      id: id,
      title: title,
      progress: progress ?? this.progress,
      isDone: isDone ?? this.isDone,
      isFailed: isFailed ?? this.isFailed,
    );
  }
}

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();

  factory DownloadService() {
    return _instance;
  }

  DownloadService._internal();

  Directory? _audioDir;
  Directory? _pdfDir;

  final ValueNotifier<List<DownloadTask>> activeDownloads = ValueNotifier<List<DownloadTask>>([]);

  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _audioDir = Directory('${appDir.path}/offline_audio');
    _pdfDir = Directory('${appDir.path}/offline_pdf');

    if (!await _audioDir!.exists()) {
      await _audioDir!.create(recursive: true);
    }
    if (!await _pdfDir!.exists()) {
      await _pdfDir!.create(recursive: true);
    }
  }

  Future<void> _ensureInitialized() async {
    if (_audioDir == null || _pdfDir == null) {
      await initialize();
    }
  }

  // ========== AUDIO OFFLINE METHODS ==========

  Future<bool> isAudioDownloaded(String key) async {
    await _ensureInitialized();
    final file = File('${_audioDir!.path}/$key.mp3');
    return await file.exists();
  }

  Future<String> getAudioPath(String key) async {
    await _ensureInitialized();
    return '${_audioDir!.path}/$key.mp3';
  }

  Future<void> deleteAudio(String key) async {
    await _ensureInitialized();
    final file = File('${_audioDir!.path}/$key.mp3');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ========== PDF OFFLINE METHODS ==========

  Future<bool> isPdfDownloaded(String key) async {
    await _ensureInitialized();
    final file = File('${_pdfDir!.path}/$key.pdf');
    return await file.exists();
  }

  Future<String> getPdfPath(String key) async {
    await _ensureInitialized();
    return '${_pdfDir!.path}/$key.pdf';
  }

  Future<void> deletePdf(String key) async {
    await _ensureInitialized();
    final file = File('${_pdfDir!.path}/$key.pdf');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ========== GENERIC DOWNLOADER ==========

  Future<void> downloadFile({
    required String url,
    required String savePath,
    required String title,
    required String id,
    required Function(double progress) onProgress,
  }) async {
    // Add to active downloads
    final task = DownloadTask(id: id, title: title, progress: 0.0);
    activeDownloads.value = [...activeDownloads.value, task];

    final File tempFile = File('$savePath.tmp');
    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    final HttpClient httpClient = HttpClient();
    httpClient.connectionTimeout = const Duration(seconds: 15);

    try {
      final HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      final HttpClientResponse response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Server returned status code ${response.statusCode}');
      }

      final int contentLength = response.contentLength;
      int downloadedBytes = 0;

      final IOSink fileSink = tempFile.openWrite();

      await for (final List<int> chunk in response) {
        fileSink.add(chunk);
        downloadedBytes += chunk.length;
        if (contentLength > 0) {
          final double progress = downloadedBytes / contentLength;
          final currentProgress = progress.clamp(0.0, 1.0);
          
          // Update active downloads list
          activeDownloads.value = activeDownloads.value.map((t) {
            if (t.id == id) {
              return t.copyWith(progress: currentProgress);
            }
            return t;
          }).toList();

          onProgress(currentProgress);
        }
      }

      await fileSink.flush();
      await fileSink.close();

      final File finalFile = File(savePath);
      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await tempFile.rename(savePath);

      // Update task to done, then remove after a short delay
      activeDownloads.value = activeDownloads.value.map((t) {
        if (t.id == id) {
          return t.copyWith(progress: 1.0, isDone: true);
        }
        return t;
      }).toList();

      Future.delayed(const Duration(seconds: 2), () {
        activeDownloads.value = activeDownloads.value.where((t) => t.id != id).toList();
      });

    } catch (e) {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      
      // Update task to failed, then remove after a short delay
      activeDownloads.value = activeDownloads.value.map((t) {
        if (t.id == id) {
          return t.copyWith(isFailed: true);
        }
        return t;
      }).toList();

      Future.delayed(const Duration(seconds: 2), () {
        activeDownloads.value = activeDownloads.value.where((t) => t.id != id).toList();
      });

      rethrow;
    } finally {
      httpClient.close();
    }
  }
}
