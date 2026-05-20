import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

// ─── Entry point (test standalone) ───────────────────────────────────────────
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

// ─── Colors ───────────────────────────────────────────────────────────────────
class AppColors {
  static const background   = Color(0xFF0A0A0F);
  static const cardBg       = Color(0x08FFFFFF);
  static const cardBorder   = Color(0x12FFFFFF);
  static const purple       = Color(0xFF7C3AED);
  static const purpleLight  = Color(0xFFA78BFA);
  static const purpleFocus  = Color(0x0FA78BFA);
  static const textPrimary  = Colors.white;
  static const textSub      = Color(0x66FFFFFF);
  static const textHint     = Color(0x40FFFFFF);
  static const inputBg      = Color(0x0AFFFFFF);
  static const inputBorder  = Color(0x14FFFFFF);
  static const divider      = Color(0x14FFFFFF);
  static const socialBg     = Color(0x0AFFFFFF);
  static const socialBorder = Color(0x1AFFFFFF);
}

// ─── Music Wave Painter ───────────────────────────────────────────────────────
class MusicWavePainter extends CustomPainter {
  final double animValue; // 0..1

  const MusicWavePainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.purpleLight, AppColors.purple],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    const heights = [8.0, 14.0, 10.0, 16.0, 12.0, 14.0, 8.0, 10.0];
    const xPositions = [4.0, 10.0, 16.0, 22.0, 28.0, 34.0, 40.0, 46.0];
    const barWidth = 4.0;

    for (int i = 0; i < heights.length; i++) {
      final baseH = heights[i];
      final wave = math.sin((animValue * 2 * math.pi) + i * 0.7);
      final h = (baseH + wave * 4).clamp(4.0, 20.0);
      final cx = xPositions[i];
      final top = size.height / 2 - h;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - barWidth / 2, top, barWidth, h * 2),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(MusicWavePainter old) => old.animValue != animValue;
}

// ─── Vinyl Record Painter ─────────────────────────────────────────────────────
class VinylPainter extends CustomPainter {
  const VinylPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer ring
    final ringPaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, ringPaint);

    // Groove rings
    for (int i = 0; i < 4; i++) {
      final gPaint = Paint()
        ..color = Colors.white.withOpacity(0.04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, radius * (0.5 + i * 0.15), gPaint);
    }

    // Center hole
    final holePaint = Paint()
      ..color = AppColors.purpleLight.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.18, holePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Orb Background Painter ───────────────────────────────────────────────────
