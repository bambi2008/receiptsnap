# SnapDeduct — Mac 端完整工作清单

> 按顺序执行，每步有具体命令。有不确定的停在这一步，先别往下走。

---

## 当前状态确认

```
仓库路径：  ~/Projects/receiptsnap/app
当前分支：  master（v1 收据扫描器）
模拟器：    已启动，flutter run 成功
代码状态：  0 errors

待做：
  □ UI 三页验证
  □ Vision OCR 替换 ML Kit
  □ StoreKit IAP 配置
  □ 应用图标换新
  □ 真机测试（如果你有 iPhone）
  □ TestFlight 打包
  □ App Store Connect 上架配置
```

---

## 1. UI 三页验证（5 分钟）

在模拟器 `flutter run` 状态下，逐一切换底部三个标签，确认内容正常：

### Camera 页 ✅ 已确认
取景框、"Free: 50"、快门按钮、三标签导航都正常。

### Receipts 页 ⬜
切过去后应看到：
- 蓝色渐变卡片，写 "THIS MONTH / 0 receipts / $0.00 in deductions"
- 下面是空（没有收据记录）

**如果看不到蓝色卡片或页面报错** → 截图发来

### More 页 ⬜
切过去后应看到：
- "FREE" 角标 + "0 of 50 receipts used" + 蓝色进度条
- "Upgrade to Pro" 按钮
- 下面 5 个菜单项（Export History / App Settings / Help & Support / Privacy Policy / Terms of Service）
- 底部 "SnapDeduct v1.0.0 · Made with ❤️ for freelancers"

**如果订阅卡上的 App 名还写的旧名 "ReceiptSnap"** → 需要重新编译：`flutter clean && flutter pub get && flutter run`

---

## 2. 应用图标（5 分钟）

模拟器上现在可能显示的是 Flutter 默认图标。检查一下：按 `Cmd+H` 回到模拟器桌面，看 SnapDeduct 的图标是什么。

仓库里已经有生成好的图标（之前提交的），用这个脚本一键应用：

```bash
cd ~/Projects/receiptsnap

# 如果图标生成脚本存在，直接跑
# 否则手动替换：找一张 1024×1024 的 app_icon.png，放到 app/ios/Runner/Assets.xcassets/AppIcon.appiconset/

# 最简单：用 flutter_launcher_icons 包
cd app
flutter pub add flutter_launcher_icons --dev
```

然后在 `app/pubspec.yaml` 末尾加上（如果还没加）：
```yaml
flutter_launcher_icons:
  ios: true
  image_path: "../icons/app_icon_1024.png"
```

跑：
```bash
flutter pub get
dart run flutter_launcher_icons
flutter run
```

图标更新后，模拟器桌面 app 名应显示为 **SnapDeduct**（不是 receiptsnap）。

---

## 3. Vision OCR 替换（核心改造，30 分钟）

当前 OCR 用的是 Google ML Kit（跨平台方案）。iOS 上有更好的选择：**Apple Vision 框架**，免费、离线、比 ML Kit 快 2-3 倍。

### 3.1 创建原生 OCR 桥接

在 `app/ios/Runner/` 下创建 `VisionOCR.swift`：

```swift
import Vision
import UIKit

class VisionOCR {
    static func recognize(imagePath: String, completion: @escaping (String?) -> Void) {
        guard let uiImage = UIImage(contentsOfFile: imagePath),
              let cgImage = uiImage.cgImage else {
            completion(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            completion(text)
        }
        request.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global().async {
            try? handler.perform([request])
        }
    }
}
```

### 3.2 在 AppDelegate 注册 Method Channel

打开 `app/ios/Runner/AppDelegate.swift`，在 `application` 方法里加：

```swift
let controller = window?.rootViewController as! FlutterViewController
let ocrChannel = FlutterMethodChannel(name: "com.snapdeduct.app/ocr", binaryMessenger: controller.binaryMessenger)

ocrChannel.setMethodCallHandler { call, result in
    if call.method == "recognizeText", let args = call.arguments as? [String: Any], let path = args["path"] as? String {
        VisionOCR.recognize(imagePath: path) { text in
            result(text ?? "")
        }
    } else {
        result(FlutterMethodNotImplemented)
    }
}
```

### 3.3 Flutter 端调用原生 OCR

替换 `app/lib/services/ocr_service.dart` 的 `processImage` 方法：

