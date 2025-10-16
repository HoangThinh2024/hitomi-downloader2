# Security Policy / Chính sách Bảo mật

[English](#english) | [Tiếng Việt](#tiếng-việt)

## English

### Security Analysis

This document provides an overview of the security measures and considerations for Hitomi Downloader.

#### Application Architecture

Hitomi Downloader is built using:
- **Frontend**: Vue 3 with TypeScript - modern, reactive UI framework
- **Backend**: Rust with Tauri 2 - secure, memory-safe native application framework
- **Dependencies**: Carefully selected open-source libraries with active maintenance

#### Security Features

1. **Memory Safety**
   - Rust's ownership system prevents memory leaks, buffer overflows, and use-after-free bugs
   - No manual memory management eliminates entire classes of vulnerabilities

2. **Sandboxed Environment**
   - Tauri provides a secure bridge between frontend and backend
   - Limited API surface reduces attack vectors
   - Frontend cannot directly access system resources without explicit permissions

3. **Network Security**
   - HTTPS/TLS encryption for all network communications
   - Support for system proxy and custom proxy configurations
   - Retry mechanism with exponential backoff prevents DOS attacks

4. **Data Privacy**
   - All data stored locally on user's machine
   - No telemetry or analytics collection
   - No cloud services or external databases
   - User maintains full control over downloaded content

5. **File System Security**
   - Sandboxed file access through Tauri's permission system
   - Path traversal prevention
   - Safe file operations with error handling

6. **Dependency Management**
   - Regular dependency audits using `cargo audit` and `pnpm audit`
   - Minimal dependency footprint
   - Pinned versions in production builds

#### Known Limitations

1. **Antivirus False Positives**
   - Individually developed applications may trigger false positives
   - Users can verify by building from source or checking file hashes
   - Code is fully open source for transparency

2. **Network Security**
   - Application downloads content from third-party servers
   - Users should ensure they trust the content sources
   - Recommend using VPN or proxy in restricted networks

#### Security Best Practices for Users

1. **Download from Official Sources**
   - Only download releases from the official GitHub repository
   - Verify checksums when available
   - Be cautious of third-party distributions

2. **Keep Software Updated**
   - Install security updates promptly
   - Check for updates regularly

3. **Use Secure Networks**
   - Avoid using public WiFi without VPN
   - Configure proxy settings appropriately

4. **Review Permissions**
   - Understand what file system access the application requests
   - Review configuration files periodically

#### Reporting Security Vulnerabilities

If you discover a security vulnerability, please:

1. **DO NOT** open a public issue
2. Email the maintainer directly with details
3. Include steps to reproduce the vulnerability
4. Allow reasonable time for a fix before public disclosure

We take security seriously and will respond to verified vulnerabilities promptly.

#### Upgrade Considerations

The application is designed for easy upgrades:

1. **Automatic Updates** (Planned)
   - Future versions will include automatic update checks
   - Digital signatures for verifying authenticity

2. **Configuration Compatibility**
   - Configuration files are versioned
   - Automatic migration of settings between versions

3. **Data Preservation**
   - Downloaded content remains accessible across versions
   - Export formats (PDF, CBZ) are standard and portable

4. **Modular Architecture**
   - Clean separation between UI and business logic
   - Easy to add new features without breaking existing functionality

---

## Tiếng Việt

### Phân tích Bảo mật

Tài liệu này cung cấp tổng quan về các biện pháp bảo mật và cân nhắc cho Hitomi Downloader.

#### Kiến trúc Ứng dụng

Hitomi Downloader được xây dựng bằng:
- **Frontend**: Vue 3 với TypeScript - framework UI hiện đại, reactive
- **Backend**: Rust với Tauri 2 - framework ứng dụng native an toàn, bảo vệ bộ nhớ
- **Dependencies**: Các thư viện mã nguồn mở được chọn lọc cẩn thận với bảo trì tích cực

#### Tính năng Bảo mật

1. **An toàn Bộ nhớ**
   - Hệ thống ownership của Rust ngăn chặn rò rỉ bộ nhớ, tràn buffer và lỗi use-after-free
   - Không quản lý bộ nhớ thủ công loại bỏ hoàn toàn các lớp lỗ hổng

2. **Môi trường Sandbox**
   - Tauri cung cấp cầu nối an toàn giữa frontend và backend
   - Bề mặt API hạn chế giảm vector tấn công
   - Frontend không thể truy cập trực tiếp tài nguyên hệ thống mà không có quyền rõ ràng

3. **Bảo mật Mạng**
   - Mã hóa HTTPS/TLS cho mọi giao tiếp mạng
   - Hỗ trợ cấu hình proxy hệ thống và proxy tùy chỉnh
   - Cơ chế thử lại với exponential backoff ngăn chặn tấn công DOS

4. **Quyền riêng tư Dữ liệu**
   - Tất cả dữ liệu được lưu trữ cục bộ trên máy người dùng
   - Không thu thập telemetry hoặc phân tích
   - Không có dịch vụ đám mây hoặc cơ sở dữ liệu bên ngoài
   - Người dùng duy trì toàn quyền kiểm soát nội dung đã tải

5. **Bảo mật Hệ thống Tệp**
   - Truy cập tệp sandbox thông qua hệ thống quyền của Tauri
   - Ngăn chặn path traversal
   - Thao tác tệp an toàn với xử lý lỗi

6. **Quản lý Dependencies**
   - Kiểm tra dependency thường xuyên bằng `cargo audit` và `pnpm audit`
   - Dấu chân dependency tối thiểu
   - Phiên bản được ghim trong bản build production

#### Hạn chế Đã biết

1. **Cảnh báo Giả của Phần mềm Diệt virus**
   - Ứng dụng phát triển cá nhân có thể kích hoạt cảnh báo giả
   - Người dùng có thể xác minh bằng cách build từ nguồn hoặc kiểm tra hash tệp
   - Mã nguồn hoàn toàn mở để minh bạch

2. **Bảo mật Mạng**
   - Ứng dụng tải nội dung từ máy chủ bên thứ ba
   - Người dùng nên đảm bảo họ tin tưởng nguồn nội dung
   - Khuyến nghị sử dụng VPN hoặc proxy trong mạng bị hạn chế

#### Thực hành Bảo mật Tốt nhất cho Người dùng

1. **Tải về từ Nguồn Chính thức**
   - Chỉ tải releases từ kho GitHub chính thức
   - Xác minh checksum khi có sẵn
   - Cẩn thận với các bản phân phối bên thứ ba

2. **Giữ Phần mềm Được cập nhật**
   - Cài đặt cập nhật bảo mật kịp thời
   - Kiểm tra cập nhật thường xuyên

3. **Sử dụng Mạng An toàn**
   - Tránh sử dụng WiFi công cộng mà không có VPN
   - Cấu hình cài đặt proxy phù hợp

4. **Xem xét Quyền**
   - Hiểu quyền truy cập hệ thống tệp mà ứng dụng yêu cầu
   - Xem xét tệp cấu hình định kỳ

#### Báo cáo Lỗ hổng Bảo mật

Nếu bạn phát hiện lỗ hổng bảo mật, vui lòng:

1. **KHÔNG** mở issue công khai
2. Gửi email trực tiếp cho người duy trì với chi tiết
3. Bao gồm các bước để tái tạo lỗ hổng
4. Cho phép thời gian hợp lý để sửa chữa trước khi công bố công khai

Chúng tôi coi trọng bảo mật và sẽ phản hồi các lỗ hổng đã xác minh kịp thời.

#### Cân nhắc Nâng cấp

Ứng dụng được thiết kế để nâng cấp dễ dàng:

1. **Cập nhật Tự động** (Đã lên kế hoạch)
   - Các phiên bản tương lai sẽ bao gồm kiểm tra cập nhật tự động
   - Chữ ký số để xác minh tính xác thực

2. **Tương thích Cấu hình**
   - Tệp cấu hình được phiên bản hóa
   - Tự động di chuyển cài đặt giữa các phiên bản

3. **Bảo toàn Dữ liệu**
   - Nội dung đã tải vẫn có thể truy cập qua các phiên bản
   - Định dạng xuất (PDF, CBZ) là tiêu chuẩn và di động

4. **Kiến trúc Mô-đun**
   - Tách biệt rõ ràng giữa UI và logic nghiệp vụ
   - Dễ dàng thêm tính năng mới mà không phá vỡ chức năng hiện có