class OrbPainter extends CustomPainter {
  const OrbPainter();
  @override
  void paint(Canvas canvas, Size size) {
    // Orb 1 - top left
    canvas.drawCircle(
      Offset(size.width * -0.1, size.height * 0.05),
      200,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.purple.withOpacity(0.25), Colors.transparent],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width * -0.1, size.height * 0.05),
          radius: 200,
        )),
    );

    // Orb 2 - bottom right
    canvas.drawCircle(
      Offset(size.width * 1.1, size.height * 1.0),
      260,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.purpleLight.withOpacity(0.15), Colors.transparent],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width * 1.1, size.height * 1.0),
          radius: 260,
        )),
    );

    // Orb 3 - middle right (pink)
    canvas.drawCircle(
      Offset(size.width * 1.05, size.height * 0.45),
      130,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFEC4899).withOpacity(0.12), Colors.transparent],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width * 1.05, size.height * 0.45),
          radius: 130,
        )),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Main Login Screen ────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus   = FocusNode();
  final _passFocus    = FocusNode();

  bool _showPass  = false;
  bool _loading   = false;
  bool _emailFocused = false;
  bool _passFocused  = false;

  late AnimationController _slideCtrl;
  late AnimationController _waveCtrl;
  late AnimationController _vinylCtrl;

  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _slideCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    )..forward();

    _slideAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic);
    _fadeAnim  = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeIn);

    _waveCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 2),
    )..repeat();

    _vinylCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 12),
    )..repeat();

    _emailFocus.addListener(() => setState(() => _emailFocused = _emailFocus.hasFocus));
    _passFocus.addListener(()  => setState(() => _passFocused  = _passFocus.hasFocus));
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _waveCtrl.dispose();
    _vinylCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background orbs
          Positioned.fill(
            child: CustomPaint(painter: const OrbPainter()),
          ),

          // Spinning vinyl record - top right
          Positioned(
            top: 48,
            right: 24,
            child: AnimatedBuilder(
              animation: _vinylCtrl,
              builder: (_, __) => Transform.rotate(
                angle: _vinylCtrl.value * 2 * math.pi,
                child: Opacity(
                  opacity: 0.35,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.purpleLight.withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: CustomPaint(
                        painter: const VinylPainter(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(_slideAnim),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _buildCard(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          const SizedBox(height: 32),
          _buildTitle(),
          const SizedBox(height: 28),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 10),
          _buildForgotPassword(),
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 24),
          _buildSocialButtons(),
          const SizedBox(height: 28),
          _buildRegisterRow(),
        ],
      ),
    );
  }

  // ── Logo ────────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.purple, AppColors.purpleLight],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withOpacity(0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (_, __) => CustomPaint(
                painter: MusicWavePainter(_waveCtrl.value),
                size: const Size(48, 32),
              ),
            ),
          ),
          const SizedBox(height: 14),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Vibe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'cast',
                  style: TextStyle(
                    color: AppColors.purpleLight,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Music & Podcast, your world',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  // ── Title ───────────────────────────────────────────────────────────────────
  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chào mừng trở lại 👋',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Đăng nhập để tiếp tục nghe nhạc',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  // ── Input field helper ──────────────────────────────────────────────────────
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isFocused ? AppColors.purpleFocus : AppColors.inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFocused
                  ? AppColors.purpleLight.withOpacity(0.6)
                  : AppColors.inputBorder,
              width: 1.5,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.purpleLight.withOpacity(0.08),
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 15),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
              suffixIcon: suffix,
            ),
            cursorColor: AppColors.purpleLight,
          ),
        ),
      ],
    );
  }

  // ── Email ───────────────────────────────────────────────────────────────────
  Widget _buildEmailField() {
    return _buildInputField(
      label: 'Email',
      controller: _emailCtrl,
      focusNode: _emailFocus,
      isFocused: _emailFocused,
      hint: 'your@email.com',
      keyboardType: TextInputType.emailAddress,
    );
  }

  // ── Password ────────────────────────────────────────────────────────────────
  Widget _buildPasswordField() {
    return _buildInputField(
      label: 'Mật khẩu',
      controller: _passwordCtrl,
      focusNode: _passFocus,
      isFocused: _passFocused,
      hint: '••••••••',
      obscure: !_showPass,
      suffix: IconButton(
        icon: Icon(
          _showPass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.white.withOpacity(_showPass ? 0.7 : 0.3),
          size: 20,
        ),
        onPressed: () => setState(() => _showPass = !_showPass),
      ),
    );
  }

  // ── Forgot Password ─────────────────────────────────────────────────────────
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {},
        child: const Text(
          'Quên mật khẩu?',
          style: TextStyle(
            color: AppColors.purpleLight,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ── Login Button ────────────────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.purple, AppColors.purpleLight],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _loading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.purple.withOpacity(0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _loading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text(
                  'Đăng nhập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Divider ─────────────────────────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'HOẶC',
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1)),
      ],
    );
  }

  // ── Social Buttons ──────────────────────────────────────────────────────────
  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(child: _socialBtn(
          label: 'Google',
          icon: _googleIcon(),
          onTap: () {},
        )),
        const SizedBox(width: 10),
        Expanded(child: _socialBtn(
          label: 'Apple',
          icon: const Icon(Icons.apple, color: Colors.white, size: 18),
          onTap: () {},
        )),
        const SizedBox(width: 10),
        Expanded(child: _socialBtn(
          label: 'Spotify',
          icon: _spotifyIcon(),
          onTap: () {},
        )),
      ],
    );
  }

  Widget _socialBtn({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.socialBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.socialBorder),
        ),
        child: Column(
          children: [
            icon,
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _googleIcon() {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }

  Widget _spotifyIcon() {
    return const Icon(Icons.music_note_rounded, color: Color(0xFF1DB954), size: 18);
  }

  // ── Register Row ────────────────────────────────────────────────────────────
  Widget _buildRegisterRow() {
    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Chưa có tài khoản? ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: 'Đăng ký ngay',
              style: const TextStyle(
                color: AppColors.purpleLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              recognizer: TapGestureRecognizer()..onTap = () {},
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Google Icon Custom Painter ───────────────────────────────────────────────
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()..style = PaintingStyle.fill;

    // Red (top-left arc)
    paint.color = const Color(0xFFEA4335);
    final path1 = Path()
      ..moveTo(s * 0.22, s * 0.41)
      ..cubicTo(s * 0.16, s * 0.27, s * 0.22, s * 0.13, s * 0.33, s * 0.07)
      ..lineTo(s * 0.5, s * 0.2)
      ..cubicTo(s * 0.39, s * 0.24, s * 0.3, s * 0.32, s * 0.22, s * 0.41)
      ..close();
    canvas.drawPath(path1, paint);

    // Green (bottom-left)
    paint.color = const Color(0xFF34A853);
    final path2 = Path()
      ..moveTo(s * 0.06, s * 0.69)
      ..lineTo(s * 0.22, s * 0.6)
      ..cubicTo(s * 0.3, s * 0.73, s * 0.42, s * 0.8, s * 0.5, s * 0.8)
      ..cubicTo(s * 0.6, s * 0.8, s * 0.69, s * 0.75, s * 0.75, s * 0.67)
      ..lineTo(s * 0.9, s * 0.76)
      ..cubicTo(s * 0.8, s * 0.89, s * 0.66, s * 0.96, s * 0.5, s * 0.96)
      ..cubicTo(s * 0.31, s * 0.96, s * 0.14, s * 0.85, s * 0.06, s * 0.69)
      ..close();
    canvas.drawPath(path2, paint);

    // Blue (right arc)
    paint.color = const Color(0xFF4285F4);
    final path3 = Path()
      ..moveTo(s * 0.9, s * 0.76)
      ..cubicTo(s * 0.96, s * 0.65, s * 1.0, s * 0.54, s * 1.0, s * 0.5)
      ..lineTo(s * 0.5, s * 0.5)
      ..lineTo(s * 0.5, s * 0.69)
      ..lineTo(s * 0.78, s * 0.69)
      ..cubicTo(s * 0.75, s * 0.74, s * 0.71, s * 0.77, s * 0.75, s * 0.67)
      ..close();
    canvas.drawPath(path3, paint);

    // Yellow (top-right)
    paint.color = const Color(0xFFFBBC05);
    final path4 = Path()
      ..moveTo(s * 0.78, s * 0.69)
      ..lineTo(s * 0.5, s * 0.69)
      ..lineTo(s * 0.5, s * 0.5)
      ..lineTo(s * 1.0, s * 0.5)
      ..cubicTo(s * 1.0, s * 0.56, s * 0.99, s * 0.62, s * 0.97, s * 0.67)
      ..close();
    canvas.drawPath(path4, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
