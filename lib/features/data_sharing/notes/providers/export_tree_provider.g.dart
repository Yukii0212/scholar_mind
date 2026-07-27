// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_tree_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$exportTreeHash() => r'fa85f65b7098efa4957c885730cb428ac53eef66';

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

/// See also [exportTree].
@ProviderFor(exportTree)
const exportTreeProvider = ExportTreeFamily();

/// See also [exportTree].
class ExportTreeFamily extends Family<AsyncValue<List<ExportTreeNode>>> {
  /// See also [exportTree].
  const ExportTreeFamily();

  /// See also [exportTree].
  ExportTreeProvider call(
    ExportModule module,
  ) {
    return ExportTreeProvider(
      module,
    );
  }

  @override
  ExportTreeProvider getProviderOverride(
    covariant ExportTreeProvider provider,
  ) {
    return call(
      provider.module,
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
  String? get name => r'exportTreeProvider';
}

/// See also [exportTree].
class ExportTreeProvider
    extends AutoDisposeFutureProvider<List<ExportTreeNode>> {
  /// See also [exportTree].
  ExportTreeProvider(
    ExportModule module,
  ) : this._internal(
          (ref) => exportTree(
            ref as ExportTreeRef,
            module,
          ),
          from: exportTreeProvider,
          name: r'exportTreeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$exportTreeHash,
          dependencies: ExportTreeFamily._dependencies,
          allTransitiveDependencies:
              ExportTreeFamily._allTransitiveDependencies,
          module: module,
        );

  ExportTreeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.module,
  }) : super.internal();

  final ExportModule module;

  @override
  Override overrideWith(
    FutureOr<List<ExportTreeNode>> Function(ExportTreeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExportTreeProvider._internal(
        (ref) => create(ref as ExportTreeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        module: module,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ExportTreeNode>> createElement() {
    return _ExportTreeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExportTreeProvider && other.module == module;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, module.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ExportTreeRef on AutoDisposeFutureProviderRef<List<ExportTreeNode>> {
  /// The parameter `module` of this provider.
  ExportModule get module;
}

class _ExportTreeProviderElement
    extends AutoDisposeFutureProviderElement<List<ExportTreeNode>>
    with ExportTreeRef {
  _ExportTreeProviderElement(super.provider);

  @override
  ExportModule get module => (origin as ExportTreeProvider).module;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
