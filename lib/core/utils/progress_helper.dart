double getStageProgress(int day, int maxDays) {
  if (maxDays <= 0) return 0.0;
  final progress = day / maxDays;
  return progress.clamp(0.0, 1.0);
}
