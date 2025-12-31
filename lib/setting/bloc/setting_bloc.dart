// setting_bloc.dart

import 'package:flutter_application_1/setting/setting_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'setting_event.dart';
import 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final settingRepo = SettingRepository();

  num? milkPrice;

  SettingBloc() : super(SettingInitial()) {
    on<LoadSettings>(_loadSettings);
    on<UpdateMilkPrice>(_updateMilkPrice);
  }

  Future<void> _loadSettings(
    LoadSettings event,
    Emitter<SettingState> emit,
  ) async {
    try {
      emit(SettingLoading());
      var milkPriceInit = await settingRepo.getMilkPrice();
      print('get seting price $milkPriceInit');
      milkPrice = milkPriceInit;
      emit(SettingLoaded(milkPrice));
    } catch (e) {
      print(';setting error$e');
      emit(SettingError(e.toString()));
    }
  }

  Future<void> _updateMilkPrice(
    UpdateMilkPrice event,
    Emitter<SettingState> emit,
  ) async {
    try {
      emit(SettingLoading());
      await settingRepo.updateMilkPrice(event.milkPrice);
      milkPrice = event.milkPrice;
      emit(SettingSuccess("Milk price updated"));
      emit(SettingLoaded(milkPrice));
    } catch (e) {
      emit(SettingError(e.toString()));
    }
  }
}
