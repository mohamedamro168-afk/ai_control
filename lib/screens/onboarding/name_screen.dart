import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'learn_screen.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    final name = _controller.text.trim().isEmpty ? 'صديقي' : _controller.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ['أحمد', 'محمد', 'علي', 'سارة', 'مريم', 'يوسف', 'عمر', 'فاطمة'];

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0f),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                const Text('الخطوة 1 من 4',
                    style: TextStyle(color: Color(0xFF7c6ef7), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: 0.25,
                    backgroundColor: const Color(0xFF1e1e32),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF7c6ef7)),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 28),
                const Text('إيه اسمك؟',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFf0f0f8))),
                const SizedBox(height: 6),
                const Text('عشان المساعد يناديك بالاسم الصح',
                    style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                const SizedBox(height: 28),
                const Text('الاسم',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Color(0xFFf0f0f8), fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'اكتب اسمك هنا...',
                    hintStyle: const TextStyle(color: Color(0xFF444444)),
                    filled: true,
                    fillColor: const Color(0xFF161622),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2a2a40)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2a2a40)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF7c6ef7)),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  onSubmitted: (_) => _handleNext(),
                ),
                const SizedBox(height: 10),
                const Text('أو اختار بسرعة:',
                    style: TextStyle(color: Color(0xFF444444), fontSize: 12)),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: suggestions.map((s) => GestureDetector(
                      onTap: () => setState(() => _controller.text = s),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: _controller.text == s
                              ? const Color(0xFF1a1838)
                              : const Color(0xFF1a1a2e),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _controller.text == s
                                ? const Color(0xFF7c6ef7)
                                : const Color(0xFF2a2a40),
                          ),
                        ),
                        child: Text(s,
                            style: TextStyle(
                              color: _controller.text == s
                                  ? const Color(0xFF7c6ef7)
                                  : const Color(0xFF9090b8),
                              fontSize: 13,
                            )),
                      ),
                    )).toList(),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7c6ef7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('التالي ←',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: _handleNext,
                    child: const Text('تخطي',
                        style: TextStyle(color: Color(0xFF444444), fontSize: 13)),
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