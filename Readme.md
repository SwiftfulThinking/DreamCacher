
# Welcome to DreamCacher

*** NOTE: THIS FRAMEWORK IS A WORK IN PROGRESS AND WILL LIKELY CHANGEIN FUTURE UPDATES ***

### Overview

DreamCacher uses the FileManager to create a local cache on the device. You may use the default cache or create your own instances. All instances of DreamCache are limited by an aggregate cache size limit, however, the instance can also have its own sub-limit. All caches are automatically managed and will remove the least recently used elements until space is available.

## Installation

**Firstly, import the package to your file.**

```swift
import DreamCacher
```



**Then, optionally update the default configuration:**
```swift
DreamCache.updateConfiguration(maximumAllowedSizeInMB: 10, isPrintEnabled: true)
```
- By default, DreamCacher will not have a size limit set by the Framework. However, items will still be saved in the Caches Directory of the FileManager, which has built-in limits that are managed by the device.
- By calling DreamCache.updateConfiguration, you will set an aggregate size limit for all instances of DreamCache.
- You may allow printing for debugging purposes. However, it is recommended to disable printing in production.



## Usage

**There is a default cache that you can immediately use:**

```swift
let cache = DreamCache.shared
```
- This cache will have the same maximum size limit as the aggregate cache (set by calling DreamCache.updateConfiguration() ).
- This cache is named "default".



**Or you can create your own instances of DreamCache:**
```swift
let cache = DreamCache(name: "MyNewCache")
let cache = DreamCache(name: "MyNewCache", maximumAllowedSizeInMB: 10)
```
- By default, new instances will have no limit, however they will still be limited by the aggregate cache limit (set by calling DreamCache.updateConfiguration() ).
- Instances of DreamCache can additionally have their own sub-limit, set within the initializer.
- New instances of DreamCache should have a valid name. Do not initialize with a blank string "" or the word "default", which is already in use.



**Start saving items to the cache:**
```swift
cache.save(imageJPG: UIImage, forKey: String)
cache.save(imagePNG: UIImage, forKey: String)
cache.save(videoMP4AtUrl: URL, forKey: String)
cache.save(audioMP3AtUrl: URL, forKey: String)
cache.save(object: Codable, forKey: String)
cache.save(objects: [Codable], forKey: String)
cache.save(value: Any, forKey: String)
cache.save(array: [Any], forKey: String)
cache.save(bool: Bool, forKey: String)
cache.save(string: String, forKey: String)
```
- DreamCacher supports many Types, including images, audio/video urls, and Codable types.
- The save() function returns a Result.
- Although there are convenience methods to save Any, it is recommended to use the explicit function for the Type you are saving when it is known. The Any initializers will attempt to find the correct file type but may fail.
- Although DreamCacher supports Codable, it may be more efficient to store Codable types elsewhere, such as CoreData.
- Although DreamCacher supports Strings and Bools, it may be more efficient to store simple types elsewhere, such as UserDefaults.



**Read saved items from the cache:**
```swift
let image = cache.image(forKey: String)
let videoURL = cache.video(forKey: String)
let audioURL = cache.audio(forKey: String)
let model: MyModel? = cache.object(forKey: String)
let models: [MyModel]? = cache.objects(forKey: String)
let any = cache.any(forKey: String)
let array = cache.array(forKey: String)
let bool = cache.bool(forKey: String)
let string = cache.string(forKey: String)
```
- Returned Types are all optional. The function may return nil if the item doesn't exist or the item is not the requested Type.



**Manually delete items if needed:**
```swift
cache.delete(forKey: String)
```
- This is a convenience method but does not have to be called. The cache will manage itself based on the instance cache size as well as the aggregate cache size.


**Other convenience methods:**

```swift
/// Name used for this instance of DreamCache.
let cacheName = cache.cacheName

// Current size of all storage in this cache instance.
let cacheSize = cache.cacheSize

/// Maximum size of storage in this instance of DreamCache in bytes. 0 means no limit.
let cacheLimit = cache.cacheSizeLimit

// Maximum size of all storage in DreamCacher in bytes, including shared instance and created instances. 0 means no limit.
let aggregateSize = DreamCache.aggregateCacheSize

// Current size of all storage in DreamCacher (aggregate across all instances).
let aggregateLimit = DreamCache.aggregateCacheSizeLimit

// Manually delete DreamCache folders and files
DreamCache.deleteAllDreamCachers()
```

## Additional Configuration & Notes

Supported Platforms:
- iOS
- tvOS
- watchOS
- macOS (Catalyst)

Updates:
- [x] Unit Tests for DreamCache.swift 
- [ ] Unit Tests for DreamCacherInteractor.swift 
- [ ] Add a 'priority' to instances of DreamCache to managing cache sizes more efficiently
- [ ] Add configuration to save to other FileManager directories (not just .caches)
- [ ] Add convenience method to delete a single cache entirely (currently only supports .deleteAllDreamCachers)
- [ ] Asynchronous methods (background threads + NSFileCoordinator)
