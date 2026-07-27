// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_library_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quizLibraryRepositoryHash() =>
    r'd2c3d432a5309171fd5c758ecc73fa8b000f277d';

/// See also [quizLibraryRepository].
@ProviderFor(quizLibraryRepository)
final quizLibraryRepositoryProvider = Provider<QuizLibraryRepository>.internal(
  quizLibraryRepository,
  name: r'quizLibraryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quizLibraryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef QuizLibraryRepositoryRef = ProviderRef<QuizLibraryRepository>;
String _$childFoldersHash() => r'07f4fbad44640c360d6d9c38f57c0835035dfadf';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [childFolders].
@ProviderFor(childFolders)
const childFoldersProvider = ChildFoldersFamily();

/// See also [childFolders].
class ChildFoldersFamily extends Family<AsyncValue<List<QuizFolder>>> {
  /// See also [childFolders].
  const ChildFoldersFamily();

  /// See also [childFolders].
  ChildFoldersProvider call(
    String parentId,
  ) {
    return ChildFoldersProvider(
      parentId,
    );
  }

  @override
  ChildFoldersProvider getProviderOverride(
    covariant ChildFoldersProvider provider,
  ) {
    return call(
      provider.parentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'childFoldersProvider';
}

/// See also [childFolders].
class ChildFoldersProvider extends AutoDisposeStreamProvider<List<QuizFolder>> {
  /// See also [childFolders].
  ChildFoldersProvider(
    String parentId,
  ) : this._internal(
          (ref) => childFolders(
            ref as ChildFoldersRef,
            parentId,
          ),
          from: childFoldersProvider,
          name: r'childFoldersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$childFoldersHash,
          dependencies: ChildFoldersFamily._dependencies,
          allTransitiveDependencies:
              ChildFoldersFamily._allTransitiveDependencies,
          parentId: parentId,
        );

  ChildFoldersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.parentId,
  }) : super.internal();

  final String parentId;

  @override
  Override overrideWith(
    Stream<List<QuizFolder>> Function(ChildFoldersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChildFoldersProvider._internal(
        (ref) => create(ref as ChildFoldersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        parentId: parentId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<QuizFolder>> createElement() {
    return _ChildFoldersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChildFoldersProvider && other.parentId == parentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, parentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ChildFoldersRef on AutoDisposeStreamProviderRef<List<QuizFolder>> {
  /// The parameter `parentId` of this provider.
  String get parentId;
}

class _ChildFoldersProviderElement
    extends AutoDisposeStreamProviderElement<List<QuizFolder>>
    with ChildFoldersRef {
  _ChildFoldersProviderElement(super.provider);

  @override
  String get parentId => (origin as ChildFoldersProvider).parentId;
}

String _$allFoldersHash() => r'ccd82b321b19ba70479378b1573c6d8bc66715aa';

/// See also [allFolders].
@ProviderFor(allFolders)
final allFoldersProvider = AutoDisposeStreamProvider<List<QuizFolder>>.internal(
  allFolders,
  name: r'allFoldersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allFoldersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllFoldersRef = AutoDisposeStreamProviderRef<List<QuizFolder>>;
String _$favoriteFoldersHash() => r'5d7b95a9fb7695b2a86e25b0f2d41db342a7f093';

/// See also [favoriteFolders].
@ProviderFor(favoriteFolders)
final favoriteFoldersProvider =
    AutoDisposeStreamProvider<List<QuizFolder>>.internal(
  favoriteFolders,
  name: r'favoriteFoldersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoriteFoldersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FavoriteFoldersRef = AutoDisposeStreamProviderRef<List<QuizFolder>>;
String _$favoriteQuizzesHash() => r'3b9cbf07d50d4714528d574a129c5337ab2ac5b1';

/// See also [favoriteQuizzes].
@ProviderFor(favoriteQuizzes)
final favoriteQuizzesProvider =
    AutoDisposeStreamProvider<List<QuizAttempt>>.internal(
  favoriteQuizzes,
  name: r'favoriteQuizzesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoriteQuizzesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FavoriteQuizzesRef = AutoDisposeStreamProviderRef<List<QuizAttempt>>;
String _$allQuizzesHash() => r'eef7c43eae72ea5678a5139e5bc160fcaf3011c6';

/// See also [allQuizzes].
@ProviderFor(allQuizzes)
final allQuizzesProvider = StreamProvider<List<QuizAttempt>>.internal(
  allQuizzes,
  name: r'allQuizzesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allQuizzesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllQuizzesRef = StreamProviderRef<List<QuizAttempt>>;
String _$archivedFoldersHash() => r'55948427584bf34c7ed8fd8c5f636a9c2dfb43ae';

/// See also [archivedFolders].
@ProviderFor(archivedFolders)
final archivedFoldersProvider =
    AutoDisposeStreamProvider<List<QuizFolder>>.internal(
  archivedFolders,
  name: r'archivedFoldersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$archivedFoldersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ArchivedFoldersRef = AutoDisposeStreamProviderRef<List<QuizFolder>>;
String _$deletedFoldersHash() => r'de1372758b03f0430df059a547e26a72ee73fe67';

/// See also [deletedFolders].
@ProviderFor(deletedFolders)
final deletedFoldersProvider =
    AutoDisposeStreamProvider<List<QuizFolder>>.internal(
  deletedFolders,
  name: r'deletedFoldersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deletedFoldersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeletedFoldersRef = AutoDisposeStreamProviderRef<List<QuizFolder>>;
String _$deletedQuizzesHash() => r'531794ad2c468417a88553bb1e27738c494e06ac';

/// See also [deletedQuizzes].
@ProviderFor(deletedQuizzes)
final deletedQuizzesProvider =
    AutoDisposeStreamProvider<List<QuizAttempt>>.internal(
  deletedQuizzes,
  name: r'deletedQuizzesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deletedQuizzesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeletedQuizzesRef = AutoDisposeStreamProviderRef<List<QuizAttempt>>;
String _$quizzesInFolderHash() => r'81c291430850e1de1c625270813752818704c87a';

/// See also [quizzesInFolder].
@ProviderFor(quizzesInFolder)
const quizzesInFolderProvider = QuizzesInFolderFamily();

/// See also [quizzesInFolder].
class QuizzesInFolderFamily extends Family<AsyncValue<List<QuizAttempt>>> {
  /// See also [quizzesInFolder].
  const QuizzesInFolderFamily();

  /// See also [quizzesInFolder].
  QuizzesInFolderProvider call(
    String folderId,
  ) {
    return QuizzesInFolderProvider(
      folderId,
    );
  }

  @override
  QuizzesInFolderProvider getProviderOverride(
    covariant QuizzesInFolderProvider provider,
  ) {
    return call(
      provider.folderId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'quizzesInFolderProvider';
}

/// See also [quizzesInFolder].
class QuizzesInFolderProvider
    extends AutoDisposeStreamProvider<List<QuizAttempt>> {
  /// See also [quizzesInFolder].
  QuizzesInFolderProvider(
    String folderId,
  ) : this._internal(
          (ref) => quizzesInFolder(
            ref as QuizzesInFolderRef,
            folderId,
          ),
          from: quizzesInFolderProvider,
          name: r'quizzesInFolderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$quizzesInFolderHash,
          dependencies: QuizzesInFolderFamily._dependencies,
          allTransitiveDependencies:
              QuizzesInFolderFamily._allTransitiveDependencies,
          folderId: folderId,
        );

  QuizzesInFolderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.folderId,
  }) : super.internal();

  final String folderId;

  @override
  Override overrideWith(
    Stream<List<QuizAttempt>> Function(QuizzesInFolderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: QuizzesInFolderProvider._internal(
        (ref) => create(ref as QuizzesInFolderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        folderId: folderId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<QuizAttempt>> createElement() {
    return _QuizzesInFolderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuizzesInFolderProvider && other.folderId == folderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, folderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin QuizzesInFolderRef on AutoDisposeStreamProviderRef<List<QuizAttempt>> {
  /// The parameter `folderId` of this provider.
  String get folderId;
}

class _QuizzesInFolderProviderElement
    extends AutoDisposeStreamProviderElement<List<QuizAttempt>>
    with QuizzesInFolderRef {
  _QuizzesInFolderProviderElement(super.provider);

  @override
  String get folderId => (origin as QuizzesInFolderProvider).folderId;
}

String _$activeQuizzesHash() => r'abc1af6d7a9c8c181aabdb0db1df5349b7985690';

/// See also [activeQuizzes].
@ProviderFor(activeQuizzes)
final activeQuizzesProvider =
    AutoDisposeStreamProvider<List<QuizAttempt>>.internal(
  activeQuizzes,
  name: r'activeQuizzesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeQuizzesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveQuizzesRef = AutoDisposeStreamProviderRef<List<QuizAttempt>>;
String _$quizHash() => r'fcedb308edd35253fbdaf9587fd31d6fc5fd6e0f';

/// See also [quiz].
@ProviderFor(quiz)
const quizProvider = QuizFamily();

/// See also [quiz].
class QuizFamily extends Family<AsyncValue<QuizAttempt>> {
  /// See also [quiz].
  const QuizFamily();

  /// See also [quiz].
  QuizProvider call(
    String quizId,
  ) {
    return QuizProvider(
      quizId,
    );
  }

  @override
  QuizProvider getProviderOverride(
    covariant QuizProvider provider,
  ) {
    return call(
      provider.quizId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'quizProvider';
}

/// See also [quiz].
class QuizProvider extends AutoDisposeStreamProvider<QuizAttempt> {
  /// See also [quiz].
  QuizProvider(
    String quizId,
  ) : this._internal(
          (ref) => quiz(
            ref as QuizRef,
            quizId,
          ),
          from: quizProvider,
          name: r'quizProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product') ? null : _$quizHash,
          dependencies: QuizFamily._dependencies,
          allTransitiveDependencies: QuizFamily._allTransitiveDependencies,
          quizId: quizId,
        );

  QuizProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.quizId,
  }) : super.internal();

  final String quizId;

  @override
  Override overrideWith(
    Stream<QuizAttempt> Function(QuizRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: QuizProvider._internal(
        (ref) => create(ref as QuizRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        quizId: quizId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<QuizAttempt> createElement() {
    return _QuizProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuizProvider && other.quizId == quizId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, quizId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin QuizRef on AutoDisposeStreamProviderRef<QuizAttempt> {
  /// The parameter `quizId` of this provider.
  String get quizId;
}

class _QuizProviderElement extends AutoDisposeStreamProviderElement<QuizAttempt>
    with QuizRef {
  _QuizProviderElement(super.provider);

  @override
  String get quizId => (origin as QuizProvider).quizId;
}

String _$folderPathHash() => r'07222646272594768a74cbb4642eab9ac95b9980';

/// See also [folderPath].
@ProviderFor(folderPath)
const folderPathProvider = FolderPathFamily();

/// See also [folderPath].
class FolderPathFamily extends Family<AsyncValue<List<QuizFolder>>> {
  /// See also [folderPath].
  const FolderPathFamily();

  /// See also [folderPath].
  FolderPathProvider call(
    String folderId,
  ) {
    return FolderPathProvider(
      folderId,
    );
  }

  @override
  FolderPathProvider getProviderOverride(
    covariant FolderPathProvider provider,
  ) {
    return call(
      provider.folderId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'folderPathProvider';
}

/// See also [folderPath].
class FolderPathProvider extends AutoDisposeFutureProvider<List<QuizFolder>> {
  /// See also [folderPath].
  FolderPathProvider(
    String folderId,
  ) : this._internal(
          (ref) => folderPath(
            ref as FolderPathRef,
            folderId,
          ),
          from: folderPathProvider,
          name: r'folderPathProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$folderPathHash,
          dependencies: FolderPathFamily._dependencies,
          allTransitiveDependencies:
              FolderPathFamily._allTransitiveDependencies,
          folderId: folderId,
        );

  FolderPathProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.folderId,
  }) : super.internal();

  final String folderId;

  @override
  Override overrideWith(
    FutureOr<List<QuizFolder>> Function(FolderPathRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FolderPathProvider._internal(
        (ref) => create(ref as FolderPathRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        folderId: folderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<QuizFolder>> createElement() {
    return _FolderPathProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FolderPathProvider && other.folderId == folderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, folderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FolderPathRef on AutoDisposeFutureProviderRef<List<QuizFolder>> {
  /// The parameter `folderId` of this provider.
  String get folderId;
}

class _FolderPathProviderElement
    extends AutoDisposeFutureProviderElement<List<QuizFolder>>
    with FolderPathRef {
  _FolderPathProviderElement(super.provider);

  @override
  String get folderId => (origin as FolderPathProvider).folderId;
}

String _$quizLibraryActionControllerHash() =>
    r'02d7fadcbaa8bb3e8620b80f7a17ba36028d2d11';

/// See also [QuizLibraryActionController].
@ProviderFor(QuizLibraryActionController)
final quizLibraryActionControllerProvider =
    AsyncNotifierProvider<QuizLibraryActionController, void>.internal(
  QuizLibraryActionController.new,
  name: r'quizLibraryActionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quizLibraryActionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QuizLibraryActionController = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
