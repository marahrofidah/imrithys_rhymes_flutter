import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/bab_model.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../services/download_service.dart';

class DengarkanSyairPage extends StatefulWidget {
  const DengarkanSyairPage({super.key});

  @override
  State<DengarkanSyairPage> createState() => _DengarkanSyairPageState();
}

class _DengarkanSyairPageState extends State<DengarkanSyairPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<BabModel> _babs = BabList.getBabs();
  final SupabaseService _supabase = SupabaseService();
  final DownloadService _downloadService = DownloadService();

  String? _userId;
  bool _isLoadingProgress = true;

  // Data progress hari ini
  List<Map<String, dynamic>> _topBabs = [];
  Map<String, int> _todayCounts = {};

  // State audio player
  BabModel? _currentBab;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isRecordedThisSession = false;

  // State download & offline
  bool _isOffline = false;
  final Set<String> _downloadedKeys = {};
  final Map<String, double> _downloadProgress = {};

  @override
  void initState() {
    super.initState();
    _userId = AuthService().currentUser?.id;
    _initDownloads();
    _setupAudioListeners();
    _checkOfflineAndLoad();
  }

  Future<void> _checkOfflineAndLoad() async {
    if (mounted) setState(() => _isLoadingProgress = true);
    
    bool offline = false;
    try {
      final result = await InternetAddress.lookup('example.com').timeout(const Duration(seconds: 2));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        offline = true;
      }
    } catch (_) {
      offline = true;
    }

    if (mounted) {
      setState(() {
        _isOffline = offline;
      });
    }

    if (!offline) {
      await _loadProgress();
    } else {
      if (mounted) {
        setState(() {
          _isLoadingProgress = false;
        });
      }
    }
  }

  Future<void> _initDownloads() async {
    await _downloadService.initialize();
    for (final bab in _babs) {
      final downloaded = await _downloadService.isAudioDownloaded(bab.key);
      if (downloaded && mounted) {
        setState(() {
          _downloadedKeys.add(bab.key);
        });
      }
    }
  }

  void _setupAudioListeners() {
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() => _position = p);

        // Jika sudah mencapai akhir durasi (selisih kurang dari 300ms dari akhir) dan progress sudah dicatat, pause & seek ke awal (untuk instan replay)
        if (_isPlaying &&
            _isRecordedThisSession &&
            _duration.inMilliseconds > 0 &&
            p.inMilliseconds >= _duration.inMilliseconds - 300) {
          setState(() {
            _isPlaying = false;
            _position = Duration.zero;
          });
          _audioPlayer.pause();
          _audioPlayer.seek(Duration.zero);
        }

        // Cek jika sudah didengar 95% dari durasi dan belum dicatat
        if (_duration.inMilliseconds > 0 && !_isRecordedThisSession) {
          final double progressPercent =
              p.inMilliseconds / _duration.inMilliseconds;
          if (progressPercent >= 0.95) {
            _isRecordedThisSession = true;
            _onAudioCompleted(_currentBab!);
          }
        }
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });

    // Ketika audio selesai diputar sampai habis
    _audioPlayer.onPlayerComplete.listen((_) async {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
      _audioPlayer.pause();
      _audioPlayer.seek(Duration.zero);
      if (_currentBab != null && _userId != null && !_isRecordedThisSession) {
        _isRecordedThisSession = true;
        await _onAudioCompleted(_currentBab!);
      }
    });
  }

  Future<void> _loadProgress() async {
    if (_userId == null) return;
    setState(() => _isLoadingProgress = true);
    try {
      final results = await Future.wait([
        _supabase.getTodayTopBabs(_userId!),
        _supabase.getTodayListeningCounts(_userId!),
      ]);
      if (mounted) {
        setState(() {
          _topBabs = results[0] as List<Map<String, dynamic>>;
          _todayCounts = results[1] as Map<String, int>;
          _isLoadingProgress = false;
          _isOffline = false; // We successfully loaded progress, so we are online
        });
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
      if (mounted) {
        setState(() {
          _isLoadingProgress = false;
          _isOffline = true; // Set offline status on failure
        });
      }
    }
  }

  Future<void> _onAudioCompleted(BabModel bab) async {
    if (_userId == null) return;

    try {
      // Catat ke database
      final error = await _supabase.recordListening(
        studentId: _userId!,
        babKey: bab.key,
        babLabel: bab.fullLabel,
      );

      if (error != null) {
        debugPrint('Gagal menyimpan progress ke database Supabase: $error');
        return;
      }

      // Update streak jika ada bab yang sudah ≥ 5x
      final bool streakIncreased = await _supabase.updateStreakIfNeeded(_userId!);

      // Refresh progress display
      await _loadProgress();

      // Tampilkan notifikasi jika streak benar-benar bertambah hari ini
      if (mounted && streakIncreased) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Expanded(
                  child: Text(
                    'Keren! ${bab.labelId} sudah 5 kali! Target hari ini tercapai, streak bertambah!',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF6E6EB0),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
         );
      }
    } catch (e) {
      debugPrint('Error saving progress (device is likely offline): $e');
      // Fail silently without disrupting user's listening experience
    }
  }

  Future<void> _playBab(BabModel bab) async {
    if (_isLoadingAudio) return;

    // Jika bab yang sama lagi, toggle play/pause
    if (_currentBab?.key == bab.key) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // Jika diputar ulang dari awal (detik ke-0), reset penanda pencatatan untuk session baru
        if (_position == Duration.zero || _position.inSeconds == 0) {
          _isRecordedThisSession = false;
        }
        await _audioPlayer.resume();
      }
      return;
    }

    // Ganti ke bab baru
    setState(() {
      _isLoadingAudio = true;
      _currentBab = bab;
      _position = Duration.zero;
      _duration = Duration.zero;
      _isRecordedThisSession = false;
    });

    try {
      await _audioPlayer.stop();

      // Cek apakah audio sudah diunduh
      final downloaded = await _downloadService.isAudioDownloaded(bab.key);
      if (downloaded) {
        final localPath = await _downloadService.getAudioPath(bab.key);
        await _audioPlayer.play(DeviceFileSource(localPath));
      } else {
        // Jika sedang offline dan file belum diunduh
        if (_isOffline) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bab ini belum diunduh dan tidak dapat diputar offline.'),
                backgroundColor: Colors.orange,
              ),
            );
            setState(() => _isLoadingAudio = false);
            return;
          }
        }
        await _audioPlayer.play(UrlSource(bab.audioUrl));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memutar audio: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAudio = false);
    }
  }

  Future<void> _downloadBab(BabModel bab) async {
    if (_downloadProgress.containsKey(bab.key)) return; // Sedang diunduh

    setState(() {
      _downloadProgress[bab.key] = 0.0;
    });

    try {
      final localPath = await _downloadService.getAudioPath(bab.key);
      await _downloadService.downloadFile(
        url: bab.audioUrl,
        savePath: localPath,
        onProgress: (p) {
          if (mounted) {
            setState(() {
              _downloadProgress[bab.key] = p;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _downloadedKeys.add(bab.key);
          _downloadProgress.remove(bab.key);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selesai mengunduh ${bab.labelId}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadProgress.remove(bab.key);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh audio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDownloadedBab(BabModel bab) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Audio'),
        content: Text('Apakah Anda yakin ingin menghapus audio offline ${bab.labelId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _downloadService.deleteAudio(bab.key);
        if (mounted) {
          setState(() {
            _downloadedKeys.remove(bab.key);
            // Jika sedang diputar, hentikan pemutaran
            if (_currentBab?.key == bab.key) {
              _audioPlayer.stop();
              _currentBab = null;
              _isPlaying = false;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Audio offline ${bab.labelId} berhasil dihapus'),
              backgroundColor: Colors.blueGrey,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus audio: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = _currentBab != null ? 405.0 : 268.0;

    final List<BabModel> visibleBabs = _isOffline
        ? _babs.where((bab) => _downloadedKeys.contains(bab.key)).toList()
        : _babs;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Stack(
        children: [
          // ---- Scrollable list (placed behind the header) ----
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, topPadding, 24, 130),
              child: Column(
                children: [
                  // Progress papan hari ini
                  _buildProgressBoard(),
                  const SizedBox(height: 16),

                  // Daftar bab
                  if (_isOffline && visibleBabs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Belum ada bab yang diunduh.\nHubungkan ke internet untuk mengunduh syair.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  else
                    ...visibleBabs.map((bab) => _buildBabTile(bab)),
                ],
              ),
            ),
          ),

          // ---- Pinned Header & Pinned Mini Player with fading bottom edge ----
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          const SafeArea(
                            bottom: false,
                            child: SizedBox(height: 0),
                          ),
                          _buildHeader(),
                        ],
                      ),
                    ),
                    // Pinned Mini Player (only visible when audio is active)
                    if (_currentBab != null) _buildMiniPlayer(),
                  ],
                ),
                // Fading gradient edge at the bottom of the header (only when mini player is not active)
                if (_currentBab == null)
                  Positioned(
                    bottom:
                        -12, // Menggeser gradasi agar lebih naik ke atas (semakin mendekati 0 semakin turun)
                    left: 0,
                    right: 0,
                    child: Container(
                      height:
                          16, // Memperpendek tinggi gradasi agar efek pudar lebih tipis
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Back Button + Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          0,
                          0,
                          0,
                        ).withValues(alpha: 0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Color.fromARGB(255, 57, 143, 241),
                  ),
                ),
              ),
              Image.asset(
                'assets/images/logo.webp',
                height: 40,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Content Row: Earphone + Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/earphone.webp',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dengarkan Syair',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3A327C),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pilih bab yang ingin kamu dengarkan',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF3A327C),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBoard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF3A327C),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              255,
              157,
              157,
              157,
            ).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Mendengarkan Hari Ini',
            style: TextStyle(
              fontSize: 20.2,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          if (_isLoadingProgress)
            const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                ),
              ),
            )
          else if (_isOffline)
            const Text(
              'Koneksi internet diperlukan untuk melihat progress.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            )
          else if (_topBabs.isEmpty)
            const Text(
              'Belum ada yang didengarkan hari ini.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ..._topBabs.map((bab) {
              final count = bab['count'] as int;
              final label = bab['babLabel'] as String;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: count >= 5
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count/5x',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: count >= 5
                              ? const Color(0xFF81C784)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF6E6EB0),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E6EB0).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon bab
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              // Nama bab
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentBab!.labelId,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _currentBab!.labelAr,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Play/pause button
              _isLoadingAudio
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : GestureDetector(
                      onTap: () async {
                        if (_isPlaying) {
                          await _audioPlayer.pause();
                        } else {
                          await _audioPlayer.resume();
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: const Color(0xFF6E6EB0),
                          size: 30,
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBabTile(BabModel bab) {
    final count = _todayCounts[bab.key] ?? 0;
    final isActive = _currentBab?.key == bab.key;
    final isDone = count >= 5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _playBab(bab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF6E6EB0)
                : isDone
                ? const Color.fromARGB(255, 232, 245, 233)
                : const Color.fromARGB(215, 230, 230, 230),
            borderRadius: BorderRadius.circular(50),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF6E6EB0).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Label bab
              Expanded(
                child: Text(
                  bab.fullLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? Colors.white
                        : isDone
                        ? const Color(0xFF388E3C)
                        : const Color(0xFF2D2D2D),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Badge count & play icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (count > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF4CAF50)
                            : isActive
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFF6E6EB0).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count/5x',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDone
                              ? Colors.white
                              : isActive
                              ? Colors.white
                              : const Color(0xFF6E6EB0),
                        ),
                      ),
                    ),
                  
                  // Tombol download/hapus audio offline
                  _buildDownloadButton(bab),
                  const SizedBox(width: 10),

                  if (isDone)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    )
                  else if (isActive && _isPlaying)
                    const Icon(
                      Icons.pause_circle_filled_rounded,
                      color: Colors.white,
                      size: 30,
                    )
                  else if (isActive)
                    const Icon(
                      Icons.play_circle_filled_rounded,
                      color: Colors.white,
                      size: 30,
                    )
                  else
                    const Icon(
                      Icons.play_circle_outline_rounded,
                      color: Color(0xFF697B91),
                      size: 28,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton(BabModel bab) {
    final isDownloaded = _downloadedKeys.contains(bab.key);
    final isDownloading = _downloadProgress.containsKey(bab.key);
    final progress = _downloadProgress[bab.key] ?? 0.0;
    final isActive = _currentBab?.key == bab.key;

    if (isDownloading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isActive ? Colors.white : const Color(0xFF6E6EB0),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xFF6E6EB0),
              ),
            ),
          ],
        ),
      );
    }

    if (isDownloaded) {
      return GestureDetector(
        onTap: () => _deleteDownloadedBab(bab),
        child: Icon(
          Icons.delete_outline_rounded,
          color: isActive ? Colors.white70 : const Color(0xFFEF5350),
          size: 22,
        ),
      );
    }

    // Jika offline, sembunyikan tombol download
    if (_isOffline) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _downloadBab(bab),
      child: Icon(
        Icons.download_rounded,
        color: isActive ? Colors.white70 : const Color(0xFF6E6EB0),
        size: 22,
      ),
    );
  }

  Widget _buildBottomNav() {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: const BorderRadius.all(Radius.circular(40)),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          Icons.home_rounded,
                          0,
                          onTap: () => Navigator.pop(context),
                        ),
                        _buildNavItem(
                          Icons.menu_book_rounded,
                          1,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/pelajari-kitab');
                          },
                        ),
                        _buildNavItem(
                          Icons.person_rounded,
                          2,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
                        _buildNavItem(
                          Icons.logout_rounded,
                          3,
                          onTap: () => _handleLogout(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    int index, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6E6EB0).withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? const Color(0xFF6E6EB0) : Colors.grey.shade400,
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Aplikasi'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
