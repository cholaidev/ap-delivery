import 'package:flutter_application_1/delivery/repo/delivery_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'deliver_bloc_event.dart';
part 'deliver_bloc_state.dart';

class DeliverBlocBloc extends Bloc<DeliverBlocEvent, DeliverBlocState> {
  final DeliverRepository repository = DeliverRepository();

  DeliverBlocBloc() : super(DeliverBlocInitial()) {
    on<LoadDeliveryItems>(_loadItems);
    on<MarkDelivered>(_markDelivered);
  }

  Future<void> _loadItems(
    LoadDeliveryItems event,
    Emitter<DeliverBlocState> emit,
  ) async {
    emit(DeliverLoading());
    try {
      final items = await repository.fetchDeliveryItems(
        employeeId: event.employeeId,
        filter: event.filter,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );
      print('check items $items');
      emit(DeliverLoaded(items));
    } catch (e) {
      emit(DeliverError(e.toString()));
    }
  }

  Future<void> _markDelivered(
    MarkDelivered event,
    Emitter<DeliverBlocState> emit,
  ) async {
    emit(DeliverLoading());
    try {
      await repository.markDelivered(
        employeeId: event.employeeId,
        supplyIds: event.supplyIds,
      );
      emit(DeliverSuccess("Delivered successfully"));
      add(LoadDeliveryItems(event.employeeId)); // reload
    } catch (e) {
      emit(DeliverError(e.toString()));
    }
  }
}
