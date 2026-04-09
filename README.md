# 🔥 Gas Monitor — Simon House IoT

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![MQTT](https://img.shields.io/badge/MQTT-TLS%208883-660066?style=for-the-badge&logo=eclipse-mosquitto&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**Hệ thống giám sát rò rỉ khí gas thời gian thực, sử dụng cảm biến MQ-5 kết hợp giao thức MQTT.**  
Cảnh báo tức thì qua push notification khi phát hiện nguy hiểm.

[📱 Flutter App](#-flutter-app) · [🌐 Web Dashboard](#-web-dashboard-giamsatgashtml) · [⚙️ Cài đặt](#️-cài-đặt--chạy-dự-án) · [🏗️ Kiến trúc](#️-kiến-trúc-hệ-thống)

</div>

---

## 📖 Giới thiệu

**Gas Monitor** là dự án IoT thuộc hệ sinh thái **Simon House** — giám sát nồng độ khí gas (LPG/CH4) trong nhà theo thời gian thực.

Dữ liệu từ cảm biến **MQ-5** được gửi lên **MQTT broker** (`broker.emqx.io`), ứng dụng nhận và hiển thị ngay lập tức. Khi nồng độ gas vượt ngưỡng nguy hiểm, hệ thống tự động:
- 🔔 Bắn **push notification** trên điện thoại
- 📳 **Rung** thiết bị (mobile/web)
- 🔴 Đổi màu giao diện thành **đỏ cảnh báo**

| Trạng thái | Màu | Ý nghĩa |
|---|---|---|
| 🟢 An toàn | Xanh lá | Nồng độ gas bình thường |
| 🟡 Đang kết nối | Cam | Chờ dữ liệu từ server |
| 🔴 Nguy hiểm | Đỏ nhấp nháy | Phát hiện rò rỉ khí gas |

---

## 🏗️ Kiến trúc hệ thống

```
┌─────────────┐        MQTT (TLS)        ┌──────────────────────┐
│  Cảm biến   │  ──────────────────────► │  broker.emqx.io      │
│    MQ-5     │  topic: simon_house/gas/ │  Port 8883 (TLS)     │
│  (Hardware) │                          │  Port 8084 (WSS Web) │
└─────────────┘                          └──────────┬───────────┘
                                                    │
                          ┌─────────────────────────┤
                          │                         │
              ┌───────────▼──────────┐  ┌───────────▼──────────┐
              │   Flutter App        │  │  Web Dashboard       │
              │  Android / iOS       │  │  GiamSatGas.html     │
              │  Push Notification   │  │  GitHub Pages        │
              └──────────────────────┘  └──────────────────────┘
```

### MQTT Topics

| Topic | Dữ liệu | Ví dụ |
|---|---|---|
| `simon_house/gas/value` | Nồng độ gas (ppm) | "450" |
| `simon_house/gas/alert` | Trạng thái cảnh báo | "An toan" / "CANH BAO RO RI" |

---

## 📱 Flutter App

Ứng dụng đa nền tảng xây dựng bằng **Flutter**, kết nối MQTT qua **TLS port 8883** — an toàn, mã hoá đầu cuối.

### ✨ Tính năng

- ✅ Hiển thị nồng độ gas **realtime** (đơn vị ppm)
- ✅ Push notification độ ưu tiên cao khi phát hiện rò rỉ
- ✅ Giao diện đổi màu động theo mức độ nguy hiểm
- ✅ Tự động **reconnect** khi mất mạng
- ✅ Bật/tắt thông báo ngay trên app (toggle switch)
- ✅ Hỗ trợ: **Android, iOS, Web, Desktop**

### 📦 Tech Stack

| Thư viện | Phiên bản | Mục đích |
|---|---|---|
| `flutter` | stable | UI Framework |
| `mqtt_client` | ^10.11.9 | Kết nối MQTT TLS |
| `flutter_local_notifications` | ^17.2.4 | Push notification |
| `permission_handler` | ^11.4.0 | Xin quyền thông báo |

---

## 🌐 Web Dashboard (`GiamSatGas.html`)

Trang web nhẹ, không cần cài đặt — chạy thẳng trên trình duyệt hoặc deploy lên **GitHub Pages**.

### ✨ Tính năng

- ✅ Kết nối MQTT qua **WebSocket Secure (WSS port 8084)**
- ✅ Hiển thị nồng độ gas realtime
- ✅ Hiệu ứng nhấp nháy đỏ khi có cảnh báo
- ✅ Rung trình duyệt (trên thiết bị hỗ trợ)
- ✅ Không phụ thuộc backend — chạy thuần HTML/JS

### 🚀 Truy cập nhanh

Trang web đã được deploy tại:  
👉 **https://nguyenchan2005.github.io/checkgas/**

---

## ⚙️ Cài đặt & Chạy dự án

### Yêu cầu hệ thống

- [Flutter SDK](https://docs.flutter.dev/get-started/install) phiên bản **stable** (>= 3.x)
- Dart SDK (đi kèm Flutter)
- Android Studio **hoặc** VS Code với extension Flutter

### Bước 1 — Clone repo

```bash
git clone https://github.com/Nguyenchan2005/checkgas.git
cd checkgas
```

### Bước 2 — Cài dependencies

```bash
flutter pub get
```

### Bước 3 — Chạy app

```bash
# Android / iOS
flutter run

# Web
flutter run -d chrome

# Desktop (Windows/macOS/Linux)
flutter run -d windows   # hoặc macos, linux
```

### Chạy Web Dashboard (không cần Flutter)

```bash
# Mở trực tiếp bằng trình duyệt
open GiamSatGas.html

# Hoặc dùng live server (VS Code extension)
```

---

## 📁 Cấu trúc thư mục

```
checkgas/
├── lib/
│   └── main.dart              # Toàn bộ logic Flutter app
├── android/                   # Cấu hình Android native
├── ios/                       # Cấu hình iOS native (Swift)
├── web/                       # Cấu hình Flutter Web
├── windows/                   # Cấu hình Windows desktop
├── linux/                     # Cấu hình Linux desktop
├── macos/                     # Cấu hình macOS desktop
├── GiamSatGas.html            # Web dashboard độc lập
├── pubspec.yaml               # Dependencies Flutter
└── README.md                  # File này
```

---

## 🔧 Cấu hình MQTT

Mặc định dự án dùng **EMQX Public Broker** (miễn phí, không cần tài khoản):

| Tham số | Giá trị |
|---|---|
| Broker | `broker.emqx.io` |
| Port (Flutter/Native) | `8883` (MQTT over TLS) |
| Port (Web) | `8084` (MQTT over WSS) |
| Topic nhận giá trị | `simon_house/gas/value` |
| Topic nhận cảnh báo | `simon_house/gas/alert` |

> 💡 **Muốn đổi broker?** Chỉnh sửa biến `broker` và `port` trong `lib/main.dart`.

---

## 🤝 Đóng góp

Pull request và issue luôn được chào đón!

1. Fork repo này
2. Tạo branch mới: `git checkout -b feature/ten-tinh-nang`
3. Commit: `git commit -m 'feat: thêm tính năng X'`
4. Push: `git push origin feature/ten-tinh-nang`
5. Mở Pull Request

---

## 👨‍💻 Tác giả

**Nguyenchan2005**  
🔗 [github.com/Nguyenchan2005](https://github.com/Nguyenchan2005)

---

<div align="center">
Made with ❤️ for Simon House IoT Project
</div>
