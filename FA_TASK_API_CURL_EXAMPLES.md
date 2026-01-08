# FA Task API - Sample CURL Commands

Base URL: `http://localhost:7071/fai`

**Lưu ý**: Tất cả các API đều yêu cầu JWT token. Thay `YOUR_JWT_TOKEN` bằng token thực tế của bạn.

## 1. Tạo Task Mới

```bash
curl -X POST "http://localhost:7071/fai/faquiz/v1/tasks" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "title": "Hoàn thành báo cáo tuần",
    "content": "Cần hoàn thành báo cáo tuần này trước thứ 6",
    "attachments": [
      {
        "type": "pdf",
        "link": "https://example.com/report-template.pdf"
      },
      {
        "type": "image",
        "link": "https://example.com/screenshot.png"
      }
    ],
    "expiredDate": 1735689599,
    "members": [123, 456, 789]
  }'
```

**Response mẫu:**
```json
{
  "meta": {
    "code": 200,
    "message": "Task created successfully"
  },
  "data": {
    "taskCode": "018f1234-5678-7abc-def0-123456789abc",
    "task": {
      "id": 1,
      "createdAt": 1703066400,
      "updatedAt": 1703066400,
      "status": "PROCESSING",
      "expiredDate": 1735689599,
      "metaInfo": {
        "content": "Cần hoàn thành báo cáo tuần này trước thứ 6",
        "attachments": [
          {
            "type": "pdf",
            "link": "https://example.com/report-template.pdf"
          },
          {
            "type": "image",
            "link": "https://example.com/screenshot.png"
          }
        ]
      },
      "title": "Hoàn thành báo cáo tuần",
      "taskCode": "018f1234-5678-7abc-def0-123456789abc",
      "members": [
        {
          "member": 123,
          "isCreator": true,
          "fullName": "Nguyễn Văn A",
          "avatar": "https://example.com/avatar/user123.jpg"
        },
        {
          "member": 456,
          "isCreator": false,
          "fullName": "Trần Thị B",
          "avatar": null
        },
        {
          "member": 789,
          "isCreator": false,
          "fullName": "Lê Văn C",
          "avatar": "https://example.com/avatar/user789.jpg"
        }
      ],
      "createdBy": 123
    }
  }
}
```

## 2. Lấy Danh Sách Task (Tất cả)

```bash
curl -X GET "http://localhost:7071/fai/faquiz/v1/tasks" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 3. Lấy Danh Sách Task (Theo Khoảng Thời Gian)

```bash
# Lấy task từ ngày 2024-12-01 đến 2024-12-31 (unix timestamp)
# startDate: 1733011200 (2024-12-01 00:00:00 UTC)
# endDate: 1735689599 (2024-12-31 23:59:59 UTC)
curl -X GET "http://localhost:7071/fai/faquiz/v1/tasks?startDate=1733011200&endDate=1735689599" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 3.1. Lấy Danh Sách Task (Theo Trạng Thái)

```bash
# Lấy task có trạng thái PROCESSING
curl -X GET "http://localhost:7071/fai/faquiz/v1/tasks?status=PROCESSING" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Lấy task có trạng thái DONE
curl -X GET "http://localhost:7071/fai/faquiz/v1/tasks?status=DONE" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Lấy task có trạng thái CANCEL
curl -X GET "http://localhost:7071/fai/faquiz/v1/tasks?status=CANCEL" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 3.2. Lấy Danh Sách Task (Kết hợp Date Range và Status)

```bash
# Lấy task từ ngày 2024-12-01 đến 2024-12-31 với trạng thái PROCESSING
curl -X GET "http://localhost:7071/fai/faquiz/v1/tasks?startDate=1733011200&endDate=1735689599&status=PROCESSING" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 3.3. Phân Biệt Task CANCELLED và Task FAIL (Quá Hạn)

Khi tìm kiếm task, cần phân biệt giữa hai trường hợp:

