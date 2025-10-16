# PDF Export Optimization / Tối ưu hóa Xuất PDF

[English](#english) | [Tiếng Việt](#tiếng-việt)

## English

### Problem

The previous PDF export implementation was creating very large files. For example, exporting 400 images could result in a 2GB PDF file, while the same images exported as CBZ (which is just a ZIP file) would only be 100MB.

### Root Cause

The issue was that each image was being read and processed independently, without any optimization:

1. **No image deduplication**: If the same image appeared multiple times (which can happen with cover pages or repeated images), it was embedded multiple times in the PDF
2. **No compression optimization**: Images were processed through the PDF library which may have been re-encoding them

### Solution Implemented

We've implemented an **image deduplication cache** that:

1. **Tracks images by content**: Uses the raw image data as a cache key
2. **Reuses image objects**: If the same image content is found again, we reuse the existing PDF image object instead of creating a new one
3. **Maintains quality**: The optimization doesn't affect image quality, it simply avoids storing the same data multiple times

### Code Changes

In `src-tauri/src/export.rs`, the `create_pdf` function now:

```rust
// Create a HashMap to cache images by their content
let mut image_cache: std::collections::HashMap<Vec<u8>, (lopdf::ObjectId, u32, u32)> = std::collections::HashMap::new();

// For each image, check if we've seen this exact content before
if let Some(&(cached_id, cached_w, cached_h)) = image_cache.get(&buffer) {
    // Reuse the existing image object
    cached_id
} else {
    // New image, create and cache it
    let new_id = doc.add_object(image_stream);
    image_cache.insert(buffer, (new_id, width, height));
    new_id
}
```

### Expected Results

- **Significant size reduction** for PDFs with repeated images
- **Faster export times** as we don't need to process the same image multiple times
- **No quality loss** as we're still using the original image data

### Additional Recommendations

For further file size optimization, consider:

1. **Use JPEG for photos**: If downloading photos/realistic images, JPEG typically provides better compression than PNG
2. **Adjust download quality settings**: If the source provides different quality options, choose appropriate quality based on your needs
3. **Use CBZ for archival**: If file size is critical and you don't need PDF features, CBZ format is more efficient

---

## Tiếng Việt

### Vấn đề

Việc xuất PDF trước đây tạo ra các tệp rất lớn. Ví dụ, xuất 400 ảnh có thể tạo ra tệp PDF 2GB, trong khi các ảnh tương tự được xuất dưới dạng CBZ (chỉ là tệp ZIP) chỉ có 100MB.

### Nguyên nhân

Vấn đề là mỗi ảnh được đọc và xử lý độc lập, không có bất kỳ tối ưu hóa nào:

1. **Không loại bỏ ảnh trùng lặp**: Nếu cùng một ảnh xuất hiện nhiều lần (có thể xảy ra với trang bìa hoặc ảnh lặp lại), nó được nhúng nhiều lần trong PDF
2. **Không tối ưu hóa nén**: Ảnh được xử lý qua thư viện PDF có thể đã được mã hóa lại

### Giải pháp Triển khai

Chúng tôi đã triển khai **bộ nhớ đệm loại bỏ trùng lặp ảnh** mà:

1. **Theo dõi ảnh theo nội dung**: Sử dụng dữ liệu ảnh thô làm khóa bộ nhớ đệm
2. **Tái sử dụng đối tượng ảnh**: Nếu tìm thấy lại cùng nội dung ảnh, chúng tôi tái sử dụng đối tượng ảnh PDF hiện có thay vì tạo mới
3. **Duy trì chất lượng**: Tối ưu hóa không ảnh hưởng đến chất lượng ảnh, nó chỉ đơn giản tránh lưu trữ cùng dữ liệu nhiều lần

### Thay đổi Code

Trong `src-tauri/src/export.rs`, hàm `create_pdf` bây giờ:

```rust
// Tạo HashMap để lưu cache ảnh theo nội dung
let mut image_cache: std::collections::HashMap<Vec<u8>, (lopdf::ObjectId, u32, u32)> = std::collections::HashMap::new();

// Đối với mỗi ảnh, kiểm tra xem chúng ta đã thấy nội dung này chưa
if let Some(&(cached_id, cached_w, cached_h)) = image_cache.get(&buffer) {
    // Tái sử dụng đối tượng ảnh hiện có
    cached_id
} else {
    // Ảnh mới, tạo và lưu cache
    let new_id = doc.add_object(image_stream);
    image_cache.insert(buffer, (new_id, width, height));
    new_id
}
```

### Kết quả Mong đợi

- **Giảm kích thước đáng kể** cho PDF có ảnh lặp lại
- **Thời gian xuất nhanh hơn** vì chúng ta không cần xử lý cùng một ảnh nhiều lần
- **Không mất chất lượng** vì chúng ta vẫn sử dụng dữ liệu ảnh gốc

### Khuyến nghị Bổ sung

Để tối ưu hóa kích thước tệp hơn nữa, hãy xem xét:

1. **Sử dụng JPEG cho ảnh**: Nếu tải xuống ảnh/hình ảnh thực tế, JPEG thường cung cấp nén tốt hơn PNG
2. **Điều chỉnh cài đặt chất lượng tải xuống**: Nếu nguồn cung cấp các tùy chọn chất lượng khác nhau, hãy chọn chất lượng phù hợp dựa trên nhu cầu của bạn
3. **Sử dụng CBZ để lưu trữ**: Nếu kích thước tệp là quan trọng và bạn không cần tính năng PDF, định dạng CBZ hiệu quả hơn
