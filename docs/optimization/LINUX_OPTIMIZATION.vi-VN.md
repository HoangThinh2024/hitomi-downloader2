# Hướng dẫn Tối ưu hóa Linux cho Ubuntu 24.04 LTS

Tài liệu này cung cấp thông tin chi tiết về các tối ưu hóa đặc thù cho Linux được triển khai trong Hitomi Downloader để đảm bảo hiệu suất tối ưu trên Ubuntu 24.04 LTS mà không bị lag hay giảm hiệu năng.

## Tối ưu hóa Hiệu suất

### 1. Đồng thời Thích ứng

Ứng dụng tự động điều chỉnh số lượng tải xuống đồng thời dựa trên số lõi CPU của hệ thống:

- **Tải xuống Comic**: `(Số lõi CPU / 2)`, tối thiểu 2, tối đa 4 tải xuống đồng thời
- **Tải xuống Hình ảnh**: `(Số lõi CPU * 2)`, tối thiểu 8, tối đa 16 tải xuống đồng thời

Điều này đảm bảo sử dụng tài nguyên tối ưu mà không làm quá tải hệ thống.

### 2. Tối ưu hóa HTTP Client

#### Connection Pooling (Nhóm kết nối)
- **API Client**: 10 kết nối idle mỗi host
- **Image Client**: 20 kết nối idle mỗi host (tối ưu cho thông lượng cao)
- **Cover Client**: 15 kết nối idle mỗi host

#### Tối ưu hóa TCP
- **TCP Keep-Alive**: Kích hoạt với khoảng thời gian 60-75 giây để duy trì kết nối
- **TCP No-Delay**: Kích hoạt cho tải xuống hình ảnh để giảm độ trễ
- **HTTP/2 Adaptive Window**: Kích hoạt để kiểm soát luồng tốt hơn

#### Quản lý Idle Timeout
- Kết nối được giữ hoạt động trong 90-120 giây để tối đa hóa việc tái sử dụng
- Tự động dọn dẹp kết nối idle để ngăn cạn kiệt tài nguyên

### 3. Tối ưu hóa Rust Compiler

Bản build release được cấu hình với các cài đặt tối ưu tối đa:

- **LTO (Link Time Optimization)**: Chế độ "fat" cho hiệu suất tốt nhất
- **Optimization Level**: 3 (tối đa)
- **Codegen Units**: 1 (tối ưu tốt hơn, thời gian compile dài hơn)
- **Binary Stripping**: Kích hoạt để giảm kích thước
- **Panic**: "abort" để giảm kích thước binary và overhead

### 4. Hỗ trợ Nén

Kích hoạt nhiều thuật toán nén để tối ưu băng thông:
- **Gzip**: Nén tiêu chuẩn
- **Brotli**: Tỷ lệ nén cao
- **Deflate**: Nén dự phòng

## Yêu cầu Hệ thống

### Yêu cầu Tối thiểu
- Ubuntu 24.04 LTS (hoặc bản phân phối Linux tương thích)
- 2 lõi CPU
- 2 GB RAM
- 100 MB dung lượng đĩa trống (không bao gồm tải xuống)

### Yêu cầu Được khuyến nghị
- Ubuntu 24.04 LTS
- 4+ lõi CPU
- 4+ GB RAM
- Ổ SSD cho thư mục tải xuống
- Kết nối internet ổn định

## Cài đặt

### Từ Gói Đã biên dịch sẵn

#### Gói DEB (Debian/Ubuntu)
```bash
sudo dpkg -i hitomi-downloader_*_linux_amd64.deb
sudo apt-get install -f  # Cài đặt dependencies nếu cần
```

#### Gói RPM (Fedora/RHEL)
```bash
sudo rpm -i hitomi-downloader_*_linux_amd64.rpm
```

#### Phiên bản Portable
```bash
tar -xzf hitomi-downloader_*_linux_amd64_portable.tar.gz
cd hitomi-downloader
./hitomi-downloader
```

### Build từ Mã nguồn

Để có hiệu suất tối ưu trên phần cứng cụ thể của bạn:

```bash
# Cài đặt dependencies
sudo apt-get update
sudo apt-get install -y libwebkit2gtk-4.1-dev libappindicator3-dev librsvg2-dev patchelf

# Cài đặt Rust, Node.js và pnpm
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install -g pnpm

# Clone và build
git clone https://github.com/HoangThinh2024/hitomi-downloader2.git
cd hitomi-downloader2
pnpm install
pnpm tauri build
```

