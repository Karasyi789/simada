import 'package:flutter_test/flutter_test.dart';
import 'package:simada_mobile/main.dart';
import 'package:simada_mobile/core/constants/app_constants.dart';

void main() {
  testWidgets('SIMADA App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SimadaApp());
    expect(find.text(AppConstants.appName), findsOneWidget);
  });
}
