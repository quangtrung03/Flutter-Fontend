import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/logo_widget.dart';
import '../../theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Nhập email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Tự động focus vào ô email khi mở form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: isWide
            ? Row(
                children: [
                  // Logo bên trái
                  Expanded(
                    child: Center(
                      child: LogoWidget(width: 200, height: 200),
                    ),
                  ),
                  // Form bên phải
                  Expanded(child: _buildForm(context, authProvider)),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    LogoWidget(width: 120, height: 120),
                    const SizedBox(height: 24),
                    _buildForm(context, authProvider),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AuthProvider authProvider) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ĐĂNG NHẬP TÀI KHOẢN CỦA BẠN',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  const Text('Không có tài khoản? Hãy đăng ký tại đây:'),
                  TextButton(
                    onPressed: () {
                      authProvider.resetMessages();
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text('Đăng ký'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                onChanged: (_) => authProvider.resetMessages(),
                onFieldSubmitted: (_) {
                  _passwordFocus.requestFocus();
                },
                // onSaved không cần thiết vì đã dùng controller
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: _validatePassword,
                onChanged: (_) => authProvider.resetMessages(),
                onFieldSubmitted: (_) async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final success = await authProvider.login(
                      _emailController.text, 
                      _passwordController.text,
                      rememberMe: _rememberMe
                    );
                    if (success && mounted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  }
                },
                // onSaved không cần thiết vì đã dùng controller
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) => setState(() => _rememberMe = value!),
                  ),
                  const Text('Ghi nhớ đăng nhập'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: Hiển thị dialog hoặc chuyển sang màn hình quên mật khẩu
                    },
                    child: Text('Quên mật khẩu?'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (authProvider.error != null)
                Text(authProvider.error!, style: const TextStyle(color: Colors.red)),
              if (authProvider.successMessage != null)
                Text(authProvider.successMessage!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    backgroundColor: null,
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                      return null;
                    }),
                  ),
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final success = await authProvider.login(
                              _emailController.text, 
                              _passwordController.text,
                              rememberMe: _rememberMe
                            );
                            if (success && mounted) {
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          }
                        },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'ĐĂNG NHẬP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.1,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 