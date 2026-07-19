import 'package:flutter_test/flutter_test.dart';

import 'package:cicsextension_offiice/app.dart';

void main() {
  testWidgets('login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CicsExtensionApp());

    expect(find.text('LOGIN ACCOUNT'), findsOneWidget);
    expect(
      find.text('CICS Extension Projects and Technology Transfer'),
      findsOneWidget,
    );
  });
}
