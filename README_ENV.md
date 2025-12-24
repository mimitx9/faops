# Cấu hình Environment Variables

## Tạo file .env

1. Copy file `.env.example` thành `.env`:
```bash
cp .env.example .env
```

2. Chỉnh sửa file `.env` với các giá trị phù hợp:

```env
# API Configuration
API_BASE_URL=https://api.facourse.com
# For local development, uncomment the line below and comment the line above
# API_BASE_URL=http://localhost:7071
```

## Lưu ý

- File `.env` đã được thêm vào `.gitignore` để không commit lên repository
- Luôn sử dụng `.env.example` làm template cho các biến môi trường cần thiết
- Không commit thông tin nhạy cảm vào repository

