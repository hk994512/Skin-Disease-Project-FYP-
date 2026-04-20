import '../global/config.dart';

class HomeProviderNotifier extends StateNotifier<int> {
  HomeProviderNotifier() : super(0);
  int onToggle(int currentItemIndex) {
    return state = currentItemIndex;
  }
}

final itemIndexProvider = StateNotifierProvider<HomeProviderNotifier, int>(
  (f) => HomeProviderNotifier(),
);
