import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mente_leve/shared/auth/auth_notifier.dart';
import 'package:mente_leve/shared/models/enums/user_role.dart';
import 'package:provider/provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);

    _bootstrap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String homeFor(Role role) => switch (role) {
    Role.student => '/student/home',
    Role.parent => '/parents/home',
    Role.psychologist => '/psychologist/home',
  };
  
  Future<void> _bootstrap() async {
    final auth = context.read<AuthNotifier>();

    await Future.wait([
      auth.restore(),
      Future<void>.delayed(Duration(seconds: 3))
    ]);
    if (!mounted) return;
    final session = auth.session;
    Navigator.of(context).pushReplacementNamed(
      session == null ? '/onboarding' : homeFor(session.role)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset('assets/images/breno.png', width: 150),
        ),
      ),
    );
  }
}
