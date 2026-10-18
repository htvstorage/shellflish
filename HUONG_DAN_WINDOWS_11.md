# HƯỚNG DẪN BUILD IOS APP TRÊN WINDOWS 11 - KHÔNG CẦN MAC

Bạn dùng Windows 11 nên không cài được Xcode. Xcode chỉ chạy trên macOS. 
Nhưng có 3 cách để bạn vẫn build ra IPA của ShellFish Clone:

---

## CÁCH 1: DÙNG CODEMAGIC (DỄ NHẤT - KHUYÊN DÙNG) - FREE 500 phút/tháng

Codemagic là dịch vụ build iOS trên cloud, có Mac M2 sẵn cho bạn dùng.

### Bước 1: Đưa code lên GitHub
1. Tạo tài khoản GitHub.com (free)
2. Tạo repo mới tên ShellFishClone
3. Tải file ShellFish-Clone-iOS-Full-v2.zip về, giải nén
4. Upload toàn bộ lên GitHub (kéo thả trên web cũng được)

### Bước 2: Tạo Apple ID cho build
1. Vào https://appleid.apple.com tạo Apple ID (dùng ID đang dùng trên iPhone cũng được)
2. Không cần trả $99 vẫn build được (free provisioning - IPA dùng 7 ngày)

### Bước 3: Build trên Codemagic
1. Vào https://codemagic.io - Sign up bằng GitHub
2. Add application > chọn repo ShellFishClone
3. Chọn workflow iOS
4. Trong phần Code Signing: 
   - Chọn Automatic code signing
   - Nhập Apple ID và mật khẩu app-specific
5. Bấm Start Build
6. Đợi 5-10 phút, xong Codemagic cho bạn tải file .ipa về!

### Bước 4: Cài IPA lên iPhone (từ Windows)
- Cách A: Dùng 3uTools (Windows) - Công cụ quản lý iPhone tốt nhất trên Windows
  1. Cài 3uTools.com trên Windows 11
  2. Cắm iPhone bằng cáp
  3. Vào Toolbox > Install IPA > chọn file .ipa vừa tải

- Cách B: Dùng AltStore
  1. Cài AltServer trên Windows: altstore.io
  2. Cài AltStore lên iPhone
  3. Mở AltStore > My Apps > + > chọn IPA

File codemagic.yaml mình đã viết sẵn trong project, chỉ cần push lên là nó tự build!

---

## CÁCH 2: THUÊ MAC TRÊN CLOUD - $10-20/tháng

Nếu Codemagic free hết giờ, thuê Mac ảo:

1. **MacInCloud.com** - $10/tháng, có Mac mini sẵn qua remote desktop
   - Đăng ký > nhận thông tin đăng nhập remote
   - Dùng Windows Remote Desktop để vào Mac
   - Cài Xcode, build như trên Mac thật

2. **AWS EC2 Mac** - $1/giờ, thuê theo giờ
   - Vào aws.amazon.com > EC2 > Dedicated Hosts > Mac
   - Thuê Mac mini M2, dùng 1-2 giờ để build xong rồi tắt

3. **Scaleway, MacStadium** - tương tự

Ưu điểm: Có Mac thật 100%, làm gì cũng được

---

## CÁCH 3: CÀI MACOS ẢO TRÊN WINDOWS 11 (VMware) - FREE NHƯNG NẶNG

Cài macOS Sonoma chạy trong VMware Workstation trên Windows 11 của bạn.

### Yêu cầu:
- CPU Intel/AMD hỗ trợ ảo hóa (bật VT-x trong BIOS)
- RAM 16GB trở lên (Mac ảo ngốn 8GB)
- Ổ cứng trống 80GB
- Windows 11 Pro (cần Hyper-V tắt)

### Các bước:
1. Cài VMware Workstation Pro (giờ free cho cá nhân)
2. Tải Unlocker để VMware chạy được macOS
3. Tải file macOS Sonoma ISO (tìm trên mạng)
4. Tạo máy ảo mới > chọn macOS
5. Cài macOS (mất 1-2 tiếng)
6. Trong macOS ảo: cài Xcode từ App Store
7. Build IPA như hướng dẫn trước

Nhược điểm: Chậm, lag, chỉ nên dùng nếu máy bạn mạnh

---

## KHUYÊN BẠN NÊN LÀM GÌ?

Vì bạn ở Hà Nội, dùng Windows 11:

**Làm ngay:**
1. Tải 3uTools về Windows: https://www.3u.com/
2. Tải AltStore về: https://altstore.io/
3. Tạo tài khoản GitHub, push code lên
4. Dùng Codemagic build IPA (free, không cần Mac)

**Sau khi có IPA:**
- Dùng 3uTools cài 1 click là xong!
- Vào Files app > ... > Edit > bật SFTPFileProvider là thấy server như ổ đĩa

**Nếu muốn lâu dài:**
- Thuê MacInCloud $10/tháng hoặc mua Mac mini cũ M1 (~8tr) để build cho tiện

---

## Cần mình giúp tạo GitHub repo và build luôn?

Nếu bạn đưa mình GitHub repo, mình có thể viết sẵn toàn bộ workflow để bạn chỉ việc bấm Build trên Codemagic là có IPA tải về, không cần động vào Xcode!

