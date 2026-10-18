// Info.plist cho FileProvider Extension - BẮT BUỘC để Files app nhận diện
/*
<key>NSExtension</key>
<dict>
    <key>NSExtensionFileProviderDocumentGroup</key>
    <string>group.com.shellfish.clone</string>
    <key>NSExtensionFileProviderSupportsEnumeration</key>
    <true/>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.fileprovider-nonui</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).FileProviderExtension</string>
</dict>

<key>NSFileProviderDomainUsageDescription</key>
<string>Cho phép duyệt file SFTP như ổ đĩa trong Files</string>
*/

// Xcode project file (project.pbxproj) - tạo nhanh bằng script

import Foundation

let projectContent = """
// !$*UTF8*$!
{
    archiveVersion = 1;
    classes = {
    };
    objectVersion = 56;
    objects = {

/* Begin PBXBuildFile section */
        A1 /* SecureShellCloneApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = A2 /* SecureShellCloneApp.swift */; };
        B1 /* FileProviderExtension.swift in Sources */ = {isa = PBXBuildFile; fileRef = B2 /* FileProviderExtension.swift */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
        A2 /* SecureShellCloneApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SecureShellCloneApp.swift; sourceTree = "<group>"; };
        B2 /* FileProviderExtension.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FileProviderExtension.swift; sourceTree = "<group>"; };
/* End PBXFileReference section */

    };
    rootObject = ROOT /* Project object */;
}
"""

// Entitlements cho App Group (cả App và Extension phải giống nhau)
/*
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.shellfish.clone</string>
</array>
<key>com.apple.developer.fileprovider.testing-mode</key>
<true/>
*/