Ứng dụng đã build sẽ nằm trong `src-tauri/target/release/`.

## Mẹo Tinh chỉnh Hiệu suất

### 1. Tối ưu hóa Hệ thống Tệp

**Sử dụng SSD cho Tải xuống**
```bash
# Kiểm tra xem thư mục tải xuống có trên SSD không
df -Th /đường/dẫn/đến/thư/mục/tải/xuống
```

**Tắt Cập nhật Thời gian Truy cập** (tùy chọn, cho tuổi thọ SSD)
```bash
# Thêm 'noatime' vào tùy chọn mount trong /etc/fstab
# Ví dụ: /dev/sda1 /home ext4 defaults,noatime 0 2
```

### 2. Tối ưu hóa Mạng

**Tăng Buffer Mạng Hệ thống**
```bash
# Thêm vào /etc/sysctl.conf
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

# Áp dụng thay đổi
sudo sysctl -p
```

**Kích hoạt BBR Congestion Control** (Mặc định Ubuntu 24.04, nhưng hãy xác minh)
```bash
# Kiểm tra congestion control hiện tại
sysctl net.ipv4.tcp_congestion_control

# Nếu không phải BBR, thêm vào /etc/sysctl.conf
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Áp dụng thay đổi
sudo sysctl -p
```

### 3. Cấu hình Proxy

Để có hiệu suất tối ưu với proxy:

1. **Chế độ System Proxy**: Tốt nhất cho người dùng có proxy hệ thống được cấu hình đúng
2. **Chế độ Custom Proxy**: Sử dụng cho máy chủ proxy cụ thể
3. **Chế độ No Proxy**: Nhanh nhất, nhưng chỉ sử dụng nếu không cần proxy

### 4. Tổ chức Thư mục Tải xuống

Ứng dụng hỗ trợ cấu trúc thư mục tùy chỉnh với các placeholder:
- `{title}` - Tiêu đề comic
- `{id}` - ID comic
- `{type}` - Loại nội dung
- `{language}` - Ngôn ngữ
- `{artists}` - Nghệ sĩ (phân cách bằng dấu phẩy)

Ví dụ: `{type}/{language}/{title} - {id}`

Điều này giúp tổ chức tải xuống hiệu quả và ngăn chặn hệ thống tệp bị chậm.

### 5. Giám sát Tài nguyên Hệ thống

Sử dụng công cụ giám sát hệ thống để đảm bảo hiệu suất tối ưu:

```bash
# Giám sát CPU và bộ nhớ
htop

# Giám sát sử dụng mạng
iftop

# Giám sát I/O đĩa
iotop
```

## Tính năng Bảo mật

### 1. An toàn Bộ nhớ
- Được viết bằng Rust, loại bỏ toàn bộ các lớp lỗ hổng bộ nhớ
- Không có buffer overflow, use-after-free, hoặc data race

### 2. Môi trường Sandbox
- Tauri cung cấp cô lập tiến trình giữa frontend và backend
- Bề mặt API hạn chế giảm vector tấn công

### 3. Bảo mật Mạng
- Mã hóa HTTPS/TLS cho tất cả giao tiếp
- Xác thực chứng chỉ được kích hoạt
- Hỗ trợ proxy hệ thống cho các lớp bảo mật bổ sung

### 4. Bảo mật Hệ thống Tệp
- Truy cập tệp sandbox thông qua hệ thống quyền của Tauri
- Bảo vệ path traversal
- Thao tác tệp an toàn với xử lý lỗi đúng

### 5. Bảo mật Dependencies
Kiểm tra bảo mật thường xuyên với:
```bash
cargo audit  # Cho dependencies Rust
pnpm audit   # Cho dependencies Node.js
```

## Khắc phục Sự cố

### Ứng dụng Cảm thấy Chậm

1. **Kiểm tra Tài nguyên Hệ thống**
   ```bash
   top -b -n 1 | head -20
   ```

2. **Xác minh Kết nối Mạng**
   ```bash
   ping -c 5 8.8.8.8
   speedtest-cli
   ```

3. **Kiểm tra Thư mục Tải xuống**
   - Đảm bảo đủ dung lượng trống
   - Xác minh quyền ghi
   - Sử dụng SSD nếu có

