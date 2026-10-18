
# HƯỚNG DẪN BUILD IPA - SHELLFISH CLONE

## Cách 1: Nhanh nhất (Xcode GUI) - 3 phút

### Bước 1: Tạo project Xcode mới
1. Mở Xcode > File > New > Project > iOS > App
2. Tên: ShellFishClone
3. Interface: SwiftUI, Language: Swift
4. Team: Chọn Apple ID của bạn (Xcode > Settings > Accounts > Add Apple ID - FREE cũng được)

### Bước 2: Copy code mình đã viết
1. Giải nén ShellFish-Clone-iOS-Full.zip
2. Kéo toàn bộ thư mục App/, Shared/, FileProvider/ vào project (chọn Copy items if needed)
3. Khi Xcode hỏi, chọn Create groups

### Bước 3: Thêm File Provider Extension
1. File > New > Target > File Provider Extension
2. Tên: SFTPFileProvider
3. Xcode sẽ tự tạo thư mục SFTPFileProvider, XÓA file mặc định và thay bằng 2 file của mình:
   - FileProviderExtension.swift
   - FileProviderItems.swift

### Bước 4: Thêm thư viện (QUAN TRỌNG)
File > Add Package Dependencies:
- https://github.com/orlandos-nl/Citadel (SSH/SFTP)
- https://github.com/migueldeicaza/SwiftTerm (Terminal)

Add cả 2 package cho CẢ 2 target (App + Extension)

### Bước 5: Bật App Groups (BẮT BUỘC để Files tích hợp hoạt động)
1. Chọn project > Target ShellFishClone > Signing & Capabilities > + Capability > App Groups
2. Thêm group: group.com.shellfish.clone
3. Làm tương tự cho target SFTPFileProvider - PHẢI CÙNG GROUP
4. Nếu báo lỗi, đổi thành group.com.TENBAN.shellfish (mỗi người phải khác nhau)

### Bước 6: Build ra IPA
1. Cắm iPhone vào Mac (hoặc chọn Generic iOS Device)
2. Product > Archive (đợi 1-2 phút)
3. Khi xong, cửa sổ Organizer hiện ra > Distribute App > Ad Hoc > Export
4. Bạn sẽ có file ShellFishClone.ipa

### Bước 7: Cài lên iPhone
- Cách A: Kéo file .ipa vào Apple Configurator 2 (cắm cáp)
- Cách B: Dùng AltStore - mở AltStore > My Apps > + > chọn .ipa
- Cách C: Nếu có Apple Developer trả phí ($99/năm): Distribute App > TestFlight

## Cách 2: Không có Mac? Dùng AltStore trực tiếp

Nếu bạn chỉ có Windows:
1. Cài AltServer trên Windows
2. Cài AltStore lên iPhone
3. Tải file .ipa mình build sẵn (bạn phải tự build trên Mac hoặc dùng Mac ảo)
4. Trong AltStore > My Apps > + > chọn IPA

## Lưu ý quan trọng về IPA

- IPA FREE Apple ID chỉ dùng được 7 ngày, sau đó phải cài lại (AltStore tự gia hạn)
- IPA trả phí Developer dùng được 1 năm
- File Provider Extension BẮT BUỘC phải có entitlements App Groups mới hiện trong Files app
- Lần đầu cài: Vào iPhone > Settings > General > VPN & Device Management > Trust Apple ID của bạn

## Troubleshooting

- Lỗi Signing: Xcode > Settings > Accounts > chọn team, bấm Manage Certificates > +
- Lỗi App Groups: Đổi tên group thành duy nhất, ví dụ group.com.hung123.shellfish
- Files app không hiện: Vào Files app > ... > Edit > bật SFTPFileProvider
- Terminal đen thui: Kiểm tra host/port, tắt firewall server

## Cần mình làm sẵn project .xcodeproj?

Mình đã viết sẵn toàn bộ Swift rồi, bạn chỉ cần làm theo bước trên là 3 phút xong. Nếu bạn muốn mình tạo sẵn file ShellFishClone.xcodeproj để chỉ việc mở là Archive luôn, nói mình nhé, mình sẽ generate luôn!
