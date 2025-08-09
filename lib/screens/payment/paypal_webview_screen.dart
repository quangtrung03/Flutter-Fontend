import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/paypal_service.dart';
import '../../utils/currency_helper.dart';

class PayPalWebViewScreen extends StatefulWidget {
  final String approvalUrl;
  final String orderId;
  final double amount;
  final Function(bool success, String? error) onPaymentComplete;

  const PayPalWebViewScreen({
    Key? key,
    required this.approvalUrl,
    required this.orderId,
    required this.amount,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<PayPalWebViewScreen> createState() => _PayPalWebViewScreenState();
}

class _PayPalWebViewScreenState extends State<PayPalWebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    print('🔄 Initializing PayPal WebView with URL: ${widget.approvalUrl}');
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🔄 PayPal WebView loading: $url');
            _handleUrlChange(url);
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            print('✅ PayPal WebView loaded: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ PayPal WebView error: ${error.description}');
            setState(() {
              isLoading = false;
            });
            if (!isProcessing) {
              widget.onPaymentComplete(false, 'Lỗi tải trang PayPal: ${error.description}');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🔍 Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  void _handleUrlChange(String url) {
    print('🔍 PayPal URL changed: $url');
    
    if (isProcessing) {
      print('⚠️ Already processing payment, ignoring URL change');
      return;
    }
    
    // Check if user approved payment (success callback)
    if (url.contains('mobilenc://payment/success') || 
        url.contains('/paypal/success') ||
        (url.contains('10.0.2.2:5000') && url.contains('success')) ||
        (url.contains('mobilenc.onrender.com') && url.contains('success')) ||
        (url.contains('success') && url.contains('paymentId'))) {
      print('✅ PayPal payment approved, extracting details...');
      _extractPaymentDetails(url);
    }
    // Check if user cancelled payment
    else if (url.contains('mobilenc://payment/cancel') || 
             url.contains('/paypal/cancel') ||
             (url.contains('10.0.2.2:5000') && url.contains('cancel')) ||
             (url.contains('mobilenc.onrender.com') && url.contains('cancel')) ||
             url.contains('cancel') || url.contains('cancelled')) {
      print('❌ PayPal payment cancelled by user');
      if (!isProcessing) {
        setState(() => isProcessing = true);
        Navigator.of(context).pop();
        widget.onPaymentComplete(false, 'Thanh toán đã bị hủy bởi người dùng');
      }
    }
    // Check for error
    else if (url.contains('error')) {
      print('❌ PayPal payment error in URL');
      if (!isProcessing) {
        setState(() => isProcessing = true);
        Navigator.of(context).pop();
        widget.onPaymentComplete(false, 'Có lỗi xảy ra trong quá trình thanh toán');
      }
    }
  }

  void _extractPaymentDetails(String url) async {
    if (isProcessing) return;
    
    setState(() => isProcessing = true);
    
    try {
      print('🎯 Extracting payment details from: $url');
      
      final uri = Uri.parse(url);
      final paymentId = uri.queryParameters['paymentId'] ?? uri.queryParameters['paymentID'];
      final payerId = uri.queryParameters['PayerID'] ?? uri.queryParameters['payerId'];
      final token = uri.queryParameters['token'];
      
      print('💳 Payment details extracted:');
      print('  - PaymentId: $paymentId');
      print('  - PayerId: $payerId');
      print('  - Token: $token');

      if (paymentId != null && payerId != null) {
        Navigator.of(context).pop();
        await _capturePayment(paymentId, payerId);
      } else {
        print('❌ Missing required payment details in callback URL');
        Navigator.of(context).pop();
        widget.onPaymentComplete(false, 'Thiếu thông tin thanh toán trong callback');
      }
    } catch (e) {
      print('❌ Error extracting payment details: $e');
      Navigator.of(context).pop();
      widget.onPaymentComplete(false, 'Lỗi xử lý thông tin thanh toán: $e');
    }
  }

  Future<void> _capturePayment(String paymentId, String payerId) async {
    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Đang xử lý thanh toán...'),
              const SizedBox(height: 8),
              Text(
                'Số tiền: ${CurrencyHelper.formatUSD(widget.amount)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    try {
      print('🔄 Capturing PayPal payment...');
      print('  - PaymentId: $paymentId');
      print('  - PayerId: $payerId');
      print('  - Amount: ${widget.amount} USD');

      final success = await PayPalService.capturePayPalPayment(
        paymentId: paymentId,
        payerId: payerId,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (success) {
        // ✅ Cập nhật order sau khi capture thành công
        final orderUpdated = await PayPalService.updateOrderAfterPayment(
          orderId: widget.orderId,
          paymentId: paymentId,
          payerId: payerId,
        );

        if (orderUpdated) {
          print('✅ PayPal payment captured and order updated successfully');
          widget.onPaymentComplete(true, null);
        } else {
          print('⚠️ PayPal payment captured but order update failed');
          widget.onPaymentComplete(true, null); // Still success for user
        }
      } else {
        print('❌ PayPal payment capture failed');
        widget.onPaymentComplete(false, 'Xác nhận thanh toán thất bại');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }
      print('❌ Error capturing PayPal payment: $e');
      widget.onPaymentComplete(false, 'Lỗi xác nhận thanh toán: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal Payment'),
        backgroundColor: const Color(0xFF0070BA), // PayPal blue
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (!isProcessing) {
              Navigator.of(context).pop();
              widget.onPaymentComplete(false, 'Thanh toán đã bị hủy');
            }
          },
        ),
        actions: [
          if (isProcessing)
            Container(
              margin: const EdgeInsets.all(8),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0070BA)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải PayPal...',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vui lòng đợi trong giây lát',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Đang xử lý thanh toán...',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Vui lòng không đóng ứng dụng',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            const Icon(Icons.security, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Giao dịch được bảo mật bởi PayPal',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Text(
              CurrencyHelper.formatUSD(widget.amount),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0070BA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