### Task CANCELLED (Hủy Nhiệm Vụ)
- **Trạng thái**: `status = "CANCEL"`
- **Nguyên nhân**: Người dùng chủ động hủy nhiệm vụ
- **Cách nhận biết**:
   - `status` = `"CANCEL"`
   - `cancelledBy` có giá trị (user ID của người hủy)
   - `expiredDate` có thể còn chưa đến hoặc đã qua

**Ví dụ tìm kiếm task CANCELLED:**
```bash
# Lấy tất cả task đã bị hủy
curl -X GET "http://localhost:7071/fai/faquiz/v1/tasks?status=CANCEL" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response mẫu:**
```json
{
  "meta": {
    "code": 200,
    "message": "Success"
  },
  "data": [
    {
      "id": 1,
      "status": "CANCEL",
      "cancelledBy": 123,
      "expiredDate": 1735689599,
      "title": "Task đã bị hủy",
      ...
    }
  ]
}
```

### Task FAIL (Quá Hạn)
- **Trạng thái**: `status = "PROCESSING"` (nhưng đã quá hạn)
- **Nguyên nhân**: Task có `expiredDate` đã qua thời gian hiện tại nhưng chưa được hoàn thành hoặc hủy
- **Cách nhận biết**:
   - `status` = `"PROCESSING"` (không phải `"CANCEL"` hoặc `"DONE"`)
   - `expiredDate` < thời gian hiện tại (Unix timestamp)
   - `cancelledBy` = `null` (chưa bị hủy)
   - `finishedBy` = `null` (chưa hoàn thành)

**Ví dụ tìm kiếm task FAIL (quá hạn):**
```bash
# Lấy task có trạng thái PROCESSING (sau đó filter ở client để tìm task quá hạn)
curl -X GET "http://localhost:7071/fai/faquiz/v1/tasks?status=PROCESSING" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Lưu ý**: Để xác định task FAIL, client cần:
1. Lấy danh sách task có `status = "PROCESSING"`
2. Kiểm tra từng task:
   - Nếu `expiredDate` != `null` và `expiredDate` < thời gian hiện tại
   - Và `cancelledBy` == `null`
   - Và `finishedBy` == `null`
   - → Task này được coi là FAIL (quá hạn)

**Response mẫu (task FAIL):**
```json
{
  "meta": {
    "code": 200,
    "message": "Success"
  },
  "data": [
    {
      "id": 2,
      "status": "PROCESSING",
      "expiredDate": 1700000000,  // Đã quá hạn (nhỏ hơn thời gian hiện tại)
      "cancelledBy": null,        // Chưa bị hủy
      "finishedBy": null,          // Chưa hoàn thành
      "title": "Task quá hạn",
      ...
    }
  ]
}
```

### So Sánh

| Tiêu chí | Task CANCELLED | Task FAIL (Quá Hạn) |
|----------|----------------|---------------------|
| **Status** | `"CANCEL"` | `"PROCESSING"` |
| **cancelledBy** | Có giá trị (user ID) | `null` |
| **expiredDate** | Có thể bất kỳ | Đã qua thời gian hiện tại |
| **finishedBy** | `null` | `null` |
| **Nguyên nhân** | Người dùng chủ động hủy | Tự động quá hạn do không hoàn thành |

## 4. Lấy Task Theo Task Code

```bash
curl -X GET "http://localhost:7071/fai/faquiz/v1/tasks/018f1234-5678-7abc-def0-123456789abc" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 5. Cập Nhật Thông Tin Task

```bash
curl -X PUT "http://localhost:7071/fai/faquiz/v1/tasks/018f1234-5678-7abc-def0-123456789abc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "title": "Hoàn thành báo cáo tuần (Updated)",
    "content": "Cần hoàn thành báo cáo tuần này trước thứ 6. Ưu tiên cao!",
    "attachments": [
      {
        "type": "pdf",
        "link": "https://example.com/report-template-v2.pdf"
      }
    ],
    "expiredDate": 1736117999
  }'
