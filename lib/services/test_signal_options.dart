import 'package:signals/signals_flutter.dart';

void main() {
  final s = signal(0, options: const SignalOptions(debugLabel: 'test'));
  print(s);
}
