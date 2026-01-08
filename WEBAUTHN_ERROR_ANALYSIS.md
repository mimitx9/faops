# Phân Tích Lỗi WebAuthn Device Registration

## Lỗi
```
{"error":"Internal server error: Failed to save WebAuthn credential"}
```

## Request Body Được Gửi
```json
{
  "publicKeyCredentialId": "z7GWnBMs1gUx7tQcjaMCHh3BP9U",
  "attestationObject": "o2NmbXRkbm9uZWdhdHRTdG10oGhhdXRoRGF0YViYczMduT40lu74ilmRAUXrzf7qmgMiXz12u9QQt0S9LeJdAAAAAPv8MAcVTk7MjAtuAgVX170AFM-xlpwTLNYFMe7UHI2jAh4dwT_VpQECAyYgASFYIIc1EGTAVB_nylW_LpBr_G_VG4pIb5py8cdVTmpQ8ZITIlggxrpefNOZ9ySNSqYF9BNCDC-ZHHiPdDUGAGK7HZcwJXo",
  "clientDataJSON": "eyJ0eXBlIjoid2ViYXV0aG4uY3JlYXRlIiwiY2hhbGxlbmdlIjoicmVxTnU2RThyZW9KQUhFOG9EODhEc3NqSk11SFAxcHZNWnk1X1FHc0Q1OCIsIm9yaWdpbiI6Imh0dHBzOi8vbmVvYml6LXNzby5kZXYudnBiYW5rLmNvbS52biJ9",
  "authenticatorLabel": "Mobile Device",
  "transports": []
}
```

## Phân Tích Request

### 1. ClientDataJSON (Decoded)
```json
{
  "type": "webauthn.create",
  "challenge": "reqNu68E8reoJAHE8oD88EssjJMuHP1pvMZy5_QGsD58",
  "origin": "https://neobiz-sso.dev.vpbank.com.vn"
}
```
✅ **OK**: Format đúng, có đủ các trường bắt buộc

### 2. Các Vấn Đề Có Thể Xảy Ra

#### A. Format Encoding
- `attestationObject` và `clientDataJSON` cần được encode đúng định dạng:
  - **Base64URL** (không padding, `-` thay cho `+`, `_` thay cho `/`)
  - Hoặc **Base64** thông thường (tùy backend yêu cầu)

#### B. Thiếu Thông Tin
Request có thể thiếu các trường sau (tùy backend yêu cầu):
- `userId` hoặc `username` - để liên kết credential với user
- `rpId` (Relying Party ID) - thường là domain của origin
- `userVerification` - yêu cầu xác thực user
- `authenticatorAttachment` - platform hoặc cross-platform

#### C. AttestationObject Format
- `attestationObject` là CBOR encoded, cần được parse đúng
- Backend có thể không parse được format này

#### D. Database/Storage Issues
- Backend không thể lưu vào database
- Thiếu quyền truy cập database
- Constraint violation (duplicate credential ID)
- Schema không đúng

## Giải Pháp Đề Xuất

### 1. Kiểm Tra Request Format
Đảm bảo encoding đúng:
```dart
// Nếu backend yêu cầu Base64URL
String base64UrlEncode(String base64) {
  return base64
      .replaceAll('+', '-')
      .replaceAll('/', '_')
      .replaceAll('=', '');
}

// Nếu backend yêu cầu Base64 thông thường
String base64Encode(List<int> bytes) {
  return base64Encode(bytes);
}
```

### 2. Thêm Các Trường Bắt Buộc
```json
{
  "publicKeyCredentialId": "z7GWnBMs1gUx7tQcjaMCHh3BP9U",
  "attestationObject": "...",
  "clientDataJSON": "...",
  "authenticatorLabel": "Mobile Device",
  "transports": [],
  "userId": "user_id_here",  // Thêm nếu backend yêu cầu
  "rpId": "neobiz-sso.dev.vpbank.com.vn",  // Thêm nếu backend yêu cầu
  "userVerification": "required"  // Thêm nếu backend yêu cầu
}
```

### 3. Kiểm Tra Backend Logs
- Xem chi tiết lỗi trong backend logs
- Kiểm tra database connection
- Kiểm tra schema của bảng lưu credentials

### 4. Validate AttestationObject
Backend cần:
- Parse CBOR format đúng
- Verify signature
- Check certificate chain (nếu có)
- Validate challenge từ clientDataJSON

### 5. Kiểm Tra Duplicate Credential
- `publicKeyCredentialId` có thể đã tồn tại
- Cần check và handle duplicate

## Code Mẫu Để Debug

### Decode và Validate Request
```dart
import 'dart:convert';

void debugWebAuthnRequest(Map<String, dynamic> request) {
  // Decode clientDataJSON
  try {
    final clientDataJson = base64UrlDecode(request['clientDataJSON']);
    final clientData = jsonDecode(utf8.decode(clientDataJson));
    print('ClientDataJSON: $clientData');
  } catch (e) {
    print('Error decoding clientDataJSON: $e');
  }
  
  // Check attestationObject length
  final attestationObject = request['attestationObject'];
  print('AttestationObject length: ${attestationObject.length}');
  
  // Validate required fields
  final requiredFields = [
    'publicKeyCredentialId',
    'attestationObject',
    'clientDataJSON',
  ];
  
  for (var field in requiredFields) {
    if (!request.containsKey(field) || request[field] == null) {
      print('Missing required field: $field');
    }
  }
}
```

## Câu Hỏi Cần Làm Rõ

1. **Endpoint API**: URL đầy đủ của API đăng ký thiết bị là gì?
2. **Backend Framework**: Backend sử dụng framework gì? (Node.js, Python, Java, etc.)
3. **Error Logs**: Có thể xem chi tiết error logs từ backend không?
4. **API Documentation**: Có tài liệu API specification không?
5. **Previous Success**: Request này đã từng thành công trước đó chưa?

## Next Steps

1. ✅ Kiểm tra format encoding của `attestationObject` và `clientDataJSON`
2. ✅ Thêm các trường bắt buộc nếu thiếu (userId, rpId, etc.)
3. ✅ Kiểm tra backend logs để xem lỗi chi tiết
4. ✅ Verify database schema và constraints
5. ✅ Test với một credential mới (không trùng ID)

