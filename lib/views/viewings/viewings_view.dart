import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock_api.dart';
import '../../data/models/viewing.dart';

/// Scheduling, tracking and managing property viewings.
///
/// setState based. Note this tab does not know about FavoritesProvider or
/// AuthProvider at all - it reads MockApi directly.
class ViewingsView extends StatefulWidget {
  const ViewingsView({super.key});

  @override
  State<ViewingsView> createState() => _ViewingsViewState();
}

class _ViewingsViewState extends State<ViewingsView>
    with SingleTickerProviderStateMixin {
  final MockApi _api = MockApi();
  late TabController _tabController;

  List<Viewing> _viewings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.fetchViewings();
      setState(() {
        _viewings = result;
        _loading = false;
      });
    } catch (e) {
      print('ViewingsView load failed: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Viewing> get _upcoming =>
      _viewings.where((v) => v.status != 'completed' && v.status != 'cancelled').toList();

  List<Viewing> get _past =>
      _viewings.where((v) => v.status == 'completed' || v.status == 'cancelled').toList();

  Future<void> _cancel(Viewing viewing) async {
    await _api.updateViewingStatus(viewing.id, 'cancelled');
    await _load();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viewing cancelled')),
    );
  }

  Future<void> _confirm(Viewing viewing) async {
    await _api.updateViewingStatus(viewing.id, 'confirmed');
    await _load();
  }

  Future<void> _reschedule(Viewing viewing) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null) return;

    final when = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    await _api.rescheduleViewing(viewing.id, when);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewings'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Upcoming (${_upcoming.length})'),
            Tab(text: 'Past (${_past.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(_upcoming, isUpcoming: true),
                    _buildList(_past, isUpcoming: false),
                  ],
                ),
    );
  }

  Widget _buildList(List<Viewing> items, {required bool isUpcoming}) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUpcoming ? Icons.event_busy : Icons.history,
                size: 56,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                isUpcoming ? 'No upcoming viewings' : 'No past viewings',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (isUpcoming)
                Text(
                  'Book one from any property page.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildCard(items[index], isUpcoming),
      ),
    );
  }

  Widget _buildCard(Viewing viewing, bool isUpcoming) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: kPrimary.withOpacity(0.10),
                    child: Icon(
                      Icons.home_outlined,
                      color: kPrimary.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewing.propertyTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(viewing.status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 15, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  formatDateShort(viewing.scheduledAt),
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 15, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  formatTime(viewing.scheduledAt),
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 15, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  '${viewing.agentName} · ${viewing.agentPhone}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                ),
              ],
            ),
            if (viewing.notes != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  viewing.notes!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                ),
              ),
            ],
            if (isUpcoming) ...[
              const Divider(height: 24),
              Row(
                children: [
                  if (viewing.status == 'pending')
                    TextButton.icon(
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Confirm'),
                      onPressed: () => _confirm(viewing),
                    ),
                  TextButton.icon(
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text('Reschedule'),
                    onPressed: () => _reschedule(viewing),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.close, size: 18, color: kDanger),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(color: kDanger),
                    ),
                    onPressed: () => _cancel(viewing),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    if (status == 'confirmed') {
      color = kPrimary;
    } else if (status == 'pending') {
      color = kAccent;
    } else if (status == 'cancelled') {
      color = kDanger;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
