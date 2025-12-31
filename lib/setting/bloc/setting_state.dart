// setting_state.dart

sealed class SettingState {}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {}

class SettingLoaded extends SettingState {
  final num? milkPrice;

  SettingLoaded(this.milkPrice);
}

class SettingSuccess extends SettingState {
  final String message;

  SettingSuccess(this.message);
}

class SettingError extends SettingState {
  final String error;

  SettingError(this.error);
}
