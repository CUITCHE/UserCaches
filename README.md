# UserCaches
A key-value storage cache tool like `UserDefaults` on iOS Platform. 

# Use

### Normal Usage

Like UserDefaults:

```swift
// Save cache.
let intVal = 123
try UserCaches.standard.set(intVal, forKey: key)
// Get cache. Specify the type('Int') to decide generic type.
let cache: Int = try UserCaches.standard.value(forKey: key)
```

`UserCaches.standard` is a global instance of UserCaches, also could create new instance through:

```swift
let cacheHelper = UserCaches(suiteName: "com.usercache.helper")
// The cache file is located at ${YourAppDocuments}/com.usercache.helper.db
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
    var identifierModel: CacheKeyMode { return .identifier }
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

If you set `identifierModel` to `CacheKeyMode.identifier`, `UserCachesSettable` will translate upper-letter to lower-case letter and insert "." before translate on enum-name and replace "_" with "." On enum-case. 

As above:

"ComBaiduMobileUserSetting"       => "com.baidu.mobile.user.setting"

"privacy_findMeByPhoneNumber" => "privacy.findMeByPhoneNumber"

The `case privacy_findMeByPhoneNumber` is translated to `com.baidu.mobile.user.setting.privacy.findMeByPhoneNumber`, as a key, associated with `true` for this example.

### Default Support Type

UseCaches support by default: 

| Default Support Type                                |
| --------------------------------------------------- |
| Bool                                                |
| Int, Int64, UInt, Uint64                            |
| Float, Double                                       |
| String, Data                                        |
| Date (Implement with TimeInterval)                  |
| Array\<CacheCodable>                                |
| Dictionary\<Key: CacheCodable, Value: CacheCodable> |
| CacheCodability\<Codable>                           |

Especially, if a struct (or class) defer to `Codable`, use CacheCodability wrap the struct (or class), UseCaches also accept it. See above `CacheCodability<User>`