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
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4DD9BB), Color(0xFF4DC2A6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Close button — white on gradient
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Hero illustration — white circle on gradient
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          heroIcon,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title — white on gradient
                      Text(
                        '$bodyPartLabel 진단 전 확인',
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Warning message — semi-transparent white card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          warningMessage,
                          style: text.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Red flag items — white cards
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
                    // Safe — proceed (white button)
                    _ActionCard(
                      icon: Icons.check_circle_outline_rounded,
                      label: confirmLabel,
                      iconColor: const Color(0xFF4DD9BB),
                      borderColor: Colors.white,
                      backgroundColor: Colors.white,
                      textColor: const Color(0xFF4DD9BB),
                      onTap: onConfirm,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                color: const Color(0xFFFFDAD6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: const Color(0xFFBA1A1A), size: 18),
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
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: text.bodySmall?.copyWith(
                      color: const Color(0xFF6E7787),
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
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.borderColor,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF2D3142),
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.5),
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
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
