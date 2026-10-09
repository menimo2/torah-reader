import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_font.dart';
import 'data/providers.dart';
import 'features/home/home_screen.dart';

class TorahReaderApp extends ConsumerWidget {
  const TorahReaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'בעל קורא',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final rtl = Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
        if (!kIsWeb) return rtl;
        return ColoredBox(
          color: const Color(0xFF1C1410),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430, maxHeight: 860),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: rtl,
              ),
            ),
          ),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C3A1E),
          brightness: Brightness.light,
        ),
        fontFamily: AppFont.family,
        useMaterial3: true,
      ),
      home: const _BootstrapGate(),
    );
  }
}

class _BootstrapGate extends ConsumerWidget {
  const _BootstrapGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ready = ref.watch(importReadyProvider);
    final progress = ref.watch(importProgressProvider);
    return ready.when(
      data: (_) => const HomeScreen(),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('לא ניתן לטעון את הטקסט:\n$error'),
          ),
        ),
      ),
      loading: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                progress == null
                    ? 'טוען את חומשי התורה…'
                    : 'מכין את ${progress.bookName} (${progress.bookIndex + 1}/${progress.bookCount})',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
