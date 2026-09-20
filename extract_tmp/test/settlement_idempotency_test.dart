import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/settlement_idempotency.dart';

void main() {
  test('match id is the stable settlement idempotency key', () {
    expect(SettlementIdempotency.keyForMatch(' match-123 '), 'match-123');
    expect(
      () => SettlementIdempotency.keyForMatch('   '),
      throwsArgumentError,
    );
  });

  test('existing settlement blocks a duplicate award', () {
    expect(
      SettlementIdempotency.canCreate(settlementAlreadyExists: false),
      isTrue,
    );
    expect(
      SettlementIdempotency.canCreate(settlementAlreadyExists: true),
      isFalse,
    );
  });
}
