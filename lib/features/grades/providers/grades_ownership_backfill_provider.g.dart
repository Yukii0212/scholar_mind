// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grades_ownership_backfill_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gradesOwnershipBackfillHash() =>
    r'af288ee732e0ced273342f972509248decea38f3';

/// One-time, per-user backfill of the `ownerId` field on Course/
/// GradingComponent documents written before ownership tracking existed.
/// Rides on the current user's own normal sign-in permissions -- it can
/// only ever touch documents reachable through that user's own semesters.
/// Watch this once near the top of the Grades feature to trigger it.
///
/// Copied from [GradesOwnershipBackfill].
@ProviderFor(GradesOwnershipBackfill)
final gradesOwnershipBackfillProvider =
    NotifierProvider<GradesOwnershipBackfill, void>.internal(
  GradesOwnershipBackfill.new,
  name: r'gradesOwnershipBackfillProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gradesOwnershipBackfillHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GradesOwnershipBackfill = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
