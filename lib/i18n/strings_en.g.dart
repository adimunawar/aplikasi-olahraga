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
      _ => null,
    };
  }
}