```

## 6. Cập Nhật Trạng Thái Task

### 6.1. Đánh dấu Task là DONE

```bash
curl -X PUT "http://localhost:7071/fai/faquiz/v1/tasks/018f1234-5678-7abc-def0-123456789abc/status" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "status": "DONE"
  }'
```

### 6.2. Đánh dấu Task là CANCEL

```bash
curl -X PUT "http://localhost:7071/fai/faquiz/v1/tasks/018f1234-5678-7abc-def0-123456789abc/status" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "status": "CANCEL"
  }'
```

### 6.3. Đánh dấu Task là PROCESSING (quay lại)

```bash
curl -X PUT "http://localhost:7071/fai/faquiz/v1/tasks/018f1234-5678-7abc-def0-123456789abc/status" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "status": "PROCESSING"
  }'
```

## 7. Tạo Comment Cho Task

```bash
curl -X POST "http://localhost:7071/fai/faquiz/v1/tasks/comments" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "taskCode": "018f1234-5678-7abc-def0-123456789abc",
    "content": "Đã bắt đầu làm báo cáo, sẽ hoàn thành trong 2 ngày nữa",
    "attachments": [
      {
        "type": "image",
        "link": "https://example.com/progress-screenshot.png"
      }
    ]
  }'
```

**Response mẫu:**
```json
{
  "meta": {
    "code": 200,
    "message": "Comment created successfully"
  },
  "data": {
    "id": 1,
    "createdAt": 1703070000,
    "updatedAt": 1703070000,
    "metaInfo": {
      "content": "Đã bắt đầu làm báo cáo, sẽ hoàn thành trong 2 ngày nữa",
      "attachments": [
        {
          "type": "image",
          "link": "https://example.com/progress-screenshot.png"
        }
      ]
    },
    "member": 123,
    "taskCode": "018f1234-5678-7abc-def0-123456789abc"
  }
}
```

## 8. Lấy Danh Sách Comment Của Task

```bash
curl -X GET "http://localhost:7071/fai/faquiz/v1/tasks/comments?taskCode=018f1234-5678-7abc-def0-123456789abc" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response mẫu:**
```json
{
  "meta": {
    "code": 200,
    "message": "Success"
  },
  "data": [
    {
      "id": 1,
      "createdAt": 1703070000,
      "updatedAt": 1703070000,
      "metaInfo": {
        "content": "Đã bắt đầu làm báo cáo, sẽ hoàn thành trong 2 ngày nữa",
        "attachments": [
          {
            "type": "image",
            "link": "https://example.com/progress-screenshot.png"
          }
        ]
      },
      "member": 123,
      "taskCode": "018f1234-5678-7abc-def0-123456789abc"
    },
    {
      "id": 2,
      "createdAt": 1703073600,
      "updatedAt": 1703073600,
      "metaInfo": {
        "content": "Đã hoàn thành 50%",
        "attachments": []
      },
      "member": 456,
      "taskCode": "018f1234-5678-7abc-def0-123456789abc"
    }
  ]
}
```

## 9. Lấy Danh Sách User Ops

```bash
curl -X GET "http://localhost:7071/fai/faquiz/v1/tasks/user-ops" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response mẫu:**
```json
{
  "meta": {
    "code": 200,
    "message": "Success"
  },
  "data": [
    {
      "userId": 12345,
      "fullName": "Nguyễn Văn A",
      "avatar": "https://example.com/avatar/user12345.jpg",
      "roles": ["admin", "moderator"]
    },
    {
      "userId": 67890,
      "fullName": "Trần Thị B",
      "avatar": "",
      "roles": ["user"]
    }
  ]
}
```

## 10. Upload Course Image

```bash
curl -X POST "https://api.facourse.com/fai/v1/file/upload-course-image" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json" \
  -F "files=@/path/to/your/image.jpg"
```

**Response mẫu:**
```json
{
  "meta": {
    "code": 200,
    "message": "Success"
  },
  "data": {
    "urlFile": "https://example.com/uploads/image-123456.jpg"
  }
}
```

## 11. Upload Course Audio

```bash
curl -X POST "https://api.facourse.com/fai/v1/file/upload-course-audio" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json" \
  -F "files=@/path/to/your/audio.mp3"
