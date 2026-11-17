///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';

import 'strings.g.dart';

// Path: <root>
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  TranslationsEn({
    Map<String, Node>? overrides,
    PluralResolver? cardinalResolver,
    PluralResolver? ordinalResolver,
    TranslationMetadata<AppLocale, Translations>? meta,
  }) : assert(
         overrides == null,
         'Set "translation_overrides: true" in order to enable this feature.',
       ),
       _meta =
           meta ??
           TranslationMetadata(
             locale: AppLocale.en,
             overrides: overrides ?? {},
             cardinalResolver: cardinalResolver,
             ordinalResolver: ordinalResolver,
           ),
       super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
    _meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <en>.
  final TranslationMetadata<AppLocale, Translations> _meta;
  @override
  TranslationMetadata<AppLocale, Translations> get $meta => _meta;

  /// Access flat map
  @override
  dynamic operator [](String key) => _meta.getTranslation(key) ?? super[key];

  late final TranslationsEn _root = this; // ignore: unused_field

  @override
  TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) =>
      TranslationsEn(meta: meta ?? this.$meta);

  // Translations
  @override
  late final _Translations$core$en core = _Translations$core$en._(_root);
  @override
  late final _Translations$home$en home = _Translations$home$en._(_root);
  @override
  late final _Translations$onboarding$en onboarding = _Translations$onboarding$en._(_root);
  @override
  late final _Translations$workoutSession$en workoutSession = _Translations$workoutSession$en._(
    _root,
  );
  @override
  late final _Translations$workouts$en workouts = _Translations$workouts$en._(_root);
}

// Path: core
class _Translations$core$en extends Translations$core$id {
  _Translations$core$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get appName => 'Home Bulking Coach';
  @override
  late final _Translations$core$actions$en actions = _Translations$core$actions$en._(_root);
  @override
  late final _Translations$core$state$en state = _Translations$core$state$en._(_root);
  @override
  late final _Translations$core$badge$en badge = _Translations$core$badge$en._(_root);
  @override
  late final _Translations$core$language$en language = _Translations$core$language$en._(_root);
  @override
  late final _Translations$core$units$en units = _Translations$core$units$en._(_root);
}

// Path: home
class _Translations$home$en extends Translations$home$id {
  _Translations$home$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  late final _Translations$home$greeting$en greeting = _Translations$home$greeting$en._(_root);
  @override
  late final _Translations$home$goalCard$en goalCard = _Translations$home$goalCard$en._(_root);
  @override
  late final _Translations$home$todayWorkout$en todayWorkout = _Translations$home$todayWorkout$en._(
    _root,
  );
  @override
  late final _Translations$home$restDay$en restDay = _Translations$home$restDay$en._(_root);
  @override
  late final _Translations$home$noProgram$en noProgram = _Translations$home$noProgram$en._(_root);
  @override
  late final _Translations$home$weeklyProgress$en weeklyProgress =
      _Translations$home$weeklyProgress$en._(_root);
  @override
  late final _Translations$home$supportGoal$en supportGoal = _Translations$home$supportGoal$en._(
    _root,
  );
  @override
  late final _Translations$home$error$en error = _Translations$home$error$en._(_root);
}

// Path: onboarding
class _Translations$onboarding$en extends Translations$onboarding$id {
  _Translations$onboarding$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  late final _Translations$onboarding$nav$en nav = _Translations$onboarding$nav$en._(_root);
  @override
  late final _Translations$onboarding$welcome$en welcome = _Translations$onboarding$welcome$en._(
    _root,
  );
  @override
  late final _Translations$onboarding$goal$en goal = _Translations$onboarding$goal$en._(_root);
  @override
  late final _Translations$onboarding$about$en about = _Translations$onboarding$about$en._(_root);
  @override
  late final _Translations$onboarding$bodyTarget$en bodyTarget =
      _Translations$onboarding$bodyTarget$en._(_root);
  @override
  late final _Translations$onboarding$experience$en experience =
      _Translations$onboarding$experience$en._(_root);
  @override
  late final _Translations$onboarding$schedule$en schedule = _Translations$onboarding$schedule$en._(
    _root,
  );
  @override
  late final _Translations$onboarding$equipment$en equipment =
      _Translations$onboarding$equipment$en._(_root);
  @override
  late final _Translations$onboarding$limitations$en limitations =
      _Translations$onboarding$limitations$en._(_root);
  @override
  late final _Translations$onboarding$creating$en creating = _Translations$onboarding$creating$en._(
    _root,
  );
  @override
  late final _Translations$onboarding$ready$en ready = _Translations$onboarding$ready$en._(_root);
  @override
  late final _Translations$onboarding$preview$en preview = _Translations$onboarding$preview$en._(
    _root,
  );
}

// Path: workoutSession
class _Translations$workoutSession$en extends Translations$workoutSession$id {
  _Translations$workoutSession$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String exerciseProgress({required Object current, required Object total}) =>
      'Exercise ${current} of ${total}';
  @override
  String setProgress({required Object current, required Object total, required Object target}) =>
      'Set ${current} of ${total} · ${target}';
  @override
  String get repsUnit => 'reps';
  @override
  String get durationUnit => 'sec';
  @override
  String repsValue({required Object value}) => '${value} reps';
  @override
  String durationValue({required Object value}) => '${value} sec';
  @override
  String get completeSet => 'Complete Set';
  @override
  String get nextRest => 'Next: Rest';
  @override
  String get preparingSession => 'Preparing your workout...';
  @override
  String get retry => 'Try Again';
  @override
  String get saveSetFailed => 'Failed to save the set. Check your connection and try again.';
  @override
  String get sessionConflictTitle => 'You have an unfinished workout';
  @override
  String sessionConflictMessage({required Object program, required Object day}) =>
      'You still have an active session for "${program}" (Day ${day}). Resume that session first, or end it to start this workout.';
  @override
  String get resumePreviousSession => 'Resume Previous Session';
  @override
  String get endPreviousSession => 'End Previous Session';
  @override
  String get completionTitle => 'Workout Completed! 🎉';
  @override
  String get completionDescription =>
      'You completed all sets and exercises. Get some rest to help your muscles recover.';
  @override
  String get durationLabel => 'Duration';
  @override
  String get exerciseLabel => 'Exercises';
  @override
  String exerciseCount({required Object count}) => '${count} exercises';
  @override
  String get totalSetsLabel => 'Total Sets';
  @override
  String totalSetsCount({required Object count}) => '${count} sets';
  @override
  String get viewSummary => 'View Workout Summary ➔';
  @override
  String get restartRestTimer => 'Restart Rest Timer';
  @override
  String get finishSessionNow => 'Finish Workout Now';
  @override
  String get exitWithoutSaving => 'Exit Without Saving';
  @override
  String get restTitle => 'Rest';
  @override
  String restNextExercise({required Object exercise}) => 'Next: ${exercise}';
  @override
  String restSetProgress({required Object current, required Object total}) =>
      'Set ${current} of ${total}';
  @override
  String get restPaused => 'PAUSED';
  @override
  String get restMinusTenSeconds => '-10s';
  @override
  String get restPlusTenSeconds => '+10s';
  @override
  String get restTipTitle => 'Tip';
  @override
  String get restTipDescription => 'Keep breathing and stay hydrated.';
  @override
  String get skipRest => 'Skip Rest';
  @override
  String setCompleteTitle({required Object current, required Object total}) =>
      'Set ${current} of ${total} Complete! 🎉';
  @override
  String targetDuration({required Object seconds}) => 'Target: ${seconds} sec';
  @override
  String targetReps({required Object reps}) => 'Target: ${reps} reps';
  @override
  String get durationCompleted => 'Duration Completed';
  @override
  String get repsCompleted => 'Reps Completed';
  @override
  String get durationQuestion => 'How many seconds did you hold?';
  @override
  String get repsQuestion => 'How many reps did you complete?';
  @override
  String get rirTitle => 'Remaining Strength (RIR - Reps in Reserve)';
  @override
  String get rirQuestion => 'How many more reps could you do before reaching failure?';
  @override
  String get rirFailureTitle => '0 — Absolute Failure';
  @override
  String get rirFailureDescription => 'You had no reps left with proper form.';
  @override
  String get rirVeryHardTitle => '1 — Very Hard';
  @override
  String get rirVeryHardDescription => 'You could only complete one more rep before failure.';
  @override
  String get rirIdealTitle => '2 — Ideal Zone (Target)';
  @override
  String get rirIdealDescription => 'Challenging, with about two reps still in reserve.';
  @override
  String get rirModerateTitle => '3 — Moderate';
  @override
  String get rirModerateDescription => 'You still had about three reps in reserve.';
  @override
  String get rirEasyTitle => '4+ — Too Easy';
  @override
  String get rirEasyDescription => 'Very easy, with four or more reps still in reserve.';
  @override
  String get rirBadgeMax => 'Maximum';
  @override
  String get rirBadgeHigh => 'High';
  @override
  String get rirBadgeOptimal => 'Optimal ⭐';
  @override
  String get rirBadgeModerate => 'Moderate';
  @override
  String get rirBadgeEasy => 'Easy';
  @override
  String get saveAndStartRest => 'Save & Start Rest';
  @override
  String restSecondsValue({required Object seconds}) => '${seconds} s';
  @override
  String durationMinutesValue({required Object value}) => '${value} min';
  @override
  String get savingSession => 'Saving your workout...';
  @override
  String get finishSessionFailed =>
      'We couldn\'t save your workout. Your recorded progress is still here. Please try again.';
}

