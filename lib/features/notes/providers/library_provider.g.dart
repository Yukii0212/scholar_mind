// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$libraryRepositoryHash() => r'd48ca58124a742d7136a46e9cb5d85390838e79e';

/// See also [libraryRepository].
@ProviderFor(libraryRepository)
final libraryRepositoryProvider = Provider<LibraryRepository>.internal(
  libraryRepository,
  name: r'libraryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LibraryRepositoryRef = ProviderRef<LibraryRepository>;
String _$childFoldersHash() => r'0f4306fdbbd984f6eb3429ce12f43d8755e4f675';

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
class ChildFoldersFamily extends Family<AsyncValue<List<LibraryFolder>>> {
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
class ChildFoldersProvider
    extends AutoDisposeStreamProvider<List<LibraryFolder>> {
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
    Stream<List<LibraryFolder>> Function(ChildFoldersRef provider) create,
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
  AutoDisposeStreamProviderElement<List<LibraryFolder>> createElement() {
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

mixin ChildFoldersRef on AutoDisposeStreamProviderRef<List<LibraryFolder>> {
  /// The parameter `parentId` of this provider.
  String get parentId;
}

class _ChildFoldersProviderElement
    extends AutoDisposeStreamProviderElement<List<LibraryFolder>>
    with ChildFoldersRef {
  _ChildFoldersProviderElement(super.provider);

  @override
  String get parentId => (origin as ChildFoldersProvider).parentId;
}

String _$favoriteFoldersHash() => r'8dcf2af359bbc33bb5062d23ff579af0037e7cb6';

/// See also [favoriteFolders].
@ProviderFor(favoriteFolders)
final favoriteFoldersProvider =
    AutoDisposeStreamProvider<List<LibraryFolder>>.internal(
  favoriteFolders,
  name: r'favoriteFoldersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoriteFoldersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FavoriteFoldersRef = AutoDisposeStreamProviderRef<List<LibraryFolder>>;
String _$archivedFoldersHash() => r'd8a49b64bc427098eb38199eba625707d5a97b18';

/// See also [archivedFolders].
@ProviderFor(archivedFolders)
final archivedFoldersProvider =
    AutoDisposeStreamProvider<List<LibraryFolder>>.internal(
  archivedFolders,
  name: r'archivedFoldersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$archivedFoldersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ArchivedFoldersRef = AutoDisposeStreamProviderRef<List<LibraryFolder>>;
String _$notesInFolderHash() => r'916af0f15abdd308014a7883da559920ee8c7211';

/// See also [notesInFolder].
@ProviderFor(notesInFolder)
const notesInFolderProvider = NotesInFolderFamily();

/// See also [notesInFolder].
class NotesInFolderFamily extends Family<AsyncValue<List<NoteItem>>> {
  /// See also [notesInFolder].
  const NotesInFolderFamily();

  /// See also [notesInFolder].
  NotesInFolderProvider call(
    String folderId,
  ) {
    return NotesInFolderProvider(
      folderId,
    );
  }

  @override
  NotesInFolderProvider getProviderOverride(
    covariant NotesInFolderProvider provider,
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
  String? get name => r'notesInFolderProvider';
}

/// See also [notesInFolder].
class NotesInFolderProvider extends AutoDisposeStreamProvider<List<NoteItem>> {
  /// See also [notesInFolder].
  NotesInFolderProvider(
    String folderId,
  ) : this._internal(
          (ref) => notesInFolder(
            ref as NotesInFolderRef,
            folderId,
          ),
          from: notesInFolderProvider,
          name: r'notesInFolderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$notesInFolderHash,
          dependencies: NotesInFolderFamily._dependencies,
          allTransitiveDependencies:
              NotesInFolderFamily._allTransitiveDependencies,
          folderId: folderId,
        );

  NotesInFolderProvider._internal(
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
    Stream<List<NoteItem>> Function(NotesInFolderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NotesInFolderProvider._internal(
        (ref) => create(ref as NotesInFolderRef),
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
  AutoDisposeStreamProviderElement<List<NoteItem>> createElement() {
    return _NotesInFolderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotesInFolderProvider && other.folderId == folderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, folderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin NotesInFolderRef on AutoDisposeStreamProviderRef<List<NoteItem>> {
  /// The parameter `folderId` of this provider.
  String get folderId;
}

class _NotesInFolderProviderElement
    extends AutoDisposeStreamProviderElement<List<NoteItem>>
    with NotesInFolderRef {
  _NotesInFolderProviderElement(super.provider);

  @override
  String get folderId => (origin as NotesInFolderProvider).folderId;
}

String _$libraryActionControllerHash() =>
    r'd20d03fc4825e0666aeb7edf1071601e02827681';

/// See also [LibraryActionController].
@ProviderFor(LibraryActionController)
final libraryActionControllerProvider =
    AsyncNotifierProvider<LibraryActionController, void>.internal(
  LibraryActionController.new,
  name: r'libraryActionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$libraryActionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LibraryActionController = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
