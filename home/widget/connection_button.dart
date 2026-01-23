import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:logvpn/core/localization/translations.dart';
import 'package:logvpn/core/model/failures.dart';
import 'package:logvpn/features/config_option/data/config_option_repository.dart';
import 'package:logvpn/features/config_option/notifier/config_option_notifier.dart';
import 'package:logvpn/features/connection/model/connection_status.dart';
import 'package:logvpn/features/connection/notifier/connection_notifier.dart';
import 'package:logvpn/features/connection/widget/experimental_feature_notice.dart';
import 'package:logvpn/features/profile/notifier/active_profile_notifier.dart';
import 'package:logvpn/features/proxy/active/active_proxy_notifier.dart';
import 'package:logvpn/utils/alerts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// VeePN 风格的连接按钮
class ConnectionButton extends HookConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final connectionStatus = ref.watch(connectionNotifierProvider);
    final activeProxy = ref.watch(activeProxyNotifierProvider);
    final delay = activeProxy.valueOrNull?.urlTestDelay ?? 0;

    final requiresReconnect = ref.watch(configOptionNotifierProvider).valueOrNull;

    ref.listen(
      connectionNotifierProvider,
      (_, next) {
        if (next case AsyncError(:final error)) {
          CustomAlertDialog.fromErr(t.presentError(error)).show(context);
        }
        if (next case AsyncData(value: Disconnected(:final connectionFailure?))) {
          CustomAlertDialog.fromErr(t.presentError(connectionFailure)).show(context);
        }
      },
    );

    Future<bool> showExperimentalNotice() async {
      final hasExperimental = ref.read(ConfigOptions.hasExperimentalFeatures);
      final canShowNotice = !ref.read(disableExperimentalFeatureNoticeProvider);
      if (hasExperimental && canShowNotice && context.mounted) {
        return await const ExperimentalFeatureNoticeDialog().show(context) ?? false;
      }
      return true;
    }

    // 判断是否已连接
    final isConnected = connectionStatus is AsyncData<ConnectionStatus> &&
        connectionStatus.value is Connected;

    // 判断是否正在连接
    final isConnecting = connectionStatus is AsyncData<ConnectionStatus> &&
        connectionStatus.value is Connecting;

    return _VeePNConnectionButton(
      onTap: switch (connectionStatus) {
        AsyncData(value: Disconnected()) || AsyncError() => () async {
            if (await showExperimentalNotice()) {
              return await ref.read(connectionNotifierProvider.notifier).toggleConnection();
            }
          },
        AsyncData(value: Connected()) => () async {
            if (requiresReconnect == true && await showExperimentalNotice()) {
              return await ref.read(connectionNotifierProvider.notifier).reconnect(await ref.read(activeProfileProvider.future));
            }
            return await ref.read(connectionNotifierProvider.notifier).toggleConnection();
          },
        _ => () {},
      },
      enabled: switch (connectionStatus) {
        AsyncData(value: Connected()) || AsyncData(value: Disconnected()) || AsyncError() => true,
        _ => false,
      },
      isConnected: isConnected,
      isConnecting: isConnecting,
      statusText: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => t.connection.reconnect,
        AsyncData(value: final status) => status.present(t),
        _ => t.connection.disconnected,
      },
    );
  }
}

/// VeePN 风格的连接按钮 UI
class _VeePNConnectionButton extends StatefulWidget {
  const _VeePNConnectionButton({
    required this.onTap,
    required this.enabled,
    required this.isConnected,
    required this.isConnecting,
    required this.statusText,
  });

  final VoidCallback onTap;
  final bool enabled;
  final bool isConnected;
  final bool isConnecting;
  final String statusText;

  @override
  State<_VeePNConnectionButton> createState() => _VeePNConnectionButtonState();
}

class _VeePNConnectionButtonState extends State<_VeePNConnectionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // VeePN 配色
    final buttonColor = widget.isConnected
        ? const Color(0xFF00C853) // 绿色（已连接）
        : widget.isConnecting
            ? const Color(0xFFFFA726) // 橙色（连接中）
            : const Color(0xFF9E9E9E); // 灰色（未连接）

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 圆形连接按钮
        Semantics(
          button: true,
          enabled: widget.enabled,
          label: widget.statusText,
          child: GestureDetector(
            onTap: widget.enabled ? widget.onTap : null,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E3A8A).withOpacity(0.3), // 深蓝色背景
                    boxShadow: widget.isConnected || widget.isConnecting
                        ? [
                            BoxShadow(
                              color: buttonColor.withOpacity(0.6 * _pulseController.value),
                              blurRadius: 40 + (20 * _pulseController.value),
                              spreadRadius: 5 + (10 * _pulseController.value),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: buttonColor,
                      ),
                      child: Icon(
                        Icons.power_settings_new,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Gap(24),
        // 状态文字
        Text(
          widget.statusText,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
