import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/fancy_button.dart';
import '../../../shared/widgets/fancy_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          context.go(AppConstants.routeDashboard);
        } else if (state.status == LoginStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Login failed',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ── Gradient Background ─────────────────────────────────────
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF0F0F1A),
                            const Color(0xFF1A0A2E),
                            const Color(0xFF0A1A2E),
                          ]
                        : [
                            const Color(0xFFF0EFFE),
                            const Color(0xFFE8E4FF),
                            const Color(0xFFFFF0F5),
                          ],
                  ),
                ),
              ),
            ),

            // ── Decorative blobs ─────────────────────────────────────────
            Positioned(
              top: -80,
              right: -60,
              child: _GlowBlob(
                color: AppColors.primary.withOpacity(isDark ? 0.35 : 0.20),
                size: 320,
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _GlowBlob(
                color: AppColors.accent.withOpacity(isDark ? 0.25 : 0.15),
                size: 380,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              right: -40,
              child: _GlowBlob(
                color: AppColors.primaryLight.withOpacity(isDark ? 0.20 : 0.12),
                size: 220,
              ),
            ),

            // ── Main content ─────────────────────────────────────────────
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: _LoginCard(
                          isDark: isDark,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          formKey: _formKey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final bool isDark;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  const _LoginCard({
    required this.isDark,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.75),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.10)
                  : AppColors.primary.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.40)
                    : AppColors.primary.withOpacity(0.10),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo / Brand
                _BrandHeader(isDark: isDark),
                const SizedBox(height: 36),

                // Email
                BlocBuilder<LoginBloc, LoginState>(
                  buildWhen: (prev, curr) => prev.email != curr.email,
                  builder: (context, state) {
                    return FancyTextField(
                      label: 'Email Address',
                      hintText: 'admin@fancyshop.com',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => context.read<LoginBloc>().add(
                        LoginEmailChanged(value),
                      ),
                      validator: (_) =>
                          state.email.isNotEmpty && !state.isEmailValid
                          ? 'Enter a valid email address'
                          : null,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Password
                BlocBuilder<LoginBloc, LoginState>(
                  buildWhen: (prev, curr) =>
                      prev.password != curr.password ||
                      prev.passwordVisible != curr.passwordVisible,
                  builder: (context, state) {
                    return FancyTextField(
                      label: 'Password',
                      hintText: '••••••••',
                      controller: passwordController,
                      obscureText: !state.passwordVisible,
                      onChanged: (value) => context.read<LoginBloc>().add(
                        LoginPasswordChanged(value),
                      ),
                      validator: (_) =>
                          state.password.isNotEmpty && !state.isPasswordValid
                          ? 'Password must be at least 6 characters'
                          : null,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => context.read<LoginBloc>().add(
                          const LoginPasswordVisibilityToggled(),
                        ),
                        child: Icon(
                          state.passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: isDark
                              ? AppColors.darkTextHint
                              : AppColors.lightTextHint,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Sign In button
                BlocBuilder<LoginBloc, LoginState>(
                  buildWhen: (prev, curr) =>
                      prev.status != curr.status ||
                      prev.isFormValid != curr.isFormValid,
                  builder: (context, state) {
                    return FancyButton(
                      label: 'Sign In',
                      isLoading: state.status == LoginStatus.loading,
                      onPressed: state.isFormValid
                          ? () => context.read<LoginBloc>().add(
                              const LoginSubmitted(),
                            )
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Footer
                Center(
                  child: Text(
                    '© 2025 Fancy Shop. Admin Access Only.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextHint
                          : AppColors.lightTextHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final bool isDark;
  const _BrandHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.40),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Welcome back,',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fancy Shop Admin',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage your store',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
