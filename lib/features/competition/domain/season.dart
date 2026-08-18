class Season {
  const Season({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.number,
  });

  final String id;
  final DateTime startsAt;
  final DateTime endsAt;
  final int number;

  bool contains(DateTime value) =>
      !value.isBefore(startsAt) && value.isBefore(endsAt);

  Duration get duration => endsAt.difference(startsAt);
}

class SeasonPolicy {
  const SeasonPolicy._();

  static const Duration duration = Duration(days: 30);

  static DateTime endFor(DateTime startsAt) => startsAt.add(duration);
}
