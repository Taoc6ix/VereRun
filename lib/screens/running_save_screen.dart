import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class RunningSaveScreen extends StatefulWidget {
  final double distance;
  final int duration;
  final String pace;
  final int calories;

  const RunningSaveScreen({
    super.key,
    required this.distance,
    required this.duration,
    required this.pace,
    required this.calories,
  });

  @override
  State<RunningSaveScreen> createState() => _RunningSaveScreenState();
}

class _RunningSaveScreenState extends State<RunningSaveScreen> {
  late TextEditingController _titleController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Default title
    final now = DateTime.now();
    final dayName = DateFormat('EEEE', 'en_US').format(now);
    _titleController = TextEditingController(text: '$dayName Morning Run');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _saveRun() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = await DatabaseHelper.instance.getCurrentUserId();
      if (userId == null) return;

      final now = DateTime.now();

      final run = Run(
        userId: userId,
        title: _titleController.text.trim(),
        distance: widget.distance,
        duration: widget.duration,
        pace: widget.pace,
        calories: widget.calories,
        runDate: DateFormat('dd/MM/yyyy').format(now),
        createdAt: now.toIso8601String(),
      );

      await DatabaseHelper.instance.createRun(run.toMap());

      if (!mounted) return;

      // Pop 2 screens (save screen + tracking screen)
      Navigator.pop(context);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Run berhasil disimpan!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Editable Title
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2196F3)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Main Stats Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric(
                    '${widget.distance.toStringAsFixed(2)} Km',
                    'Distance',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildMetric(
                    _formatDuration(widget.duration),
                    'Duration',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildMetric(
                    widget.pace,
                    'Avg Pace',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detail Cards
            _buildDetailCard(
              'Jarak',
              '${(widget.distance * 1000).toStringAsFixed(0)} m',
            ),
            _buildDetailCard(
              'Durasi',
              _formatDuration(widget.duration),
            ),
            _buildDetailCard(
              'Rata-rata Pace',
              '${widget.pace}',
            ),
            _buildDetailCard(
              'Kalori',
              '${widget.calories} kcal',
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveRun,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Simpan',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'FugazOne',
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}