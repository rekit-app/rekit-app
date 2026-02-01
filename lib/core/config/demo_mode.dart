const bool kDemoMode = true;

bool allowDemoPaywallBypass() {
  return kDemoMode;
}

int getDemoDayIncrement() {
  return kDemoMode ? 3 : 1;
}
