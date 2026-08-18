import 'package:flutter/widgets.dart';

class SocialCopy {
  const SocialCopy._({required this.isArabic});

  final bool isArabic;

  static SocialCopy of(BuildContext context) {
    return SocialCopy._(
      isArabic: Localizations.localeOf(context).languageCode == 'ar',
    );
  }

  String get friends => isArabic ? 'الأصدقاء' : 'Friends';
  String get friendsSubtitle => isArabic
      ? 'العب مع أصدقائك وادعهم إلى تحديات خاصة.'
      : 'Play with friends and invite them to private challenges.';
  String get yourFriendCode => isArabic ? 'رمز الصديق الخاص بك' : 'Your friend code';
  String get copyCode => isArabic ? 'نسخ الرمز' : 'Copy code';
  String get findFriend => isArabic ? 'البحث عن صديق' : 'Find a friend';
  String get friendCodeHint => isArabic ? 'مثال PLAYER#4821' : 'Example PLAYER#4821';
  String get search => isArabic ? 'بحث' : 'Search';
  String get sendRequest => isArabic ? 'إرسال طلب' : 'Send request';
  String get requestSent => isArabic ? 'تم إرسال طلب الصداقة' : 'Friend request sent';
  String get playerNotFound => isArabic ? 'لم يتم العثور على اللاعب' : 'Player not found';
  String get invalidFriendCode => isArabic ? 'رمز الصديق غير صحيح' : 'Invalid friend code';
  String get requests => isArabic ? 'الطلبات' : 'Requests';
  String get acceptedFriends => isArabic ? 'أصدقاؤك' : 'Your friends';
  String get recentPlayers => isArabic ? 'لاعبون لعبت معهم مؤخرًا' : 'Recent players';
  String get noFriendsYet => isArabic ? 'لا يوجد أصدقاء بعد' : 'No friends yet';
  String get noRequests => isArabic ? 'لا توجد طلبات جديدة' : 'No new requests';
  String get noRecentPlayers => isArabic ? 'لا يوجد لاعبون حديثون بعد' : 'No recent players yet';
  String get accept => isArabic ? 'قبول' : 'Accept';
  String get remove => isArabic ? 'إزالة' : 'Remove';
  String get block => isArabic ? 'حظر' : 'Block';
  String get addFriend => isArabic ? 'إضافة صديق' : 'Add friend';
  String get playWithFriends => isArabic ? 'العب مع الأصدقاء' : 'Play with friends';
  String get ranked => isArabic ? 'تنافسي' : 'Ranked';
  String get rankedSubtitle => isArabic ? '1 ضد 1 • ترتيب موسمي' : '1v1 • Seasonal ranking';
  String get createRoom => isArabic ? 'إنشاء غرفة' : 'Create room';
  String get joinRoom => isArabic ? 'الانضمام لغرفة' : 'Join room';
  String get roomCode => isArabic ? 'رمز الغرفة' : 'Room code';
  String get players2 => isArabic ? 'لاعبان' : '2 players';
  String get players4 => isArabic ? '4 لاعبين' : '4 players';
  String get players6 => isArabic ? '6 لاعبين' : '6 players';
  String get privateRoom => isArabic ? 'غرفة خاصة' : 'Private room';
  String get roomRule => isArabic
      ? 'نفس 3 دقائق ونفس 8 ألعاب ونفس الترتيب للجميع.'
      : 'Same 3 minutes, 8 games and game order for everyone.';
  String get roomNoRankedRp => isArabic
      ? 'مباريات الأصدقاء لا تمنح RP.'
      : 'Friend matches do not award RP.';
  String get invite => isArabic ? 'دعوة' : 'Invite';
  String get shareRoom => isArabic ? 'مشاركة الغرفة' : 'Share room';
  String get roomFull => isArabic ? 'الغرفة مكتملة' : 'Room full';
  String get waitingPlayers => isArabic ? 'بانتظار اللاعبين' : 'Waiting for players';
  String get party => isArabic ? 'المجموعة' : 'Party';
  String get playAgainTogether => isArabic ? 'العبوا مرة أخرى' : 'Play again together';
  String get socialError => isArabic ? 'تعذر إكمال العملية. حاول مرة أخرى.' : 'Could not complete the action. Try again.';
}
