import 'package:flutter_test/flutter_test.dart';
import 'package:lineup_builder_example/main.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const LineupBuilderExampleApp());
    expect(find.text('Lineup Builder'), findsOneWidget);
    expect(find.text('Display Mode'), findsOneWidget);
    expect(find.text('Builder Mode'), findsOneWidget);
  });
}
