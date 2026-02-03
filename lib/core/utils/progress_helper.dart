double getStageProgress(int day, int maxDays) {
  if (maxDays <= 0) return 0.0;
  final progress = day / maxDays;
  return progress.clamp(0.0, 1.0);
}

String getBodyPartLabel(String? dx) {
  if (dx == null) {
    return '';
  }
  if (dx.startsWith('DX_NECK_') ||
      dx.startsWith('DX_HEADACHE_') ||
      dx.startsWith('DX_ULTT_') ||
      dx == 'DX_CT' ||
      dx == 'DX_NORMAL' ||
      dx == 'DX_MENTAL') {
    return '목';
  }
  if (dx.startsWith('DX_')) {
    return '어깨';
  }
  return '부위 미확인';
}
