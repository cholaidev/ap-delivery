part of 'deliver_bloc_bloc.dart';

sealed class DeliverBlocState {}

final class DeliverBlocInitial extends DeliverBlocState {}

final class DeliverLoading extends DeliverBlocState {}

final class DeliverLoaded extends DeliverBlocState {
  final Map<String, dynamic> items;

  DeliverLoaded(this.items);
}

final class DeliverSuccess extends DeliverBlocState {
  final String message;
  DeliverSuccess(this.message);
}

final class DeliverError extends DeliverBlocState {
  final String error;
  DeliverError(this.error);
}
