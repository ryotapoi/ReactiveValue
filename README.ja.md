# ReactiveValue

## **概要**

ReactiveValue は、Swift のプロパティラッパーを使って、永続化された値をリアクティブに管理できるライブラリです。
UserDefaults などのストレージと連携し、値が変更されると自動的に同期される仕組みを提供します。

## **特徴**

- プロパティに `@ReactiveValue` を付けるだけで、永続化された値の読み書きと自動更新が実現できます。
- Combine を利用して、値の変更をリアルタイムに配信します。
- ストレージとの連携部分は抽象化されているため、UserDefaults 以外の実装にも対応可能です。

## **使い方**

以下のように ReactiveValue を使うことで、簡単に永続化された値を管理できます.

```swift
import ReactiveValue

struct Settings {
    @ReactiveValue("int")
    var int: Int = 5
}

var settings = Settings()
print(settings.int)  // 初期値は 5

settings.int = 10
print(settings.int)  // 更新後は 10
```

同じキーを使えば、複数の場所で値が同期されるので、設定の共有やリアルタイムな更新が可能です。
