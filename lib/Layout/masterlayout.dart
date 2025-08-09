import 'package:flutter/material.dart';
import 'package:do_an_mobile_nc/theme/colors.dart'; // Import file color.dart

class MasterLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MasterLayout({
    super.key,
    required this.child,
    this.currentIndex = 0,
  });

  @override
  _MasterLayoutState createState() => _MasterLayoutState();
}

class _MasterLayoutState extends State<MasterLayout> {
  // Biến lưu trữ vị trí Y của FAB
  double _fabYPosition = 100.0; // Vị trí ban đầu (cách đỉnh màn hình)
  double _maxYPosition = 0.0; // Giới hạn dưới (sẽ được tính sau)

  @override
  void initState() {
    super.initState();
    // Tính toán giới hạn dưới trong initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      final bottomNavHeight = 80.0; // Ước lượng chiều cao của bottomNavigationBar
      setState(() {
        _maxYPosition = screenHeight - bottomNavHeight - 80.0; // 80 là chiều cao FAB
      });
    });
  }

  void _onTabTapped(BuildContext context, int index) {
    if (index == widget.currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/products');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/blog');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/contact');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.local_cafe,
                                color: AppColors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Fresh Drinks',
                              style: TextStyle(
                                fontFamily: 'Pacifico',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                shadows: [
                                  Shadow(
                                    color: AppColors.shadowMedium,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.shopping_cart,
                              color: AppColors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/cart');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
            // FloatingActionButton với khả năng kéo thả
            Positioned(
              right: 16.0,
              top: _fabYPosition,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    // Cập nhật vị trí Y dựa trên cử chỉ kéo
                    _fabYPosition += details.delta.dy;
                    // Giới hạn vị trí FAB để không vượt ra ngoài màn hình
                    _fabYPosition = _fabYPosition.clamp(50.0, _maxYPosition);
                  });
                },
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chatbot');
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chat_bubble_rounded,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Trang chủ', context),
                _buildNavItem(1, Icons.local_bar_rounded, 'Sản phẩm', context),
                _buildNavItem(2, Icons.article_rounded, 'Blog', context),
                _buildNavItem(3, Icons.contact_support_rounded, 'Liên hệ', context),
                _buildNavItem(4, Icons.person_rounded, 'Cá nhân', context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, BuildContext context) {
    final isSelected = index == widget.currentIndex;

    return GestureDetector(
      onTap: () => _onTabTapped(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.white.withOpacity(0.2)
              : AppColors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.white.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.white
                  : AppColors.white.withOpacity(0.7),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}