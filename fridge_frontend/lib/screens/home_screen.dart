import 'package:flutter/material.dart';
import '../models/home_models.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<FridgeStatus?> _statusFuture;
  late Future<List<ExpiringItem>> _expiringFuture;
  late Future<List<RecentItem>> _recentFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _statusFuture = ApiService.getStatus();
    _expiringFuture = ApiService.getExpiringItems();
    _recentFuture = ApiService.getRecentItems();
  }

  void _refresh() => setState(() => _load());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusSection(),
          const SizedBox(height: 16),
          _buildExpiringSection(),
          const SizedBox(height: 16),
          _buildRecentSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 섹션 공통 카드 래퍼
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF2D5BFF)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // 냉장고 상태 요약
  Widget _buildStatusSection() {
    return FutureBuilder<FridgeStatus?>(
      future: _statusFuture,
      builder: (context, snapshot) {
        final status = snapshot.data;
        final loading = snapshot.connectionState == ConnectionState.waiting;

        return _sectionCard(
          icon: Icons.thermostat,
          title: '냉장고 상태',
          child: Row(
            children: [
              Expanded(
                child: _statusTile(
                  icon: Icons.device_thermostat,
                  label: '온도',
                  value: loading ? '-' : status != null ? '${status.temperature.toStringAsFixed(1)}°C' : '-',
                  color: const Color(0xFF2D5BFF),
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey[200]),
              Expanded(
                child: _statusTile(
                  icon: Icons.water_drop_outlined,
                  label: '습도',
                  value: loading ? '-' : status != null ? '${status.humidity.toStringAsFixed(1)}%' : '-',
                  color: const Color(0xFF00B4D8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 유통기한 임박 재료
  Widget _buildExpiringSection() {
    return FutureBuilder<List<ExpiringItem>>(
      future: _expiringFuture,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final loading = snapshot.connectionState == ConnectionState.waiting;

        return _sectionCard(
          icon: Icons.warning_amber_outlined,
          title: '유통기한 임박',
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? _emptyMessage('임박한 유통기한이 없습니다')
                  : Column(
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          if (i > 0) Divider(height: 1, color: Colors.grey[100]),
                          _expiringItemRow(items[i]),
                        ],
                      ],
                    ),
        );
      },
    );
  }

  // 최근 활동
  Widget _buildRecentSection() {
    return FutureBuilder<List<RecentItem>>(
      future: _recentFuture,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        final loading = snapshot.connectionState == ConnectionState.waiting;

        return _sectionCard(
          icon: Icons.history,
          title: '최근 활동',
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? _emptyMessage('최근 활동이 없습니다')
                  : Column(
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          if (i > 0) Divider(height: 1, color: Colors.grey[100]),
                          _recentItemRow(items[i]),
                        ],
                      ],
                    ),
        );
      },
    );
  }

  Widget _statusTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _expiringItemRow(ExpiringItem item) {
    final days = item.daysUntilExpiry;
    final Color badgeColor = days <= 0
        ? Colors.red
        : days == 1
            ? Colors.orange
            : const Color(0xFFFFB703);
    final String ddayText = days <= 0 ? '만료' : days == 0 ? 'D-Day' : 'D-$days';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.fastfood, size: 16, color: badgeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.category,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              ddayText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentItemRow(RecentItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF2D5BFF).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_circle_outline,
                size: 16, color: Color(0xFF2D5BFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${item.productName} 추가됨',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            item.timeAgo,
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _emptyMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(message,
            style: TextStyle(color: Colors.grey[400], fontSize: 13)),
      ),
    );
  }
}