// Path: workouts
class _Translations$workouts$en extends Translations$workouts$id {
  _Translations$workouts$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Workouts';
  @override
  String get searchHint => 'Search workouts & exercises...';
  @override
  late final _Translations$workouts$tabs$en tabs = _Translations$workouts$tabs$en._(_root);
  @override
  late final _Translations$workouts$activeProgram$en activeProgram =
      _Translations$workouts$activeProgram$en._(_root);
  @override
  late final _Translations$workouts$weeklySchedule$en weeklySchedule =
      _Translations$workouts$weeklySchedule$en._(_root);
  @override
  late final _Translations$workouts$emptyState$en emptyState =
      _Translations$workouts$emptyState$en._(_root);
  @override
  late final _Translations$workouts$allWorkouts$en allWorkouts =
      _Translations$workouts$allWorkouts$en._(_root);
  @override
  late final _Translations$workouts$errorState$en errorState =
      _Translations$workouts$errorState$en._(_root);
  @override
  late final _Translations$workouts$session$en session = _Translations$workouts$session$en._(_root);
  @override
  late final _Translations$workouts$workoutDetail$en workoutDetail =
      _Translations$workouts$workoutDetail$en._(_root);
  @override
  late final _Translations$workouts$filter$en filter = _Translations$workouts$filter$en._(_root);
  @override
  late final _Translations$workouts$categories$en categories =
      _Translations$workouts$categories$en._(_root);
}

// Path: core.actions
class _Translations$core$actions$en extends Translations$core$actions$id {
  _Translations$core$actions$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get save => 'Save';
  @override
  String get cancel => 'Cancel';
  @override
  String get back => 'Back';
  @override
  String get next => 'Next';
  @override
  String get skip => 'Skip';
  @override
  String get done => 'Done';
  @override
  String get retry => 'Retry';
  @override
  String get close => 'Close';
  @override
  String get edit => 'Edit';
  @override
  String get delete => 'Delete';
}

// Path: core.state
class _Translations$core$state$en extends Translations$core$state$id {
  _Translations$core$state$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get loading => 'Loading...';
  @override
  String get empty => 'Nothing here yet';
  @override
  String get error => 'Something went wrong';
}

// Path: core.badge
class _Translations$core$badge$en extends Translations$core$badge$id {
  _Translations$core$badge$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get currentPlan => 'Current Plan';
}

// Path: core.language
class _Translations$core$language$en extends Translations$core$language$id {
  _Translations$core$language$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get label => 'Language';
  @override
  String get id => 'Bahasa Indonesia';
  @override
  String get en => 'English';
}

// Path: core.units
class _Translations$core$units$en extends Translations$core$units$id {
  _Translations$core$units$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get reps => 'reps';
  @override
  String get sets => 'sets';
  @override
  String get seconds => 'sec';
  @override
  String get kg => 'kg';
}

// Path: home.greeting
class _Translations$home$greeting$en extends Translations$home$greeting$id {
  _Translations$home$greeting$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String goodMorning({required Object name}) => 'Good Morning, ${name} 👋';
  @override
  String goodAfternoon({required Object name}) => 'Good Afternoon, ${name} 👋';
  @override
  String goodEvening({required Object name}) => 'Good Evening, ${name} 👋';
  @override
  String get subtitle => 'Stay consistent and reach your goal!';
}

// Path: home.goalCard
class _Translations$home$goalCard$en extends Translations$home$goalCard$id {
  _Translations$home$goalCard$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get goalPrefix => 'Goal:';
  @override
  String get gainWeight => 'Gain Weight & Build Muscle';
  @override
  String get fatLoss => 'Fat Loss & Build Lean Body';
  @override
  String get maintain => 'Maintain & Stay Fit';
  @override
  String get target => 'Target';
  @override
  String get current => 'Current';
  @override
  String programDuration({required Object weeks}) => '${weeks} Weeks Program';
  @override
  String weekOf({required Object current, required Object total}) => 'Week ${current} of ${total}';
}

// Path: home.todayWorkout
class _Translations$home$todayWorkout$en extends Translations$home$todayWorkout$id {
  _Translations$home$todayWorkout$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Today\'s Workout';
  @override
  String get viewPlan => 'View Plan →';
  @override
  String get startWorkout => 'Start Workout';
  @override
  String approxMin({required Object min}) => '≈ ${min} min';
  @override
  String approxKcal({required Object kcal}) => '≈ ${kcal} kcal';
}

// Path: home.restDay
class _Translations$home$restDay$en extends Translations$home$restDay$id {
  _Translations$home$restDay$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Today is a Rest Day';
  @override
  String get subtitle => 'Time to recover, let your muscles repair and grow.';
  @override
  String get recoveryTips => 'Recovery Tips';
  @override
  String get hydrate => 'Stay hydrated';
  @override
  String get sleep => 'Get 7–9 hours of sleep';
  @override
  String get stretch => 'Do light stretching or mobility';
}

// Path: home.noProgram
class _Translations$home$noProgram$en extends Translations$home$noProgram$id {
  _Translations$home$noProgram$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'You don\'t have a training program yet';
  @override
  String get subtitle =>
      'Create a personalized training plan based on your goal, profile, and preference.';
  @override
  String get createProgram => 'Create My Program';
}

