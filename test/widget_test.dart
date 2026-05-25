import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dubebook/main.dart';

void main() {
  testWidgets('App loads successfully smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: DubeNoteApp(),
      ),
    );

    // Verify the app starts up and displays the main widget
    expect(find.byType(DubeNoteApp), findsOneWidget);
  });
}
