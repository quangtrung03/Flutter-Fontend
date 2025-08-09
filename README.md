# Mobile Coffee Shop App

Ứng dụng di động quản lý quán cà phê với Flutter + Node.js

## 🚀 Backend Server

**Production Server:** https://mobilenc.onrender.com
- Server đã được deploy trên Render (free tier)
- Có thể mất 30-60 giây để "wake up" nếu không có traffic
- Tự động kết nối qua config, không cần setup backend local

## 📦 Quick Start

### 1. Clone repository
```bash
git clone https://github.com/tothaihao/MobileNC.git
cd MobileNC/MobileNC
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run app
```bash
flutter run
```

**Lưu ý:** App sẽ tự động kết nối với server production trên Render.

## 🔧 Environment Configuration

File `lib/config/app_config.dart` đã được cấu hình:

```dart
static const String currentEnv = _production; // Sử dụng Render server
```

### Nếu muốn chạy local backend:
1. Uncomment và thay đổi:
```dart
static const String currentEnv = _development;
```

2. Setup local backend:
```bash
cd TheCoffeeShop_BE/server
npm install
node server.js
```

## 📱 Platform Support

| Platform | Status | API URL |
|----------|--------|---------|
| Android Emulator | ✅ | `https://mobilenc.onrender.com/api` |
| Android Device | ✅ | `https://mobilenc.onrender.com/api` |
| iOS Simulator | ✅ | `https://mobilenc.onrender.com/api` |
| iOS Device | ✅ | `https://mobilenc.onrender.com/api` |

## 🎯 Features

### User Features
- 📝 Đăng ký/Đăng nhập
- ☕ Xem menu sản phẩm
- 🛒 Giỏ hàng
- 💳 Đặt hàng & thanh toán
- 📋 Lịch sử đơn hàng
- ⭐ Đánh giá sản phẩm
- 💬 Chat hỗ trợ

### Admin Features  
- 📊 Dashboard
- 🏷️ Quản lý sản phẩm
- 📦 Quản lý đơn hàng
- 👥 Quản lý user
- 📰 Quản lý blog
- 🎫 Quản lý voucher
- 🖼️ Quản lý banner

## 🐛 Troubleshooting

### Server "spinning up"
- Render free tier cần thời gian khởi động
- Chờ 30-60 giây và thử lại
- Kiểm tra: https://mobilenc.onrender.com

### Flutter issues
```bash
flutter clean
flutter pub get
flutter run
```

### Debug API calls
- Kiểm tra console output
- Xem network tab trong browser (nếu chạy web)

## 📞 Liên hệ

- **Repository:** https://github.com/tothaihao/MobileNC
- **Backend:** https://mobilenc.onrender.com
- **Branch:** trung

## 🎉 Ready to Go!

App đã sẵn sàng sử dụng với server production. Chỉ cần:
1. `git clone` → `flutter pub get` → `flutter run`
2. Chờ server khởi động (lần đầu)
3. Enjoy! ☕
