import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../finance/domain/repositories/i_finance_repository.dart';

// Events
abstract class ConfigEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchRatesEvent extends ConfigEvent {}

// State
class ConfigState extends Equatable {
  final Map<String, dynamic> rates;
  final bool isLoading;
  final String? error;

  const ConfigState({
    this.rates = const {},
    this.isLoading = false,
    this.error,
  });

  ConfigState copyWith({
    Map<String, dynamic>? rates,
    bool? isLoading,
    String? error,
  }) {
    return ConfigState(
      rates: rates ?? this.rates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [rates, isLoading, error];
}

// Bloc
class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  final IFinanceRepository _financeRepository;

  ConfigBloc(this._financeRepository) : super(const ConfigState()) {
    on<FetchRatesEvent>(_onFetchRates);
  }

  Future<void> _onFetchRates(FetchRatesEvent event, Emitter<ConfigState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final rates = await _financeRepository.getLatestRates();
      emit(state.copyWith(rates: rates, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }
}
