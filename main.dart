import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const SolarPumpApp());

class SolarPumpApp extends StatelessWidget {
  const SolarPumpApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xff0d0d11)),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d0d11),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset('assets/images/splash.png', width: 200, height: 200, errorBuilder
: (c, e, s) => const Icon(Icons.solar_power_outlined, size: 120, color: Color(0xff00BCD4))),
        const SizedBox(height: 24),
        const Text("Fadi Sayegh App", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        const Text("جاري تشغيل النظام الهيدروليكي المؤتمت...", style: TextStyle(fontSize: 13, color: Colors.white54)),
        const SizedBox(height: 40),
        const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00BCD4))),
      ])),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _subHd = TextEditingController(text: "210"), _subDiff = TextEditingController(text: "9"), _subTk = TextEditingController(text: "15"), _subPipe = TextEditingController(text: "30"), _subQ = TextEditingController(text: "40"), _subEff = TextEditingController(text: "72");
  final _hzLen = TextEditingController(text: "45"), _hzLoss = TextEditingController(text: "15"), _hzQ = TextEditingController(text: "25"), _hzEff = TextEditingController(text: "75");
  double hSub = 0, pwrSub = 0; int pvSub = 0; double hHz = 0, pwrHz = 0; int pvHz = 0;
  late AnimationController _ac; double _wl = 0.0; bool _isFilling = true;

  void calc() {
    setState(() {
      double sDyn = double.tryParse(_subHd.text) ?? 0, sDiff = double.tryParse(_subDiff.text) ?? 0, sTk = double.tryParse(_subTk.text) ?? 0, sPipe = double.tryParse(_subPipe.text) ?? 0, sQ = double.tryParse(_subQ.text) ?? 0, sEff = (double.tryParse(_subEff.text) ?? 72) / 100;
      hSub = (sDyn + sDiff + sTk + sPipe) * 1.1; pwrSub = (1000 * (sQ / 3600) * hSub) / (102 * sEff); pvSub = (((pwrSub * 1000) * 1.3) / 550).ceil();
      double hLen = double.tryParse(_hzLen.text) ?? 0, hLoss = double.tryParse(_hzLoss.text) ?? 0, hQ = double.tryParse(_hzQ.text) ?? 0, hEff = (double.tryParse(_hzEff.text) ?? 75) / 100;
      hHz = (hLen + hLoss) * 1.1; pwrHz = (1000 * (hQ / 3600) * hHz) / (102 * hEff); pvHz = (((pwrHz * 1000) * 1.3) / 550).ceil();
    });
  }

  @override
  void initState() {
    super.initState(); calc();
    _ac = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _ac.addListener(() {
      setState(() {
        double qSub = double.tryParse(_subQ.text) ?? 40, qHz = double.tryParse(_hzQ.text) ?? 25;
        if (_isFilling) { _wl += (qSub * 0.00005); if (_wl >= 1.0) { _wl = 1.0; _isFilling = false; } }
        else { _wl -= (qHz * 0.00005); if (_wl <= 0.10) { _wl = 0.10; _isFilling = true; } }
      });
    });
  }

  @override void dispose() { _ac.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Column(children: [
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), color: const Color(0xff141419), child: const Text("برنامج الحسابات الهندسية للمضخات والمخطط التفاعلي بالنظام المؤتمت الذكي", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff00BCD4)))),
          Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
            SizedBox(width: 310, child: SingleChildScrollView(child: Column(children: [
              _fr("معطيات المضخة الغاطسة (Submersible)", const Color(0xff00BCD4), Column(children: [_in("المنسوب الديناميكي :(m)", _subHd), _in("فرق منسوب الفوهة والمكان :(m)", _subDiff), _in("ارتفاع الخزان :(m)", _subTk), _in("الارتفاع ضمن القساطل :(m)", _subPipe), _in("الغزارة المطلوبة :(m³/h)", _subQ), _in("مردود المضخة :(%)", _subEff)])),
              const SizedBox(height: 10),
              _fr("معطيات المضخة الأفقية (Horizontal)", const Color(0xff9C27B0), Column(children: [_in("طول شبكة الرفع :(m)", _hzLen), _in("فواقد شبكة الري :(m)", _hzLoss), _in("الغزارة المطلوبة :(m³/h)", _hzQ), _in("مردود المضخة :(%)", _hzEff)])),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 40, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff4CAF50)), onPressed: calc, child: const Text("تحديث الحسابات وجريان المياه", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
            ]))),
            const SizedBox(width: 15),
            Expanded(child: Column(children: [
              Expanded(flex: 5, child: Container(width: double.infinity, decoration: BoxDecoration(color: const Color(0xff09090c), border: Border.all(color: const Color(0xff1d1d24)), borderRadius: BorderRadius.circular(8)), child: CustomPaint(painter: HydraulicSystemPainter(_ac.value, _wl, _isFilling)))),
              const SizedBox(height: 10),
              Expanded(flex: 3, child: Row(children: [
                Expanded(child: _fr("مخرجات وتحديد المضخة الغاطسة ومصفوفاتها", const Color(0xff00BCD4), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_cl("الرفع الإجمالي (H1)", "${hSub.toStringAsFixed(1)} متر", const Color(0xff00BCD4)), _cl("الاستطاعة (kW)", "${pwrSub.toStringAsFixed(1)} kW", Colors.white), _cl("عدد الألواح (550W)", "$pvSub لوح", const Color(0xffFFC107))]))),
                const SizedBox(width: 10),
                Expanded(child: _fr("مخرجات وتحديد المضخة الأفقية ومصفوفاتها", const Color(0xff9C27B0), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_cl("الرفع الإجمالي (H2)", "${hHz.toStringAsFixed(1)} متر", const Color(0xff9C27B0)), _cl("الاستطاعة (kW)", "${pwrHz.toStringAsFixed(1)} kW", Colors.white), _cl("عدد الألواح (550W)", "$pvHz لوح", const Color(0xffFFC107))]))),
              ])),
            ])),
          ]))),
          InkWell(onTap: () => launchUrl(Uri.parse("https://wa.me")), child: Container(width: double.infinity, height: 40, color: const Color(0xff141419), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("إعداد المهندس فادي صايغ | اضغط هنا للتواصل عبر الواتساب: ", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)), Directionality(textDirection: TextDirection.ltr, child: Text("+963940065411", style: TextStyle(color: Color(0xff00BCD4), fontSize: 13, fontWeight: FontWeight.bold)))])))
        ]),
      ),
    );
  }

  Widget _fr(String t, Color c, Widget ch) => Container(width: double.infinity, margin: const EdgeInsets.only(top: 8), decoration: BoxDecoration(border: Border.all(color: c.withValues(alpha: 0.6), width: 1.2), borderRadius: BorderRadius.circular(4)), child: Stack(clipBehavior: Clip.none, children: [Positioned(right: 12, top: -10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6), color: const Color(0xff0d0d11), child: Text(t, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold)))), Padding(padding: const EdgeInsets.all(10), child: ch)]));
  Widget _in(String l, TextEditingController c) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Expanded(child: Text(l, style: const TextStyle(fontSize: 11, color: Colors.white70))), SizedBox(width: 75, height: 26, child: TextField(controller: c, textAlign: TextAlign.center, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), decoration: InputDecoration(contentPadding: EdgeInsets.zero, fillColor: const Color(0xff16161b), filled: true, enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800)), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xff00BCD4))))))]));
  Widget _cl(String l, String v, Color vc) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(l, style: const TextStyle(fontSize: 10, color: Colors.white60)), const SizedBox(height: 4), Text(v, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: vc))]);
}
class HydraulicSystemPainter extends CustomPainter {
  final double progress; final double waterLevel; final bool isFilling;
  HydraulicSystemPainter(this.progress, this.waterLevel, this.isFilling);

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width, h = size.height;
    final pFrame = Paint()..color = const Color(0xff23232e)..style = PaintingStyle.stroke..strokeWidth = 1.2;
    final pElectric = Paint()..color = const Color(0xffFFC107)..style = PaintingStyle.stroke..strokeWidth = 1.2;
    final pWaterSub = Paint()..color = const Color(0xff00BCD4)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    final pWaterHz = Paint()..color = const Color(0xff9C27B0)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromLTWH(w * 0.02, h * 0.05, w * 0.52, h * 0.88), pFrame);
    canvas.drawRect(Rect.fromLTWH(w * 0.56, h * 0.05, w * 0.42, h * 0.88), pFrame);

    final pRect = Rect.fromLTWH(w * 0.04, h * 0.12, 100, 50); canvas.drawRect(pRect, Paint()..color = const Color(0xff152238)); canvas.drawRect(pRect, pFrame..color = Colors.white24);
    for(int i=1; i<4; i++) {
      canvas.drawLine(Offset(w*0.04 + i*25, h*0.12), Offset(w*0.04 + i*25, h*0.12+50), pFrame);
    }
    _txt(canvas, "الألواح الشمسية", Offset(w * 0.05, h * 0.14), const Color(0xff00BCD4), 10);

    final cRect = Rect.fromLTWH(w * 0.22, h * 0.12, 80, 50); canvas.drawRect(cRect, Paint()..color = const Color(0xff1e272c)); canvas.drawRect(cRect, pFrame..color = Colors.green);
    canvas.drawRect(Rect.fromLTWH(w * 0.23, h * 0.14, 68, 14), Paint()..color = Colors.black);
    _txt(canvas, "50.0 Hz", Offset(w * 0.25, h * 0.145), Colors.greenAccent, 9);
    _txt(canvas, "Controller", Offset(w * 0.23, h * 0.20), Colors.white, 9);

    final tk = Rect.fromLTWH(w * 0.52, h * 0.20, w * 0.14, h * 0.48); canvas.drawRect(tk, Paint()..color = const Color(0xff16161e)); canvas.drawRect(tk, pFrame..color = Colors.blueGrey);
    double wH = (h * 0.48) * waterLevel;
    canvas.drawRect(Rect.fromLTWH(w * 0.523, (h * 0.20 + h * 0.48) - wH, (w * 0.14) - 5, wH - 2), Paint()..color = const Color(0xff00BCD4).withValues(alpha: 0.6));
    _txt(canvas, "${(waterLevel * 100).toStringAsFixed(0)}%", Offset(w * 0.57, h * 0.42), Colors.white, 13, isBold: true);

    _bdg(canvas, "SUB PUMP ON", isFilling ? const Color(0xff4CAF50) : Colors.grey.shade700, Offset(w * 0.38, h * 0.13));
    _bdg(canvas, "HZ PUMP ON", !isFilling ? const Color(0xff4CAF50) : Colors.grey.shade700, Offset(w * 0.70, h * 0.13));

    final wellRect = Rect.fromLTWH(w * 0.35, h * 0.65, 80, 75); canvas.drawRect(wellRect, Paint()..color = const Color(0xff141e24)); canvas.drawRect(wellRect, pFrame..color = Colors.blueGrey.shade700..strokeWidth = 2); canvas.drawRect(Rect.fromLTWH(w * 0.352, h * 0.69, 76, 45), Paint()..color = Colors.blue.withValues(alpha: 0.25));
    _txt(canvas, "بئر جوفي", Offset(w * 0.37, h * 0.66), Colors.white54, 9);

    final sPump = Offset(w * 0.35 + 40, h * 0.74); canvas.drawCircle(sPump, 16, Paint()..color = const Color(0xff16161a)); canvas.drawCircle(sPump, 16, pFrame..color = isFilling ? const Color(0xff00BCD4) : Colors.grey);
    _txt(canvas, "غاطسة", Offset(w * 0.35 + 23, h * 0.79), isFilling ? const Color(0xff00BCD4) : Colors.grey, 9);

    final hPump = Offset(w * 0.74, h * 0.74); canvas.drawCircle(hPump, 15, Paint()..color = const Color(0xff16161a)); canvas.drawCircle(hPump, 15, pFrame..color = !isFilling ? const Color(0xff9C27B0) : Colors.grey); canvas.drawRect(Rect.fromLTWH(w * 0.74, h * 0.71, 10, 8), Paint()..color = !isFilling ? const Color(0xff9C27B0) : Colors.grey);
    _txt(canvas, "أفقية (سحب موجب)", Offset(w * 0.70, h * 0.80), !isFilling ? const Color(0xff9C27B0) : Colors.grey, 9); _bdg(canvas, "شبكة الري", const Color(0xff00BCD4), Offset(w * 0.84, h * 0.71));

    _ln(canvas, Offset(w * 0.04 + 100, h * 0.17), Offset(w * 0.22, h * 0.17), pElectric); _ln(canvas, Offset(w * 0.26, h * 0.17), Offset(w * 0.26, h * 0.74), pElectric); _ln(canvas, Offset(w * 0.26, h * 0.74), Offset((w * 0.35 + 40) - 16, h * 0.74), pElectric);
    final pathSub = Path()..moveTo(w * 0.35 + 40, h * 0.74 - 16)..lineTo(w * 0.35 + 40, h * 0.32)..lineTo(w * 0.52, h * 0.32); canvas.drawPath(pathSub, pWaterSub..color = Colors.blueGrey.shade800); if (isFilling) _dot(canvas, pathSub, progress, const Color(0xff00BCD4));
    final pathHz = Path()..moveTo(w * 0.66, h * 0.64)..lineTo(w * 0.74, h * 0.64)..lineTo(w * 0.74, h * 0.74 + 15)..moveTo(w * 0.74 + 10, h * 0.74)..lineTo(w * 0.84, h * 0.74); canvas.drawPath(pathHz, pWaterHz..color = Colors.blueGrey.shade800); if (!isFilling) _dot(canvas, pathHz, progress, const Color(0xffe91e63));
  }

  void _dot(Canvas canvas, Path p, double a, Color c) {
    final paint = Paint()..color = c..style = PaintingStyle.fill;
    for (final m in p.computeMetrics()) {
      double len = m.length, step = 18.0;
      for (double o = a * step; o < len; o += step) {
        final t = m.getTangentForOffset(o); if (t != null) canvas.drawCircle(t.position, 2.5, paint);
      }
    }
  }

  void _ln(Canvas canvas, Offset s, Offset e, Paint paint) {
    double dx = e.dx - s.dx, dy = e.dy - s.dy, dist = math.sqrt(dx * dx + dy * dy), curr = 0.0;
    while (curr < dist) {
      canvas.drawLine(Offset(s.dx + (dx * curr / dist), s.dy + (dy * curr / dist)), Offset(s.dx + (dx * math.min(curr + 5, dist) / dist), s.dy + (dy * math.min(curr + 5, dist) / dist)), paint);
      curr += 10.0;
    }
  }

  void _bdg(Canvas canvas, String t, Color c, Offset o) {
    final r = Rect.fromLTWH(o.dx, o.dy, 85, 22); canvas.drawRect(r, Paint()..color = const Color(0xff161622)); canvas.drawRect(r, Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = 1.0);
    _txt(canvas, t, Offset(o.dx + 6, o.dy + 4), c, 9, isBold: true);
  }
  void _txt(Canvas canvas, String t, Offset o, Color c, double s, {bool isBold = false}) {
    TextPainter(text: TextSpan(text: t, style: TextStyle(color: c, fontSize: s, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), textDirection: TextDirection.rtl)..layout()..paint(canvas, o);
  }
  @override bool shouldRepaint(covariant HydraulicSystemPainter oldDelegate) => true;
}
