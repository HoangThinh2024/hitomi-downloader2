# 📦 GitHub Packages Publishing Guide / Hướng dẫn Publish lên GitHub Packages

[English](#english) | [Tiếng Việt](#tiếng-việt)

---

## English

### Overview

This guide explains how to publish Docker images to GitHub Container Registry (ghcr.io) automatically using GitHub Actions.

### What's Already Set Up

The repository is already configured with:
- ✅ Dockerfile for building the application
- ✅ docker-compose.yml for local testing
- ✅ GitHub Actions workflow (`.github/workflows/docker-publish.yml`)
- ✅ Automatic tagging and versioning

### How It Works

The GitHub Actions workflow automatically builds and publishes Docker images when you:
1. Push code to `main` or `develop` branches
2. Create a new release tag (e.g., `v1.0.0`)
3. Manually trigger the workflow

### Step-by-Step Guide to Publish

#### Step 1: Enable GitHub Actions

1. Go to your repository on GitHub
2. Click on **Settings** tab
3. Navigate to **Actions** → **General**
4. Under "Actions permissions", select **"Allow all actions and reusable workflows"**
5. Click **Save**

#### Step 2: Configure Package Permissions

1. In repository **Settings**, go to **Actions** → **General**
2. Scroll down to **"Workflow permissions"**
3. Select **"Read and write permissions"**
4. Check ☑️ **"Allow GitHub Actions to create and approve pull requests"**
5. Click **Save**

#### Step 3: Trigger the First Build

Choose one of these methods:

**Method A: Push to main/develop branch** (Recommended)
```bash
# Make sure you're on main or develop branch
git checkout main

# Push your changes
git push origin main
```

**Method B: Create a release tag**
```bash
# Create and push a version tag
git tag v0.1.0
git push origin v0.1.0
```

**Method C: Manual workflow trigger**
1. Go to **Actions** tab in your repository
2. Select **"Build and Publish Docker Image"** workflow
3. Click **"Run workflow"** button
4. Select branch and click **"Run workflow"**

#### Step 4: Monitor the Build

1. Go to **Actions** tab
2. Click on the running workflow
3. Watch the build progress
4. Build typically takes 15-30 minutes for first build

#### Step 5: Verify Published Image

Once the build completes:

1. Go to your repository main page
2. Look for **Packages** section on the right sidebar
3. Click on the package name
4. You should see your Docker image with tags

Or check directly at:
```
https://github.com/YOUR_USERNAME/hitomi-downloader2/pkgs/container/hitomi-downloader2
```

#### Step 6: Make Package Public (Optional but Recommended)

By default, packages are private. To make them public:

1. Go to the package page
2. Click **"Package settings"**
3. Scroll to bottom → **"Danger Zone"**
4. Click **"Change visibility"**
5. Select **"Public"**
6. Type the package name to confirm
7. Click **"I understand, change package visibility"**

### Using the Published Image

Once published, anyone can pull and use your image:

```bash
# Pull the image
docker pull ghcr.io/YOUR_USERNAME/hitomi-downloader2:latest

# Run the container
docker run -d -p 6080:6080 ghcr.io/YOUR_USERNAME/hitomi-downloader2:latest

# Or use with docker-compose
# Update the image name in docker-compose.yml to:
# image: ghcr.io/YOUR_USERNAME/hitomi-downloader2:latest
```

### Available Tags

The workflow creates these tags automatically:

| Tag | Description | Example |
|-----|-------------|---------|
| `latest` | Latest build from main branch | `ghcr.io/user/repo:latest` |
| `develop` | Latest build from develop branch | `ghcr.io/user/repo:develop` |
| `main` | Latest build from main branch | `ghcr.io/user/repo:main` |
| `v*.*.*` | Specific version from git tag | `ghcr.io/user/repo:v1.0.0` |
| `v*.*` | Major.minor version | `ghcr.io/user/repo:v1.0` |
| `v*` | Major version | `ghcr.io/user/repo:v1` |

### Updating the Image

To publish a new version:

**For development updates:**
```bash
git checkout develop
# Make your changes
git add .
git commit -m "Update: description of changes"
git push origin develop
```

**For releases:**
```bash
git checkout main
# Make sure main is up to date
git pull origin main

# Create a new tag
git tag v0.2.0
git push origin v0.2.0
```

The GitHub Actions workflow will automatically build and publish the new version.

### Troubleshooting

#### Build Failed

**Check the logs:**
1. Go to **Actions** tab
2. Click on the failed workflow run
3. Expand the failed step to see error details

**Common issues:**

1. **Permission denied**
   - Solution: Check Step 2 - ensure "Read and write permissions" is enabled

2. **Build timeout**
   - Solution: The first build takes longest. Subsequent builds use cache and are faster

3. **Docker build errors**
   - Solution: Test locally first with `docker build -t test .`

#### Cannot Pull Image

**Authentication required:**
If package is private, you need to authenticate:

```bash
# Login to GitHub Container Registry
echo YOUR_GITHUB_PAT | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# Then pull
docker pull ghcr.io/YOUR_USERNAME/hitomi-downloader2:latest
```

To create a Personal Access Token (PAT):
1. GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token
3. Select scopes: `read:packages` (to pull), `write:packages` (to push)

### Advanced Configuration

#### Customize Build Platforms

Edit `.github/workflows/docker-publish.yml`:

```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    platforms: linux/amd64,linux/arm64  # Add more platforms
```

#### Add Build Arguments

```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    build-args: |
      VERSION=${{ github.ref_name }}
      BUILD_DATE=${{ github.event.head_commit.timestamp }}
```

#### Customize Tags

Edit the `tags:` section in `.github/workflows/docker-publish.yml`:

```yaml
tags: |
  type=ref,event=branch
  type=ref,event=pr
  type=semver,pattern={{version}}
  type=raw,value=latest,enable={{is_default_branch}}
  type=raw,value=stable,enable=${{ startsWith(github.ref, 'refs/tags/v') }}
```

### Best Practices

1. ✅ **Test locally first** before pushing
   ```bash
   docker build -t test-local .
   docker run -p 6080:6080 test-local
   ```

2. ✅ **Use semantic versioning** for tags
   - `v1.0.0` - Major.Minor.Patch
   - Increment appropriately

3. ✅ **Keep Dockerfile optimized**
   - Use multi-stage builds
   - Minimize layers
   - Use .dockerignore

4. ✅ **Document breaking changes**
   - Update CHANGELOG.md
   - Note in release description

5. ✅ **Tag releases properly**
   - Use GitHub Releases feature
   - Include release notes

### Automation Tips

#### Auto-publish on merge to main

Already configured! When you merge a PR to main:
1. Workflow triggers automatically
2. Builds and tests the image
3. Publishes with `latest` and `main` tags

#### Auto-publish releases

Already configured! When you create a GitHub release:
1. Tag format: `v1.0.0`
2. Workflow triggers automatically
3. Publishes with version tags

### Monitoring and Maintenance

#### Check Image Size

```bash
docker images ghcr.io/YOUR_USERNAME/hitomi-downloader2:latest
```

Optimize if > 2GB.

#### View Image History

```bash
docker history ghcr.io/YOUR_USERNAME/hitomi-downloader2:latest
```

#### Clean Old Images

In Package settings:
1. Go to package page
2. Click on **Package settings**
3. Scroll to **Manage versions**
4. Delete old/unused versions

### Support

If you encounter issues:
1. Check the Actions logs
2. Review this guide
3. Open an issue on GitHub
4. Check Docker documentation

---

## Tiếng Việt

### Tổng quan

Hướng dẫn này giải thích cách publish Docker images lên GitHub Container Registry (ghcr.io) tự động bằng GitHub Actions.

### Những gì đã được cài đặt sẵn

Repository đã được cấu hình với:
- ✅ Dockerfile để build ứng dụng
- ✅ docker-compose.yml để test local
- ✅ GitHub Actions workflow (`.github/workflows/docker-publish.yml`)
- ✅ Tự động tagging và versioning

### Cách hoạt động

GitHub Actions workflow tự động build và publish Docker images khi bạn:
1. Push code lên nhánh `main` hoặc `develop`
2. Tạo release tag mới (ví dụ: `v1.0.0`)
3. Kích hoạt workflow thủ công

### Hướng dẫn từng bước để Publish

#### Bước 1: Enable GitHub Actions

1. Vào repository trên GitHub
2. Click tab **Settings**
3. Vào **Actions** → **General**
4. Trong "Actions permissions", chọn **"Allow all actions and reusable workflows"**
5. Click **Save**

#### Bước 2: Cấu hình Package Permissions

1. Trong **Settings** của repository, vào **Actions** → **General**
2. Scroll xuống **"Workflow permissions"**
3. Chọn **"Read and write permissions"**
4. Check ☑️ **"Allow GitHub Actions to create and approve pull requests"**
5. Click **Save**

#### Bước 3: Kích hoạt Build đầu tiên

Chọn một trong các phương pháp:

**Phương pháp A: Push lên nhánh main/develop** (Khuyên dùng)
```bash
# Đảm bảo bạn đang ở nhánh main hoặc develop
git checkout main

# Push changes
git push origin main
```

**Phương pháp B: Tạo release tag**
```bash
# Tạo và push version tag
git tag v0.1.0
git push origin v0.1.0
```

**Phương pháp C: Kích hoạt workflow thủ công**
1. Vào tab **Actions** trong repository
2. Chọn workflow **"Build and Publish Docker Image"**
3. Click nút **"Run workflow"**
4. Chọn branch và click **"Run workflow"**

#### Bước 4: Theo dõi Build

1. Vào tab **Actions**
2. Click vào workflow đang chạy
3. Xem tiến trình build
4. Build thường mất 15-30 phút cho lần đầu

#### Bước 5: Kiểm tra Image đã Publish

Khi build hoàn thành:

1. Vào trang chính của repository
2. Tìm phần **Packages** ở thanh bên phải
3. Click vào tên package
4. Bạn sẽ thấy Docker image với các tags

Hoặc kiểm tra trực tiếp tại:
```
https://github.com/TEN_NGUOI_DUNG/hitomi-downloader2/pkgs/container/hitomi-downloader2
```

#### Bước 6: Đặt Package ở chế độ Public (Tùy chọn nhưng khuyên dùng)

Mặc định, packages là private. Để đặt public:

1. Vào trang package
2. Click **"Package settings"**
3. Scroll xuống cuối → **"Danger Zone"**
4. Click **"Change visibility"**
5. Chọn **"Public"**
6. Gõ tên package để xác nhận
7. Click **"I understand, change package visibility"**

### Sử dụng Image đã Publish

Sau khi publish, ai cũng có thể pull và dùng image:

```bash
# Pull image
docker pull ghcr.io/TEN_NGUOI_DUNG/hitomi-downloader2:latest

# Chạy container
docker run -d -p 6080:6080 ghcr.io/TEN_NGUOI_DUNG/hitomi-downloader2:latest

# Hoặc dùng với docker-compose
# Cập nhật tên image trong docker-compose.yml thành:
# image: ghcr.io/TEN_NGUOI_DUNG/hitomi-downloader2:latest
```

### Các Tags có sẵn

Workflow tự động tạo các tags:

| Tag | Mô tả | Ví dụ |
|-----|-------|-------|
| `latest` | Build mới nhất từ main | `ghcr.io/user/repo:latest` |
| `develop` | Build mới nhất từ develop | `ghcr.io/user/repo:develop` |
| `main` | Build mới nhất từ main | `ghcr.io/user/repo:main` |
| `v*.*.*` | Version cụ thể từ git tag | `ghcr.io/user/repo:v1.0.0` |
| `v*.*` | Major.minor version | `ghcr.io/user/repo:v1.0` |
| `v*` | Major version | `ghcr.io/user/repo:v1` |

### Cập nhật Image

Để publish version mới:

**Cho development updates:**
```bash
git checkout develop
# Thực hiện changes
git add .
git commit -m "Update: mô tả thay đổi"
git push origin develop
```

**Cho releases:**
```bash
git checkout main
# Đảm bảo main là mới nhất
git pull origin main

# Tạo tag mới
git tag v0.2.0
git push origin v0.2.0
```

GitHub Actions workflow sẽ tự động build và publish version mới.

### Xử lý sự cố

#### Build thất bại

**Kiểm tra logs:**
1. Vào tab **Actions**
2. Click vào workflow run bị lỗi
3. Mở rộng step bị lỗi để xem chi tiết

**Vấn đề thường gặp:**

1. **Permission denied**
   - Giải pháp: Kiểm tra Bước 2 - đảm bảo "Read and write permissions" được enable

2. **Build timeout**
   - Giải pháp: Build đầu tiên mất thời gian nhất. Các build sau sử dụng cache và nhanh hơn

3. **Docker build errors**
   - Giải pháp: Test local trước với `docker build -t test .`

#### Không pull được Image

**Cần authentication:**
Nếu package là private, bạn cần authenticate:

```bash
# Login vào GitHub Container Registry
echo YOUR_GITHUB_PAT | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# Sau đó pull
docker pull ghcr.io/TEN_NGUOI_DUNG/hitomi-downloader2:latest
```

Để tạo Personal Access Token (PAT):
1. GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token
3. Chọn scopes: `read:packages` (để pull), `write:packages` (để push)

### Best Practices

1. ✅ **Test local trước** khi push
   ```bash
   docker build -t test-local .
   docker run -p 6080:6080 test-local
   ```

2. ✅ **Dùng semantic versioning** cho tags
   - `v1.0.0` - Major.Minor.Patch
   - Tăng phù hợp

3. ✅ **Giữ Dockerfile tối ưu**
   - Dùng multi-stage builds
   - Minimize layers
   - Dùng .dockerignore

4. ✅ **Document breaking changes**
   - Cập nhật CHANGELOG.md
   - Ghi chú trong release description

5. ✅ **Tag releases đúng cách**
   - Dùng GitHub Releases feature
   - Bao gồm release notes

### Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra Actions logs
2. Xem lại hướng dẫn này
3. Mở issue trên GitHub
4. Kiểm tra Docker documentation

---

## Quick Reference / Tham khảo nhanh

```bash
# Build locally / Build local
docker build -t test .

# Run locally / Chạy local
docker run -p 6080:6080 test

# Push tag / Push tag
git tag v1.0.0 && git push origin v1.0.0

# Pull published image / Pull image đã publish
docker pull ghcr.io/YOUR_USERNAME/hitomi-downloader2:latest

# Check image size / Kiểm tra kích thước image
docker images ghcr.io/YOUR_USERNAME/hitomi-downloader2:latest
```
