import 'package:daily_water_tracker/common/services/app_bootstrapper.dart';

import '../assets.dart';
import '../services/credentials_loader.dart';
import '../services/logger.dart';
import 'app_flavor.dart';

Future<Credentials> loadCredentials() async {
  try {
    final credentials = await CredentialsLoader(
      pathToFile: _credentialsFileForFlavor(flutterFlavor),
    ).load();
    return credentials;
  } catch (e, st) {
    logCaughtError('loadCredentials', e, st);
    rethrow;
  }
}

String _credentialsFileForFlavor(AppFlavor flavor) {
  switch (flavor) {
    case AppFlavor.prod:
      return credentialsProdFile;
    case AppFlavor.dev:
      return credentialsDevFile;
  }
}

class EnumToString {
  String? parse(dynamic enumItem) {
    if (enumItem == null) {
      return null;
    }
    return enumItem.toString().split('.')[1];
  }

  T? fromString<T>(List<T> enumValues, String? value) {
    if (value == null) {
      return null;
    }

    return enumValues.singleWhere(
      (enumItem) => EnumToString().parse(enumItem) == value,
    );
  }
}

Iterable<E> indexedMap<E, T>(
  Iterable<T> items,
  E Function(int index, T item) f,
) sync* {
  var index = 0;
  for (final item in items) {
    yield f(index, item);
    index = index + 1;
  }
}
