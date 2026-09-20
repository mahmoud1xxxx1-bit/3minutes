// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => '3 Minutes';

  @override
  String get play => 'PLAY';

  @override
  String get resume => 'RESUME';

  @override
  String get ready => 'READY';

  @override
  String get waitingForOpponent => 'Waiting for opponent...';

  @override
  String get opponentFound => 'Opponent found';

  @override
  String get matchHistory => 'Match history';

  @override
  String get signOut => 'Sign out';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get profile => 'Profile';

  @override
  String get shop => 'Shop';

  @override
  String get season => 'Season';

  @override
  String get level => 'Level';

  @override
  String get rank => 'Rank';

  @override
  String get stars => 'Stars';

  @override
  String get wins => 'Wins';

  @override
  String get losses => 'Losses';

  @override
  String get points => 'Points';

  @override
  String get coins => 'Coins';

  @override
  String miniGamesSummary(int count) {
    return '3 Minutes • $count Mini-Games';
  }

  @override
  String levelWithValue(int level) {
    return 'Level $level';
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
  String get levelProgress => 'Level progress';

  @override
  String get rankProgress => 'Rank progress';

  @override
  String xpProgressValue(int current, int target) {
    return '$current/$target XP';
  }

  @override
  String rpToNextRank(int rp, String rank) {
    return '$rp RP to $rank';
  }

  @override
  String rpToNext(int rp) {
    return '$rp RP to next rank';
  }

  @override
  String get maxTier => 'MAX TIER';

  @override
  String get highestRank => 'Highest rank';

  @override
  String get matches => 'Matches';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get playerName => 'Player name';

  @override
  String get playerNameHelp => '3–20 characters';

  @override
  String get playerNameLengthError =>
      'Player name must be between 3 and 20 characters.';

  @override
  String get playerNameLetterNumberError =>
      'Player name must include at least one letter or number.';

  @override
  String get playerNameUnsupportedError =>
      'Player name contains unsupported characters.';

  @override
  String get avatar => 'Avatar';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String get couldNotSaveProfile =>
      'Could not save your profile. Check your connection and try again.';

  @override
  String get seasonCompetition => 'Season competition';

  @override
  String seasonDuration(int days) {
    return 'Each season lasts $days days.';
  }

  @override
  String get seasonStarsExplanation =>
      'Your highest tier in the season awards permanent stars. Stars stay on your identity and never affect gameplay.';

  @override
  String get liveStandingsLocked =>
      'Live standings activate with the secure competition backend.';

  @override
  String get liveStandingsProtected =>
      'Live standings are protected by the secure competition backend.';

  @override
  String get liveStandings => 'Live standings';

  @override
  String get rankLadder => 'Rank ladder';

  @override
  String seasonNumber(int number) {
    return 'Season #$number';
  }

  @override
  String seasonRemaining(int days, int hours) {
    return '${days}d ${hours}h remaining';
  }

  @override
  String get seasonClosed => 'Season closed';

  @override
  String get noActiveSeason => 'No active season.';

  @override
  String get couldNotLoadSeason => 'Could not load the current season.';

  @override
  String get couldNotLoadStandings => 'Could not load live standings.';

  @override
  String get noRankedPlayers => 'No ranked players yet.';

  @override
  String get tryAgain => 'TRY AGAIN';

  @override
  String seasonStarsReward(int stars) {
    return '$stars season stars';
  }

  @override
  String get secureCosmeticsShop => 'Secure cosmetics shop';

  @override
  String get shopLockedDescription =>
      'Cosmetics only. Purchases activate after the secure server economy is enabled.';

  @override
  String get shopSecureDescription =>
      'Cosmetic purchases are protected by the secure server economy.';

  @override
  String get couldNotLoadInventory => 'Could not load your inventory.';

  @override
  String get purchaseFailed => 'Purchase failed. Please try again.';

  @override
  String get equipFailed => 'Could not equip this cosmetic.';

  @override
  String purchaseSuccess(String item, int coins) {
    return '$item purchased • $coins coins remaining';
  }

  @override
  String equipSuccess(String item) {
    return '$item equipped';
  }

  @override
  String get catalog => 'Catalog';

  @override
  String get all => 'All';

  @override
  String get frames => 'Frames';

  @override
  String get badges => 'Badges';

  @override
  String get backgrounds => 'Backgrounds';

  @override
  String get nameStyles => 'Name styles';

  @override
  String get avatarFrame => 'Avatar frame';

  @override
  String get badge => 'Badge';

  @override
  String get profileBackground => 'Profile background';

  @override
  String get nameStyle => 'Name style';

  @override
  String get locked => 'LOCKED';

  @override
  String get available => 'AVAILABLE';

  @override
  String get owned => 'OWNED';

  @override
  String get equipped => 'EQUIPPED';

  @override
  String get buy => 'BUY';

  @override
  String get equip => 'EQUIP';

  @override
  String get common => 'Common';

  @override
  String get rare => 'Rare';

  @override
  String get epic => 'Epic';

  @override
  String get legendary => 'Legendary';

  @override
  String get cosmeticFrameClassic => 'Classic Frame';

  @override
  String get cosmeticFrameNeon => 'Neon Frame';

  @override
  String get cosmeticBadgeTimer => 'Three Minute Badge';

  @override
  String get cosmeticBadgeCrown => 'Crown Badge';

  @override
  String get cosmeticBackgroundGrid => 'Grid Profile';

  @override
  String get cosmeticBackgroundArena => 'Arena Profile';

  @override
  String get cosmeticNameBold => 'Bold Name';

  @override
  String get cosmeticNameChampion => 'Champion Name';

  @override
  String get findingOpponent => 'Finding opponent';

  @override
  String get joiningQueue => 'Entering the arena...';

  @override
  String get searchingForPlayer => 'Searching for a player...';

  @override
  String get fairMatchMessage =>
      'Both players get the same 3-minute clock, game order, and difficulty.';

  @override
  String get matchmakingFailed => 'Could not start matchmaking. Try again.';

  @override
  String get cancel => 'Cancel';

  @override
  String get leaving => 'Leaving...';

  @override
  String get matchRoom => 'Match room';

  @override
  String get leaveMatch => 'Leave match';

  @override
  String get leaveMatchQuestion => 'Leave match?';

  @override
  String get leaveMatchDescription =>
      'The match will be cancelled before it starts.';

  @override
  String get stay => 'STAY';

  @override
  String get leave => 'LEAVE';

  @override
  String get couldNotReady => 'Could not mark you ready. Try again.';

  @override
  String get couldNotLeaveMatch => 'Could not leave this match. Try again.';

  @override
  String get connectionLostRoom =>
      'Connection lost. Keep this screen open; the match will resume when the connection returns.';

  @override
  String get legacyMatchTitle => 'This saved match uses an older game set.';

  @override
  String get legacyMatchDescription =>
      'Remove the old match to return home and start with the current game version.';

  @override
  String get removeOldMatch => 'REMOVE OLD MATCH';

  @override
  String get removing => 'REMOVING...';

  @override
  String get couldNotRemoveOldMatch =>
      'Could not remove the old match. Try again.';

  @override
  String get opponentLeft => 'Opponent left the match.';

  @override
  String get matchCancelled => 'Match cancelled.';

  @override
  String get backToHome => 'BACK TO HOME';

  @override
  String get you => 'You';

  @override
  String get opponent => 'Opponent';

  @override
  String get waiting => 'WAITING';

  @override
  String get bothPlayersReady => 'Both players are ready';

  @override
  String get readyInstructions =>
      'Both players must be ready before the synchronized 3-2-1 starts.';

  @override
  String get gettingReady => 'Getting ready...';

  @override
  String get go => 'GO!';

  @override
  String get refresh => 'Refresh';

  @override
  String get couldNotLoadHistory => 'Could not load match history.';

  @override
  String get noFinishedMatches => 'No finished matches yet.';

  @override
  String get cancelled => 'CANCELLED';

  @override
  String get win => 'WIN';

  @override
  String get loss => 'LOSS';

  @override
  String historyMyResult(int games, int total, int points) {
    return '$games/$total games • $points pts';
  }

  @override
  String historyOpponentResult(int games, int total, int points) {
    return 'Opponent $games/$total • $points pts';
  }

  @override
  String get signInTagline => 'Two players. One clock.';

  @override
  String get googleSignInFailed => 'Google sign-in failed. Please try again.';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get createProfile => 'Create profile';

  @override
  String get choosePlayerName => 'Choose your player name';

  @override
  String get chooseAvatar => 'Choose an avatar';

  @override
  String get continueAction => 'Continue';

  @override
  String get couldNotCreateProfile =>
      'Could not create your profile. Check your connection and try again.';

  @override
  String get signingYouIn => 'Signing you in...';

  @override
  String get loadingProfile => 'Loading your profile...';

  @override
  String get profileLoadFailed => 'We could not load your player profile.';

  @override
  String get checkConnection => 'Check your internet connection and try again.';

  @override
  String get victory => 'VICTORY';

  @override
  String get defeat => 'DEFEAT';

  @override
  String get tie => 'TIE';

  @override
  String get rematch => 'REMATCH';

  @override
  String get home => 'HOME';

  @override
  String get bronze => 'Bronze';

  @override
  String get silver => 'Silver';

  @override
  String get gold => 'Gold';

  @override
  String get platinum => 'Platinum';

  @override
  String get diamond => 'Diamond';

  @override
  String get master => 'Master';

  @override
  String get grandmaster => 'Grandmaster';

  @override
  String get legend => 'Legendary';
}
