import 'package:soupbag/core/network/app_http_client.dart';
import 'package:soupbag/core/network/legado_http_gateway.dart';
import 'package:soupbag/core/storage/database/app_database.dart';

class AppServices {
  AppServices._();

  static final AppServices instance = AppServices._();

  late final AppHttpClient httpClient = AppHttpClient();

  late final LegadoHttpGateway legadoHttpGateway =
      LegadoHttpGateway(httpClient.client);

  late final AppDatabase database = AppDatabase();
}
