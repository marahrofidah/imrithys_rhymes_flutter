import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/bab_model.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';

class DengarkanSyairPage extends StatefulWidget {
  const DengarkanSyairPage({super.key});

  @override
  State<DengarkanSyairPage> createState() => _DengarkanSyairPageState();
}

class _DengarkanSyairPageState extends State<DengarkanSyairPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<BabModel> _babs = BabList.getBabs();
  final SupabaseService _supabase = SupabaseService();

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
  bool _showLyrics = false;

  @override
  void initState() {
    super.initState();
    _userId = AuthService().currentUser?.id;
    _loadProgress();
    _setupAudioListeners();
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
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingProgress = false);
    }
  }

  Future<void> _onAudioCompleted(BabModel bab) async {
    if (_userId == null) return;

    // Catat ke database
    final error = await _supabase.recordListening(
      studentId: _userId!,
      babKey: bab.key,
      babLabel: bab.fullLabel,
    );

    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan progress: $error'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
      await _audioPlayer.play(UrlSource(bab.audioUrl));
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SafeArea(bottom: false, child: SizedBox(height: 8)),
          // ---- Header earphone + judul ----
          _buildHeader(),

          // ---- Mini player (muncul jika ada audio aktif) ----
          if (_currentBab != null) _buildMiniPlayer(),

          // ---- Scrollable list ----
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  // Progress papan hari ini
                  _buildProgressBoard(),
                  const SizedBox(height: 16),

                  // Daftar bab
                  ..._babs.map((bab) => _buildBabTile(bab)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
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
                    color: const Color.fromARGB(255, 233, 233, 233),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
              Image.asset(
                'assets/images/logo.png',
                height: 40,
                fit: BoxFit.contain,
              ),
            ],
          ),
          // Content Row: Earphone + Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/earphone.png',
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
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A327C).withValues(alpha: 0.3),
            blurRadius: 30,
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

          // Divider tipis lirik
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 8),

          // Tombol Toggle Lirik
          GestureDetector(
            onTap: () {
              setState(() => _showLyrics = !_showLyrics);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showLyrics
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _showLyrics ? 'Sembunyikan Lirik' : 'Tampilkan Lirik',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Lirik Box (Expandable)
          if (_showLyrics) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 180),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: _currentBab!.lyrics.map((line) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        line,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
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
}
