import 'package:flutter/material.dart'; 
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';

void main() => runApp(const MyApp());

/* =========================================================
   APP STATE (Wishlist only)
========================================================= */
class AppState extends ChangeNotifier {
  final List<Product> wishlist = [];
  Map<String, dynamic>? currentUser;
  String? authToken;

  bool isWishlisted(Product p) => wishlist.any((x) => x.id == p.id);

  void setUser(Map<String, dynamic>? user, String? token) {
    currentUser = user;
    authToken = token;
    notifyListeners();
  }

  void toggleWishlist(Product p) {
    if (isWishlisted(p)) {
      wishlist.removeWhere((x) => x.id == p.id);
    } else {
      wishlist.add(p);
    }
    notifyListeners();
  }

  void remove(Product p) {
    wishlist.removeWhere((x) => x.id == p.id);
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    return scope!.notifier!;
  }
}

/* =========================================================
   PRODUCT MODEL
========================================================= */
class Product {
  final String id;
  final String brand;
  final String name;
  final String finish; // Liquid/Matte etc
  final String undertone; // Warm/Cool/Neutral
  final String price;
  final String imageUrl;

  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.finish,
    required this.undertone,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      brand: json['brand'] ?? '',
      name: json['name'] ?? '',
      finish: json['finish'] ?? '',
      undertone: json['undertone'] ?? '',
      price: json['price'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

/* =========================================================
   APP ROOT
========================================================= */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(useMaterial3: true);

    return AppScope(
      notifier: AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "SKINMATCH",
        theme: base.copyWith(
          scaffoldBackgroundColor: const Color(0xFFF7F7F7),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withOpacity(0.95),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        home: const StartScreen(),
      ),
    );
  }
}

/* =========================================================
   STEP 1: START SCREEN
========================================================= */
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  static const String bgUrl =
      "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=1400&q=80";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            bgUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFC1CC), Color(0xFFFFE7D6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              child: const Text(
                "Background image didn't load.\n(Internet required)",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.28)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Shade Match",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "MANUAL FOUNDATION SHADE DETECTIIVE WITHOUT AI ",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 18),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC1CC),
                      foregroundColor: Colors.black,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Start",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
}

