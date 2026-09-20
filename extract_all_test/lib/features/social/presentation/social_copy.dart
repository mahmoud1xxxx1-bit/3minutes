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
  String get decline => isArabic ? 'رفض' : 'Decline';
  String get remove => isArabic ? 'إزالة' : 'Remove';
  String get block => isArabic ? 'حظر' : 'Block';
  String get addFriend => isArabic ? 'إضافة صديق' : 'Add friend';
  String get playWithFriends => isArabic ? 'العب مع الأصدقاء' : 'Play with friends';
  String get ranked => isArabic ? 'تنافسي' : 'Ranked';
  String get rankedSubtitle => isArabic ? '1 ضد 1 • ترتيب موسمي' : '1v1 • Seasonal ranking';
  String get createRoom => isArabic ? 'إنشاء غرفة' : 'Create room';
  String get joinRoom => isArabic ? 'الانضمام لغرفة' : 'Join room';
  String get roomCode => isArabic ? 'رمز الغرفة' : 'Room code';
  String get enterRoomCode => isArabic ? 'أدخل رمز الغرفة المكوّن من 5 رموز' : 'Enter the 5-character room code';
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
  String get invited => isArabic ? 'تمت الدعوة' : 'Invited';
  String get shareRoom => isArabic ? 'مشاركة الغرفة' : 'Share room';
  String get inviteCopied => isArabic ? 'تم نسخ رابط الدعوة' : 'Invite link copied';
  String get roomFull => isArabic ? 'الغرفة مكتملة' : 'Room full';
  String get waitingPlayers => isArabic ? 'بانتظار اللاعبين' : 'Waiting for players';
  String get party => isArabic ? 'المجموعة' : 'Party';
  String get partySubtitle => isArabic
      ? 'كوّن مجموعة حتى 6 لاعبين وابقوا معًا للمباريات المتكررة.'
      : 'Keep up to 6 players together for repeated matches.';
  String get createParty => isArabic ? 'إنشاء مجموعة' : 'Create party';
  String get partyInvitations => isArabic ? 'دعوات المجموعة' : 'Party invitations';
  String get noPartyInvites => isArabic ? 'لا توجد دعوات مجموعة حاليًا' : 'No party invitations right now';
  String get partyLeader => isArabic ? 'قائد المجموعة' : 'Party leader';
  String get partyMembers => isArabic ? 'أعضاء المجموعة' : 'Party members';
  String get inviteFriends => isArabic ? 'دعوة الأصدقاء' : 'Invite friends';
  String get leaveParty => isArabic ? 'مغادرة المجموعة' : 'Leave party';
  String get removeFromParty => isArabic ? 'إزالة من المجموعة' : 'Remove from party';
  String get partySizeRule => isArabic
      ? 'يمكن بدء المباراة عندما يكون العدد 2 أو 4 أو 6.'
      : 'A party can start a match at 2, 4, or 6 members.';
  String get partyWaitingSize => isArabic
      ? 'أضف أو أزل لاعبًا حتى يصبح العدد 2 أو 4 أو 6.'
      : 'Add or remove a player until the party size is 2, 4, or 6.';
  String get startPartyMatch => isArabic ? 'ابدأ مباراة المجموعة' : 'Start party match';
  String get playAgainTogether => isArabic ? 'العبوا مرة أخرى' : 'Play again together';
  String get ready => isArabic ? 'جاهز' : 'Ready';
  String get notReady => isArabic ? 'غير جاهز' : 'Not ready';
  String get startMatch => isArabic ? 'ابدأ المباراة' : 'Start match';
  String get host => isArabic ? 'المضيف' : 'Host';
  String get you => isArabic ? 'أنت' : 'You';
  String get leaveRoom => isArabic ? 'مغادرة الغرفة' : 'Leave room';
  String get cancelRoom => isArabic ? 'إلغاء الغرفة' : 'Cancel room';
  String get roomCancelled => isArabic ? 'تم إلغاء الغرفة' : 'Room cancelled';
  String get roomNotFound => isArabic ? 'لم يتم العثور على الغرفة' : 'Room not found';
  String get invalidRoomCode => isArabic ? 'رمز الغرفة غير صحيح' : 'Invalid room code';
  String get creatingRoom => isArabic ? 'جارٍ إنشاء الغرفة...' : 'Creating room...';
  String get joiningRoom => isArabic ? 'جارٍ الانضمام...' : 'Joining room...';
  String get everyoneMustBeReady => isArabic
      ? 'يجب أن تمتلئ الغرفة ويكون الجميع جاهزين.'
      : 'The room must be full and everyone must be ready.';
  String get matchStarting => isArabic ? 'المباراة تبدأ الآن...' : 'Match starting...';
  String get socialError => isArabic ? 'تعذر إكمال العملية. حاول مرة أخرى.' : 'Could not complete the action. Try again.';
}
