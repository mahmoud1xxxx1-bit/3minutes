import 'package:flutter/widgets.dart';

import '../domain/cosmetic_item.dart';

class ShopCopy {
  const ShopCopy._(this.arabic);

  final bool arabic;

  static ShopCopy of(BuildContext context) => ShopCopy._(
        Localizations.localeOf(context).languageCode == 'ar',
      );

  String get featured => arabic ? 'المميز' : 'Featured';
  String get coins => arabic ? 'كوينز' : 'Coins';
  String get prestige => arabic ? 'الهيبة' : 'Prestige';
  String get premium => arabic ? 'بريميوم' : 'Premium';
  String get owned => arabic ? 'ممتلكاتي' : 'Owned';
  String get exclusive => arabic ? 'حصري' : 'EXCLUSIVE';
  String get animated => arabic ? 'متحرك' : 'ANIMATED';
  String get preview => arabic ? 'معاينة' : 'Preview';
  String get longTermGoal => arabic
      ? 'هدف طويل المدى — لا يمكن شراء نجوم الهيبة بالمال.'
      : 'Long-term goal — Prestige Stars can never be bought.';
  String get premiumPromise => arabic
      ? 'مظهر فقط. لا يمنح أي قوة أو أفضلية تنافسية.'
      : 'Cosmetic only. Never grants competitive power.';
  String get featuredSubtitle => arabic
      ? 'قطع نادرة صُممت لتكون أهدافًا تستحق اللعب والجمع.'
      : 'Rare pieces designed to be worth playing and collecting for.';
  String get coinSubtitle => arabic
      ? 'من أهداف يومية إلى قطع أسطورية تحتاج أسابيع من اللعب.'
      : 'From daily goals to legendary pieces that take weeks to earn.';
  String get prestigeSubtitle => arabic
      ? 'نجومك تثبت تاريخك عبر المواسم. هذه القطع لا تُشترى بالمال.'
      : 'Your Stars prove your season history. These pieces are never sold for money.';
  String get premiumSubtitle => arabic
      ? 'قطع بريميوم قوية بصريًا فقط، بدون Pay-to-Win.'
      : 'High-impact premium cosmetics only, with zero pay-to-win.';
  String get ownedSubtitle => arabic
      ? 'كل ما جمعته أو اشتريته، جاهز للتجهيز.'
      : 'Everything you earned or purchased, ready to equip.';
  String get noOwned => arabic
      ? 'لم تجمع أي قطعة بعد.'
      : 'You have not collected any cosmetics yet.';

  String itemName(CosmeticItem item) {
    if (!arabic) return item.name;
    return switch (item.id) {
      'name_bold' => 'اسم عريض',
      'frame_classic' => 'إطار كلاسيكي',
      'badge_timer' => 'شارة الثلاث دقائق',
      'background_grid' => 'خلفية الشبكة',
      'emote_gg' => 'إيموت GG',
      'avatar_comet' => 'أفاتار المذنب',
      'frame_neon' => 'إطار النيون',
      'name_champion' => 'اسم البطل',
      'frame_voltage' => 'إطار الفولتية',
      'background_arena' => 'خلفية الحلبة',
      'victory_confetti' => 'احتفال النصر',
      'name_electric' => 'الاسم الكهربائي',
      'room_arcade' => 'غرفة الآركيد',
      'intro_redline' => 'دخول الخط الأحمر',
      'aura_storm' => 'هالة العاصفة',
      'badge_crown' => 'تاج الهيبة',
      'frame_prestige' => 'إطار الهيبة I',
      'aura_rank_flare' => 'هالة توهج الرتبة',
      'intro_champion' => 'دخول البطل',
      'background_constellation' => 'خلفية الكوكبة',
      'name_royal' => 'الاسم الملكي',
      'victory_crown_burst' => 'انفجار التاج',
      'frame_elite' => 'إطار الهيبة النخبوي',
      'aura_mythic_legacy' => 'هالة الإرث الأسطوري',
      'frame_obsidian' => 'إطار الأوبسيديان',
      'background_void' => 'خلفية الفراغ الحي',
      'intro_portal' => 'دخول البوابة',
      'victory_lightning' => 'نصر البرق',
      'room_cyber_royal' => 'الغرفة السيبرانية الملكية',
      _ => item.name,
    };
  }

  String itemDescription(CosmeticItem item) {
    final special = switch (item.id) {
      'aura_mythic_legacy' => arabic
          ? 'أندر هدف Prestige في المتجر. يحتاج تاريخ مواسم طويلًا.'
          : 'The rarest Prestige goal in the shop. Built for long season history.',
      'room_cyber_royal' => arabic
          ? 'حوّل غرفة الأصدقاء بالكامل إلى ساحة سيبرانية ملكية.'
          : 'Transforms your friends room into a premium cyber-royal arena.',
      'victory_crown_burst' => arabic
          ? 'انفجار تاج Mythic يظهر لحظة فوزك أمام المجموعة.'
          : 'A Mythic crown burst that fires when you win in front of the group.',
      'intro_champion' => arabic
          ? 'دخول تنافسي نادر قبل بداية المباراة.'
          : 'A rare competitive entrance before the match begins.',
      'aura_storm' => arabic
          ? 'هالة Mythic متحركة حول هويتك ورتبتك.'
          : 'A Mythic animated storm around your identity and rank.',
      _ => null,
    };
    if (special != null) return special;

    return switch (item.slot) {
      CosmeticSlot.avatar => arabic
          ? 'غيّر حضور شخصيتك في البروفايل والغرف.'
          : 'Changes your player identity across profile and rooms.',
      CosmeticSlot.avatarFrame => arabic
          ? 'إطار يظهر حول أفاتارك في البروفايل والغرف.'
          : 'A frame shown around your avatar in profile and rooms.',
      CosmeticSlot.badge => arabic
          ? 'شارة تعرض بجانب هويتك وإنجازاتك.'
          : 'A badge displayed with your identity and achievements.',
      CosmeticSlot.profileBackground => arabic
          ? 'خلفية كاملة لواجهة بروفايلك.'
          : 'A full visual background for your player profile.',
      CosmeticSlot.nameStyle => arabic
          ? 'أسلوب مميز لاسمك أمام المنافسين.'
          : 'A distinctive name treatment visible to rivals.',
      CosmeticSlot.matchIntro => arabic
          ? 'مؤثر دخول يظهر قبل بداية المواجهة.'
          : 'An entrance effect shown before the match starts.',
      CosmeticSlot.victoryEffect => arabic
          ? 'مؤثر خاص يظهر عند فوزك.'
          : 'A special effect shown when you win.',
      CosmeticSlot.rankAura => arabic
          ? 'هالة Prestige تحيط بهوية اللاعب والرتبة.'
          : 'A prestige aura around your player identity and rank.',
      CosmeticSlot.emote => arabic
          ? 'تعبير اجتماعي سريع لمباريات الأصدقاء.'
          : 'A quick social expression for friend matches.',
      CosmeticSlot.roomTheme => arabic
          ? 'ثيم كامل للغرفة الخاصة التي تستضيفها.'
          : 'A full theme for private rooms you host.',
    };
  }
}
