import 'package:fpdart/fpdart.dart';
import 'package:logvpn/core/utils/exception_handler.dart';
import 'package:logvpn/features/stats/model/stats_entity.dart';
import 'package:logvpn/features/stats/model/stats_failure.dart';
import 'package:logvpn/singbox/service/singbox_service.dart';
import 'package:logvpn/utils/custom_loggers.dart';

abstract interface class StatsRepository {
  Stream<Either<StatsFailure, StatsEntity>> watchStats();
}

class StatsRepositoryImpl
    with ExceptionHandler, InfraLogger
    implements StatsRepository {
  StatsRepositoryImpl({required this.singbox});

  final SingboxService singbox;

  @override
  Stream<Either<StatsFailure, StatsEntity>> watchStats() {
    return singbox
        .watchStats()
        .map(
          (event) => StatsEntity(
            uplink: event.uplink,
            downlink: event.downlink,
            uplinkTotal: event.uplinkTotal,
            downlinkTotal: event.downlinkTotal,
          ),
        )
        .handleExceptions(StatsUnexpectedFailure.new);
  }
}
