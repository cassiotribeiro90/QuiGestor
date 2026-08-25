import 'package:flutter_test/flutter_test.dart';
import 'package:quigestor/main.dart';
import 'package:quigestor/shared/api/api_client.dart';
import 'package:quigestor/app/di/dependencies.dart';

void main() {
  testWidgets('QuiGestorApp smoke test', (WidgetTester tester) async {
    await setupDependencies();
    await tester.pumpWidget(QuiGestorApp(apiClient: ApiClient()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(QuiGestorApp), findsOneWidget);
  });
}