// Path: home.weeklyProgress
class _Translations$home$weeklyProgress$en extends Translations$home$weeklyProgress$id {
  _Translations$home$weeklyProgress$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'This Week Progress';
  @override
  String get seeDetails => 'See Details →';
  @override
  late final _Translations$home$weeklyProgress$states$en states =
      _Translations$home$weeklyProgress$states$en._(_root);
}

// Path: home.supportGoal
class _Translations$home$supportGoal$en extends Translations$home$supportGoal$id {
  _Translations$home$supportGoal$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Support Your Goal';
  @override
  String get subtitleGain => 'Get simple nutrition tips for muscle gain.';
  @override
  String get subtitleLoss => 'Get simple nutrition tips for fat loss.';
  @override
  String get subtitleMaintain => 'Get simple nutrition tips to stay fit.';
}

// Path: home.error
class _Translations$home$error$en extends Translations$home$error$id {
  _Translations$home$error$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get connectionIssue => 'Connection issue';
  @override
  String get connectionDesc =>
      'Some information couldn\'t be refreshed. Showing your last available data.';
  @override
  String lastSynced({required Object time}) => 'Last synced: ${time}';
  @override
  String get retry => 'Retry';
}

// Path: onboarding.nav
class _Translations$onboarding$nav$en extends Translations$onboarding$nav$id {
  _Translations$onboarding$nav$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String progress({required Object current, required Object total}) => '${current} of ${total}';
  @override
  String get getStarted => 'Get Started ➔';
  @override
  String get continueCta => 'Continue';
  @override
  String get createMyPlan => 'Create My Plan';
}

// Path: onboarding.welcome
class _Translations$onboarding$welcome$en extends Translations$onboarding$welcome$id {
  _Translations$onboarding$welcome$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get brand => 'Workout\nCoach';
  @override
  String get title => 'Your Personal\nWorkout Coach';
  @override
  String get subtitle =>
      'Get a workout program based\non your goal, body condition,\nand lifestyle.';
}

// Path: onboarding.goal
class _Translations$onboarding$goal$en extends Translations$onboarding$goal$id {
  _Translations$onboarding$goal$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'What\'s your main goal?';
  @override
  String get subtitle => 'Choose the goal that fits your current focus.';
  @override
  List<GoalOption> get options => [
    _Translations$onboarding$goal$options$0$en._(_root),
    _Translations$onboarding$goal$options$1$en._(_root),
    _Translations$onboarding$goal$options$2$en._(_root),
  ];
}

// Path: onboarding.about
class _Translations$onboarding$about$en extends Translations$onboarding$about$id {
  _Translations$onboarding$about$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Tell us about you';
  @override
  String get subtitle => 'We need some basic info to personalize your program.';
  @override
  String get gender => 'Gender';
  @override
  String get male => 'Male';
  @override
  String get female => 'Female';
  @override
  String get age => 'Age';
  @override
  String get ageUnit => 'years';
  @override
  String get height => 'Height';
  @override
  String get heightUnit => 'cm';
}

// Path: onboarding.bodyTarget
class _Translations$onboarding$bodyTarget$en extends Translations$onboarding$bodyTarget$id {
  _Translations$onboarding$bodyTarget$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Your body & target';
  @override
  String get subtitle => 'Set your current and target weight.';
  @override
  String get currentWeight => 'Current weight';
  @override
  String get targetWeight => 'Target weight';
  @override
  String get unit => 'kg';
  @override
  late final _Translations$onboarding$bodyTarget$insight$en insight =
      _Translations$onboarding$bodyTarget$insight$en._(_root);
}

// Path: onboarding.experience
class _Translations$onboarding$experience$en extends Translations$onboarding$experience$id {
  _Translations$onboarding$experience$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'What\'s your experience level?';
  @override
  String get subtitle => 'Choose an option that best describes you.';
  @override
  List<ExperienceOption> get options => [
    _Translations$onboarding$experience$options$0$en._(_root),
    _Translations$onboarding$experience$options$1$en._(_root),
    _Translations$onboarding$experience$options$2$en._(_root),
  ];
}

