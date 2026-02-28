import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_partner/main.dart';
import 'package:ai_partner/logic/services/settings_service.dart';
import 'package:ai_partner/logic/services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // 1. Initialize SharedPreferences with mock values
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 2. Initialize the required services
    final settingsService = SettingsService(prefs);
    final ttsService = TtsService();

    // 3. Build our app and trigger a frame, passing the new dependencies
    await tester.pumpWidget(
      MyApp(
        prefs: prefs,
        settingsService: settingsService,
        ttsService: ttsService,
      ),
    );

    // Note: If your NavbarScreen doesn't have a counter,
    // these '0' and '1' checks will fail.
    // Ensure you are testing for text actually present on your home screen.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
