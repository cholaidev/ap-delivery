import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/bloc/auth_bloc.dart';
import 'package:flutter_application_1/auth/bloc/auth_event.dart';
import 'package:flutter_application_1/auth/screen/login_page.dart';
import 'package:flutter_application_1/shared/date_filtered_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  DateFilterType _filter = DateFilterType.today;
  DateTimeRange? _customRange;

  /// ✅ STORE UNIQUE DELIVERY ITEM IDs (NOT supply id)
  final Set<int> selectedDeliveryIds = {};

  late TabController _tabController;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allItems = [];
  List<dynamic> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final range = _resolveDateRange(DateFilterType.today);
    _loadData(range);

    _searchController.addListener(_onSearchChanged);

    _tabController.addListener(() {
      setState(() {}); // 🔥 rebuild when tab changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 🔍 SEARCH (NAME / PHONE / HOUSE / LOCATION / MILK)
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

  /// 🔹 DATE RANGE
  DateTimeRange _resolveDateRange(DateFilterType filter) {
    final now = DateTime.now();

    switch (filter) {
      case DateFilterType.today:
        final start = DateTime(now.year, now.month, now.day);
        return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 1)),
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

  /// 🔹 LOAD API
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

  /// 🔹 DELIVERY LIST (FIXED SELECTION)
  Widget _buildDelivery(List items) {
    _allItems = items;
    if (!_isSearching) _filteredItems = items;

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

          /// ✅ UNIQUE DELIVERY ITEM ID
          final deliveryId = item['id'];

          final customer = item['customer'];
          final checked = selectedDeliveryIds.contains(deliveryId);

          return Card(
            child: CheckboxListTile(
              key: ValueKey(deliveryId), // ✅ PREVENT STATE LEAK
              value: checked,
              onChanged: (v) {
                setState(() {
                  v == true
                      ? selectedDeliveryIds.add(deliveryId)
                      : selectedDeliveryIds.remove(deliveryId);
                });
              },
              title: Text(
                customer['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🏠 ${customer['house_name'] ?? ''}"),
                  Text("📞 ${customer['phone'] ?? ''}"),
                  Text(
                    "📍 ${customer['location'] ?? ''}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item['milk']} • ${item['quantity']} L",
                    style: const TextStyle(fontWeight: FontWeight.w600),
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

  /// 🔹 METRICS TAB
  Widget _buildMetrics(List items) {
    // 🔹 TOTALS
    final totalQty = items.fold<num>(0, (s, i) => s + (i['quantity'] ?? 0));
    final totalAmt = items.fold<num>(0, (s, i) => s + (i['amount'] ?? 0));
    final totalCustomers = items.map((i) => i['customer']['id']).toSet().length;

    // 🔹 DELIVERED METRICS
    final deliveredItems = items.where((i) => i['is_delivered'] == 1).toList();

    final deliveredQty = deliveredItems.fold<num>(
      0,
      (s, i) => s + (i['quantity'] ?? 0),
    );

    final deliveredAmt = deliveredItems.fold<num>(
      0,
      (s, i) => s + (i['amount'] ?? 0),
    );

    final deliveredCustomers =
        deliveredItems.map((i) => i['customer']['id']).toSet().length;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 TOTAL
          _metric("Total Customers", totalCustomers.toString()),
          _metric("Total Milk (L)", totalQty.toString()),

          // _metric("Total Amount", "₹$totalAmt"),
          const Divider(height: 32),

          // 🔹 DELIVERED
          _metric("Delivered Customers", deliveredCustomers.toString()),
          _metric("Delivered Milk (L)", deliveredQty.toString()),
          // _metric("Delivered Amount", "₹$deliveredAmt"),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

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
                    textAlignVertical: TextAlignVertical.center,
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

      body: BlocBuilder<DeliverBlocBloc, DeliverBlocState>(
        builder: (_, state) {
          if (state is DeliverLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DeliverLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildDelivery(state.items),
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

      floatingActionButton:
          (_tabController.index == 0 && selectedDeliveryIds.isNotEmpty)
              ? FloatingActionButton.extended(
                backgroundColor: Colors.green,
                onPressed: () {
                  print('check delivery ids ${selectedDeliveryIds.toList()}');
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
