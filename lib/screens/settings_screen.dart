import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/cache_service.dart';
import '../theme/theme_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final textPrimary = ThemeColors.textPrimary(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Appearance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary)),
        SwitchListTile(
          title: Text("Dark Mode", style: TextStyle(color: textPrimary)),
          value: theme.mode == ThemeMode.dark,
          onChanged: (_) => context.read<ThemeProvider>().toggle(),
        ),
        const SizedBox(height: 24),
        Text("Data", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary)),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text("Clear cached prices", style: TextStyle(color: textPrimary)),
          subtitle: const Text("Removes offline price data stored on this device"),
          trailing: const Icon(Icons.delete_outline),
          onTap: () async {
            await CacheService.clearAll();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Cached prices cleared")),
              );
            }
          },
        ),
      ],
    );
  }
}