import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> serviceData;
  const DetailScreen({super.key, required this.serviceData});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // State untuk checkbox layanan
  final List<Map<String, dynamic>> _serviceOptions = [
    {'name': 'Cuci Kering', 'price': 5000, 'selected': false},
    {'name': 'Cuci + Setrika', 'price': 7000, 'selected': true},
    {'name': 'Setrika', 'price': 4000, 'selected': false},
  ];

  // State untuk berat
  int _weight = 1;

  void _addToCart() async {
    // TODO: Implementasi Supabase Insert ke tabel 'cart'
    /*
      Contoh logika:
      final supabase = Supabase.instance.client;
      final selectedServices = _serviceOptions.where((s) => s['selected']).toList();
      
      await supabase.from('cart').insert({
        'user_id': supabase.auth.currentUser!.id,
        'laundry_id': widget.serviceData['id'],
        'weight': _weight,
        'services': selectedServices,
      });
    */
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil ditambahkan ke keranjang!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // Hero Image
          Image.network(
            widget.serviceData['image_url'] ?? 'https://picsum.photos/seed/laundry_hero/500/300',
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Toko
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.serviceData['name'] ?? 'Laundry Express', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          Text('${widget.serviceData['rating'] ?? '4.8'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.serviceData['price_subtitle'] ?? 'Mulai Rp 7.000 / kg', style: const TextStyle(fontSize: 16, color: Color(0xFF2E3192), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 16),

                  // Pilih Layanan (Checkboxes)
                  const Text('Pilih Layanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._serviceOptions.map((option) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFF2E3192),
                      title: Text(option['name']),
                      subtitle: Text('Rp ${option['price']} / kg', style: const TextStyle(color: Colors.grey)),
                      value: option['selected'],
                      onChanged: (bool? value) {
                        setState(() {
                          option['selected'] = value ?? false;
                        });
                      },
                    );
                  }).toList(),
                  
                  const SizedBox(height: 24),
                  
                  // Kuantitas/Berat
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Berat (kg)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('(Min. 1kg)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (_weight > 1) setState(() => _weight--);
                              },
                            ),
                            Text('$_weight', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => setState(() => _weight++),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Action
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: ElevatedButton(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E3192),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('+ Tambah ke Keranjang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}