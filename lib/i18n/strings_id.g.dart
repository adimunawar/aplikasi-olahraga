///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsId = Translations; // ignore: unused_element

class Translations with BaseTranslations<AppLocale, Translations> {
  /// Returns the current translations of the given [context].
  ///
  /// Usage:
  /// final t = Translations.of(context);
  static Translations of(BuildContext context) =>
      InheritedLocaleData.of<AppLocale, Translations>(context).translations;

  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  Translations({
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
             locale: AppLocale.id,
             overrides: overrides ?? {},
             cardinalResolver: cardinalResolver,
             ordinalResolver: ordinalResolver,
           ) {
    _meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <id>.
  final TranslationMetadata<AppLocale, Translations> _meta;
  @override
  TranslationMetadata<AppLocale, Translations> get $meta => _meta;

  /// Access flat map
  dynamic operator [](String key) => _meta.getTranslation(key);

  late final Translations _root = this; // ignore: unused_field

  Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) =>
      Translations(meta: meta ?? this.$meta);

  // Translations
  late final Translations$core$id core = Translations$core$id.internal(_root);
}

// Path: core
class Translations$core$id {
  Translations$core$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Home Bulking Coach'
  String get appName => 'Home Bulking Coach';

  late final Translations$core$actions$id actions = Translations$core$actions$id.internal(_root);
  late final Translations$core$state$id state = Translations$core$state$id.internal(_root);
  late final Translations$core$badge$id badge = Translations$core$badge$id.internal(_root);
  late final Translations$core$language$id language = Translations$core$language$id.internal(_root);
  late final Translations$core$units$id units = Translations$core$units$id.internal(_root);
}

// Path: core.actions
class Translations$core$actions$id {
  Translations$core$actions$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Simpan'
  String get save => 'Simpan';

  /// id: 'Batal'
  String get cancel => 'Batal';

  /// id: 'Kembali'
  String get back => 'Kembali';

  /// id: 'Lanjut'
  String get next => 'Lanjut';

  /// id: 'Lewati'
  String get skip => 'Lewati';

  /// id: 'Selesai'
  String get done => 'Selesai';

  /// id: 'Coba Lagi'
  String get retry => 'Coba Lagi';

  /// id: 'Tutup'
  String get close => 'Tutup';

  /// id: 'Ubah'
  String get edit => 'Ubah';

  /// id: 'Hapus'
  String get delete => 'Hapus';
}

// Path: core.state
class Translations$core$state$id {
  Translations$core$state$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Memuat...'
  String get loading => 'Memuat...';

  /// id: 'Belum ada data'
  String get empty => 'Belum ada data';

  /// id: 'Terjadi kesalahan'
  String get error => 'Terjadi kesalahan';
}

// Path: core.badge
class Translations$core$badge$id {
  Translations$core$badge$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Program Aktif'
  String get currentPlan => 'Program Aktif';
}

// Path: core.language
class Translations$core$language$id {
  Translations$core$language$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'Bahasa'
  String get label => 'Bahasa';

  /// id: 'Bahasa Indonesia'
  String get id => 'Bahasa Indonesia';

  /// id: 'English'
  String get en => 'English';
}

// Path: core.units
class Translations$core$units$id {
  Translations$core$units$id.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// id: 'repetisi'
  String get reps => 'repetisi';

  /// id: 'set'
  String get sets => 'set';

  /// id: 'detik'
  String get seconds => 'detik';

  /// id: 'kg'
  String get kg => 'kg';
}

/// The flat map containing all translations for locale <id>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
  dynamic _flatMapFunction(String path) {
    return switch (path) {
      'core.appName' => 'Home Bulking Coach',
      'core.actions.save' => 'Simpan',
      'core.actions.cancel' => 'Batal',
      'core.actions.back' => 'Kembali',
      'core.actions.next' => 'Lanjut',
      'core.actions.skip' => 'Lewati',
      'core.actions.done' => 'Selesai',
      'core.actions.retry' => 'Coba Lagi',
      'core.actions.close' => 'Tutup',
      'core.actions.edit' => 'Ubah',
      'core.actions.delete' => 'Hapus',
      'core.state.loading' => 'Memuat...',
      'core.state.empty' => 'Belum ada data',
      'core.state.error' => 'Terjadi kesalahan',
      'core.badge.currentPlan' => 'Program Aktif',
      'core.language.label' => 'Bahasa',
      'core.language.id' => 'Bahasa Indonesia',
      'core.language.en' => 'English',
      'core.units.reps' => 'repetisi',
      'core.units.sets' => 'set',
      'core.units.seconds' => 'detik',
      'core.units.kg' => 'kg',
      _ => null,
    };
  }
}
