import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'3 Minutes'**
  String get appName;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resume;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get ready;

  /// No description provided for @waitingForOpponent.
  ///
  /// In en, this message translates to:
  /// **'Waiting for opponent...'**
  String get waitingForOpponent;

  /// No description provided for @opponentFound.
  ///
  /// In en, this message translates to:
  /// **'Opponent found'**
  String get opponentFound;

  /// No description provided for @matchHistory.
  ///
  /// In en, this message translates to:
  /// **'Match history'**
  String get matchHistory;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @losses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get losses;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @miniGamesSummary.
  ///
  /// In en, this message translates to:
  /// **'3 Minutes • {count} Mini-Games'**
  String miniGamesSummary(int count);

  /// No description provided for @levelWithValue.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelWithValue(int level);

  /// No description provided for @rpWithValue.
  ///
  /// In en, this message translates to:
  /// **'{rp} RP'**
  String rpWithValue(int rp);

  /// No description provided for @starsWithValue.
  ///
  /// In en, this message translates to:
  /// **'★ {stars}'**
  String starsWithValue(int stars);

  /// No description provided for @levelProgress.
  ///
  /// In en, this message translates to:
  /// **'Level progress'**
  String get levelProgress;

  /// No description provided for @rankProgress.
  ///
  /// In en, this message translates to:
  /// **'Rank progress'**
  String get rankProgress;

  /// No description provided for @xpProgressValue.
  ///
  /// In en, this message translates to:
  /// **'{current}/{target} XP'**
  String xpProgressValue(int current, int target);

  /// No description provided for @rpToNextRank.
  ///
  /// In en, this message translates to:
  /// **'{rp} RP to {rank}'**
  String rpToNextRank(int rp, String rank);

  /// No description provided for @rpToNext.
  ///
  /// In en, this message translates to:
  /// **'{rp} RP to next rank'**
  String rpToNext(int rp);

  /// No description provided for @maxTier.
  ///
  /// In en, this message translates to:
  /// **'MAX TIER'**
  String get maxTier;

  /// No description provided for @highestRank.
  ///
  /// In en, this message translates to:
  /// **'Highest rank'**
  String get highestRank;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @playerName.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get playerName;

  /// No description provided for @playerNameHelp.
  ///
  /// In en, this message translates to:
  /// **'3–20 characters'**
  String get playerNameHelp;

  /// No description provided for @playerNameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Player name must be between 3 and 20 characters.'**
  String get playerNameLengthError;

  /// No description provided for @playerNameLetterNumberError.
  ///
  /// In en, this message translates to:
  /// **'Player name must include at least one letter or number.'**
  String get playerNameLetterNumberError;

  /// No description provided for @playerNameUnsupportedError.
  ///
  /// In en, this message translates to:
  /// **'Player name contains unsupported characters.'**
  String get playerNameUnsupportedError;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @couldNotSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not save your profile. Check your connection and try again.'**
  String get couldNotSaveProfile;

  /// No description provided for @seasonCompetition.
  ///
  /// In en, this message translates to:
  /// **'Season competition'**
  String get seasonCompetition;

  /// No description provided for @seasonDuration.
  ///
  /// In en, this message translates to:
  /// **'Each season lasts {days} days.'**
  String seasonDuration(int days);

  /// No description provided for @seasonStarsExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your highest tier in the season awards permanent stars. Stars stay on your identity and never affect gameplay.'**
  String get seasonStarsExplanation;

  /// No description provided for @liveStandingsLocked.
  ///
  /// In en, this message translates to:
  /// **'Live standings activate with the secure competition backend.'**
  String get liveStandingsLocked;

  /// No description provided for @liveStandingsProtected.
  ///
  /// In en, this message translates to:
  /// **'Live standings are protected by the secure competition backend.'**
  String get liveStandingsProtected;

  /// No description provided for @liveStandings.
  ///
  /// In en, this message translates to:
  /// **'Live standings'**
  String get liveStandings;

  /// No description provided for @rankLadder.
  ///
  /// In en, this message translates to:
  /// **'Rank ladder'**
  String get rankLadder;

  /// No description provided for @seasonNumber.
  ///
  /// In en, this message translates to:
  /// **'Season #{number}'**
  String seasonNumber(int number);

  /// No description provided for @seasonRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days}d {hours}h remaining'**
  String seasonRemaining(int days, int hours);

  /// No description provided for @seasonClosed.
  ///
  /// In en, this message translates to:
  /// **'Season closed'**
  String get seasonClosed;

  /// No description provided for @noActiveSeason.
  ///
  /// In en, this message translates to:
  /// **'No active season.'**
  String get noActiveSeason;

  /// No description provided for @couldNotLoadSeason.
  ///
  /// In en, this message translates to:
  /// **'Could not load the current season.'**
  String get couldNotLoadSeason;

  /// No description provided for @couldNotLoadStandings.
  ///
  /// In en, this message translates to:
  /// **'Could not load live standings.'**
  String get couldNotLoadStandings;

  /// No description provided for @noRankedPlayers.
  ///
  /// In en, this message translates to:
  /// **'No ranked players yet.'**
  String get noRankedPlayers;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get tryAgain;

  /// No description provided for @seasonStarsReward.
  ///
  /// In en, this message translates to:
  /// **'{stars} season stars'**
  String seasonStarsReward(int stars);

  /// No description provided for @secureCosmeticsShop.
  ///
  /// In en, this message translates to:
  /// **'Secure cosmetics shop'**
  String get secureCosmeticsShop;

  /// No description provided for @shopLockedDescription.
  ///
  /// In en, this message translates to:
  /// **'Cosmetics only. Purchases activate after the secure server economy is enabled.'**
  String get shopLockedDescription;

  /// No description provided for @shopSecureDescription.
  ///
  /// In en, this message translates to:
  /// **'Cosmetic purchases are protected by the secure server economy.'**
  String get shopSecureDescription;

  /// No description provided for @couldNotLoadInventory.
  ///
  /// In en, this message translates to:
  /// **'Could not load your inventory.'**
  String get couldNotLoadInventory;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get purchaseFailed;

  /// No description provided for @equipFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not equip this cosmetic.'**
  String get equipFailed;

  /// No description provided for @purchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'{item} purchased • {coins} coins remaining'**
  String purchaseSuccess(String item, int coins);

  /// No description provided for @equipSuccess.
  ///
  /// In en, this message translates to:
  /// **'{item} equipped'**
  String equipSuccess(String item);

  /// No description provided for @catalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalog;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @frames.
  ///
  /// In en, this message translates to:
  /// **'Frames'**
  String get frames;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @backgrounds.
  ///
  /// In en, this message translates to:
  /// **'Backgrounds'**
  String get backgrounds;

  /// No description provided for @nameStyles.
  ///
  /// In en, this message translates to:
  /// **'Name styles'**
  String get nameStyles;

  /// No description provided for @avatarFrame.
  ///
  /// In en, this message translates to:
  /// **'Avatar frame'**
  String get avatarFrame;

  /// No description provided for @badge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get badge;

  /// No description provided for @profileBackground.
  ///
  /// In en, this message translates to:
  /// **'Profile background'**
  String get profileBackground;

  /// No description provided for @nameStyle.
  ///
  /// In en, this message translates to:
  /// **'Name style'**
  String get nameStyle;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get locked;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE'**
  String get available;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'OWNED'**
  String get owned;

  /// No description provided for @equipped.
  ///
  /// In en, this message translates to:
  /// **'EQUIPPED'**
  String get equipped;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get buy;

  /// No description provided for @equip.
  ///
  /// In en, this message translates to:
  /// **'EQUIP'**
  String get equip;

  /// No description provided for @common.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get common;

  /// No description provided for @rare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get rare;

  /// No description provided for @epic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get epic;

  /// No description provided for @legendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get legendary;

  /// No description provided for @cosmeticFrameClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic Frame'**
  String get cosmeticFrameClassic;

  /// No description provided for @cosmeticFrameNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon Frame'**
  String get cosmeticFrameNeon;

  /// No description provided for @cosmeticBadgeTimer.
  ///
  /// In en, this message translates to:
  /// **'Three Minute Badge'**
  String get cosmeticBadgeTimer;

  /// No description provided for @cosmeticBadgeCrown.
  ///
  /// In en, this message translates to:
  /// **'Crown Badge'**
  String get cosmeticBadgeCrown;

  /// No description provided for @cosmeticBackgroundGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid Profile'**
  String get cosmeticBackgroundGrid;

  /// No description provided for @cosmeticBackgroundArena.
  ///
  /// In en, this message translates to:
  /// **'Arena Profile'**
  String get cosmeticBackgroundArena;

  /// No description provided for @cosmeticNameBold.
  ///
  /// In en, this message translates to:
  /// **'Bold Name'**
  String get cosmeticNameBold;

  /// No description provided for @cosmeticNameChampion.
  ///
  /// In en, this message translates to:
  /// **'Champion Name'**
  String get cosmeticNameChampion;

  /// No description provided for @findingOpponent.
  ///
  /// In en, this message translates to:
  /// **'Finding opponent'**
  String get findingOpponent;

  /// No description provided for @joiningQueue.
  ///
  /// In en, this message translates to:
  /// **'Entering the arena...'**
  String get joiningQueue;

  /// No description provided for @searchingForPlayer.
  ///
  /// In en, this message translates to:
  /// **'Searching for a player...'**
  String get searchingForPlayer;

  /// No description provided for @fairMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Both players get the same 3-minute clock, game order, and difficulty.'**
  String get fairMatchMessage;

  /// No description provided for @matchmakingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start matchmaking. Try again.'**
  String get matchmakingFailed;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @leaving.
  ///
  /// In en, this message translates to:
  /// **'Leaving...'**
  String get leaving;

  /// No description provided for @matchRoom.
  ///
  /// In en, this message translates to:
  /// **'Match room'**
  String get matchRoom;

  /// No description provided for @leaveMatch.
  ///
  /// In en, this message translates to:
  /// **'Leave match'**
  String get leaveMatch;

  /// No description provided for @leaveMatchQuestion.
  ///
  /// In en, this message translates to:
  /// **'Leave match?'**
  String get leaveMatchQuestion;

  /// No description provided for @leaveMatchDescription.
  ///
  /// In en, this message translates to:
  /// **'The match will be cancelled before it starts.'**
  String get leaveMatchDescription;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'STAY'**
  String get stay;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'LEAVE'**
  String get leave;

  /// No description provided for @couldNotReady.
  ///
  /// In en, this message translates to:
  /// **'Could not mark you ready. Try again.'**
  String get couldNotReady;

  /// No description provided for @couldNotLeaveMatch.
  ///
  /// In en, this message translates to:
  /// **'Could not leave this match. Try again.'**
  String get couldNotLeaveMatch;

  /// No description provided for @connectionLostRoom.
  ///
  /// In en, this message translates to:
  /// **'Connection lost. Keep this screen open; the match will resume when the connection returns.'**
  String get connectionLostRoom;

  /// No description provided for @legacyMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'This saved match uses an older game set.'**
  String get legacyMatchTitle;

  /// No description provided for @legacyMatchDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove the old match to return home and start with the current game version.'**
  String get legacyMatchDescription;

  /// No description provided for @removeOldMatch.
  ///
  /// In en, this message translates to:
  /// **'REMOVE OLD MATCH'**
  String get removeOldMatch;

  /// No description provided for @removing.
  ///
  /// In en, this message translates to:
  /// **'REMOVING...'**
  String get removing;

  /// No description provided for @couldNotRemoveOldMatch.
  ///
  /// In en, this message translates to:
  /// **'Could not remove the old match. Try again.'**
  String get couldNotRemoveOldMatch;

  /// No description provided for @opponentLeft.
  ///
  /// In en, this message translates to:
  /// **'Opponent left the match.'**
  String get opponentLeft;

  /// No description provided for @matchCancelled.
  ///
  /// In en, this message translates to:
  /// **'Match cancelled.'**
  String get matchCancelled;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'BACK TO HOME'**
  String get backToHome;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @opponent.
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get opponent;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'WAITING'**
  String get waiting;

  /// No description provided for @bothPlayersReady.
  ///
  /// In en, this message translates to:
  /// **'Both players are ready'**
  String get bothPlayersReady;

  /// No description provided for @readyInstructions.
  ///
  /// In en, this message translates to:
  /// **'Both players must be ready before the synchronized 3-2-1 starts.'**
  String get readyInstructions;

  /// No description provided for @gettingReady.
  ///
  /// In en, this message translates to:
  /// **'Getting ready...'**
  String get gettingReady;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'GO!'**
  String get go;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @couldNotLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load match history.'**
  String get couldNotLoadHistory;

  /// No description provided for @noFinishedMatches.
  ///
  /// In en, this message translates to:
  /// **'No finished matches yet.'**
  String get noFinishedMatches;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get cancelled;

  /// No description provided for @win.
  ///
  /// In en, this message translates to:
  /// **'WIN'**
  String get win;

  /// No description provided for @loss.
  ///
  /// In en, this message translates to:
  /// **'LOSS'**
  String get loss;

  /// No description provided for @historyMyResult.
  ///
  /// In en, this message translates to:
  /// **'{games}/{total} games • {points} pts'**
  String historyMyResult(int games, int total, int points);

  /// No description provided for @historyOpponentResult.
  ///
  /// In en, this message translates to:
  /// **'Opponent {games}/{total} • {points} pts'**
  String historyOpponentResult(int games, int total, int points);

  /// No description provided for @signInTagline.
  ///
  /// In en, this message translates to:
  /// **'Two players. One clock.'**
  String get signInTagline;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get googleSignInFailed;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create profile'**
  String get createProfile;

  /// No description provided for @choosePlayerName.
  ///
  /// In en, this message translates to:
  /// **'Choose your player name'**
  String get choosePlayerName;

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose an avatar'**
  String get chooseAvatar;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @couldNotCreateProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not create your profile. Check your connection and try again.'**
  String get couldNotCreateProfile;

  /// No description provided for @signingYouIn.
  ///
  /// In en, this message translates to:
  /// **'Signing you in...'**
  String get signingYouIn;

  /// No description provided for @loadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading your profile...'**
  String get loadingProfile;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load your player profile.'**
  String get profileLoadFailed;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get checkConnection;

  /// No description provided for @victory.
  ///
  /// In en, this message translates to:
  /// **'VICTORY'**
  String get victory;

  /// No description provided for @defeat.
  ///
  /// In en, this message translates to:
  /// **'DEFEAT'**
  String get defeat;

  /// No description provided for @tie.
  ///
  /// In en, this message translates to:
  /// **'TIE'**
  String get tie;

  /// No description provided for @rematch.
  ///
  /// In en, this message translates to:
  /// **'REMATCH'**
  String get rematch;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get home;

  /// No description provided for @bronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get bronze;

  /// No description provided for @silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silver;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @platinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get platinum;

  /// No description provided for @diamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get diamond;

  /// No description provided for @master.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get master;

  /// No description provided for @grandmaster.
  ///
  /// In en, this message translates to:
  /// **'Grandmaster'**
  String get grandmaster;

  /// No description provided for @legend.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get legend;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
