import '../domain/models/export/export_statistics.dart';

/// A rough, bucketed estimate of how long a share-link export will take,
/// shown to the user before they start one so a multi-minute wait (common
/// for a folder with many files, since each file is downloaded and
/// re-uploaded — see NotesDataShareHandler._mapInBatches) doesn't feel like
/// the app has hung. There's no real timing telemetry to calibrate a
/// precise formula against, so this deliberately returns a coarse range
/// rather than a fake-precise countdown.
String estimateExportDuration(ExportStatistics stats) {
  // Per-file download+reupload dominates the cost; folder traversal reads
  // are comparatively cheap, so they're weighted much lighter here.
  final weightedUnits =
      stats.selectedItems + (stats.selectedFolders * 0.3);

  if (weightedUnits <= 5) {
    return '< 1 min';
  }

  if (weightedUnits <= 20) {
    return '~1-3 min';
  }

  if (weightedUnits <= 50) {
    return '~3-5 min';
  }

  return '5+ min';
}