```

**Response mẫu:**
```json
{
  "meta": {
    "code": 200,
    "message": "Success"
  },
  "data": {
    "urlFile": "https://example.com/uploads/audio-123456.mp3"
  }
}
```

## 12. Upload Course Video

```bash
curl -X POST "https://api.facourse.com/fai/v1/file/upload-course-video" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json" \
  -F "files=@/path/to/your/video.mp4"
```

**Response mẫu:**
```json
{
  "meta": {
    "code": 200,
    "message": "Success"
  },
  "data": {
    "urlFile": "https://example.com/uploads/video-123456.mp4"
  }
}
```

## Lưu ý:

1. **JWT Token**: Thay `YOUR_JWT_TOKEN` bằng token thực tế từ API login/authentication
2. **User IDs**: Thay các giá trị `123, 456, 789` trong `members` bằng user IDs thực tế trong hệ thống. Hệ thống sẽ tự động loại bỏ các ID trùng lặp.
3. **Task Code**: Sau khi tạo task, lưu lại `taskCode` từ response để dùng cho các API khác
4. **Date Format**:
   - **Tất cả thời gian đều dùng Unix Timestamp (int64)** - số giây tính từ 1970-01-01 00:00:00 UTC
   - Query params: Unix timestamp (ví dụ: `1735689599` cho 2024-12-31 23:59:59 UTC)
   - JSON body: Unix timestamp (ví dụ: `1735689599`)
   - Response: Unix timestamp (ví dụ: `1703066400`)
   - **Ví dụ chuyển đổi**:
      - JavaScript: `Math.floor(new Date('2024-12-31T23:59:59Z').getTime() / 1000)` → `1735689599`
      - Python: `int(datetime(2024, 12, 31, 23, 59, 59).timestamp())` → `1735689599`
5. **Status Values**: Chỉ chấp nhận `PROCESSING`, `DONE`, `CANCEL`
   - Khi status = `DONE`: Tự động set `finishedBy` = userID hiện tại
   - Khi status = `CANCEL`: Tự động set `cancelledBy` = userID hiện tại
   - Khi status = `PROCESSING`: Clear `finishedBy` và `cancelledBy`
   - **Filter theo Status**: Có thể filter task theo status bằng query parameter `status` trong API GetTasks
   - Có thể kết hợp với `startDate` và `endDate` để filter theo cả thời gian và trạng thái
   - **Phân biệt CANCELLED và FAIL**:
      - **Task CANCELLED**: `status = "CANCEL"`, có `cancelledBy` (người dùng chủ động hủy)
      - **Task FAIL**: `status = "PROCESSING"` nhưng `expiredDate` < thời gian hiện tại, `cancelledBy = null`, `finishedBy = null` (tự động quá hạn)
6. **Members Response**:
   - Không còn `id` và `createdAt`
   - Có thêm `fullName` và `avatar` (có thể null)
   - `fullName` được lấy từ `users.extra_data` hoặc `fa_users.full_name`
   - `avatar` được lấy từ `fa_users.avatar`
7. **Task Response**:
   - Có thêm `createdBy`, `finishedBy`, `cancelledBy` (có thể null)
   - `createdBy` được set khi tạo task
   - `finishedBy` được set khi status chuyển sang `DONE`
   - `cancelledBy` được set khi status chuyển sang `CANCEL`
8. **User Ops Response**:
   - Chỉ trả về `userId`, `fullName`, `avatar`, `roles`
   - `fullName` và `avatar` được lấy từ `users.extra_data`
   - `roles` là mảng string các quyền của user
9. **File Upload**:
   - Sử dụng `multipart/form-data` với field name là `files`
   - Hỗ trợ upload image (jpg, png, etc.), audio (mp3, wav, etc.) và video (mp4, avi, etc.)
   - Response trả về URL của file đã upload trong `data.urlFile`

