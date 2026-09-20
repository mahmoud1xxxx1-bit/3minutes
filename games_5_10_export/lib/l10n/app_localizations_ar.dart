// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => '3 دقائق';

  @override
  String get play => 'العب';

  @override
  String get resume => 'استئناف';

  @override
  String get ready => 'جاهز';

  @override
  String get waitingForOpponent => 'بانتظار الخصم...';

  @override
  String get opponentFound => 'تم العثور على خصم';

  @override
  String get matchHistory => 'سجل المباريات';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get leaderboard => 'الترتيب';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get shop => 'المتجر';

  @override
  String get season => 'الموسم';

  @override
  String get level => 'المستوى';

  @override
  String get rank => 'الرتبة';

  @override
  String get stars => 'النجوم';

  @override
  String get wins => 'الانتصارات';

  @override
  String get losses => 'الخسائر';

  @override
  String get points => 'النقاط';

  @override
  String get coins => 'العملات';

  @override
  String miniGamesSummary(int count) {
    return '3 دقائق • $count ألعاب مصغرة';
  }

  @override
  String levelWithValue(int level) {
    return 'المستوى $level';
  }

  @override
  String rpWithValue(int rp) {
    return '$rp RP';
  }

  @override
  String starsWithValue(int stars) {
    return '★ $stars';
  }

  @override
  String get levelProgress => 'تقدم المستوى';

  @override
  String get rankProgress => 'تقدم الرتبة';

  @override
  String xpProgressValue(int current, int target) {
    return '$current/$target XP';
  }

  @override
  String rpToNextRank(int rp, String rank) {
    return '$rp RP إلى $rank';
  }

  @override
  String rpToNext(int rp) {
    return '$rp RP إلى الرتبة التالية';
  }

  @override
  String get maxTier => 'أعلى رتبة';

  @override
  String get highestRank => 'أعلى رتبة';

  @override
  String get matches => 'المباريات';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get playerName => 'اسم اللاعب';

  @override
  String get playerNameHelp => 'من 3 إلى 20 حرفًا';

  @override
  String get playerNameLengthError => 'يجب أن يكون اسم اللاعب بين 3 و20 حرفًا.';

  @override
  String get playerNameLetterNumberError =>
      'يجب أن يحتوي اسم اللاعب على حرف أو رقم واحد على الأقل.';

  @override
  String get playerNameUnsupportedError =>
      'اسم اللاعب يحتوي على رموز غير مدعومة.';

  @override
  String get avatar => 'الصورة الرمزية';

  @override
  String get save => 'حفظ';

  @override
  String get saving => 'جارٍ الحفظ...';

  @override
  String get couldNotSaveProfile =>
      'تعذر حفظ ملفك الشخصي. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get seasonCompetition => 'منافسات الموسم';

  @override
  String seasonDuration(int days) {
    return 'يستمر كل موسم $days يومًا.';
  }

  @override
  String get seasonStarsExplanation =>
      'أعلى رتبة تصل إليها خلال الموسم تمنحك نجومًا دائمة. النجوم تبقى جزءًا من هويتك ولا تؤثر على اللعب.';

  @override
  String get liveStandingsLocked =>
      'يتم تفعيل الترتيب المباشر بعد تشغيل خادم المنافسة الآمن.';

  @override
  String get liveStandingsProtected =>
      'الترتيب المباشر محمي بواسطة خادم المنافسة الآمن.';

  @override
  String get liveStandings => 'الترتيب المباشر';

  @override
  String get rankLadder => 'سلم الرتب';

  @override
  String seasonNumber(int number) {
    return 'الموسم #$number';
  }

  @override
  String seasonRemaining(int days, int hours) {
    return 'متبقي $days يوم و$hours ساعة';
  }

  @override
  String get seasonClosed => 'انتهى الموسم';

  @override
  String get noActiveSeason => 'لا يوجد موسم نشط.';

  @override
  String get couldNotLoadSeason => 'تعذر تحميل الموسم الحالي.';

  @override
  String get couldNotLoadStandings => 'تعذر تحميل الترتيب المباشر.';

  @override
  String get noRankedPlayers => 'لا يوجد لاعبون في الترتيب بعد.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String seasonStarsReward(int stars) {
    return '$stars نجوم موسمية';
  }

  @override
  String get secureCosmeticsShop => 'متجر المظاهر الآمن';

  @override
  String get shopLockedDescription =>
      'جميع العناصر تجميلية فقط. يتم تفعيل الشراء بعد تشغيل نظام الاقتصاد الآمن على الخادم.';

  @override
  String get shopSecureDescription =>
      'عمليات شراء العناصر التجميلية محمية بواسطة نظام الاقتصاد الآمن.';

  @override
  String get couldNotLoadInventory => 'تعذر تحميل مقتنياتك.';

  @override
  String get purchaseFailed => 'تعذر إتمام الشراء. حاول مرة أخرى.';

  @override
  String get equipFailed => 'تعذر تجهيز هذا العنصر.';

  @override
  String purchaseSuccess(String item, int coins) {
    return 'تم شراء $item • المتبقي $coins عملة';
  }

  @override
  String equipSuccess(String item) {
    return 'تم تجهيز $item';
  }

  @override
  String get catalog => 'الكتالوج';

  @override
  String get all => 'الكل';

  @override
  String get frames => 'الإطارات';

  @override
  String get badges => 'الشارات';

  @override
  String get backgrounds => 'الخلفيات';

  @override
  String get nameStyles => 'أنماط الاسم';

  @override
  String get avatarFrame => 'إطار الصورة';

  @override
  String get badge => 'شارة';

  @override
  String get profileBackground => 'خلفية الملف';

  @override
  String get nameStyle => 'نمط الاسم';

  @override
  String get locked => 'مقفل';

  @override
  String get available => 'متاح';

  @override
  String get owned => 'مملوك';

  @override
  String get equipped => 'مجهز';

  @override
  String get buy => 'شراء';

  @override
  String get equip => 'تجهيز';

  @override
  String get common => 'عادي';

  @override
  String get rare => 'نادر';

  @override
  String get epic => 'ملحمي';

  @override
  String get legendary => 'أسطوري';

  @override
  String get cosmeticFrameClassic => 'الإطار الكلاسيكي';

  @override
  String get cosmeticFrameNeon => 'إطار النيون';

  @override
  String get cosmeticBadgeTimer => 'شارة الثلاث دقائق';

  @override
  String get cosmeticBadgeCrown => 'شارة التاج';

  @override
  String get cosmeticBackgroundGrid => 'خلفية الشبكة';

  @override
  String get cosmeticBackgroundArena => 'خلفية الحلبة';

  @override
  String get cosmeticNameBold => 'الاسم العريض';

  @override
  String get cosmeticNameChampion => 'اسم البطل';

  @override
  String get findingOpponent => 'البحث عن خصم';

  @override
  String get joiningQueue => 'دخول ساحة التحدي...';

  @override
  String get searchingForPlayer => 'جارٍ البحث عن لاعب...';

  @override
  String get fairMatchMessage =>
      'يحصل اللاعبان على نفس مدة الثلاث دقائق وترتيب الألعاب ونفس الصعوبة.';

  @override
  String get matchmakingFailed => 'تعذر بدء البحث عن خصم. حاول مرة أخرى.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get leaving => 'جارٍ المغادرة...';

  @override
  String get matchRoom => 'غرفة المباراة';

  @override
  String get leaveMatch => 'مغادرة المباراة';

  @override
  String get leaveMatchQuestion => 'مغادرة المباراة؟';

  @override
  String get leaveMatchDescription => 'سيتم إلغاء المباراة قبل أن تبدأ.';

  @override
  String get stay => 'ابقَ';

  @override
  String get leave => 'غادر';

  @override
  String get couldNotReady => 'تعذر تسجيل جاهزيتك. حاول مرة أخرى.';

  @override
  String get couldNotLeaveMatch => 'تعذر مغادرة المباراة. حاول مرة أخرى.';

  @override
  String get connectionLostRoom =>
      'انقطع الاتصال. أبقِ هذه الشاشة مفتوحة وستستأنف المباراة عند عودة الاتصال.';

  @override
  String get legacyMatchTitle =>
      'هذه المباراة المحفوظة تستخدم مجموعة ألعاب أقدم.';

  @override
  String get legacyMatchDescription =>
      'احذف المباراة القديمة للعودة إلى الرئيسية وبدء مباراة بالإصدار الحالي.';

  @override
  String get removeOldMatch => 'حذف المباراة القديمة';

  @override
  String get removing => 'جارٍ الحذف...';

  @override
  String get couldNotRemoveOldMatch =>
      'تعذر حذف المباراة القديمة. حاول مرة أخرى.';

  @override
  String get opponentLeft => 'غادر الخصم المباراة.';

  @override
  String get matchCancelled => 'تم إلغاء المباراة.';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get you => 'أنت';

  @override
  String get opponent => 'الخصم';

  @override
  String get waiting => 'بانتظار';

  @override
  String get bothPlayersReady => 'اللاعبان جاهزان';

  @override
  String get readyInstructions =>
      'يجب أن يكون اللاعبان جاهزين قبل بدء العد التنازلي 3-2-1.';

  @override
  String get gettingReady => 'جارٍ الاستعداد...';

  @override
  String get go => 'ابدأ!';

  @override
  String get refresh => 'تحديث';

  @override
  String get couldNotLoadHistory => 'تعذر تحميل سجل المباريات.';

  @override
  String get noFinishedMatches => 'لا توجد مباريات منتهية بعد.';

  @override
  String get cancelled => 'ملغاة';

  @override
  String get win => 'فوز';

  @override
  String get loss => 'خسارة';

  @override
  String historyMyResult(int games, int total, int points) {
    return '$games/$total ألعاب • $points نقطة';
  }

  @override
  String historyOpponentResult(int games, int total, int points) {
    return 'الخصم $games/$total • $points نقطة';
  }

  @override
  String get signInTagline => 'لاعبان. مؤقت واحد.';

  @override
  String get googleSignInFailed =>
      'تعذر تسجيل الدخول عبر Google. حاول مرة أخرى.';

  @override
  String get signingIn => 'جارٍ تسجيل الدخول...';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get createProfile => 'إنشاء الملف الشخصي';

  @override
  String get choosePlayerName => 'اختر اسم اللاعب';

  @override
  String get chooseAvatar => 'اختر صورة رمزية';

  @override
  String get continueAction => 'متابعة';

  @override
  String get couldNotCreateProfile =>
      'تعذر إنشاء ملفك الشخصي. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get signingYouIn => 'جارٍ تسجيل دخولك...';

  @override
  String get loadingProfile => 'جارٍ تحميل ملفك الشخصي...';

  @override
  String get profileLoadFailed => 'تعذر تحميل ملف اللاعب.';

  @override
  String get checkConnection => 'تحقق من اتصال الإنترنت وحاول مرة أخرى.';

  @override
  String get victory => 'فوز';

  @override
  String get defeat => 'خسارة';

  @override
  String get tie => 'تعادل';

  @override
  String get rematch => 'إعادة التحدي';

  @override
  String get home => 'الرئيسية';

  @override
  String get bronze => 'برونزي';

  @override
  String get silver => 'فضي';

  @override
  String get gold => 'ذهبي';

  @override
  String get platinum => 'بلاتيني';

  @override
  String get diamond => 'ألماسي';

  @override
  String get master => 'ماستر';

  @override
  String get grandmaster => 'غراند ماستر';

  @override
  String get legend => 'أسطوري';
}
