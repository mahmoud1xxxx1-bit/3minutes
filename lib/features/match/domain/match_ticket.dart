enum MatchTicketStatus {
  waiting,
  matched;

  static MatchTicketStatus fromWire(String value) {
    return value == MatchTicketStatus.matched.name
        ? MatchTicketStatus.matched
        : MatchTicketStatus.waiting;
  }
}

class MatchTicket {
  const MatchTicket({
    required this.uid,
    required this.status,
    this.matchId,
  });

  final String uid;
  final MatchTicketStatus status;
  final String? matchId;
}
