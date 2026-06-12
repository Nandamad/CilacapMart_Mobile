import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DashboardScreen.dart'; // <-- Import file dashboard kamu

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // ===== FUNGSI LOGIN (Sesuai kodemu tanpa role) =====
  Future<void> _handleLogin() async {
    if (_loginController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email/Username dan Password wajib diisi'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Response response = await Dio().post(
        'http://localhost:8080/api/login', // Pastikan ganti ke IP komputermu jika di-run di HP fisik (misal: 192.168.1.x)
        data: {
          'login': _loginController.text,
          'password': _passwordController.text,
        },
      );

      print("STATUS: ${response.statusCode}");
      print("DATA: ${response.data}");

      if (response.data['status'] == 1) {
        final prefs = await SharedPreferences.getInstance();

        // Simpan data tanpa role
        await prefs.setInt('id', response.data['data']['id']);
        await prefs.setString('username', response.data['data']['username']);
        await prefs.setString('email', response.data['data']['email']);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigasi langsung diarahkan ke DashboardScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Login gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on DioException catch (e) {
      print("ERROR DIO: $e");

      String pesan = 'Login gagal, terjadi kesalahan jaringan';
      if (e.response != null) {
        pesan = e.response?.data['message'] ?? 'Terjadi kesalahan pada server';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===== TAMPILAN UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003A6A), // Warna biru gelap header sesuai gambar
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- BAGIAN HEADER (BIRU) ---
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Column(
                children: [
                  // TODO: Nanti buka comment ini dan masukkan gambar logomu
                  /*
                  Image.asset(
                    'assets/images/logo.png', // Ganti path sesuai asetmu
                    height: 80,
                  ),
                  */
                  
                  // Placeholder sementara karena logo di-comment
                  const Icon(Icons.eco, size: 60, color: Colors.amber), 
                  const SizedBox(height: 10),
                  const Text(
                    'CilacapMart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Belanja Lokal bangga produk lokal.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // --- BAGIAN FORM (PUTIH) ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Form
                      const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF0A6B74), // Warna teal gelap
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input Email / Username
                      _buildTextField(
                        controller: _loginController,
                        hintText: 'Email or Username',
                        icon: Icons.mail_outline,
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        icon: Icons.key_outlined,
                        isPassword: true,
                      ),
                      const SizedBox(height: 8),

                      // Lupa Password & Belum Punya Akun (Rata Kanan)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {}, // Aksi lupa password
                              child: const Text(
                                'Lupa Password?',
                                style: TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {}, // Aksi daftar akun
                              child: const Text(
                                'Belum Punya Akun?',
                                style: TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Login
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D6EFD), // Warna biru terang
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Divider "Atau Login dengan"
                      Row(
                        children: const [
                          Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Atau Login dengan',
                              style: TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ),
                          Expanded(child: Divider(thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tombol Login Google
                      _buildSocialButton(
                        text: 'Sign with Google',
                        iconWidget: const Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),

                      // Tombol Login Apple
                      _buildSocialButton(
                        text: 'Sign with Apple',
                        iconWidget: const Icon(Icons.apple, color: Colors.black, size: 24),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget bantuan untuk Text Field agar rapi dan tidak mengulang kode
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50], // Background agak abu-abu terang
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.black45, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.black45,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // Widget bantuan untuk tombol sosial (Google / Apple)
  Widget _buildSocialButton({
    required String text,
    required Widget iconWidget,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          side: BorderSide(color: Colors.grey[400]!), // Garis border abu-abu
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}