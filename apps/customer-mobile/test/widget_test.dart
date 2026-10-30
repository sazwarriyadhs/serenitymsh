import 'package:flutter_test/flutter_test.dart';
import 'package:serenity_customer_mobile/main.dart';

void main() {
  testWidgets('Customer app renders successfully', (tester) async {
    await tester.pumpWidget(const SerenityApp());

    expect(find.byType(SerenityApp), findsOneWidget);
    expect(find.byType(IPBHomePage), findsOneWidget);
    expect(find.text('IPB Convention Hotel'), findsOneWidget);
  });

  testWidgets('Customer navigation is available', (tester) async {
    await tester.pumpWidget(const SerenityApp());

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Booking'), findsOneWidget);
    expect(find.text('Layanan'), findsOneWidget);
    expect(find.text('Concierge'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
