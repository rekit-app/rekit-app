import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage_keys.dart';
import '../core/config/stage_config.dart';
import 'root_screen.dart';
import '../core/utils/progress_helper.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ResultData>(
      future: _loadData(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final data = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('진단 결과')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DiagnosisSummaryCard(data: data),
                const SizedBox(height: 24),
                _StageInfoCard(data: data),
                const SizedBox(height: 24),
                const _StepGuide(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        ctx,
                        MaterialPageRoute(builder: (_) => const RootScreen()),
                        (_) => false,
                      );
                    },
                    child: Text(
                      '프로그램 시작하기',
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<_ResultData> _loadData() async {
  final prefs = await SharedPreferences.getInstance();

  final dx = prefs.getString(StorageKeys.diagnosisCode) ?? '';
  final stage = prefs.getInt(StorageKeys.stage) ?? 1;

  final maxDays = getStage1Days(dx);

  return _ResultData(
    diagnosisCode: dx,
    stage: stage,
    maxDays: maxDays,
  );
}

class _ResultData {
  final String diagnosisCode;
  final int stage;
  final int maxDays;

  const _ResultData({
    required this.diagnosisCode,
    required this.stage,
    required this.maxDays,
  });


  String get bodyPartLabel {
    return getBodyPartLabel(diagnosisCode);
  }
}

// ─── _DiagnosisSummaryCard ──────────────────────────────────

class _DiagnosisSummaryCard extends StatelessWidget {
  final _ResultData data;

  const _DiagnosisSummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '진단 부위',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              data.bodyPartLabel,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              '${data.bodyPartLabel} 관절 가동성과 유연성을 회복하기 위한 프로그램입니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _StageInfoCard ─────────────────────────────────────────

class _StageInfoCard extends StatelessWidget {
  final _ResultData data;

  const _StageInfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stage ${data.stage}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'ROM 회복 · 스트레칭',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '총 ${data.maxDays}일 구성. 매일 간단한 스트레칭과 관절 가동성 운동으로 구성되어 있습니다.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _StepGuide ─────────────────────────────────────────────

class _StepGuide extends StatelessWidget {
  const _StepGuide();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('앞으로의 진행', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            const _StepRow(
              step: 1,
              label: 'ROM 회복 · 스트레칭',
              active: true,
            ),
            const _StepRow(
              step: 2,
              label: '근력 강화',
              active: false,
            ),
            const _StepRow(
              step: 3,
              label: '기능 회복',
              active: false,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int step;
  final String label;
  final bool active;
  final bool isLast;

  const _StepRow({
    required this.step,
    required this.label,
    required this.active,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator with connecting line
        Column(
          children: [
            // Circle with glow effect for active
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: active
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Connecting line (not for last item)
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: active
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Label
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: active
                ? theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
      ],
    );
  }
}
