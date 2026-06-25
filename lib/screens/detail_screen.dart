import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart_screen.dart';

class DetailScreen extends StatefulWidget {
  final String serviceId; // id layanan dari tabel `services` Supabase

  const DetailScreen({super.key, required this.serviceId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const primaryColor = Color(0xFF2E3192);

  int _quantity = 3;
  bool _isAddingToCart = false;

  final Map<String, bool> _selectedServices = {
    'Cuci Kering': false,
    'Cuci + Setrika': true,
    'Setrika': false,
  };
  final Map<String, int> _servicePrices = {
    'Cuci Kering': 5000,
    'Cuci + Setrika': 7000,
    'Setrika': 4000,
  };

  int get _totalPrice {
    int total = 0;
    _selectedServices.forEach((service, selected) {
      if (selected) {
        total += _servicePrices[service]! * _quantity;
      }
    });
    return total;
  }

  String _formatCurrency(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  // =======================================================
  // TAMBAH KE KERANJANG -> SIMPAN KE LOCAL CART DATA
  // =======================================================
  Future<void> _handleAddToCart() async {
    final selectedNames = _selectedServices.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedNames.isEmpty) {
      _showSnackBar('Pilih minimal satu layanan', isError: true);
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      // Add to local cart
      CartData.addItem({
        'service_names': selectedNames.join(', '),
        'weight_kg': _quantity,
        'total_price': _totalPrice,
      });

      _showSnackBar('Ditambahkan ke keranjang!', isError: false);
    } catch (e) {
      debugPrint('Gagal menambahkan ke cart: $e');
      _showSnackBar('Gagal menambahkan ke keranjang: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: isError ? Colors.red[400] : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A2E)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
              ),
              child: IconButton(
                icon: const Icon(Icons.favorite_border_rounded, size: 20, color: Color(0xFF1A1A2E)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fitur favorit akan segera hadir!', style: GoogleFonts.poppins(fontSize: 13)),
                      backgroundColor: primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(),
            _buildShopInfo(),
            _buildServiceSelection(),
            _buildQuantitySection(),
            const SizedBox(height: 12),
            _buildReviews(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?w=800&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.local_laundry_service, size: 80, color: Colors.grey),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFF2ECC71), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('Buka', style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laundry Express',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 4),
          Text(
            'Jl. Sudirman No. 42, Jakarta Pusat',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoBadge(icon: Icons.star_rounded, iconColor: const Color(0xFFFFB800), text: '4.7 (120 review)'),
              const SizedBox(width: 10),
              _InfoBadge(icon: Icons.access_time_rounded, iconColor: primaryColor, text: '1-2 Hari'),
              const SizedBox(width: 10),
              _InfoBadge(icon: Icons.location_on_outlined, iconColor: Colors.redAccent, text: '0.8 km'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('Mulai ', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
              Text(
                'Rp 7.000 / kg',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[100], thickness: 1.5),
        ],
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Layanan',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 12),
          Column(
            children: _selectedServices.entries.map((entry) {
              final isSelected = entry.value;
              return GestureDetector(
                onTap: () => setState(() => _selectedServices[entry.key] = !isSelected),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withOpacity(0.05) : const Color(0xFFF8F9FF),
                    border: Border.all(color: isSelected ? primaryColor : Colors.transparent, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.white,
                          border: Border.all(color: isSelected ? primaryColor : Colors.grey[300]!, width: 1.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isSelected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? primaryColor : const Color(0xFF1A1A2E),
                              ),
                            ),
                            if (isSelected)
                              Text(
                                'Estimasi 1-2 hari',
                                style: GoogleFonts.poppins(fontSize: 11, color: primaryColor.withOpacity(0.7)),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${_servicePrices[entry.key]}/kg',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? primaryColor : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FF), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Berat (kg)', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                Text('Min. 1kg', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _quantity > 1 ? Colors.white : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _quantity > 1 ? Colors.grey[200]! : Colors.transparent),
                    ),
                    child: Icon(Icons.remove_rounded, size: 18, color: _quantity > 1 ? const Color(0xFF1A1A2E) : Colors.grey[400]),
                  ),
                ),
                const SizedBox(width: 16),
                Text('$_quantity', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => setState(() => _quantity++),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey[100], thickness: 1.5),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ulasan Pelanggan', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fitur lihat semua ulasan akan segera hadir!', style: GoogleFonts.poppins(fontSize: 13)),
                      backgroundColor: primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: Text('Lihat Semua', style: GoogleFonts.poppins(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ReviewTile(name: 'Budi Santoso', rating: 5, comment: 'Hasilnya bersih banget dan tepat waktu. Sangat puas!', time: '2 hari lalu'),
          _ReviewTile(name: 'Sari Dewi', rating: 4, comment: 'Pelayanan bagus, harga terjangkau. Recommended!', time: '1 minggu lalu'),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500])),
                  Text(
                    _formatCurrency(_totalPrice),
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isAddingToCart ? null : _handleAddToCart,
                  icon: _isAddingToCart
                      ? const SizedBox.shrink()
                      : const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: _isAddingToCart
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          '+ Tambah ke Keranjang',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _InfoBadge({required this.icon, required this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FF), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final String name;
  final int rating;
  final String comment;
  final String time;

  const _ReviewTile({required this.name, required this.rating, required this.comment, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FF), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF2E3192).withOpacity(0.1),
                child: Text(name[0], style: const TextStyle(color: Color(0xFF2E3192), fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                    Row(
                      children: [
                        ...List.generate(rating, (_) => const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFB800))),
                        const SizedBox(width: 4),
                        Text(time, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[400])),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.5)),
        ],
      ),
    );
  }
}
