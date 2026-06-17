import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen.dart';

class ReadyScreen extends StatefulWidget {
  const ReadyScreen({super.key});

  @override
  State<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends State<ReadyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleStart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final examples = [
      {'icon': '📞', 'text': '"اتصل بأحمد"'},
      {'icon': '💬', 'text': '"ابعت واتساب لماما: أنا جاي"'},
      {'icon': '⏰', 'text': '"حط منبه الساعة 7 الصبح"'},
      {'icon': '📱', 'text': '"افتح يوتيوب"'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0f),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 80),
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7c6ef7),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('جاهز تمامًا!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFf0f0f8))),
                const SizedBox(height: 8),
                const Text('المساعد اتعلم منك وجاهز ينفذ أوامرك',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13131f),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1e1e32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('قدر تقول مثلاً:',
                          style: TextStyle(color: Color(0xFF666666), fontSize: 12)),
                      const SizedBox(height: 12),
                      ...examples.map((ex) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Text(ex['icon']!, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Text(ex['text']!,
                                style: const TextStyle(color: Color(0xFFc0c0d8), fontSize: 13)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161628),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2a2a48)),
                  ),
                  child: const Row(
                    children: [
                      Text('💡', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'كل ما تستخدم التطبيق أكتر، كل ما المساعد هيتعلم عاداتك ويبقى أسرع وأدق.',
                          style: TextStyle(color: Color(0xFF8080b0), fontSize: 12, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7c6ef7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: const Text('🎤  ابدأ تكلّم المساعد',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}