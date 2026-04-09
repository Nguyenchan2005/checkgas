# Gas Monitor

Repository này đang chứa hai phần tách biệt:

- Ứng dụng Flutter trong thư mục dự án hiện tại để chạy trên Android, iOS, desktop và Flutter Web.
- Trang web cũ `GiamSatGas.html` để giám sát gas trực tiếp trên trình duyệt.

## Flutter app

Ứng dụng Flutter nhận dữ liệu MQTT và hiển thị cảnh báo khí gas trên thiết bị.

### Yêu cầu

- Flutter stable
- Dart SDK đi kèm Flutter
- Android Studio hoặc VS Code có Flutter support

### Chạy local

```bash
flutter pub get
flutter run
```

## Web cũ

File `GiamSatGas.html` được giữ lại vì đây là phiên bản web riêng với app Flutter.

### Chạy nhanh

- Mở trực tiếp `GiamSatGas.html` bằng trình duyệt.
- Hoặc đưa file này lên một web host tĩnh nếu muốn dùng online.

## Ghi chú

- Các thư mục generate và file cấu hình máy local đã được loại khỏi version control.
- Nếu clone về mà thiếu file generate của Flutter, chỉ cần chạy `flutter pub get` rồi `flutter run`.
