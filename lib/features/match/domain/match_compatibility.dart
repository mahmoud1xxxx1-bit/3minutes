class MatchCompatibility {
  const MatchCompatibility._();

  static bool supportsRegistry({
    required int matchRegistryVersion,
    required int appRegistryVersion,
  }) {
    return matchRegistryVersion == appRegistryVersion;
  }
}