```dart
import 'dart:io';
import 'package:flutter/services.dart';
import '../config/categories.dart';

class OcrResult {
  final String vendorName;
  final double amount;
  final String category;
  final DateTime? date;
  OcrResult({required this.vendorName, required this.amount, required this.category, this.date});
}

class OcrService {
  static const _channel = MethodChannel('com.snapdeduct.app/ocr');

  static Future<OcrResult> processImage(String imagePath) async {
    final rawText = await _channel.invokeMethod<String>('recognizeText', {'path': imagePath}) ?? '';
    final lines = rawText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final vendor = _extractVendor(lines);
    final amount = _extractAmount(lines, rawText);
    final date = _extractDate(rawText);
    final category = guessCategory(vendor);

    return OcrResult(
      vendorName: vendor.isNotEmpty && vendor.length >= 2 ? vendor : 'Unknown Vendor',
      amount: amount > 0 ? amount : 0.0,
      category: category,
      date: date,
    );
  }

  // 保留现有的 _extractVendor, _extractAmount, _extractDate 方法
  // ...（不变，复制过来）
}
```

### 3.4 测试

```bash
cd ~/Projects/receiptsnap/app
flutter clean
flutter pub get
flutter run
```

在模拟器上，点画廊按钮选一张图片（提前拖一张收据图片到模拟器里），看 OCR 是否跑通。

---

## 4. StoreKit 2 IAP 配置（20 分钟）

### 4.1 App Store Connect 创建产品

1. 登录 https://appstoreconnect.apple.com
2. 进入你的 App → **Subscriptions** → 创建订阅组 "SnapDeduct Pro"
3. 创建两个产品：

| 产品 ID | 类型 | 价格 |
|---------|------|------|
| com.snapdeduct.pro.monthly | Auto-Renewable | $6.99 |
| com.snapdeduct.pro.annual | Auto-Renewable | $39.99 |

4. 添加本地化（英文）：显示名称 "SnapDeduct Pro Monthly" / "SnapDeduct Pro Annual"

### 4.2 Xcode 签名配置

App Store Connect 建好 App 后：
1. Xcode 打开 `app/ios/Runner.xcworkspace`
2. Signing & Capabilities → 选你的 Team
3. Bundle Identifier 填 `com.snapdeduct.app`
4. 勾选 "In-App Purchase" capability

### 4.3 测试 IAP

```bash
# 用 StoreKit 配置文件在模拟器测
# Xcode → Product → Scheme → Edit Scheme → Options → StoreKit Configuration
```

或直接等 TestFlight 真机测——模拟器 IAP 测不准。

---

## 5. 真机测试（如果你有 iPhone）

```bash
# 连 iPhone → 信任电脑 → Xcode 里选你的设备
flutter run -d <device-id>

# 或者直接在 Xcode 里点 Run，选你的 iPhone
```

真机上验证：
- 拍照功能能用（模拟器不行）
- Vision OCR 能跑
- UI 在各种尺寸下正常

---

## 6. TestFlight 打包（上架前最后一步）

```bash
cd ~/Projects/receiptsnap/app
flutter build ios --release

# 然后用 Xcode 打开 Runner.xcworkspace
# Product → Archive → Distribute App → App Store Connect
```

上传后在 App Store Connect 的 TestFlight 里添加内部测试员，就可以让别人安装了。

---

## 7. App Store 正式提交清单

提交前确认：
```
□ App 名称：SnapDeduct: Tax Savings Tracker
□ 副标题：See your tax savings grow
□ 关键词填好（docs/aso-launch-strategy.md 里有）
□ 隐私政策 URL 有效
□ 服务条款 URL 有效
□ 截图已上传（6 张）
□ IAP 产品和首版一起提交
□ 审核备注写好（免费 50 张试用说明）
```

完整上架文案在 `docs/aso-launch-strategy.md`，直接复制粘贴到 App Store Connect。

---

## 8. 快速参考

```
flutter run             → 模拟器运行
flutter build ios       → 打 release 包
flutter clean            → 清缓存重来
flutter pub get          → 装依赖
open -a Simulator        → 开模拟器
xcrun simctl list        → 列出模拟器
```

---

## 紧急联系 Hermes

如果某个步骤卡住了：
1. 截图发 Windows 上的 Hermes
2. 或者 Mac 上装 Hermes：`curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash`
3. Mac Hermes 可以帮我直接在 Mac 上操作（连 Xcode、改代码）

---

## 对应任务优先级

```
P0（上线必须）:
  □ UI 验证（Receipts + More 页）
  □ Vision OCR 替换
  □ App 图标
  □ Xcode 签名 + Bundle ID

P1（重要）:
  □ StoreKit IAP 创建
  □ TestFlight 打包

P2（验证后）:
  □ 真机测试（需要 iPhone）
  □ App Store 正式提交
```
