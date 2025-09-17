enum TodaySmartStatus { loading, success, error }

class FixturesState {
  final TodaySmartStatus status;
  final List fixtures;
  final String? errorMessage;

  FixturesState({
    required this.status,
    required this.fixtures,
    this.errorMessage,
  });

  factory FixturesState.loading() => FixturesState(status: TodaySmartStatus.loading, fixtures: []);
  factory FixturesState.success(List fixtures) => FixturesState(status: TodaySmartStatus.success, fixtures: fixtures);
  factory FixturesState.error(String msg) => FixturesState(status: TodaySmartStatus.error, fixtures: [], errorMessage: msg);
}
