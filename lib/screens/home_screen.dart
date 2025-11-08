import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/models.dart';
import 'history_screen.dart';
import 'tracking_screen.dart';
import 'welcome_screen.dart';
import 'run_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserStats? _stats;
  List<Run> _recentRuns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = await DatabaseHelper.instance.getCurrentUserId();
      if (userId == null) return;

      final statsMap = await DatabaseHelper.instance.getUserStats(userId);
      final runsMap = await DatabaseHelper.instance.getRunsByUser(userId);

      setState(() {
        _stats = UserStats.fromMap(statsMap);
        _recentRuns = runsMap.take(2).map((e) => Run.fromMap(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await DatabaseHelper.instance.clearCurrentUser();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'VereRun',
          style: TextStyle(
            fontFamily: 'FugazOne',
            fontSize: 24,
            fontStyle: FontStyle.italic,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Lari Kamu',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _stats?.totalDistance.toStringAsFixed(2) ?? '0.00',
                      style: TextStyle(
                        fontFamily: 'FugazOne',
                        fontSize: 64,
                        fontStyle: FontStyle.italic,
                        height: 1,
                      ),
                    ),
                    Text(
                      'Kilometer',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Histori Terakhir',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HistoryScreen(),
                              ),
                            );
                            _loadData();
                          },
                          child: Row(
                            children: [
                              Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  color: const Color(0xFF2196F3),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Color(0xFF2196F3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_recentRuns.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'Belum ada data lari\nMulai lari sekarang!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._recentRuns.map((run) => _buildRunCard(run)),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TrackingScreen()),
          );
          _loadData();
        },
        backgroundColor: const Color(0xFF0D47A1),
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: Text(
          'Mulai Lari',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRunCard(Run run) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RunDetailScreen(run: run),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              run.runDate,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              run.title,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Text(
                  run.durationFormatted,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  run.pace,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Waktu',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 46),
                Text(
                  'Pace',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${run.distance.toStringAsFixed(2)} Km',
                  style: const TextStyle(
                    fontFamily: 'FugazOne',
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}