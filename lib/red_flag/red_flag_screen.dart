import 'package:flutter/material.dart';

/// Data model for a single red flag warning item.
class RedFlagItem {
  final String title;
  final String description;
  final IconData icon;

  const RedFlagItem({
    required this.title,
    required this.description,
    this.icon = Icons.warning_rounded,
  });
}

/// Shared Red Flag screen used by shoulder, neck, and back variants.
/// Displays medical warnings before diagnosis begins.
class RedFlagScreen extends StatelessWidget {
  final String bodyPartLabel;
  final String warningMessage;
  final IconData heroIcon;
  final List<RedFlagItem> items;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const RedFlagScreen({
    super.key,
    required this.bodyPartLabel,
    required this.warningMessage,
    required this.heroIcon,
    required this.items,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Hero illustration
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        heroIcon,
                        size: 48,
                        color: colors.error,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      '$bodyPartLabel 진단 전 확인',
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Warning message
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        warningMessage,
                        style: text.bodyMedium?.copyWith(
                          color: colors.onErrorContainer,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Red flag items
                    ...items.map((item) => _RedFlagCard(item: item)),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  // Safe — proceed
                  _ActionCard(
                    icon: Icons.check_circle_outline_rounded,
                    label: confirmLabel,
                    iconColor: colors.primary,
                    borderColor: colors.primary,
                    onTap: onConfirm,
                  ),
                  const SizedBox(height: 12),
                  // Danger — go back
                  _ActionCard(
                    icon: Icons.local_hospital_rounded,
                    label: '해당 사항 있음, 병원 방문',
                    iconColor: colors.error,
                    borderColor: colors.error,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _RedFlagCard ───────────────────────────────────────────

class _RedFlagCard extends StatelessWidget {
  final RedFlagItem item;

  const _RedFlagCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: colors.error, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _ActionCard ────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: text.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: borderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
