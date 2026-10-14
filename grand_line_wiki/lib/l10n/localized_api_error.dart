import 'package:flutter/widgets.dart';

import '../data/api_service.dart';
import 'app_localizations.dart';

String localizedApiError(BuildContext context, Object error) {
  if (error is! ApiException) return '$error';

  final strings = AppLocalizations.of(context)!;
  return switch (error.type) {
    ApiErrorType.notFound => strings.apiNotFound,
    ApiErrorType.status => strings.apiStatusError('${error.statusCode}'),
    ApiErrorType.timeout => strings.apiTimeout,
    ApiErrorType.offline => strings.apiOffline,
    ApiErrorType.unexpected => strings.apiUnexpected,
    ApiErrorType.itemNotFound => strings.apiItemNotFound,
    ApiErrorType.endpointNotFound => strings.apiEndpointNotFound,
  };
}
