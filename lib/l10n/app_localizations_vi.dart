// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get authNotSignedIn => 'Hãy đăng nhập để tiếp tục.';

  @override
  String get authTokenExpired =>
      'Phiên đăng nhập đã hết hạn. Hãy đăng nhập lại.';

  @override
  String get commonAppName => 'TripMate';

  @override
  String get rateLimited =>
      'Bạn gửi quá nhiều yêu cầu. Hãy chờ một chút rồi thử lại.';

  @override
  String get requestInvalid => 'Một số thông tin bạn gửi không hợp lệ.';

  @override
  String get requestIdempotencyKeyRequired =>
      'Yêu cầu này cần header Idempotency-Key.';

  @override
  String get requestIdempotencyInProgress =>
      'Yêu cầu giống hệt vẫn đang được xử lý. Hãy thử lại sau giây lát.';

  @override
  String get requestIdempotencyMismatch =>
      'Idempotency-Key này đã được dùng cho một yêu cầu khác.';

  @override
  String get requestFieldMissing => 'Trường này là bắt buộc.';

  @override
  String get requestFieldInvalid => 'Giá trị này không hợp lệ.';

  @override
  String get requestNotFound => 'Địa chỉ này không tồn tại.';

  @override
  String get requestMethodNotAllowed =>
      'Không thể thực hiện thao tác này ở đây.';

  @override
  String get serverError => 'Đã có lỗi ở phía chúng tôi. Hãy thử lại sau.';

  @override
  String get serverUnavailable =>
      'TripMate tạm thời không hoạt động. Hãy thử lại sau giây lát.';

  @override
  String get serverNotImplemented =>
      'Tính năng này chưa có. Nó sẽ có trong một phiên bản sau.';
}
