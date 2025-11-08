import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/models.dart';
import 'run_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  UserStats? _stats;
  List<Run> _runs = [];
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
        _runs = runsMap.map((e) => Run.fromMap(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Histori Total Lari',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_stats?.totalDistance.toStringAsFixed(2) ?? '0.00'}',
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
              children: [
                Expanded(
                  child: _buildStatCard(
                    '${_stats?.totalRuns ?? 0}',
                    'Lari',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    _stats?.averagePace ?? "0'00\"",
                    'Rata-rata Pace',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    _stats?.totalTime ?? '0h 0m',
                    'Waktu',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_runs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'Belum ada histori lari',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ..._runs.map((run) => _buildRunCard(run)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'FugazOne',
              fontSize: 20,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
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