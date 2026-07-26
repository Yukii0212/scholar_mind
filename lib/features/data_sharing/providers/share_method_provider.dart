import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/share/share_method.dart';

part 'share_method_provider.g.dart';

@riverpod
class ShareMethodNotifier
    extends _$ShareMethodNotifier {
  @override
  ShareMethod build() {
    return ShareMethod.qrCode;
  }

  void setMethod(
      ShareMethod method,
      ) {
    state = method;
  }
}