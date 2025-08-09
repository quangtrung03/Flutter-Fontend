import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/review_provider.dart';
import 'providers/voucher_provider.dart';
import 'providers/address_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/support_request_provider.dart';
import 'providers/support_chat_provider.dart';
import 'providers/admin_support_chat_provider.dart';
import 'providers/feature_provider.dart';
import 'providers/notification_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home.dart';
import 'screens/product/product.dart'; // Thêm import này
import 'screens/cart/cart_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/checkout/success_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/order/order_history_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/contact/contact_screen.dart';
import 'screens/blog/blog_screen.dart';
import 'screens/profile/address_screen.dart';
import 'screens/profile/favorites_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'package:do_an_mobile_nc/chatbot/chat_bot.dart';


// Admin
import 'admin/pages/dashboard_page.dart';

// Services
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _isLoggedInFuture;

  @override
  void initState() {
    super.initState();
    _isLoggedInFuture = _initializeApp();
  }

  Future<bool> _initializeApp() async {
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();
    if (isLoggedIn) {
      // Nếu có token, khởi tạo user data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AuthProvider>(context, listen: false).initializeUser();
      });
    }
    return isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => SupportRequestProvider()),
        ChangeNotifierProvider(create: (_) => SupportChatProvider()),
        ChangeNotifierProvider(create: (_) => AdminSupportChatProvider()),
        ChangeNotifierProvider(create: (_) => FeatureProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Coffee Shop App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.brown,
          scaffoldBackgroundColor: const Color(0xFFF7F7F7),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
          ),
        ),

        // ❗ CHỈ dùng home (không dùng route '/')
        home: FutureBuilder<bool>(
          future: _isLoggedInFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snapshot.data! ? HomeScreen() : const LoginScreen();
          },
        ),

        routes: {
          // USER ROUTES
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/products': (context) => ProductListScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/order-history': (context) => const OrderHistoryScreen(),
          '/search': (context) => const SearchScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/success': (context) => const SuccessScreen(),
          '/contact': (context) => const ContactScreen(),
          '/blog': (context) => BlogScreen(),
          '/address': (context) => const AddressScreen(),
          '/favorites': (context) => const FavoritesScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/chatbot': (context) => const ChatbotScreen(),

          // ADMIN
          '/admin': (context) => const DashboardPage(),
        },
      ),
    );
  }
}
