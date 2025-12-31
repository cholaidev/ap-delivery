// setting_event.dart

sealed class SettingEvent {}

class LoadSettings extends SettingEvent {}

class UpdateMilkPrice extends SettingEvent {
  final num? milkPrice;

  UpdateMilkPrice(this.milkPrice);
}
