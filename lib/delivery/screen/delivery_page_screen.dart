import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_1/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/auth/bloc/auth_event.dart';
import 'package:flutter_application_1/auth/screen/login_page.dart';

import 'package:flutter_application_1/shared/date_filtered_helper.dart';
import 'package:flutter_application_1/shared/constant/colors.dart';

import '../bloc/deliver_bloc_bloc.dart';

class DeliveryPage extends StatefulWidget {
  final int employeeId;

  const DeliveryPage({super.key, required this.employeeId});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage>
    with SingleTickerProviderStateMixin {
  /// 🔹 DATE FILTER
  DateFilterType _filter = DateFilterType.today;
  DateTimeRange? _customRange;

  /// 🔹 SELECTION
  final Set<int> selectedDeliveryIds = {};

  /// 🔹 TAB
  late TabController _tabController;

  /// 🔹 SEARCH
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allItems = [];
  List<dynamic> _filteredItems = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));

    _searchController.addListener(_onSearchChanged);

    /// 🔥 DEFAULT LOAD (TODAY)
    final range = _resolveDateRange(DateFilterType.today);
    _loadData(range);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ===============================
  // 🔹 DATE FILTER LOGIC
  // ===============================

  DateTimeRange _resolveDateRange(DateFilterType filter) {
    final now = DateTime.now();

    switch (filter) {
      case DateFilterType.today:
        final start = DateTime(now.year, now.month, now.day);
        return DateTimeRange(
          start: start,
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );

      case DateFilterType.week:
        final start = DateTime(
          now.year,
          now.month,
          now.day - (now.weekday - 1),
        );
        return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 7)),
        );

      case DateFilterType.month:
        final start = DateTime(now.year, now.month, 1);
        return DateTimeRange(
          start: start,
          end: DateTime(now.year, now.month + 1, 1),
        );

      case DateFilterType.custom:
        return _customRange!;
    }
  }

  Future<void> _onFilterChange(DateFilterType value) async {
    if (value == DateFilterType.custom) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(DateTime.now().year + 1),
      );

      if (range == null) return;

      setState(() {
        _filter = value;
        _customRange = range;
      });

      _loadData(range);
    } else {
      final range = _resolveDateRange(value);

      setState(() {
        _filter = value;
        _customRange = null;
      });

      _loadData(range);
    }
  }

  String _formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";
  }

  // ===============================
  // 🔹 API LOAD
  // ===============================

  void _loadData(DateTimeRange range) {
    selectedDeliveryIds.clear();

    context.read<DeliverBlocBloc>().add(
      LoadDeliveryItems(
        widget.employeeId,
        fromDate: _fmt(range.start),
        toDate: _fmt(range.end),
      ),
    );
  }

  Future<void> _onRefresh() async {
    final range = _resolveDateRange(_filter);
    _loadData(range);
  }

  String _fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  // ===============================
  // 🔍 SEARCH
  // ===============================

  void _onSearchChanged() {
    final q = _searchController.text.toLowerCase();

    setState(() {
      _filteredItems =
          _allItems.where((i) {
            final c = i['customer'] ?? {};
            return (c['name'] ?? '').toLowerCase().contains(q) ||
                (c['phone'] ?? '').toString().contains(q) ||
                (c['house_name'] ?? '').toLowerCase().contains(q) ||
                (c['location'] ?? '').toLowerCase().contains(q) ||
                (i['milk'] ?? '').toLowerCase().contains(q);
          }).toList();
    });
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filteredItems = _allItems;
    });
  }

  // ===============================
  // 🔽 DATE FILTER BAR UI
  // ===============================

  Widget _buildDateFilterBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter by date",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              DropdownButton<DateFilterType>(
                value: _filter,
                underline: const SizedBox(),
                onChanged: (v) {
                  if (v != null) _onFilterChange(v);
                },
                items: const [
                  DropdownMenuItem(
                    value: DateFilterType.today,
                    child: Text("Today"),
                  ),
                  DropdownMenuItem(
                    value: DateFilterType.week,
                    child: Text("This Week"),
                  ),
                  DropdownMenuItem(
                    value: DateFilterType.month,
                    child: Text("This Month"),
                  ),
                  DropdownMenuItem(
                    value: DateFilterType.custom,
                    child: Text("Custom"),
                  ),
                ],
              ),
            ],
          ),
          if (_filter == DateFilterType.custom && _customRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "From ${_formatDate(_customRange!.start)} "
                "to ${_formatDate(_customRange!.end)}",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===============================
  // 📦 DELIVERY LIST
  // ===============================

  Widget _buildDelivery(List items) {
    _allItems = items;
    if (!_isSearching) _filteredItems = items;
    print('metrics items $items');
    if (_filteredItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(child: Text("No deliveries")),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _filteredItems.length,
        itemBuilder: (_, i) {
          final item = _filteredItems[i];
          final deliveryId = item['id'];
          final customer = item['customer'];

          final checked = selectedDeliveryIds.contains(deliveryId);
          double _d(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;
          return Card(
            child: CheckboxListTile(
              key: ValueKey(deliveryId),
              value: checked,
              onChanged: (v) {
                setState(() {
                  v == true
                      ? selectedDeliveryIds.add(deliveryId)
                      : selectedDeliveryIds.remove(deliveryId);
                });
              },
              title: Text(
                "🏠${customer['house_name'] ?? ''}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: // helpers inline (safe double)
                  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("👤 ${customer['name'] ?? ''}"),
                  Text("📞 ${customer['phone'] ?? ''}"),
                  Text(
                    "📍 ${customer['location'] ?? ''}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),

                  if (_d(item['cow_milk_quantity']) > 0)
                    Text(
                      "🐄 Cow : ${_d(item['cow_milk_quantity']).toStringAsFixed(2)} L",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                  if (_d(item['buffalo_milk_quantity']) > 0)
                    Text(
                      "🐃 Buffalo : ${_d(item['buffalo_milk_quantity']).toStringAsFixed(2)} L",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                  const SizedBox(height: 2),

                  Text(
                    "Total : ${_d(item['total_quantity']).toStringAsFixed(2)} L",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  Text(
                    "Date: ${item['supply']['supply_date']}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===============================
  // 📊 METRICS TAB
  // ===============================

  Widget _buildMetrics(Map<String, dynamic> data) {
    final totals = data['totals'];

    final delivered = data['delivered'];

    final undelivered = data['undelivered'];

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 🔹 TOTAL
          _sectionTitle("Total Summary", Icons.analytics, Colors.blue),

          _metric(
            "Total Customers",
            totals['customers'].toString(),
            Icons.people,
            Colors.blue,
          ),

          _metric(
            "Total Cow Milk (L)",
            totals['cow_milk'].toString(),
            Icons.water_drop,
            Colors.green,
          ),

          _metric(
            "Total Buffalo Milk (L)",
            totals['buffalo_milk'].toString(),
            Icons.opacity,
            Colors.deepPurple,
          ),

          _metric(
            "Total Quantity (L)",
            totals['total_quantity'].toString(),
            Icons.local_drink,
            Colors.orange,
          ),

          const SizedBox(height: 16),

          /// 🔹 DELIVERED
          _sectionTitle("Delivered", Icons.check_circle, Colors.green),

          _metric(
            "Delivered Customers",
            delivered['customers'].toString(),
            Icons.people_alt,
            Colors.green,
          ),

          _metric(
            "Delivered Cow Milk (L)",
            delivered['cow_milk'].toString(),
            Icons.water_drop,
            Colors.green,
          ),

          _metric(
            "Delivered Buffalo Milk (L)",
            delivered['buffalo_milk'].toString(),
            Icons.opacity,
            Colors.teal,
          ),

          _metric(
            "Delivered Quantity (L)",
            delivered['total_quantity'].toString(),
            Icons.local_shipping,
            Colors.green,
          ),

          const SizedBox(height: 16),

          /// 🔹 UNDELIVERED
          _sectionTitle("Undelivered", Icons.pending_actions, Colors.red),

          _metric(
            "Undelivered Customers",
            undelivered['customers'].toString(),
            Icons.people_outline,
            Colors.red,
          ),

          _metric(
            "Undelivered Cow Milk (L)",
            undelivered['cow_milk'].toString(),
            Icons.water_drop_outlined,
            Colors.red,
          ),

          _metric(
            "Undelivered Buffalo Milk (L)",
            undelivered['buffalo_milk'].toString(),
            Icons.opacity,
            Colors.deepOrange,
          ),

          _metric(
            "Undelivered Quantity (L)",
            undelivered['total_quantity'].toString(),
            Icons.warning_amber,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 20),
          ),

          const SizedBox(width: 10),

          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),

        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),

        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
  // ===============================
  // 🔐 LOGOUT
  // ===============================

  void _logout() {
    context.read<AuthBloc>().add(LogoutEvent());
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (_) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                child: const Text("Logout"),
              ),
            ],
          ),
    );
  }

  // ===============================
  // 🧱 BUILD
  // ===============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title:
            _isSearching
                ? Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Search name, phone, house, location...",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                )
                : const Text("Delivery", style: TextStyle(color: whiteColor)),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: whiteColor,
            ),
            onPressed: () => _isSearching ? _stopSearch() : _startSearch(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: whiteColor),
            onPressed: _showLogoutDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: "Delivery"), Tab(text: "Metrics")],
        ),
      ),
      body: Column(
        children: [
          _buildDateFilterBar(),
          Expanded(
            child: BlocBuilder<DeliverBlocBloc, DeliverBlocState>(
              builder: (_, state) {
                if (state is DeliverLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DeliverLoaded) {
                  final data = state.items;
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDelivery(
                        List<Map<String, dynamic>>.from(
                          data['undelivered']['items'],
                        ),
                      ),
                      _buildMetrics(state.items),
                    ],
                  );
                }
                if (state is DeliverError) {
                  return Center(child: Text(state.error));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
          (_tabController.index == 0 && selectedDeliveryIds.isNotEmpty)
              ? FloatingActionButton.extended(
                backgroundColor: Colors.green,
                onPressed: () {
                  context.read<DeliverBlocBloc>().add(
                    MarkDelivered(
                      employeeId: widget.employeeId,
                      supplyIds: selectedDeliveryIds.toList(),
                    ),
                  );
                },
                icon: const Icon(Icons.check, color: whiteColor),
                label: const Text(
                  "Mark Delivered",
                  style: TextStyle(color: whiteColor),
                ),
              )
              : null,
    );
  }
}
