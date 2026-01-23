import 'package:flutter/material.dart';
import 'package:logvpn/core/localization/translations.dart';
import 'package:logvpn/features/home/widget/connection_button.dart';
import 'package:logvpn/features/home/widget/empty_profiles_home_body.dart';
import 'package:logvpn/features/profile/notifier/active_profile_notifier.dart';
import 'package:logvpn/features/proxy/active/active_proxy_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// VeePN 风格的主页面
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final hasAnyProfile = ref.watch(hasAnyProfileProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final activeProxy = ref.watch(activeProxyNotifierProvider);

    // 如果没有配置文件，显示空状态页面
    if (!hasAnyProfile) {
      return const Scaffold(
        body: EmptyProfilesHomeBody(),
      );
    }

    // 获取当前选中的服务器名称
    final serverName = activeProfile.valueOrNull?.name ?? t.general.appTitle;

    return Scaffold(
      backgroundColor: const Color(0xFF1E40AF), // VeePN 深蓝色背景
      body: SafeArea(
        child: Stack(
          children: [
            // 主内容区域
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 连接按钮
                  const ConnectionButton(),
                  const SizedBox(height: 40),
                  
                  // Kill Switch 开关
                  _KillSwitchToggle(),
                  
                  const SizedBox(height: 60),
                  
                  // 当前选中的服务器
                  _ServerSelector(serverName: serverName),
                  
                  const SizedBox(height: 20),
                  
                  // IP 地址显示（如果已连接）
                  _IPAddressDisplay(),
                ],
              ),
            ),
            
            // 左侧导航栏
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _SideNavigationBar(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kill Switch 开关
class _KillSwitchToggle extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Kill Switch',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.info_outline,
            color: Colors.white.withOpacity(0.7),
            size: 18,
          ),
          const SizedBox(width: 12),
          Switch(
            value: false, // TODO: 连接到实际状态
            onChanged: (value) {
              // TODO: 实现 Kill Switch 功能
            },
            activeColor: const Color(0xFF00C853),
          ),
        ],
      ),
    );
  }
}

/// 服务器选择器
class _ServerSelector extends StatelessWidget {
  const _ServerSelector({required this.serverName});
  
  final String serverName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 打开服务器列表
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              color: Color(0xFF2454FF),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              serverName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// IP 地址显示
class _IPAddressDisplay extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 获取实际 IP 地址
    final ipAddress = '240d8a55-3550-9790-567-806d:ae04:b35b';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.vpn_key,
            color: Colors.white54,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            ipAddress,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// 左侧导航栏
class _SideNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: const Color(0xFF1E3A8A).withOpacity(0.5),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield,
              color: Color(0xFF2454FF),
              size: 30,
            ),
          ),
          const SizedBox(height: 40),
          // VPN 按钮
          _NavButton(
            icon: Icons.vpn_lock,
            label: 'VPN',
            isActive: true,
            onTap: () {},
          ),
          const SizedBox(height: 20),
          // 设置按钮
          _NavButton(
            icon: Icons.settings,
            label: '设置',
            isActive: false,
            onTap: () {
              // TODO: 打开设置页面
            },
          ),
        ],
      ),
    );
  }
}

/// 导航按钮
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2454FF).withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
