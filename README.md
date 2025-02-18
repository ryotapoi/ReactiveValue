# ReactiveValue

## **Overview**

ReactiveValue is a library that allows you to manage persistent values reactively using Swift property wrappers.  
It integrates with storage systems such as UserDefaults to automatically synchronize values when they change.

## **Features**

- By simply adding `@ReactiveValue` to a property, you can enable reading, writing, and automatic updating of persistent values.
- It leverages Combine to deliver real-time notifications when values change.
- The storage interface is abstracted, making it compatible with implementations beyond just UserDefaults.

## **Usage**

Using ReactiveValue is as simple as annotating your property. For example:

```swift
import ReactiveValue

struct Settings {
    @ReactiveValue("int")
    var int: Int = 5
}

var settings = Settings()
print(settings.int)  // The initial value is 5

settings.int = 10
print(settings.int)  // The updated value is 10
```

When using the same key across different parts of your app, values are automatically synchronized, allowing for shared settings and real-time updates.
