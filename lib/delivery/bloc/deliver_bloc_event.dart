part of 'deliver_bloc_bloc.dart';

sealed class DeliverBlocEvent {}

class LoadDeliveryItems extends DeliverBlocEvent {
  final int employeeId;
  final String? filter; // today | week | month
  final String? fromDate;
  final String? toDate;

  LoadDeliveryItems(this.employeeId, {this.filter, this.fromDate, this.toDate});
}

class MarkDelivered extends DeliverBlocEvent {
  final int employeeId;
  final List<int> supplyIds;

  MarkDelivered({required this.employeeId, required this.supplyIds});
}