/* =========================================================
   STEP 2: AUTH SCREEN (Professional) - Frontend demo
========================================================= */
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  final _loginKey = GlobalKey<FormState>();
  final _loginUser = TextEditingController();
  final _loginPass = TextEditingController();

  final _signupKey = GlobalKey<FormState>();
  final _signEmail = TextEditingController();
  final _signUser = TextEditingController();
  final _signPass = TextEditingController();

  bool _hideLoginPass = true;
  bool _hideSignPass = true;

  final Set<String> _takenUsernames = {"saranya", "admin", "user", "test"};

  @override
  void dispose() {
    _loginUser.dispose();
    _loginPass.dispose();
    _signEmail.dispose();
    _signUser.dispose();
    _signPass.dispose();
    super.dispose();
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _goForm() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SkinFormScreen()),
    );
  }

  Future<void> _submitLogin() async {
    if (!_loginKey.currentState!.validate()) return;

    final email = _loginUser.text.trim();
    final pass = _loginPass.text;

    final response = await ApiService.login(email, pass);
    // print("LOGIN RESPONSE: $response");
    if (response == null) {
      _toast("Invalid email or password");
      return;
    }

   // 👇 ADD THIS
final prefs = await SharedPreferences.getInstance();
await prefs.setString("token", response['token']);
await prefs.setString("userId", response['user']['id']);

final state = AppScope.of(context);
state.setUser(response['user'], response['token']);

_toast("Login successfully");
final userId = response['user']['id'];

final existingData = await ApiService.getSkinData(userId);

if (existingData != null) {
  final data = SkinFormData(
    fullName: existingData['fullName'],
    age: existingData['age'],
    gender: existingData['gender'],
    skinType: existingData['skinType'],
    undertone: existingData['undertone'],
    shadeLevel: existingData['shadeLevel'],
  );

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => MannequinScreen(data: data),
    ),
  );
} else {
  _goForm();
}
  }

  List<String> _suggestUsernames(String desired) {
    final base = desired.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    return ["${base}01", "${base}02", "${base}_official", "${base}_2026"];
  }

  bool _isStrongPassword(String s) {
    return s.length >= 5;
  }

  Future<void> _submitSignup() async {
    if (!_signupKey.currentState!.validate()) return;

    final email = _signEmail.text.trim().toLowerCase();
    final username = _signUser.text.trim().toLowerCase();
    final pass = _signPass.text;

    if (!email.contains("@") || !email.contains(".")) {
      _toast("Enter valid email");
      return;
    }

    if (!_isStrongPassword(pass)) {
      _toast(
          "Password must be at least 5 characters.");
      return;
    }

    final response = await ApiService.signup(username, email, pass);
    if (response == null) {
      _toast("Signup failed. User might already exist.");
      return;
    }

    final state = AppScope.of(context);
    state.setUser(response['user'], response['token']);

    _toast("Sign up success ");
    _goForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "SKINMATCH",
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLogin ? "Log in to continue" : "Create your account",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 18),
                  _CardShell(
                    child: Column(
                      children: [
                        _SegmentToggle(
                          left: "Login",
                          right: "Sign Up",
                          leftSelected: isLogin,
                          onLeft: () => setState(() => isLogin = true),
                          onRight: () => setState(() => isLogin = false),
                        ),
                        const SizedBox(height: 14),
                        if (isLogin) _loginForm() else _signupForm(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Demo now. Firebase email verification will be added later.",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Form(
      key: _loginKey,
      child: Column(
        children: [
          TextFormField(
            controller: _loginUser,
            decoration: const InputDecoration(
              hintText: "Phone number, username, or email",
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? "Enter username/email" : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _loginPass,
            obscureText: _hideLoginPass,
            decoration: InputDecoration(
              hintText: "Password",
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _hideLoginPass = !_hideLoginPass),
                icon: Icon(
                    _hideLoginPass ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: (v) => (v == null || v.isEmpty) ? "Enter password" : null,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Log in",
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "login: user = saranimalar2407@gmail.com  |  pass = saranya",
            style: TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _signupForm() {
    return Form(
      key: _signupKey,
      child: Column(
        children: [
          TextFormField(
            controller: _signEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Email address"),
            validator: (v) {
              final s = (v ?? "").trim();
              if (s.isEmpty) return "Enter email";
              if (!s.contains("@") || !s.contains(".")) return "Enter valid email";
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _signUser,
            decoration: const InputDecoration(hintText: "Username"),
            validator: (v) {
              final s = (v ?? "").trim();
              if (s.isEmpty) return "Enter username";
              if (s.length < 3) return "Username too short";
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _signPass,
            obscureText: _hideSignPass,
            decoration: InputDecoration(
              hintText: "Password",
              helperText: "Minimum 5 characters.",
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hideSignPass = !_hideSignPass),
                icon:
                    Icon(_hideSignPass ? Icons.visibility : Icons.visibility_off),
              ),
            ),
            validator: (v) {
              final s = v ?? "";
              if (s.isEmpty) return "Enter password";
              if (s.length < 5) return "Must be at least 5 characters";
              return null;
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("Sign up",
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   STEP 3: FORM PAGE
========================================================= */
class SkinFormScreen extends StatefulWidget {
  const SkinFormScreen({super.key});

  @override
  State<SkinFormScreen> createState() => _SkinFormScreenState();
}

class _SkinFormScreenState extends State<SkinFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullName = TextEditingController();
  final _age = TextEditingController();

  String gender = "Female";
  String skinType = "Normal";
  String undertone = "Neutral";
  String shadeLevel = "Medium";
  bool consent = false;

  @override
  void dispose() {
    _fullName.dispose();
    _age.dispose();
    super.dispose();
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ageVal = int.tryParse(_age.text.trim()) ?? 0;
    if (ageVal < 1 || ageVal > 100) {
      _toast("Please enter a valid age (1 to 100).");
      return;
    }

    if (!consent) {
      _toast("Please tick the checkbox to continue.");
      return;
    }

    final state = AppScope.of(context);
    final userId = state.currentUser?['id'];

    if (userId == null) {
      _toast("User not logged in");
      return;
    }

    final data = SkinFormData(
      fullName: _fullName.text.trim(),
      age: ageVal,
      gender: gender,
      skinType: skinType,
      undertone: undertone,
      shadeLevel: shadeLevel,
    );

    // Save to backend
    final success = await ApiService.saveSkinData({
      "userId": userId,
      "fullName": data.fullName,
      "age": data.age,
      "gender": data.gender,
      "skinType": data.skinType,
      "undertone": data.undertone,
      "shadeLevel": data.shadeLevel,
    });

    if (!success) {
      _toast("Failed to save skin details. (check backend)");
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MannequinScreen(data: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Skin Details Form")),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: _CardShell(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Tell us about your skin",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Manual selection (no AI). We show shades based on your choice.",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel("Full Name"),
                      TextFormField(
                        controller: _fullName,
                        decoration: const InputDecoration(
                          hintText: "Enter your full name",
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? "Name is required" : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _FieldLabel("Age"),
                                TextFormField(
                                  controller: _age,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: "Eg: 20",
                                    prefixIcon: Icon(Icons.cake),
                                  ),
                                  validator: (v) {
                                    final s = (v ?? "").trim();
                                    if (s.isEmpty) return "Age required";
                                    if (int.tryParse(s) == null) return "Numbers only";
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _FieldLabel("Gender"),
                                DropdownButtonFormField<String>(
                                  value: gender,
                                  decoration:
                                      const InputDecoration(prefixIcon: Icon(Icons.wc)),
                                  items: const [
                                    DropdownMenuItem(value: "Female", child: Text("Female")),
                                    DropdownMenuItem(value: "Male", child: Text("Male")),
                                    DropdownMenuItem(value: "Other", child: Text("Other")),
                                  ],
                                  onChanged: (v) => setState(() => gender = v ?? "Female"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const _FieldLabel("Skin Type"),
                      DropdownButtonFormField<String>(
                        value: skinType,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.face)),
                        items: const [
                          DropdownMenuItem(value: "Normal", child: Text("Normal")),
                          DropdownMenuItem(value: "Dry", child: Text("Dry")),
                          DropdownMenuItem(value: "Oily", child: Text("Oily")),
                        DropdownMenuItem(value: "Combination", child: Text("Combination")),
                        DropdownMenuItem(value: "Sensitive", child: Text("Sensitive")),
                        ],
                        onChanged: (v) => setState(() => skinType = v ?? "Normal"),
                      ),
                      const SizedBox(height: 14),
                      const _FieldLabel("Undertone"),
                      DropdownButtonFormField<String>(
                        value: undertone,
                        decoration:
                            const InputDecoration(prefixIcon: Icon(Icons.color_lens)),
                        items: const [
                          DropdownMenuItem(value: "Warm", child: Text("Warm")),
                          DropdownMenuItem(value: "Cool", child: Text("Cool")),
                          DropdownMenuItem(value: "Neutral", child: Text("Neutral")),
                        ],
                        onChanged: (v) => setState(() => undertone = v ?? "Neutral"),
                      ),
                      const SizedBox(height: 14),
                      const _FieldLabel("Shade Level"),
                      DropdownButtonFormField<String>(
                        value: shadeLevel,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.palette)),
                        items: const [
                          DropdownMenuItem(value: "Fair", child: Text("Fair")),
                          DropdownMenuItem(value: "Light", child: Text("Light")),
                          DropdownMenuItem(value: "Medium", child: Text("Medium")),
                          DropdownMenuItem(value: "Tan", child: Text("Tan")),
                          DropdownMenuItem(value: "Deep", child: Text("Deep")),
                        ],
                        onChanged: (v) => setState(() => shadeLevel = v ?? "Medium"),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: CheckboxListTile(
                          value: consent,
                          onChanged: (v) => setState(() => consent = v ?? false),
                          title: const Text(
                            "I agree to save my details",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: const Text("Frontend demo only."),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Submit",
                              style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SkinFormData {
  final String fullName;
  final int age;
  final String gender;
  final String skinType;
  final String undertone;
  final String shadeLevel;

  SkinFormData({
    required this.fullName,
    required this.age,
    required this.gender,
    required this.skinType,
    required this.undertone,
    required this.shadeLevel,
  });
}

/* =========================================================
   STEP 4: MANNEQUIN + LEFT COLOR STRIP SLIDER
========================================================= */
class MannequinScreen extends StatefulWidget {
  final SkinFormData data;
  const MannequinScreen({super.key, required this.data});

  @override
  State<MannequinScreen> createState() => _MannequinScreenState();
}

class _MannequinScreenState extends State<MannequinScreen> {
  double shadeAdjust = 0.0;

  @override
  Widget build(BuildContext context) {
    final base = _baseShade(widget.data.shadeLevel, widget.data.undertone);
    final applied = _adjustShade(base, shadeAdjust);

    return Scaffold(
appBar: AppBar(
  title: const Text("Shade Preview"),
  actions: [

    // 👤 PROFILE BUTTON
    IconButton(
      icon: const Icon(Icons.person),
      onPressed: () {
        final state = AppScope.of(context);
        final userId = state.currentUser?['id'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(userId: userId),
          ),
        );
      },
    ),

    // ❤️ WISHLIST BUTTON
    IconButton(
      icon: const Icon(Icons.favorite),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WishlistScreen(),
          ),
        );
      },
    ),
  ],
),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _LeftColorStrip(
                    base: base,
                    applied: applied,
                    shadeAdjust: shadeAdjust,
                    onChanged: (v) => setState(() => shadeAdjust = v),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: _FacePreviewCard(
                            name: widget.data.fullName,
                            baseColor: base,
                            appliedColor: applied,
                            undertone: widget.data.undertone,
                            shadeLevel: widget.data.shadeLevel,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ShopScreen(
                                    undertone: widget.data.undertone,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text("Next",
                                style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _baseShade(String level, String undertone) {
    Color base;
    if (level == "Fair") {
      base = const Color(0xFFFFE5D0);
    } else if (level == "Light") {
      base = const Color(0xFFFFD1B3);
    } else if (level == "Medium") {
      base = const Color(0xFFE8B08D);
    } else if (level == "Tan") {
      base = const Color(0xFFD08B63);
    } else if (level == "Deep") {
      base = const Color(0xFF8C5A3C);
    } else {
      base = const Color(0xFFE8B08D);
    }

    if (undertone == "Warm") {
      base = _shift(base, r: 10, g: 6, b: -6);
    } else if (undertone == "Cool") {
      base = _shift(base, r: -6, g: 0, b: 10);
    }
    return base;
  }

  Color _adjustShade(Color c, double t) {
    final amount = (t * 45).round();
    return _shift(c, r: amount, g: amount, b: amount);
  }
}

class _LeftColorStrip extends StatelessWidget {
  final Color base;
  final Color applied;
  final double shadeAdjust;
  final ValueChanged<double> onChanged;

  const _LeftColorStrip({
    required this.base,
    required this.applied,
    required this.shadeAdjust,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lighter = _shift(base, r: 24, g: 24, b: 24);
    final darker = _shift(base, r: -24, g: -24, b: -24);

    return SizedBox(
      width: 88,
      child: Column(
        children: [
          _Swatch(label: "Lighter", color: lighter),
          const SizedBox(height: 8),
          _Swatch(label: "Base", color: base),
          const SizedBox(height: 8),
          _Swatch(label: "Darker", color: darker),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  const Text("Lighter",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Slider(
                        value: shadeAdjust,
                        min: -1,
                        max: 1,
                        divisions: 20,
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("Darker",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                const Text("Applied",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: applied,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final String label;
  final Color color;
  const _Swatch({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FacePreviewCard extends StatelessWidget {
  final String name;
  final Color baseColor;
  final Color appliedColor;
  final String undertone;
  final String shadeLevel;

  const _FacePreviewCard({
    required this.name,
    required this.baseColor,
    required this.appliedColor,
    required this.undertone,
    required this.shadeLevel,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Hi, $name",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            "Shade: $shadeLevel • Undertone: $undertone",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black12.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 290,
                        decoration: BoxDecoration(
                          color: appliedColor,
                          borderRadius: BorderRadius.circular(150),
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                      const Positioned(top: 105, left: 72, child: _Eye()),
                      const Positioned(top: 105, right: 72, child: _Eye()),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Use the left slider: Up = lighter, Down = darker.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

/* =========================================================
   STEP 5: SHOP PAGE
========================================================= */
class ShopScreen extends StatelessWidget {
  final String undertone;
  const ShopScreen({super.key, required this.undertone});
  

  static const _allProducts = <Product>[
    Product(
      id: "p1",
      brand: "Maybelline",
      name: "Fit Me Matte + Poreless 128 Warm Nude",
      finish: "Liquid • Matte",
      undertone: "warm",
      price: "₹389",
      imageUrl: "assets/p1.jpeg"
    ),
    Product(
      id: "p2",
      brand: "Maybelline",
      name: "Fit Me Matte + Poreless 127 Golden Honey",
      finish: "Liquid • Matte",
      undertone: "warm",
      price: "₹399",
     imageUrl: "assets/p1.jpeg"
    ),
    // Product(
    //   id: "p3",
    //   brand: "Maybelline",
    //   name: "Fit Me Matte + Poreless 220 Natural Beige",
    //   finish: "Liquid • Matte",
    //   undertone: "warm",
    //   price: "₹389",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61Y3+3+LkML._SL1500_.jpg",
    // ),Product(
    //   id: "p4",
    //   brand: "Maybelline",
    //   name: "Fit Me Matte + Poreless 230 Natural Buff",
    //   finish: "Liquid • Matte",
    //   undertone: "warm",
    //   price: "₹399",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61h6jFjKJLL._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p5",
    //   brand: "Maybelline",
    //   name: "Fit Me Matte + Poreless 310 Sun Beige",
    //   finish: "Liquid • Matte",
    //   undertone: "warm",
    //   price: "₹389",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61y4XgQzWkL._SL1500_.jpg",
    // ),
    Product(
      id: "p6",
      brand: "MAC",
      name: "MAC Studio Fix Fluid SPF 15 Foundation",
      finish: "Liquid • Matte",
      undertone: "warm",
      price: "₹3400-4000",
   imageUrl: "assets/p6.jpeg"
    ),
    Product(
      id: "p7",
      brand: "MAC",
      name: "MAC Studio Fix Fluid SPF 15 Foundation NC20",
      finish: "Liquid • Matte",
      undertone: "warm",
      price: "₹3400",
imageUrl: "assets/p7.jpeg"
    ),
    // Product(
    //   id: "p8",
    //   brand: "MAC",
    //   name: "MAC Studio Fix Fluid SPF 15 Foundation NC45",
    //   finish: "Liquid • Matte",
    //   undertone: "warm",
    //   price: "₹4000",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61C6pWq9rQL._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p9",
    //   brand: "MAC",
    //   name: "MAC Studio Radiance Serum‑Powered Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "warm",
    //   price: "₹3200-3500",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61gk7yKqXIL._SL1500_.jpg",
    // ),
    // Product(
    //   id: "10",
    //   brand: "MAC",
    //   name: "MAC Studio Fix Powder Plus Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "warm",
    //   price: "₹2700-3400",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/71Kk1u0FQmL._SL1500_.jpg",
    // ),
    Product(
      id: "p11",
      brand: "L'Oréal Paris",
      name: "Infallible Fresh Wear",
      finish: "Liquid • Longwear",
      undertone: "Warm",
      price: "₹899",
imageUrl: "assets/p11.jpeg"
    ),
    Product(
      id: "p12",
      brand: "L'Oréal Paris",
      name: "L'Oréal Paris Infallible 24H Matte Cover Liquid Foundation",
      finish: "Liquid • Longwear",
      undertone: "Warm",
      price: "₹521-899",
imageUrl: "assets/p12.jpeg"
    ),
    // Product(
    //   id: "p13",
    //   brand: "L'Oréal Paris",
    //   name: "L'Oréal Paris Infallible 24H Matte Cover Liquid Foundation",
    //   finish: "Liquid • Longwear",
    //   undertone: "Warm",
    //   price: "₹755",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61n8rR7yYJL._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p14",
    //   brand: "L'Oréal Paris",
    //   name: "L'Oréal Paris Infallible 32H Fresh Wear Foundation",
    //   finish: "Liquid • Longwear",
    //   undertone: "Warm",
    //   price: "₹499-1249",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61yOe5fWmHL._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p15",
    //   brand: "L'Oréal Paris",
    //   name: "L'Oréal Paris True Match Super‑Blendable Foundation",
    //   finish: "Liquid • Longwear",
    //   undertone: "Warm",
    //   price: "₹837-1390",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61tFh8y4uPL._SL1500_.jpg",
    // ),
    Product(
      id: "p16",
      brand: "M·A·C",
      name: "Studio Fix Fluid",
      finish: "Liquid • Matte",
      undertone: "Cool",
      price: "₹3499",
    imageUrl: "assets/p16.jpeg"
    ),
    Product(
      id: "p17",
      brand: "M·A·C",
      name: "Studio Fix Fluid",
      finish: "Liquid • Matte",
      undertone: "Cool",
      price: "₹3400",
    imageUrl: "assets/p16.jpeg"
    ),
    // Product(
    //   id: "p18",
    //   brand: "M·A·C",
    //   name: "Studio Fix Fluid",
    //   finish: "Liquid • Matte",
    //   undertone: "Cool",
    //   price: "₹3400",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61dQhZB5qQL._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p19",
    //   brand: "M·A·C",
    //   name: "Studio Fix Fluid",
    //   finish: "Liquid • Matte",
    //   undertone: "Cool",
    //   price: "₹3400-4000",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61Y3+3+LkML._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p20",
    //   brand: "M·A·C",
    //   name: "Studio Fix Fluid",
    //   finish: "Liquid • Matte",
    //   undertone: "Cool",
    //   price: "₹3440-4300",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61gk7yKqXIL._SL1500_.jpg",
    // ),
    Product(
      id: "p21",
      brand: "L'Oréal Paris",
      name: "L'Oréal Paris True Match Super‑Blendable Liquid Foundation",
      finish: "Liquid • Matte",
      undertone: "Cool",
      price: "₹988-1200",
     imageUrl: "assets/p21.jpeg"

    ),

Product(
      id: "p22",
      brand: "L'Oréal Paris",
      name: "L'Oreal Paris True Match Super‑Blendable Foundation",
      finish: "Liquid • Matte",
      undertone: "Cool",
      price: "₹899-109",
    imageUrl: "assets/p22.jpeg"

    ),

// Product(
//       id: "p23",
//       brand: "L'Oréal Paris",
//       name: "L'Oreal Paris Infallible 32H Matte Cover Liquid Foundation",
//       finish: "Liquid • Matte",
//       undertone: "Cool",
//       price: "₹700-899",
//       imageUrl:
//           "https://m.media-amazon.com/images/I/61gk7yKqXIL._SL1500_.jpg",
//     ),

// Product(
//       id: "p24",
//       brand: "L'Oréal Paris",
//       name: "L'Oreal Paris Infallible 32H Matte Cover Liquid Foundation",
//       finish: "Liquid • Matte",
//       undertone: "Cool",
//       price: "₹674-899",
//       imageUrl:
//           "https://m.media-amazon.com/images/I/61n8rR7yYJL._SL1500_.jpg",
//     ),

// Product(
//       id: "p25",
//       brand: "L'Oréal Paris",
//       name: "L'Oreal Paris Infallible 32H Matte Cover Liquid Foundation",
//       finish: "Liquid • Matte",
//       undertone: "Cool",
//       price: "₹629-899",
//       imageUrl:
//           "https://m.media-amazon.com/images/I/61R8i9sF3ZL._SL1500_.jpg",
//     ),
    Product(
      id: "p26",
      brand: "L'Oréal Paris",
      name: "L'Oréal Paris True Match Super‑Blendable Liquid Foundation",
      finish: "Liquid • Matte",
      undertone: "Neutral",
      price: "₹899 – ₹1,099",
imageUrl: "assets/p26.jpeg"
    ),
    Product(
      id: "p27",
      brand: "L'Oréal Paris",
      name: "L'Oréal Paris True Match Super‑Blendable Liquid Foundation",
      finish: "Liquid • Matte",
      undertone: "Neutral",
      price: "₹899 – ₹1,099",
imageUrl: "assets/p27.jpeg"
    ),
    // Product(
    //   id: "p28",
    //   brand: "L'Oréal Paris",
    //   name: "L'Oréal Paris True Match Super‑Blendable Liquid Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "Neutral",
    //   price: "₹899-1099",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61E0pHcF+UL._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p29",
    //   brand: "L'Oréal Paris",
    //   name: "L'Oréal Paris True Match Super‑Blendable Liquid Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "Neutral",
    //   price: "₹899-1099",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61N1s9y9c8L._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p30",
    //   brand: "L'Oréal Paris",
    //   name: "L'Oréal Paris True Match Super‑Blendable Liquid Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "Neutral",
    //   price: "₹813-1099",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61+qC4Xx0XL._SL1500_.jpg",
    // ),
    Product(
      id: "p31",
      brand: "M·A·C",
      name: "M.A.C Studio Fix Fluid SPF 15 Soft Matte FoundationStudio Fix Fluid",
      finish: "Liquid • Matte",
      undertone: "Neutral",
      price: "₹3400",
imageUrl: "assets/p31.jpeg"
    ),
    Product(
      id: "p32",
      brand: "M·A·C",
      name: "MAC Studio Radiance Serum‑Powered Foundation",
      finish: "Liquid • Matte",
      undertone: "Neutral",
      price: "₹3200-4300",
imageUrl: "assets/p32.jpeg"
    ),
    // Product(
    //   id: "p33",
    //   brand: "M·A·C",
    //   name: "M.A.C Studio Fix Powder Plus Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "Neutral",
    //   price: "₹3025",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/71Kk1u0FQmL._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p34",
    //   brand: "M·A·C",
    //   name: "MAC Pro Longwear Nourishing Waterproof Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "Neutral",
    //   price: "₹10798",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61k1s9Y0q4L._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p35",
    //   brand: "M·A·C",
    //   name: "M.A.C Studio Fix Fluid Mini Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "Neutral",
    //   price: "₹2250",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61uR8nE5g3L._SL1500_.jpg",
    // ),
    Product(
      id: "p36",
      brand: "Maybelline",
      name: "Maybelline New York Fit Me Matte + Poreless Liquid Foundation",
      finish: "Liquid • Matte",
      undertone: "cool",
      price: "₹471",
    imageUrl: "assets/p36.jpeg"

    ),
    Product(
      id: "p37",
      brand: "Maybelline",
      name: "Maybelline Super Stay Full Coverage Foundation",
      finish: "Liquid • Matte",
      undertone: "cool",
      price: "₹76",
    imageUrl: "assets/p37.jpeg"

    ),
    // Product(
    //   id: "p38",
    //   brand: "Maybelline",
    //   name: "Maybelline New York Super Stay Lumi‑Matte Liquid Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "cool",
    //   price: "₹3660",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61dQhZB5qQL._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p39",
    //   brand: "Maybelline",
    //   name: "Maybelline Fit Me Dewy + Smooth Liquid Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "cool",
    //   price: "₹1699",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61h6jFjKJLL._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p40",
    //   brand: "Maybelline",
    //   name: "Maybelline Fit Me Matte + Poreless Liquid Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "Neutral",
    //   price: "₹369",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61vM4M1oLQL._SL1500_.jpg",
    // ),
    Product(
      id: "p41",
      brand: "Maybelline",
      name: "Maybelline Fit Me Matte + Poreless Liquid Foundation",
      finish: "Liquid • Matte",
      undertone: "Neutral",
      price: "₹325",
    imageUrl: "assets/p41.jpeg"

    ),
    Product(
      id: "p42",
      brand: "Maybelline",
      name: "Maybelline Fit Me Matte + Poreless Liquid Foundation",
      finish: "Liquid • Matte",
      undertone: "Neutral",
      price: "₹471",
    imageUrl: "assets/p42.jpeg"

    ),
    // Product(
    //   id: "p43",
    //   brand: "Maybelline",
    //   name: "Maybelline Fit Me Matte + Poreless Liquid Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "Neutral",
    //   price: "₹478",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61h6jFjKJLL._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p44",
    //   brand: "Maybelline",
    //   name: "Maybelline Super Stay Lumi‑Matte Liquid Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "Neutral",
    //   price: "₹660",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61dQhZB5qQL._SL1500_.jpg",
    // ),
    // Product(
    //   id: "p45",
    //   brand: "Maybelline",
    //   name: "Maybelline New York Fit Me Matte + Poreless Liquid Foundation",
    //   finish: "Liquid • Matte",
    //   undertone: "Neutral",
    //   price: "₹369",
    //   imageUrl:
    //       "https://m.media-amazon.com/images/I/61DjL4Y7tPL._SL1500_.jpg",
    // ),
  ];
  @override
  Widget build(BuildContext context) {
    final items = _allProducts
        .where((p) => p.undertone.toLowerCase() == undertone.toLowerCase())
        .toList();

    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Foundations ($undertone)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              final state = AppScope.of(context);
              final userId = state.currentUser?['id'];

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: userId),
                ),
              );
            },
          ),
          IconButton(
            tooltip: "Wishlist",
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                "No products available for $undertone undertone.",
                textAlign: TextAlign.center,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, i) {
                  final p = items[i];
                  final liked = state.isWishlisted(p);

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                                child: Image.network(
                                  p.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, error, stack) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: InkWell(
                                  onTap: () => state.toggleWishlist(p),
                                  child: Icon(
                                    liked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: liked ? Colors.pink : Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.brand,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(p.name,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(
                                "${p.finish} • ${p.undertone}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                p.price,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
/* =========================================================
   WISHLIST PAGE
========================================================= */
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Wishlist")),
      body: state.wishlist.isEmpty
          ? const Center(
              child: Text(
                "No items saved.\nTap ❤️ on the product to add wishlist.",
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: state.wishlist.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = state.wishlist[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 16,
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          p.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              width: 72,
                              height: 72,
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.brand,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 2),
                            Text(
                              p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${p.finish} • ${p.undertone} • ${p.price}",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.55)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: "Remove",
                        onPressed: () => state.remove(p),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

/* =========================================================
   UI HELPERS
========================================================= */
class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _SegmentToggle extends StatelessWidget {
  final String left;
  final String right;
  final bool leftSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  const _SegmentToggle({
    required this.left,
    required this.right,
    required this.leftSelected,
    required this.onLeft,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _SegBtn(label: left, selected: leftSelected, onTap: onLeft)),
          Expanded(child: _SegBtn(label: right, selected: !leftSelected, onTap: onRight)),
        ],
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.black : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _shift(Color c, {int r = 0, int g = 0, int b = 0}) {
  int clamp(int v) => v < 0 ? 0 : (v > 255 ? 255 : v);
  return Color.fromARGB(
    255,
    clamp(c.red + r),
    clamp(c.green + g),
    clamp(c.blue + b),
  );
}     