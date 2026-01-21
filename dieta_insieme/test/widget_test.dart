import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dieta_insieme/main.dart';
import 'package:dieta_insieme/providers/app_state.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize date formatting
    await initializeDateFormatting('it_IT', null);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MyApp(),
      ),
    );

    // Verify that the app starts with "DietaInsieme" title
    expect(find.text('DietaInsieme'), findsOneWidget);
    
    // Verify FAB exists
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
