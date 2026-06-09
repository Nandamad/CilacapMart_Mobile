import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk menangkap teks input pengguna
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Status boolean untuk fitur sembunyikan/perlihatkan password
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Skema Warna Konsisten sesuai Web CilacapMart Anda
  final Color navyBlue = const Color(0xFF003366);
  final Color backgroundColor = const Color(0xFFF4F4F4);

  // Fungsi penangan aksi tombol Login
  void _handleLogin() async {
    final String loginInput = _loginController.text.trim();
    final String passwordInput = _passwordController.text;

    if (loginInput.isEmpty || passwordInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email/Username dan Password wajib diisi.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // PENTING: Ganti 10.0.2.2 ke IP Laptop Anda jika uji coba menggunakan HP asli via Wi-Fi
      var response = await Dio().post(
        "http://10.0.2.2:8080/api/login",
        data: {"login": loginInput, "password": passwordInput},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        String userName = response.data['user']['username'] ?? 'User';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat datang kembali, $userName!'),
            backgroundColor: Colors.green,
          ),
        );
        // Arahkan ke halaman utama setelah login sukses
        // Navigator.pushReplacementNamed(context, '/home');
      }
    } on DioException catch (e) {
      String errMsg = "Terjadi kesalahan koneksi.";
      if (e.response != null && e.response?.data['message'] != null) {
        errMsg = e.response?.data['message'];
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errMsg), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 1. JUDUL DAN LOGO UTAMA ---
              Text(
                "Cilacap Mart",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: navyBlue,
                ),
              ),
              const SizedBox(height: 25),

              // Wadah Logo dengan latar belakang Biru Tua (Meniru login-image-column di Web)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: navyBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Image.network(
                  "http://10.0.2.2:8080/logo.png",
                  width: 80,
                  height: 80,
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.storefront,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- 2. INPUT USERNAME / EMAIL ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Masukkan Email atau Username",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _loginController,
                decoration: InputDecoration(
                  hintText: "Email atau Username",
                  prefixIcon: Icon(Icons.person, color: navyBlue),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- 3. INPUT PASSWORD ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Masukkan Password",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: Icon(Icons.lock, color: navyBlue),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // --- 4. TOMBOL LOG IN UTAMA ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navyBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "LOG IN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // --- 5. LINK NAVIGASI BAWAH ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed:
                        () {}, // Tambahkan navigasi register Anda di sini
                    child: Text(
                      "Belum Punya Akun?",
                      style: TextStyle(
                        color: navyBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () {}, // Tambahkan navigasi forgot password Anda di sini
                    child: Text(
                      "Lupa Password?",
                      style: TextStyle(
                        color: navyBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              // --- 6. DIVIDER SEPARATOR ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        "— Atau Login dengan —",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                  ],
                ),
              ),

              // --- 7. BUTTON SOCIAL MEDIA LOGIN ---
              // Google Login
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: 30,
                  color: Colors.red,
                ), // Mengganti dengan ikon Google bawaan / Asset jika ada
                label: const Text(
                  "Sign with Google",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                onPressed: () {}, // Pasang integrasi OAuth Google Flutter Anda
              ),
              const SizedBox(height: 12),

              // Apple Login
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                icon: const Icon(Icons.apple, size: 24, color: Colors.black),
                label: const Text(
                  "Sign with Apple",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                onPressed: () {}, // Pasang integrasi OAuth Apple Flutter Anda
              ),
            ],
          ),
        ),
      ),
    );
  }
}
