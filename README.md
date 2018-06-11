# UserCaches
[![Build Status][TravisBadge]][TravisLink]  [![Swift4 compatible][Swift4Badge]][Swift4Link]

A key-value storage cache tool like `UserDefaults` on iOS Platform. 

# Usage

### Normal Usage

Like UserDefaults:

```swift
// Save cache.
let intVal = 123
try UserCaches.standard.set(intVal, forKey: key)
// Get cache. Specify the type('Int') to decide generic type.
let cache: Int = try UserCaches.standard.value(forKey: key)
```

`UserCaches.standard` is a global instance of UserCaches.

Could also create new instance:

```swift
let cacheHelper = try UserCaches(cachePath: URL(fileURLWithPath: "/tmp/usercache.db"))
```

### Advance Usage

**However**, I suggest using following usage. (Example of setting of Baidu App)

```swift
import UserCaches

struct User: Codable {
    let id: Int64
    let name: String
}

enum ComBaiduMobileUserSetting: String, UserCachesSettable {
    /// 隐私设置 - 允许通过手机号搜索到我
    case privacy_findMeByPhoneNumber
    /// 隐私设置 - 可通过感兴趣的人找到我
    case privacy_findMeByInteresting
    /// 隐私设置 - 开启通讯录关联
    case privacy_relateAddressList
    /// 隐私设置 - 黑名单
    case privacy_blacklist
    /// 字体大小
    case font_size
    var identifierMode: CacheKeyMode { return .identifier }
}
// Save caches
ComBaiduMobileUserSetting.privacy_findMeByPhoneNumber.storage = true
ComBaiduMobileUserSetting.privacy_findMeByInteresting.storage = false
ComBaiduMobileUserSetting.privacy_relateAddressList.storage   = false
ComBaiduMobileUserSetting.privacy_blacklist.storage = [CacheCodability(User(id: 100120054,
                                                                            name: "abc"))]
ComBaiduMobileUserSetting.font_size.storage = 20

// Get caches
let isFindMeByPhoneNumber: Bool? = ComBaiduMobileUserSetting.privacy_findMeByPhoneNumber.value()
let isFindMeByInteresting: Bool? = ComBaiduMobileUserSetting.privacy_findMeByInteresting.value()
let isRelateAddressList: Bool? = ComBaiduMobileUserSetting.privacy_relateAddressList.value()
let blacklist: [CacheCodability<User>] = ComBaiduMobileUserSetting.privacy_blacklist.value()
let fontSize: Int = ComBaiduMobileUserSetting.font_size.value() ?? 16
```

If you set `identifierMode` to `CacheKeyMode.identifier`, `UserCachesSettable` will translate upper-case letter to lower-case letter and insert "." to translated left side on enum-name and replace "_" with "." on enum-case. 

As above:

"ComBaiduMobileUserSetting"       => "com.baidu.mobile.user.setting"

"privacy_findMeByPhoneNumber" => "privacy.findMeByPhoneNumber"

The `case privacy_findMeByPhoneNumber` is translated to `com.baidu.mobile.user.setting.privacy.findMeByPhoneNumber`, as a key, associated with `true` for this example.

### Default Support Type

UseCaches support by default: 

| Default Support Type                     |
| ---------------------------------------- |
| Bool                                     |
| Int, Int64, UInt, Uint64                 |
| Float, Double                            |
| String, Data                             |
| Date (Implement with TimeInterval)       |
| Array\<CacheCodable>                     |
| Dictionary\<Key: CacheCodable, Value: CacheCodable> |
| CacheCodability\<Codable>                |

Especially, if a struct (or class) defer to `Codable`, use CacheCodability wrap the struct (or class), UserCaches also accept it. See above `CacheCodability<User>`

# Installation

> Note: UserCaches requires Swift 4.1 and Xcode 9.3+

### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. To install UserCaches with CocoaPods:

1. Make sure CocoaPods is [installed](https://guides.cocoapods.org/using/getting-started.html#getting-started). (UserCaches requires version 1.0.0 or greater.)

   ```shell
   # Using the default Ruby install will require you to use sudo when
   # installing and updating gems.
   [sudo] gem install cocoapods
   ```

2. Update your Podfile to include the following:

   ```
   use_frameworks!

   target 'YourAppTargetName' do
       pod 'UserCaches', '~> 0.0.5'
   end
   ```

3. Run `pod install --repo-update`.

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager) is a tool for managing the distribution of Swift code.

1. Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/CUITCHE/UserCaches.git", from: "0.0.3")
]
```

2. Build your project:

```
$ swift build
```

# How to Test

1. `clone` this repo.
2. `cd` the repo directory.
3. Execute order`swift test`.

# Author

[hejunqiu](https://github.com/CUITCHE)

# License

UserCaches is available under the MIT license. 

[TravisBadge]: https://travis-ci.org/CUITCHE/UserCaches.svg?branch=master
[TravisLink]: https://travis-ci.org/CUITCHE/UserCaches
[Swift4Badge]: https://img.shields.io/badge/swift-4.1-orange.svg?style=flat
[Swift4Link]: https://developer.apple.com/swift/
