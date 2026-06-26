# SnapDeduct — App Store ASO（竞品实数据修正版）

> 基于 2026-06-26 iTunes Search API 实时抓取的 15 个竞品数据

---

## 一、竞品全景

| App | 评分 | 评价数 | 定价 | 关键词战术 |
|-----|------|--------|------|-----------|
| TurboTax | 4.79 | 938K | 免费+付费报税 | "File Your Tax Return" |
| Keeper | 4.78 | 12K | 免费+订阅 | "Tax Filing and Expenses" |
| MileIQ | 4.77 | 105K | $5.99/月 | "Mileage Tracker and Log" |
| Everlance | 4.83 | 50K | $8/月 | "Mileage Tracker" |
| Hurdlr | 4.74 | 20K | $7.99/月 | "Mileage, Expenses and Tax" |
| **Stride** | **4.84** | **92K** | **完全免费** | "Mileage and Tax Tracker" |
| SimplyWise | 4.85 | 35K | 免费+订阅 | "Receipts, Expenses" |
| Smart Receipts | 4.76 | 12K | $4.99/月 | "Expenses and Tax" |
| Driversnote | 4.78 | 37K | $9.99/月 | "Mileage Tracker" |
| Expensify | 4.63 | 154K | $5-9/月 | "Travel and Expense" |

---

## 二、没人占的关键词（我们的机会）

通过分析 15 个竞品标题+副标题，**以下词零竞争**：

| 关键词 | 为什么重要 | 有人用吗 |
|--------|-----------|---------|
| `quarterly tax` | 独有功能 | ❌ 0/15 |
| `tax assistant` | 定位差异化 | ❌ 0/15 |
| `Schedule C` | IRS 精确匹配 | ❌ 0/15 |
| `IRS compliant` | 信任信号 | Driversnote 有但不稳定 |

**这四个词必须进关键词字段。**

---

## 三、修正后的 App Store 配置

### 名称（30 字符）
```
SnapDeduct: Tax Assistant
```
**理由：** 没有人用 "Tax Assistant"——这是不占地。TurboTax 用 "File Your Tax Return"，Keeper 用 "Tax Filing"。

### 副标题（30 字符，A/B 测试两版）
```
Track Quarterly Tax & Miles
```
**理由：** "Quarterly" 是没人碰的词。"Miles" 比 "Mileage" 短 3 个字符，省下来的空间可以加别的。

### 关键词（100 字符，0 空格）
```
deduction,self employed,freelancer,1099,quarterly,Schedule C,IRS,receipt,log,reminder
```

**已经自动索引的（不用浪费关键词字符）：**
- `SnapDeduct`（标题）
- `Tax Assistant`（标题）
- `Track Quarterly Tax Miles`（副标题）

Apple 会自动把标题+副标题的每个词都加入搜索索引。

---

## 四、定价分析

| 竞品 | 月付 | 年付 |
|------|------|------|
| Smart Receipts | $4.99 | $49.99 |
| MileIQ | $5.99 | $59.99 |
| Hurdlr | $7.99 | $59.99 |
| Everlance | $8 | $60 |
| **SnapDeduct** | **$8.99** | **$89.99** |
| Driversnote | $9.99 | $99.99 |

我们在上半区，合理。**但需要 A/B 测试 $79.99/年**——Driversnote 和 Hurdlr 之间巨大的空隙没人填。

---

## 五、最大威胁：Stride

| | Stride | SnapDeduct |
|--|--------|------------|
| 价格 | $0 | $89.99/年 |
| 评分 | 4.84 (92K) | 0 (新品) |
| 里程 | ✅ 自动 GPS | ✅ 手动日志 |
| 税务提醒 | ❌ | ✅ 季度税引擎 |
| IRS 教育 | ❌ | ✅ 12 类 + 出处 |
| 收据 OCR | ❌ | ✅ |
| SE 税计算 | ❌ | ✅ |

**应对：** 不在里程上跟 Stride 拼（他们免费 + 自动 GPS），在**税务智能**上打差异化。文案强调："Stride doesn't tell you about quarterly taxes."

---

## 六、截图对标

前 3 名 App 的截图风格：

| App | 风格 |
|-----|------|
| Keeper | 深色渐变背景 + 大字 + iPhone 截图 |
| Hurdlr | 品牌色背景 + "$X saved" 数据展示 |
| Everlance | 白色背景 + 里程数字放大 |

**我们采用：** 深蓝渐变 + 数据展示路线。第一张截图必须出现数字（$）。用户 3 秒决定下载，$ 符号比文字快 10 倍。

---

## 七、上线后跟踪

| 指标 | 查看位置 | 频率 |
|------|---------|------|
| 展示量 | App Store Connect → Analytics | 每天 |
| 关键词排名 | 搜索 "quarterly tax" 等 | 每周 |
| 竞品评分 | iTunes API | 每月 |
| 转化率 | ASA 后台（Q1 启用） | 每天 |