4. **Điều chỉnh Concurrency** (nếu cần)
   - Ứng dụng tự động điều chỉnh dựa trên lõi CPU
   - Nhiều lõi hơn = concurrency cao hơn = hiệu suất tốt hơn

### Sử dụng CPU Cao

Điều này bình thường trong:
- Tải xuống đang hoạt động (xử lý hình ảnh)
- Thao tác xuất PDF/CBZ
- Tải kết quả tìm kiếm ban đầu

Nếu sử dụng CPU cao khi rảnh rỗi:
1. Kiểm tra tác vụ nền
2. Đóng tác vụ tải xuống không sử dụng
3. Giảm tải xuống đồng thời nếu cần

### Sử dụng Bộ nhớ Cao

Sử dụng bộ nhớ mong đợi:
- Cơ bản: ~100-200 MB
- Mỗi tải xuống đang hoạt động: ~50-100 MB
- Trong khi xuất: +200-500 MB

Nếu sử dụng bộ nhớ quá mức:
1. Giảm tải xuống đồng thời
2. Đóng tải xuống đã hoàn thành
3. Khởi động lại ứng dụng

### Vấn đề Mạng

1. **Hết thời gian Kết nối**
   - Kiểm tra kết nối internet
   - Xác minh cài đặt proxy
   - Thử chế độ proxy khác

2. **Tốc độ Tải xuống Chậm**
   - Kiểm tra tốc độ mạng
   - Kiểm tra buffer mạng hệ thống (xem Tối ưu hóa Mạng)
   - Xác minh proxy không phải điểm nghẽn

## Thực hành Tốt nhất

1. **Cập nhật Thường xuyên**: Giữ ứng dụng và hệ thống được cập nhật
2. **Lưu trữ SSD**: Sử dụng SSD cho thư mục tải xuống để có hiệu suất tốt nhất
3. **Tài nguyên Đầy đủ**: Đảm bảo hệ thống đáp ứng yêu cầu được khuyến nghị
4. **Chất lượng Mạng**: Sử dụng kết nối internet ổn định, tốc độ cao
5. **Cấu hình Proxy**: Sử dụng chế độ proxy phù hợp cho thiết lập của bạn
6. **Tổ chức Thư mục**: Sử dụng cấu trúc thư mục tùy chỉnh cho bộ sưu tập lớn
7. **Bảo trì Thường xuyên**: Dọn dẹp tải xuống cũ, kiểm tra dung lượng đĩa

## Benchmark Hiệu suất

Trên hệ thống Ubuntu 24.04 LTS điển hình với:
- CPU: 4 lõi @ 2.5 GHz
- RAM: 8 GB
- Lưu trữ: SSD
- Mạng: 100 Mbps

Hiệu suất mong đợi:
- **Tải xuống Đồng thời**: 2 comic, 8-16 hình ảnh mỗi comic
- **Tốc độ Tải xuống**: Lên đến 10-15 MB/s (phụ thuộc mạng)
- **Sử dụng Bộ nhớ**: 200-500 MB trong khi tải xuống đang hoạt động
- **Sử dụng CPU**: 20-40% trong khi tải xuống
- **Phản hồi Tìm kiếm**: < 2 giây
- **Tốc độ Xuất**: ~500 hình ảnh/phút sang PDF/CBZ

## Tương thích

Ứng dụng này được kiểm tra và tối ưu hóa cho:
- Ubuntu 24.04 LTS (mục tiêu chính)
- Ubuntu 22.04 LTS
- Debian 12+
- Fedora 38+
- Các bản phân phối Linux hiện đại khác với GTK 3.0+

## Tài nguyên Bổ sung

- [README Chính](../../README.md)
- [Chính sách Bảo mật](../../SECURITY.md)
- [README Tiếng Anh](../../README.md)
- [English Linux Optimization Guide](./LINUX_OPTIMIZATION.md)
- [GitHub Issues](https://github.com/HoangThinh2024/hitomi-downloader2/issues)

## Đóng góp

Nếu bạn phát hiện cách cải thiện hiệu suất Linux:
1. Kiểm tra kỹ lưỡng trên Ubuntu 24.04 LTS
2. Đo lường cải thiện hiệu suất
3. Gửi PR với benchmark
4. Cập nhật tài liệu này với các mẹo mới

## Giấy phép

Dự án này được cấp phép theo cùng giấy phép với ứng dụng chính. Xem [LICENSE](./LICENSE) để biết chi tiết.
