import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const primaryColor = Color(0xFF2E3192);

  String _selectedPayment = 'COD';
  String _selectedDate = 'Pilih Tanggal';
  String _selectedTime = 'Pilih Jam';
  String _deliveryAddress = 'Jl. Merdeka No. 10, Jakarta';

  Future<void> _processCheckout(int totalAmount) async {
    try {
      if (_selectedDate == 'Pilih Tanggal' || _selectedTime == 'Pilih Jam') {
        _showSnackBar('Pilih tanggal dan jam pengambilan', isError: true);
        return;
      }

      if (CartData.items.isEmpty) {
        _showSnackBar('Keranjang kosong', isError: true);
        return;
      }

      // Create local order
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final order = {
        'id': orderId,
        'total_amount': totalAmount,
        'status': 'Menunggu Persetujuan',
        'payment_method': _selectedPayment,
        'delivery_address': _deliveryAddress,
        'pickup_date': _selectedDate,
        'pickup_time': _selectedTime,
        'created_at': DateTime.now().toIso8601String(),
        'items': List.from(CartData.items),
      };

      // Add to order history
      OrderData.addOrder(order);

      // Clear cart
      CartData.clear();

      _showSnackBar('Pesanan berhasil dibuat!', isError: false);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/order-status',
            arguments: orderId);
      }
    } catch (e) {
      _showSnackBar('Gagal memproses checkout: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: isError ? Colors.red[400] : Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatCurrency(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = CartData.subtotal;
    int shipping = 5000;
    int finalTotal = totalPrice + shipping;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Color(0xFF1A1A2E)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alamat Pengiriman
            Text('Alamat Pengiriman',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rumah',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            )),
                        Text(_deliveryAddress,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[600],
                            )),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Fitur edit alamat akan segera hadir!', style: GoogleFonts.poppins(fontSize: 13)),
                          backgroundColor: primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    child: Text('Edit',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Jadwal Pickup
            Text('Jadwal Pickup & Jam',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate =
                              '${date.day}/${date.month}/${date.year}';
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[500],
                              )),
                          const SizedBox(height: 4),
                          Text(_selectedDate,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _selectedTime =
                              '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jam',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[500],
                              )),
                          const SizedBox(height: 4),
                          Text(_selectedTime,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Metode Pembayaran
            Text('Metode Pembayaran',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 12),
            ..._buildPaymentOptions(),
            const SizedBox(height: 24),

            // Total
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: GoogleFonts.poppins(fontSize: 12)),
                      Text(_formatCurrency(finalTotal),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Pesan Sekarang
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _processCheckout(finalTotal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Pesan Sekarang',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPaymentOptions() {
    final options = [
      {'name': 'COD', 'label': 'COD (Bayar di Tempat)', 'icon': Icons.local_shipping},
      {'name': 'E-Wallet', 'label': 'E-Wallet (OVO, GoPay, DANA)', 'icon': Icons.account_balance_wallet},
      {'name': 'Transfer', 'label': 'Transfer Bank', 'icon': Icons.account_balance},
    ];

    return options.map((option) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedPayment = option['name'] as String;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedPayment == option['name'] ? primaryColor.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _selectedPayment == option['name'] ? primaryColor : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Radio<String>(
                value: option['name'] as String,
                groupValue: _selectedPayment,
                onChanged: (value) {
                  setState(() {
                    _selectedPayment = value!;
                  });
                },
                activeColor: primaryColor,
              ),
              const SizedBox(width: 8),
              Icon(option['icon'] as IconData, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(option['label'] as String,
                  style: GoogleFonts.poppins(fontSize: 13)),
            ],
          ),
        ),
      );
    }).toList();
  }
}