// Path: onboarding.schedule
class _Translations$onboarding$schedule$en extends Translations$onboarding$schedule$id {
  _Translations$onboarding$schedule$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'How often can you work out?';
  @override
  String get subtitle => 'Choose a weekly workout schedule that fits your lifestyle.';
  @override
  String daysPerWeek({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
        n,
        one: '${n} day / week',
        other: '${n} days / week',
      );
  @override
  String get sessionDuration => 'Session duration';
  @override
  String minutes({required Object n}) => '${n} min';
}

// Path: onboarding.equipment
class _Translations$onboarding$equipment$en extends Translations$onboarding$equipment$id {
  _Translations$onboarding$equipment$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'What equipment do you have?';
  @override
  String get subtitle => 'Select all that apply.';
  @override
  List<EquipmentOption> get options => [
    _Translations$onboarding$equipment$options$0$en._(_root),
    _Translations$onboarding$equipment$options$1$en._(_root),
    _Translations$onboarding$equipment$options$2$en._(_root),
    _Translations$onboarding$equipment$options$3$en._(_root),
    _Translations$onboarding$equipment$options$4$en._(_root),
    _Translations$onboarding$equipment$options$5$en._(_root),
  ];
}

// Path: onboarding.limitations
class _Translations$onboarding$limitations$en extends Translations$onboarding$limitations$id {
  _Translations$onboarding$limitations$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Any limitations or considerations?';
  @override
  String get subtitle => 'Let us know if you have any health conditions or areas to avoid.';
  @override
  List<LimitationOption> get options => [
    _Translations$onboarding$limitations$options$0$en._(_root),
    _Translations$onboarding$limitations$options$1$en._(_root),
    _Translations$onboarding$limitations$options$2$en._(_root),
    _Translations$onboarding$limitations$options$3$en._(_root),
    _Translations$onboarding$limitations$options$4$en._(_root),
    _Translations$onboarding$limitations$options$5$en._(_root),
  ];
}

// Path: onboarding.creating
class _Translations$onboarding$creating$en extends Translations$onboarding$creating$id {
  _Translations$onboarding$creating$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Creating your\npersonal plan...';
  @override
  String get subtitle => 'Analyzing your goal, body data,\npreferences, and availability.';
  @override
  List<String> get steps => [
    'Analyzing your profile',
    'Calculating training volume',
    'Selecting the best exercises',
    'Building your weekly plan',
  ];
}

// Path: onboarding.ready
class _Translations$onboarding$ready$en extends Translations$onboarding$ready$id {
  _Translations$onboarding$ready$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Your plan is ready! 🎉';
  @override
  String get subtitle => 'A personalized program based on\nyour goal, profile, and preferences.';
  @override
  String weeksBadge({required Object weeks}) => '⭐ ${weeks} Weeks';
  @override
  String get daysPerWeek => 'Days / Week';
  @override
  String get minutesPerSession => 'Minutes / Session';
  @override
  String get level => 'Level';
  @override
  List<String> get features => [
    'Build muscle and increase body weight',
    'Progressive overload (gradual increase)',
    'Designed for home training',
    'Adapted to your schedule and equipment',
  ];
  @override
  String get viewMyPlan => 'View My Plan';
  @override
  late final _Translations$onboarding$ready$program$en program =
      _Translations$onboarding$ready$program$en._(_root);
}

// Path: onboarding.preview
class _Translations$onboarding$preview$en extends Translations$onboarding$preview$id {
  _Translations$onboarding$preview$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Your Training Plan';
  @override
  String get tabOverview => 'Overview';
  @override
  String get tabWorkoutSplit => 'Workout Split';
  @override
  String get loading => 'Loading your plan preview...';
  @override
  String get activateStart => 'Activate & Start Workout ➔';
  @override
  String get activateDashboard => 'Activate & Go to Dashboard';
  @override
  String sessionFallbackName({required Object n}) => 'Session ${n}';
  @override
  String sessionDuration({required Object n}) => '${n} min';
  @override
  String exercisesInSession({required Object count}) => 'EXERCISES IN THIS SESSION (${count})';
  @override
  String prescription({required Object sets, required Object reps, required Object rests}) =>
      '${sets} sets • ${reps} reps • ${rests} rest';
}

// Path: workouts.tabs
class _Translations$workouts$tabs$en extends Translations$workouts$tabs$id {
  _Translations$workouts$tabs$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get myProgram => 'My Program';
  @override
  String get allWorkouts => 'All Workouts';
}

// Path: workouts.activeProgram
class _Translations$workouts$activeProgram$en extends Translations$workouts$activeProgram$id {
  _Translations$workouts$activeProgram$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Active Program';
  @override
  String weeksHomeWorkout({required Object weeks}) => '${weeks} weeks • Home workout';
  @override
  String weekOf({required Object current, required Object total}) => 'Week ${current} of ${total}';
  @override
  late final _Translations$workouts$activeProgram$status$en status =
      _Translations$workouts$activeProgram$status$en._(_root);
}

// Path: workouts.weeklySchedule
class _Translations$workouts$weeklySchedule$en extends Translations$workouts$weeklySchedule$id {
  _Translations$workouts$weeklySchedule$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Weekly Schedule';
  @override
  String workoutCount({required Object completed, required Object total}) =>
      '${completed}/${total} workouts';
  @override
  String get current => 'Current';
  @override
  String weekShort({required Object n}) => 'W${n}';
  @override
  String get empty => 'No workout sessions are scheduled for this week.';
  @override
  String get previewTitle => 'Preview mode';
  @override
  String get previewNotice =>
      'You can review this week\'s plan, but workouts can only be started on their scheduled day.';
  @override
  String get previewTooltip => 'Preview upcoming week';
  @override
  late final _Translations$workouts$weeklySchedule$statusTooltip$en statusTooltip =
      _Translations$workouts$weeklySchedule$statusTooltip$en._(_root);
}

// Path: workouts.emptyState
class _Translations$workouts$emptyState$en extends Translations$workouts$emptyState$id {
  _Translations$workouts$emptyState$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get noProgramTitle => 'No active program yet';
  @override
  String get noProgramSubtitle => 'Create a program to see your weekly workouts here.';
}

// Path: workouts.allWorkouts
class _Translations$workouts$allWorkouts$en extends Translations$workouts$allWorkouts$id {
  _Translations$workouts$allWorkouts$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get emptyTitle => 'No exercises found';
  @override
  String get emptySubtitle => 'Try another search or adjust your muscle filters.';
  @override
  String get clearFilters => 'Clear search & filters';
}

// Path: workouts.errorState
class _Translations$workouts$errorState$en extends Translations$workouts$errorState$id {
  _Translations$workouts$errorState$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Failed to load data';
  @override
  String get subtitle => 'Something went wrong while reading your workout data. Please try again.';
  @override
  String get retry => 'Retry';
  @override
  String get refreshFailed => 'Failed to refresh. Showing the last loaded data.';
}

// Path: workouts.session
class _Translations$workouts$session$en extends Translations$workouts$session$id {
  _Translations$workouts$session$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String day({required Object n}) => 'Day ${n}';
  @override
  String date({required Object n, required Object date}) => 'Day ${n} • ${date}';
  @override
  String min({required Object min}) => '${min} min';
  @override
  late final _Translations$workouts$session$status$en status =
      _Translations$workouts$session$status$en._(_root);
}

// Path: workouts.workoutDetail
class _Translations$workouts$workoutDetail$en extends Translations$workouts$workoutDetail$id {
  _Translations$workouts$workoutDetail$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get readOnlyTitle => 'Preview mode';
  @override
  String get readOnlyNotice =>
      'You can review this workout plan. The start button unlocks on its scheduled day.';
  @override
  String get resume => 'Resume Workout';
}

// Path: workouts.filter
class _Translations$workouts$filter$en extends Translations$workouts$filter$id {
  _Translations$workouts$filter$en._(TranslationsEn root) : this._root = root, super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Filter by Muscle Group';
}

// Path: workouts.categories
class _Translations$workouts$categories$en extends Translations$workouts$categories$id {
  _Translations$workouts$categories$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get all => 'All';
  @override
  String get chest => 'Chest';
  @override
  String get back => 'Back';
  @override
  String get legs => 'Legs';
  @override
  String get core => 'Core';
  @override
  String get arms => 'Arms';
  @override
  String get shoulders => 'Shoulders';
}

// Path: home.weeklyProgress.states
class _Translations$home$weeklyProgress$states$en
    extends Translations$home$weeklyProgress$states$id {
  _Translations$home$weeklyProgress$states$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get completed => 'Completed (workout done)';
  @override
  String get today => 'Today (scheduled workout)';
  @override
  String get rest => 'Rest day';
  @override
  String get upcoming => 'Upcoming (not yet)';
  @override
  String get missed => 'Missed';
}

// Path: onboarding.goal.options.0
class _Translations$onboarding$goal$options$0$en extends Translations$onboarding$goal$options$0$id
    with GoalOption {
  _Translations$onboarding$goal$options$0$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'muscle_gain';
  @override
  String get title => 'Gain Weight & Build Muscle';
  @override
  String get description => 'Increase body weight while building muscle mass (bulking).';
}

// Path: onboarding.goal.options.1
class _Translations$onboarding$goal$options$1$en extends Translations$onboarding$goal$options$1$id
    with GoalOption {
  _Translations$onboarding$goal$options$1$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'fat_loss';
  @override
  String get title => 'Lose Weight & Reduce Fat';
  @override
  String get description => 'Reduce body fat while maintaining muscle (cutting).';
}

// Path: onboarding.goal.options.2
class _Translations$onboarding$goal$options$2$en extends Translations$onboarding$goal$options$2$id
    with GoalOption {
  _Translations$onboarding$goal$options$2$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'maintenance';
  @override
  String get title => 'Maintain & Stay Fit';
  @override
  String get description => 'Keep your current weight and overall fitness.';
}

// Path: onboarding.bodyTarget.insight
class _Translations$onboarding$bodyTarget$insight$en
    extends Translations$onboarding$bodyTarget$insight$id {
  _Translations$onboarding$bodyTarget$insight$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String gainTitle({required Object diff}) => 'Target gain: +${diff} kg';
  @override
  String lossTitle({required Object diff}) => 'Target loss: ${diff} kg';
  @override
  String get maintainTitle => 'Target: Maintenance';
  @override
  String gainHint({required Object minWeeks, required Object maxWeeks}) =>
      'A healthy gain is around 0.25 - 0.5 kg per week (${minWeeks} - ${maxWeeks} weeks).';
  @override
  String lossHint({required Object minWeeks, required Object maxWeeks}) =>
      'A healthy loss is around 0.5 - 1.0 kg per week (${minWeeks} - ${maxWeeks} weeks).';
  @override
  String get maintainHint =>
      'Keep your current body weight and focus on building muscle density and strength.';
}

// Path: onboarding.experience.options.0
class _Translations$onboarding$experience$options$0$en
    extends Translations$onboarding$experience$options$0$id
    with ExperienceOption {
  _Translations$onboarding$experience$options$0$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'beginner';
  @override
  String get title => 'Beginner';
  @override
  String get description => 'New to training or exercising inconsistently.';
}

// Path: onboarding.experience.options.1
class _Translations$onboarding$experience$options$1$en
    extends Translations$onboarding$experience$options$1$id
    with ExperienceOption {
  _Translations$onboarding$experience$options$1$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'intermediate';
  @override
  String get title => 'Intermediate';
  @override
  String get description => 'Have some experience and train regularly.';
}

// Path: onboarding.experience.options.2
class _Translations$onboarding$experience$options$2$en
    extends Translations$onboarding$experience$options$2$id
    with ExperienceOption {
  _Translations$onboarding$experience$options$2$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'advanced';
  @override
  String get title => 'Advanced';
  @override
  String get description => 'Train consistently, have good form, and want a bigger challenge.';
}

// Path: onboarding.equipment.options.0
class _Translations$onboarding$equipment$options$0$en
    extends Translations$onboarding$equipment$options$0$id
    with EquipmentOption {
  _Translations$onboarding$equipment$options$0$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'bodyweight';
  @override
  String get label => 'Bodyweight\n(no equipment)';
}

// Path: onboarding.equipment.options.1
class _Translations$onboarding$equipment$options$1$en
    extends Translations$onboarding$equipment$options$1$id
    with EquipmentOption {
  _Translations$onboarding$equipment$options$1$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'dumbbell';
  @override
  String get label => 'Dumbbell';
}

// Path: onboarding.equipment.options.2
class _Translations$onboarding$equipment$options$2$en
    extends Translations$onboarding$equipment$options$2$id
    with EquipmentOption {
  _Translations$onboarding$equipment$options$2$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'resistance_band';
  @override
  String get label => 'Resistance\nBand';
}

// Path: onboarding.equipment.options.3
class _Translations$onboarding$equipment$options$3$en
    extends Translations$onboarding$equipment$options$3$id
    with EquipmentOption {
  _Translations$onboarding$equipment$options$3$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'kettlebell';
  @override
  String get label => 'Kettlebell';
}

// Path: onboarding.equipment.options.4
class _Translations$onboarding$equipment$options$4$en
    extends Translations$onboarding$equipment$options$4$id
    with EquipmentOption {
  _Translations$onboarding$equipment$options$4$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'pull_up_bar';
  @override
  String get label => 'Pull-up Bar';
}

// Path: onboarding.equipment.options.5
class _Translations$onboarding$equipment$options$5$en
    extends Translations$onboarding$equipment$options$5$id
    with EquipmentOption {
  _Translations$onboarding$equipment$options$5$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'barbell';
  @override
  String get label => 'Barbell';
}

// Path: onboarding.limitations.options.0
class _Translations$onboarding$limitations$options$0$en
    extends Translations$onboarding$limitations$options$0$id
    with LimitationOption {
  _Translations$onboarding$limitations$options$0$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'none';
  @override
  String get label => 'No limitations';
}

// Path: onboarding.limitations.options.1
class _Translations$onboarding$limitations$options$1$en
    extends Translations$onboarding$limitations$options$1$id
    with LimitationOption {
  _Translations$onboarding$limitations$options$1$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'knee';
  @override
  String get label => 'Knee (e.g. pain, injury)';
}

// Path: onboarding.limitations.options.2
class _Translations$onboarding$limitations$options$2$en
    extends Translations$onboarding$limitations$options$2$id
    with LimitationOption {
  _Translations$onboarding$limitations$options$2$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'back';
  @override
  String get label => 'Back (e.g. lower back pain)';
}

// Path: onboarding.limitations.options.3
class _Translations$onboarding$limitations$options$3$en
    extends Translations$onboarding$limitations$options$3$id
    with LimitationOption {
  _Translations$onboarding$limitations$options$3$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'shoulder';
  @override
  String get label => 'Shoulder';
}

// Path: onboarding.limitations.options.4
class _Translations$onboarding$limitations$options$4$en
    extends Translations$onboarding$limitations$options$4$id
    with LimitationOption {
  _Translations$onboarding$limitations$options$4$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'wrist';
  @override
  String get label => 'Wrist';
}

// Path: onboarding.limitations.options.5
class _Translations$onboarding$limitations$options$5$en
    extends Translations$onboarding$limitations$options$5$id
    with LimitationOption {
  _Translations$onboarding$limitations$options$5$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get id => 'other';
  @override
  String get label => 'Other';
}

// Path: onboarding.ready.program
class _Translations$onboarding$ready$program$en extends Translations$onboarding$ready$program$id {
  _Translations$onboarding$ready$program$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  late final _Translations$onboarding$ready$program$bulking$en bulking =
      _Translations$onboarding$ready$program$bulking$en._(_root);
  @override
  late final _Translations$onboarding$ready$program$cutting$en cutting =
      _Translations$onboarding$ready$program$cutting$en._(_root);
  @override
  late final _Translations$onboarding$ready$program$maintain$en maintain =
      _Translations$onboarding$ready$program$maintain$en._(_root);
}

// Path: workouts.activeProgram.status
class _Translations$workouts$activeProgram$status$en
    extends Translations$workouts$activeProgram$status$id {
  _Translations$workouts$activeProgram$status$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String notStarted({required Object date}) => 'Starts ${date}';
  @override
  String get completed => 'Program completed';
  @override
  String get expired => 'Program ended';
}

// Path: workouts.weeklySchedule.statusTooltip
class _Translations$workouts$weeklySchedule$statusTooltip$en
    extends Translations$workouts$weeklySchedule$statusTooltip$id {
  _Translations$workouts$weeklySchedule$statusTooltip$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get completed => 'All workouts completed';
  @override
  String get partial => 'Some workouts completed';
  @override
  String get missed => 'Some workouts were missed';
}

// Path: workouts.session.status
class _Translations$workouts$session$status$en extends Translations$workouts$session$status$id {
  _Translations$workouts$session$status$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get completed => 'Completed';
  @override
  String get inProgress => 'In progress';
  @override
  String get readyToStart => 'Today • Ready to start';
  @override
  String get missed => 'Missed';
  @override
  String get scheduled => 'Scheduled';
}

// Path: onboarding.ready.program.bulking
class _Translations$onboarding$ready$program$bulking$en
    extends Translations$onboarding$ready$program$bulking$id {
  _Translations$onboarding$ready$program$bulking$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Bulking Program';
  @override
  String get subtitle => 'Muscle Gain & Strength';
}

// Path: onboarding.ready.program.cutting
class _Translations$onboarding$ready$program$cutting$en
    extends Translations$onboarding$ready$program$cutting$id {
  _Translations$onboarding$ready$program$cutting$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Fat Loss & Conditioning';
  @override
  String get subtitle => 'Fat Loss & Tone';
}

// Path: onboarding.ready.program.maintain
class _Translations$onboarding$ready$program$maintain$en
    extends Translations$onboarding$ready$program$maintain$id {
  _Translations$onboarding$ready$program$maintain$en._(TranslationsEn root)
    : this._root = root,
      super.internal(root);

  final TranslationsEn _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Maintain & Stay Fit';
  @override
  String get subtitle => 'Strength & General Fitness';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
  dynamic _flatMapFunction(String path) {
    return switch (path) {
      'core.appName' => 'Home Bulking Coach',
      'core.actions.save' => 'Save',
      'core.actions.cancel' => 'Cancel',
      'core.actions.back' => 'Back',
      'core.actions.next' => 'Next',
      'core.actions.skip' => 'Skip',
      'core.actions.done' => 'Done',
      'core.actions.retry' => 'Retry',
      'core.actions.close' => 'Close',
      'core.actions.edit' => 'Edit',
      'core.actions.delete' => 'Delete',
      'core.state.loading' => 'Loading...',
      'core.state.empty' => 'Nothing here yet',
      'core.state.error' => 'Something went wrong',
      'core.badge.currentPlan' => 'Current Plan',
      'core.language.label' => 'Language',
      'core.language.id' => 'Bahasa Indonesia',
      'core.language.en' => 'English',
      'core.units.reps' => 'reps',
      'core.units.sets' => 'sets',
      'core.units.seconds' => 'sec',
      'core.units.kg' => 'kg',
      'home.greeting.goodMorning' => ({required Object name}) => 'Good Morning, ${name} 👋',
      'home.greeting.goodAfternoon' => ({required Object name}) => 'Good Afternoon, ${name} 👋',
      'home.greeting.goodEvening' => ({required Object name}) => 'Good Evening, ${name} 👋',
      'home.greeting.subtitle' => 'Stay consistent and reach your goal!',
      'home.goalCard.goalPrefix' => 'Goal:',
      'home.goalCard.gainWeight' => 'Gain Weight & Build Muscle',
      'home.goalCard.fatLoss' => 'Fat Loss & Build Lean Body',
      'home.goalCard.maintain' => 'Maintain & Stay Fit',
      'home.goalCard.target' => 'Target',
      'home.goalCard.current' => 'Current',
      'home.goalCard.programDuration' => ({required Object weeks}) => '${weeks} Weeks Program',
      'home.goalCard.weekOf' => ({
        required Object current,
        required Object total,
      }) => 'Week ${current} of ${total}',
      'home.todayWorkout.title' => 'Today\'s Workout',
      'home.todayWorkout.viewPlan' => 'View Plan →',
      'home.todayWorkout.startWorkout' => 'Start Workout',
      'home.todayWorkout.approxMin' => ({required Object min}) => '≈ ${min} min',
      'home.todayWorkout.approxKcal' => ({required Object kcal}) => '≈ ${kcal} kcal',
      'home.restDay.title' => 'Today is a Rest Day',
      'home.restDay.subtitle' => 'Time to recover, let your muscles repair and grow.',
      'home.restDay.recoveryTips' => 'Recovery Tips',
      'home.restDay.hydrate' => 'Stay hydrated',
      'home.restDay.sleep' => 'Get 7–9 hours of sleep',
      'home.restDay.stretch' => 'Do light stretching or mobility',
      'home.noProgram.title' => 'You don\'t have a training program yet',
      'home.noProgram.subtitle' =>
        'Create a personalized training plan based on your goal, profile, and preference.',
      'home.noProgram.createProgram' => 'Create My Program',
      'home.weeklyProgress.title' => 'This Week Progress',
      'home.weeklyProgress.seeDetails' => 'See Details →',
      'home.weeklyProgress.states.completed' => 'Completed (workout done)',
      'home.weeklyProgress.states.today' => 'Today (scheduled workout)',
      'home.weeklyProgress.states.rest' => 'Rest day',
      'home.weeklyProgress.states.upcoming' => 'Upcoming (not yet)',
      'home.weeklyProgress.states.missed' => 'Missed',
      'home.supportGoal.title' => 'Support Your Goal',
      'home.supportGoal.subtitleGain' => 'Get simple nutrition tips for muscle gain.',
      'home.supportGoal.subtitleLoss' => 'Get simple nutrition tips for fat loss.',
      'home.supportGoal.subtitleMaintain' => 'Get simple nutrition tips to stay fit.',
      'home.error.connectionIssue' => 'Connection issue',
      'home.error.connectionDesc' =>
        'Some information couldn\'t be refreshed. Showing your last available data.',
      'home.error.lastSynced' => ({required Object time}) => 'Last synced: ${time}',
      'home.error.retry' => 'Retry',
      'onboarding.nav.progress' => ({
        required Object current,
        required Object total,
      }) => '${current} of ${total}',
      'onboarding.nav.getStarted' => 'Get Started ➔',
      'onboarding.nav.continueCta' => 'Continue',
      'onboarding.nav.createMyPlan' => 'Create My Plan',
      'onboarding.welcome.brand' => 'Workout\nCoach',
      'onboarding.welcome.title' => 'Your Personal\nWorkout Coach',
      'onboarding.welcome.subtitle' =>
        'Get a workout program based\non your goal, body condition,\nand lifestyle.',
      'onboarding.goal.title' => 'What\'s your main goal?',
      'onboarding.goal.subtitle' => 'Choose the goal that fits your current focus.',
      'onboarding.goal.options.0.id' => 'muscle_gain',
      'onboarding.goal.options.0.title' => 'Gain Weight & Build Muscle',
      'onboarding.goal.options.0.description' =>
        'Increase body weight while building muscle mass (bulking).',
      'onboarding.goal.options.1.id' => 'fat_loss',
      'onboarding.goal.options.1.title' => 'Lose Weight & Reduce Fat',
      'onboarding.goal.options.1.description' =>
        'Reduce body fat while maintaining muscle (cutting).',
      'onboarding.goal.options.2.id' => 'maintenance',
      'onboarding.goal.options.2.title' => 'Maintain & Stay Fit',
      'onboarding.goal.options.2.description' => 'Keep your current weight and overall fitness.',
      'onboarding.about.title' => 'Tell us about you',
      'onboarding.about.subtitle' => 'We need some basic info to personalize your program.',
      'onboarding.about.gender' => 'Gender',
      'onboarding.about.male' => 'Male',
      'onboarding.about.female' => 'Female',
      'onboarding.about.age' => 'Age',
      'onboarding.about.ageUnit' => 'years',
      'onboarding.about.height' => 'Height',
      'onboarding.about.heightUnit' => 'cm',
      'onboarding.bodyTarget.title' => 'Your body & target',
      'onboarding.bodyTarget.subtitle' => 'Set your current and target weight.',
      'onboarding.bodyTarget.currentWeight' => 'Current weight',
      'onboarding.bodyTarget.targetWeight' => 'Target weight',
      'onboarding.bodyTarget.unit' => 'kg',
      'onboarding.bodyTarget.insight.gainTitle' => ({
        required Object diff,
      }) => 'Target gain: +${diff} kg',
      'onboarding.bodyTarget.insight.lossTitle' => ({
        required Object diff,
      }) => 'Target loss: ${diff} kg',
      'onboarding.bodyTarget.insight.maintainTitle' => 'Target: Maintenance',
      'onboarding.bodyTarget.insight.gainHint' => ({
        required Object minWeeks,
        required Object maxWeeks,
      }) => 'A healthy gain is around 0.25 - 0.5 kg per week (${minWeeks} - ${maxWeeks} weeks).',
      'onboarding.bodyTarget.insight.lossHint' => ({
        required Object minWeeks,
        required Object maxWeeks,
      }) => 'A healthy loss is around 0.5 - 1.0 kg per week (${minWeeks} - ${maxWeeks} weeks).',
      'onboarding.bodyTarget.insight.maintainHint' =>
        'Keep your current body weight and focus on building muscle density and strength.',
      'onboarding.experience.title' => 'What\'s your experience level?',
      'onboarding.experience.subtitle' => 'Choose an option that best describes you.',
      'onboarding.experience.options.0.id' => 'beginner',
      'onboarding.experience.options.0.title' => 'Beginner',
      'onboarding.experience.options.0.description' =>
        'New to training or exercising inconsistently.',
      'onboarding.experience.options.1.id' => 'intermediate',
      'onboarding.experience.options.1.title' => 'Intermediate',
      'onboarding.experience.options.1.description' => 'Have some experience and train regularly.',
      'onboarding.experience.options.2.id' => 'advanced',
      'onboarding.experience.options.2.title' => 'Advanced',
      'onboarding.experience.options.2.description' =>
        'Train consistently, have good form, and want a bigger challenge.',
      'onboarding.schedule.title' => 'How often can you work out?',
      'onboarding.schedule.subtitle' =>
        'Choose a weekly workout schedule that fits your lifestyle.',
      'onboarding.schedule.daysPerWeek' =>
        ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
          n,
          one: '${n} day / week',
          other: '${n} days / week',
        ),
      'onboarding.schedule.sessionDuration' => 'Session duration',
      'onboarding.schedule.minutes' => ({required Object n}) => '${n} min',
      'onboarding.equipment.title' => 'What equipment do you have?',
      'onboarding.equipment.subtitle' => 'Select all that apply.',
      'onboarding.equipment.options.0.id' => 'bodyweight',
      'onboarding.equipment.options.0.label' => 'Bodyweight\n(no equipment)',
      'onboarding.equipment.options.1.id' => 'dumbbell',
      'onboarding.equipment.options.1.label' => 'Dumbbell',
      'onboarding.equipment.options.2.id' => 'resistance_band',
      'onboarding.equipment.options.2.label' => 'Resistance\nBand',
      'onboarding.equipment.options.3.id' => 'kettlebell',
      'onboarding.equipment.options.3.label' => 'Kettlebell',
      'onboarding.equipment.options.4.id' => 'pull_up_bar',
      'onboarding.equipment.options.4.label' => 'Pull-up Bar',
      'onboarding.equipment.options.5.id' => 'barbell',
      'onboarding.equipment.options.5.label' => 'Barbell',
      'onboarding.limitations.title' => 'Any limitations or considerations?',
      'onboarding.limitations.subtitle' =>
        'Let us know if you have any health conditions or areas to avoid.',
      'onboarding.limitations.options.0.id' => 'none',
      'onboarding.limitations.options.0.label' => 'No limitations',
      'onboarding.limitations.options.1.id' => 'knee',
      'onboarding.limitations.options.1.label' => 'Knee (e.g. pain, injury)',
      'onboarding.limitations.options.2.id' => 'back',
      'onboarding.limitations.options.2.label' => 'Back (e.g. lower back pain)',
      'onboarding.limitations.options.3.id' => 'shoulder',
      'onboarding.limitations.options.3.label' => 'Shoulder',
      'onboarding.limitations.options.4.id' => 'wrist',
      'onboarding.limitations.options.4.label' => 'Wrist',
      'onboarding.limitations.options.5.id' => 'other',
      'onboarding.limitations.options.5.label' => 'Other',
      'onboarding.creating.title' => 'Creating your\npersonal plan...',
      'onboarding.creating.subtitle' =>
        'Analyzing your goal, body data,\npreferences, and availability.',
      'onboarding.creating.steps.0' => 'Analyzing your profile',
      'onboarding.creating.steps.1' => 'Calculating training volume',
      'onboarding.creating.steps.2' => 'Selecting the best exercises',
      'onboarding.creating.steps.3' => 'Building your weekly plan',
      'onboarding.ready.title' => 'Your plan is ready! 🎉',
      'onboarding.ready.subtitle' =>
        'A personalized program based on\nyour goal, profile, and preferences.',
      'onboarding.ready.weeksBadge' => ({required Object weeks}) => '⭐ ${weeks} Weeks',
      'onboarding.ready.daysPerWeek' => 'Days / Week',
      'onboarding.ready.minutesPerSession' => 'Minutes / Session',
      'onboarding.ready.level' => 'Level',
      'onboarding.ready.features.0' => 'Build muscle and increase body weight',
      'onboarding.ready.features.1' => 'Progressive overload (gradual increase)',
      'onboarding.ready.features.2' => 'Designed for home training',
      'onboarding.ready.features.3' => 'Adapted to your schedule and equipment',
      'onboarding.ready.viewMyPlan' => 'View My Plan',
      'onboarding.ready.program.bulking.title' => 'Bulking Program',
      'onboarding.ready.program.bulking.subtitle' => 'Muscle Gain & Strength',
      'onboarding.ready.program.cutting.title' => 'Fat Loss & Conditioning',
      'onboarding.ready.program.cutting.subtitle' => 'Fat Loss & Tone',
      'onboarding.ready.program.maintain.title' => 'Maintain & Stay Fit',
      'onboarding.ready.program.maintain.subtitle' => 'Strength & General Fitness',
      'onboarding.preview.title' => 'Your Training Plan',
      'onboarding.preview.tabOverview' => 'Overview',
      'onboarding.preview.tabWorkoutSplit' => 'Workout Split',
      'onboarding.preview.loading' => 'Loading your plan preview...',
      'onboarding.preview.activateStart' => 'Activate & Start Workout ➔',
      'onboarding.preview.activateDashboard' => 'Activate & Go to Dashboard',
      'onboarding.preview.sessionFallbackName' => ({required Object n}) => 'Session ${n}',
      'onboarding.preview.sessionDuration' => ({required Object n}) => '${n} min',
      'onboarding.preview.exercisesInSession' => ({
        required Object count,
      }) => 'EXERCISES IN THIS SESSION (${count})',
      'onboarding.preview.prescription' => ({
        required Object sets,
        required Object reps,
        required Object rests,
      }) => '${sets} sets • ${reps} reps • ${rests} rest',
      'workoutSession.exerciseProgress' => ({
        required Object current,
        required Object total,
      }) => 'Exercise ${current} of ${total}',
      'workoutSession.setProgress' => ({
        required Object current,
        required Object total,
        required Object target,
      }) => 'Set ${current} of ${total} · ${target}',
      'workoutSession.repsUnit' => 'reps',
      'workoutSession.durationUnit' => 'sec',
      'workoutSession.repsValue' => ({required Object value}) => '${value} reps',
      'workoutSession.durationValue' => ({required Object value}) => '${value} sec',
      'workoutSession.completeSet' => 'Complete Set',
      'workoutSession.nextRest' => 'Next: Rest',
      'workoutSession.preparingSession' => 'Preparing your workout...',
      'workoutSession.retry' => 'Try Again',
      'workoutSession.saveSetFailed' =>
        'Failed to save the set. Check your connection and try again.',
      'workoutSession.sessionConflictTitle' => 'You have an unfinished workout',
      'workoutSession.sessionConflictMessage' => ({
        required Object program,
        required Object day,
      }) => 'You still have an active session for "${program}" (Day ${day}). Resume that session first, or end it to start this workout.',
      'workoutSession.resumePreviousSession' => 'Resume Previous Session',
      'workoutSession.endPreviousSession' => 'End Previous Session',
      'workoutSession.completionTitle' => 'Workout Completed! 🎉',
      'workoutSession.completionDescription' =>
        'You completed all sets and exercises. Get some rest to help your muscles recover.',
      'workoutSession.durationLabel' => 'Duration',
      'workoutSession.exerciseLabel' => 'Exercises',
      'workoutSession.exerciseCount' => ({required Object count}) => '${count} exercises',
      'workoutSession.totalSetsLabel' => 'Total Sets',
      'workoutSession.totalSetsCount' => ({required Object count}) => '${count} sets',
      'workoutSession.viewSummary' => 'View Workout Summary ➔',
      'workoutSession.restartRestTimer' => 'Restart Rest Timer',
      'workoutSession.finishSessionNow' => 'Finish Workout Now',
      'workoutSession.exitWithoutSaving' => 'Exit Without Saving',
      'workoutSession.restTitle' => 'Rest',
      'workoutSession.restNextExercise' => ({required Object exercise}) => 'Next: ${exercise}',
      'workoutSession.restSetProgress' => ({
        required Object current,
        required Object total,
      }) => 'Set ${current} of ${total}',
      'workoutSession.restPaused' => 'PAUSED',
      'workoutSession.restMinusTenSeconds' => '-10s',
      'workoutSession.restPlusTenSeconds' => '+10s',
      'workoutSession.restTipTitle' => 'Tip',
      'workoutSession.restTipDescription' => 'Keep breathing and stay hydrated.',
      'workoutSession.skipRest' => 'Skip Rest',
      'workoutSession.setCompleteTitle' => ({
        required Object current,
        required Object total,
      }) => 'Set ${current} of ${total} Complete! 🎉',
      'workoutSession.targetDuration' => ({required Object seconds}) => 'Target: ${seconds} sec',
      'workoutSession.targetReps' => ({required Object reps}) => 'Target: ${reps} reps',
      'workoutSession.durationCompleted' => 'Duration Completed',
      'workoutSession.repsCompleted' => 'Reps Completed',
      'workoutSession.durationQuestion' => 'How many seconds did you hold?',
      'workoutSession.repsQuestion' => 'How many reps did you complete?',
      'workoutSession.rirTitle' => 'Remaining Strength (RIR - Reps in Reserve)',
      'workoutSession.rirQuestion' => 'How many more reps could you do before reaching failure?',
      'workoutSession.rirFailureTitle' => '0 — Absolute Failure',
      'workoutSession.rirFailureDescription' => 'You had no reps left with proper form.',
      'workoutSession.rirVeryHardTitle' => '1 — Very Hard',
      'workoutSession.rirVeryHardDescription' =>
        'You could only complete one more rep before failure.',
      'workoutSession.rirIdealTitle' => '2 — Ideal Zone (Target)',
      'workoutSession.rirIdealDescription' => 'Challenging, with about two reps still in reserve.',
      'workoutSession.rirModerateTitle' => '3 — Moderate',
      'workoutSession.rirModerateDescription' => 'You still had about three reps in reserve.',
      'workoutSession.rirEasyTitle' => '4+ — Too Easy',
      'workoutSession.rirEasyDescription' => 'Very easy, with four or more reps still in reserve.',
      'workoutSession.rirBadgeMax' => 'Maximum',
      'workoutSession.rirBadgeHigh' => 'High',
      'workoutSession.rirBadgeOptimal' => 'Optimal ⭐',
      'workoutSession.rirBadgeModerate' => 'Moderate',
      'workoutSession.rirBadgeEasy' => 'Easy',
      'workoutSession.saveAndStartRest' => 'Save & Start Rest',
      'workoutSession.restSecondsValue' => ({required Object seconds}) => '${seconds} s',
      'workoutSession.durationMinutesValue' => ({required Object value}) => '${value} min',
      'workoutSession.savingSession' => 'Saving your workout...',
      'workouts.title' => 'Workouts',
      'workouts.searchHint' => 'Search workouts & exercises...',
      'workouts.tabs.myProgram' => 'My Program',
      'workouts.tabs.allWorkouts' => 'All Workouts',
      'workouts.activeProgram.title' => 'Active Program',
      'workouts.activeProgram.weeksHomeWorkout' => ({
        required Object weeks,
      }) => '${weeks} weeks • Home workout',
      'workouts.activeProgram.weekOf' => ({
        required Object current,
        required Object total,
      }) => 'Week ${current} of ${total}',
      'workouts.activeProgram.status.notStarted' => ({required Object date}) => 'Starts ${date}',
      'workouts.activeProgram.status.completed' => 'Program completed',
      'workouts.activeProgram.status.expired' => 'Program ended',
      'workouts.weeklySchedule.title' => 'Weekly Schedule',
      'workouts.weeklySchedule.workoutCount' => ({
        required Object completed,
        required Object total,
      }) => '${completed}/${total} workouts',
      'workouts.weeklySchedule.current' => 'Current',
      'workouts.weeklySchedule.weekShort' => ({required Object n}) => 'W${n}',
      'workouts.weeklySchedule.empty' => 'No workout sessions are scheduled for this week.',
      'workouts.weeklySchedule.previewTitle' => 'Preview mode',
      'workouts.weeklySchedule.previewNotice' => 'You can review this week\'s plan, but workouts can only be started on their scheduled day.',
      'workouts.weeklySchedule.previewTooltip' => 'Preview upcoming week',
      'workouts.weeklySchedule.statusTooltip.completed' => 'All workouts completed',
      'workouts.weeklySchedule.statusTooltip.partial' => 'Some workouts completed',
      'workouts.weeklySchedule.statusTooltip.missed' => 'Some workouts were missed',
      'workouts.emptyState.noProgramTitle' => 'No active program yet',
      'workouts.emptyState.noProgramSubtitle' =>
        'Create a program to see your weekly workouts here.',
      'workouts.allWorkouts.emptyTitle' => 'No exercises found',
      'workouts.allWorkouts.emptySubtitle' => 'Try another search or adjust your muscle filters.',
      'workouts.allWorkouts.clearFilters' => 'Clear search & filters',
      'workouts.errorState.title' => 'Failed to load data',
      'workouts.errorState.subtitle' =>
        'Something went wrong while reading your workout data. Please try again.',
      'workouts.errorState.retry' => 'Retry',
      'workouts.errorState.refreshFailed' => 'Failed to refresh. Showing the last loaded data.',
      'workouts.session.day' => ({required Object n}) => 'Day ${n}',
      'workouts.session.date' => ({
        required Object n,
        required Object date,
      }) => 'Day ${n} • ${date}',
      'workouts.session.min' => ({required Object min}) => '${min} min',
      'workouts.session.status.completed' => 'Completed',
      'workouts.session.status.inProgress' => 'In progress',
      'workouts.session.status.readyToStart' => 'Today • Ready to start',
      'workouts.session.status.missed' => 'Missed',
      'workouts.session.status.scheduled' => 'Scheduled',
      'workouts.workoutDetail.readOnlyTitle' => 'Preview mode',
      'workouts.workoutDetail.readOnlyNotice' =>
        'You can review this workout plan. The start button unlocks on its scheduled day.',
      'workouts.workoutDetail.resume' => 'Resume Workout',
      'workouts.filter.title' => 'Filter by Muscle Group',
      'workouts.categories.all' => 'All',
      'workouts.categories.chest' => 'Chest',
      'workouts.categories.back' => 'Back',
      'workouts.categories.legs' => 'Legs',
      'workouts.categories.core' => 'Core',
      'workouts.categories.arms' => 'Arms',
      'workouts.categories.shoulders' => 'Shoulders',
      _ => null,
    };
  }
}
