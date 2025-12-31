import 'package:flutter/material.dart';
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

  /// ✅ SUPPLY ID based selection (CORRECT)
  final Set<int> selectedSupplyIds = {};

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    /// 🔥 DEFAULT = TODAY
    final range = _resolveDateRange(DateFilterType.today);
    _loadData(range);
  }

  @override
  void dispose() {
    _tabController.dispose(); // ✅ prevent memory leak
    super.dispose();
  }

  /// 🔹 Convert filter → DateTimeRange
  DateTimeRange _resolveDateRange(DateFilterType filter) {
    final now = DateTime.now();

    switch (filter) {
      case DateFilterType.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        return DateTimeRange(start: start, end: end);

      case DateFilterType.week:
        final start = DateTime(
          now.year,
          now.month,
          now.day - (now.weekday - 1),
        );
        final end = start.add(const Duration(days: 7));
        return DateTimeRange(start: start, end: end);

      case DateFilterType.month:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return DateTimeRange(start: start, end: end);

      case DateFilterType.custom:
        return _customRange!;
    }
  }

  /// 🔹 LOAD API
  void _loadData(DateTimeRange range) {
    selectedSupplyIds.clear(); // ✅ reset selection safely

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

  /// 🔹 FILTER CHANGE HANDLER
  Future<void> _onFilterChange(DateFilterType value) async {
    if (value == DateFilterType.custom) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
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

  String _fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/"
      "${d.month.toString().padLeft(2, '0')}/"
      "${d.year}";

  /// 🔹 METRICS TAB
  Widget _buildMetrics(List items) {
    final totalQty = items.fold<num>(0, (s, i) => s + (i['quantity'] ?? 0));
    final totalAmt = items.fold<num>(0, (s, i) => s + (i['amount'] ?? 0));
    final customers = items.map((i) => i['customer']['id']).toSet().length;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _metric("Total Customers", customers.toString()),
          _metric("Total Milk (L)", totalQty.toString()),
          _metric("Total Amount", "₹$totalAmt"),
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

  /// 🔹 DELIVERY LIST (SUPPLY ID BASED)
  Widget _buildDelivery(List items) {
    if (items.isEmpty) {
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
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          final supplyId = item['supply']['id'];
          final customer = item['customer'];
          final checked = selectedSupplyIds.contains(supplyId);

          return Card(
            child: CheckboxListTile(
              value: checked,
              onChanged: (v) {
                setState(() {
                  v == true
                      ? selectedSupplyIds.add(supplyId)
                      : selectedSupplyIds.remove(supplyId);
                });
              },
              title: Text(
                customer['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${item['milk']} • ${item['quantity']} L\n"
                "Date: ${item['supply']['supply_date']}",
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery", style: TextStyle(color: whiteColor)),
        backgroundColor: const Color(0xFF2E7D32),
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
          /// 🔽 DATE FILTER BAR
          Container(
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
          ),

          Expanded(
            child: BlocBuilder<DeliverBlocBloc, DeliverBlocState>(
              builder: (context, state) {
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
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: selectedSupplyIds.isEmpty ? Colors.grey : Colors.green,
        onPressed:
            selectedSupplyIds.isEmpty
                ? null
                : () {
                  context.read<DeliverBlocBloc>().add(
                    MarkDelivered(
                      employeeId: widget.employeeId,
                      supplyIds: selectedSupplyIds.toList(),
                    ),
                  );
                },
        icon: const Icon(Icons.check),
        label: const Text(
          "Mark Delivered",
          style: TextStyle(color: whiteColor),
        ),
      ),
    );
  }
}
