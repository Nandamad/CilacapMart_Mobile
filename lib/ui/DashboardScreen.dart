import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  // Variabel state untuk menampung data dari database
  List<dynamic> _listBarang = [];
  bool _isLoadingBarang = true;

  @override
  void initState() {
    super.initState();
    _fetchDataBarang(); // Panggil API saat halaman dibuka
  }

  // Fungsi untuk mengambil data barang dari CI4
  Future<void> _fetchDataBarang() async {
    try {
      // Sesuaikan URL dengan IP/Localhost kamu.
      // Jika pakai emulator Android: http://10.0.2.2:8080/api/barang
      // Jika pakai HP fisik: http://192.168.x.x:8080/api/barang
      Response response = await Dio().get('http://localhost:8080/api/barang');

      setState(() {
        // Cek struktur JSON dari CI4 kamu.
        // Jika CI4 me-return langsung array: _listBarang = response.data;
        // Jika dibungkus object 'data': _listBarang = response.data['data'];
        if (response.data is List) {
           _listBarang = response.data;
        } else if (response.data['data'] != null) {
           _listBarang = response.data['data'];
        }
        _isLoadingBarang = false;
      });
    } catch (e) {
      print("Error ambil data barang: $e");
      setState(() {
        _isLoadingBarang = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildBanner(),
                const SizedBox(height: 24),
                _buildCategorySection(),
                const SizedBox(height: 24),
                _buildPopularSection(),
                const SizedBox(height: 16),
                _buildProductGrid(), // <-- Grid ini sekarang dinamis memanggil _listBarang
                const SizedBox(height: 20), 
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- WIDGET HEADER ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.location_on_outlined, size: 24),
            SizedBox(width: 4),
            Text(
              'Cilacap, jawatengah',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, size: 28),
              onPressed: () {},
            ),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFD9E2EC),
              child: Icon(Icons.person_outline, size: 20, color: Colors.black87),
            ),
          ],
        )
      ],
    );
  }

  // --- WIDGET SEARCH BAR ---
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF325A82), 
        borderRadius: BorderRadius.circular(25),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari',
          hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // --- WIDGET BANNER ---
  Widget _buildBanner() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=800&q=80'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Cari Info Terbaru Disini !',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Dapatkan Informasi terbaru dan kekinian\nyang super update hanya disini!',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4C5B79).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'sedang hits',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KATEGORI ---
  Widget _buildCategorySection() {
    final categories = [
      {'name': 'Makanan', 'img': 'https://images.unsplash.com/photo-1550461716-dbf266b2a8a7?w=200&q=80'},
      {'name': 'Minuman', 'img': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=200&q=80'},
      {'name': 'Kerajinan', 'img': 'https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?w=200&q=80'},
      {'name': 'Busana', 'img': 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=200&q=80'},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Icon(Icons.arrow_forward, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: categories.map((cat) {
            return Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(cat['img']!),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name']!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                )
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- WIDGET POPULER FILTER ---
  Widget _buildPopularSection() {
    final filters = ['varian', 'varian', 'varian', 'varian'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Populer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(filters.length, (index) {
              bool isSelected = index == 0; 
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1B4965) : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 12,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // --- WIDGET GRID PRODUK DINAMIS ---
  Widget _buildProductGrid() {
    if (_isLoadingBarang) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_listBarang.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Belum ada produk.'),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), 
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75, // Mengatur rasio agar nama & harga muat
      ),
      itemCount: _listBarang.length,
      itemBuilder: (context, index) {
        final barang = _listBarang[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: Colors.grey[200],
                    image: barang['gambar'] != null && barang['gambar'] != ''
                      ? DecorationImage(
                          // Pastikan folder penyimpanan gambarmu sesuai ('/uploads/...')
                          image: NetworkImage('http://localhost:8080/img/${barang['gambar']}'), 
                          fit: BoxFit.cover,
                        )
                      : null,
                  ),
                  child: (barang['gambar'] == null || barang['gambar'] == '')
                    ? const Center(child: Icon(Icons.image, size: 40, color: Colors.grey))
                    : null, 
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom nama_barang dari CI4
                    Text(
                      barang['nama_barang'] ?? 'Tanpa Nama',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Kolom harga_jual dari CI4
                    Text(
                      'Rp ${barang['harga_jual'] ?? 0}',
                      style: const TextStyle(
                        color: Color(0xFF0D6EFD), 
                        fontWeight: FontWeight.w600, 
                        fontSize: 13
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET BOTTOM NAV BAR ---
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: const Color(0xFF1B4965),
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 28), activeIcon: Icon(Icons.home, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline, size: 28), label: ''),
        ],
      ),
    );
  }
}