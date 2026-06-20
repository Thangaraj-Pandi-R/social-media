import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/shared_widgets/responsive_layout.dart';
import 'package:social_media/features/auth/presentation/providers/auth_provider.dart';
import 'package:social_media/features/feed/presentation/views/feed_screen.dart';
import 'package:social_media/features/feed/presentation/views/search_screen.dart';
import 'package:social_media/features/profile/presentation/views/profile_screen.dart';
import 'package:social_media/features/post/presentation/views/create_post_screen.dart';
import 'package:social_media/core/shared_widgets/connectivity_banner.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/core/utils/string_constants.dart';
import 'package:social_media/core/services/toast_service.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';

import 'package:flutter/services.dart';

class MainNavigationLayout extends StatelessWidget {
  const MainNavigationLayout({super.key});

  void _navigateToCreatePost(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CreatePostScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lastPressedAt = ValueNotifier<DateTime?>(null);

    return Selector<AuthProvider, ({UserEntity? user, int navIdx})>(
      selector: (_, provider) => (
        user: provider.user,
        navIdx: provider.navIdx,
      ),
      builder: (context, data, _) {
        final currentUserId = data.user?.id ?? '';
        final currentIndex = data.navIdx;
        final authProviderNonListening = Provider.of<AuthProvider>(context, listen: false);

        final pages = [
          const FeedScreen(),
          const SearchScreen(),
          ProfileScreen(userId: currentUserId),
        ];

        final childWidget = ResponsiveLayout(
          mobileBody: Scaffold(
            body: Column(
              children: [
                const ConnectivityBanner(),
                Expanded(
                  child: FadeIndexedStack(
                    index: currentIndex,
                    children: pages,
                  ),
                ),
              ],
            ),
            floatingActionButton: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _navigateToCreatePost(context),
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.add_rounded, size: 28, color: Colors.white),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF1C1C1E) 
                    : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
                    width: 0.5,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: authProviderNonListening.changeNavIdx,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
                unselectedLabelStyle: const TextStyle(letterSpacing: 0.2),
                iconSize: 22,
                selectedItemColor: AppTheme.primaryNeon,
                unselectedItemColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: AppStrings.homeTab,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.explore_outlined),
                    activeIcon: Icon(Icons.explore_rounded),
                    label: AppStrings.exploreTab,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    activeIcon: Icon(Icons.person_rounded),
                    label: AppStrings.profileTab,
                  ),
                ],
              ),
            ),
          ),
          desktopBody: Scaffold(
            body: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    border: Border(
                      right: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: NavigationRail(
                    backgroundColor: Colors.transparent,
                    selectedIndex: currentIndex,
                    onDestinationSelected: authProviderNonListening.changeNavIdx,
                    labelType: NavigationRailLabelType.all,
                    useIndicator: true,
                    indicatorColor: AppTheme.primaryNeon.withValues(alpha: 0.08),
                    selectedLabelTextStyle: const TextStyle(
                      color: AppTheme.primaryNeon,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                    leading: Column(
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(height: 32),
                        FloatingActionButton(
                          onPressed: () => _navigateToCreatePost(context),
                          backgroundColor: AppTheme.primaryNeon,
                          foregroundColor: Colors.white,
                          mini: true,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          tooltip: AppStrings.newPostTooltip,
                          child: const Icon(Icons.add_rounded),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryNeon),
                        label: AppText(AppStrings.homeTab),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore_rounded, color: AppTheme.primaryNeon),
                        label: AppText(AppStrings.exploreTab),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline_rounded),
                        selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryNeon),
                        label: AppText(AppStrings.profileTab),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const ConnectivityBanner(),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: FadeIndexedStack(
                              index: currentIndex,
                              children: pages,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            final now = DateTime.now();
            final doublePressDuration = const Duration(seconds: 2);
            final isDoublePress = lastPressedAt.value != null &&
                now.difference(lastPressedAt.value!) <= doublePressDuration;

            if (isDoublePress) {
              SystemNavigator.pop();
            } else {
              lastPressedAt.value = now;
              ToastService.showInfo(context, AppStrings.pressBackToExit);
            }
          },
          child: childWidget,
        );
      },
    );
  }
}

class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _prevIndex;
  int? _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _controller.addListener(() {
      setState(() {});
    });
    _controller.forward();
  }

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _prevIndex = oldWidget.index;
      _currentIndex = widget.index;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.children.length, (i) {
        final isSelected = i == _currentIndex;
        final isPrevious = i == _prevIndex;
        final visible = isSelected || (isPrevious && _controller.isAnimating);

        return Visibility(
          visible: visible,
          maintainState: true,
          child: IgnorePointer(
            ignoring: !isSelected,
            child: Opacity(
              opacity: isSelected
                  ? _controller.value
                  : (isPrevious ? (1.0 - _controller.value) : 0.0),
              child: widget.children[i],
            ),
          ),
        );
      }),
    );
  }
}
