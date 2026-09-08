import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torah_reader/features/reading/hold_to_peek.dart';

void main() {
  testWidgets('peek turns on after 1.5 seconds and off on release', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HoldToPeek(
          builder: (context, peeking) => Text(peeking ? 'peek' : 'idle'),
        ),
      ),
    );

    expect(find.text('idle'), findsOneWidget);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('idle')),
    );
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('idle'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('peek'), findsOneWidget);

    await gesture.up();
    await tester.pump();
    expect(find.text('idle'), findsOneWidget);
  });

  testWidgets('moving the pointer before 1.5 seconds cancels peek', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HoldToPeek(
          builder: (context, peeking) => Text(peeking ? 'peek' : 'idle'),
        ),
      ),
    );

    final center = tester.getCenter(find.text('idle'));
    final gesture = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('peek'), findsNothing);
    await gesture.up();
  });
}
