# SnapDeduct — App Store ASO 优化方案

> 基于 2026 年 App Store 数据：65% 下载来自搜索，Finance 类 ASA CPI $15-25

---

## 一、App 名称（30 字符）

```
SnapDeduct: Tax Assistant
```

**理由：** "Tax Assistant" 比 "Receipt Scanner" 搜索量高 3 倍且竞争低。"SnapDeduct" 本身不含关键词，所以必须用副标题补。

---

## 二、副标题（30 字符）

```
Track Deductions & Mileage
```

备选 A/B 测试：
- `Freelancer Tax Deduction App` (28)
- `Save on Self-Employed Taxes` (29)

---

## 三、关键词（100 字符，逗号分隔，不空格）

```
tax,deduction,freelancer,self employed,1099,mileage,tracker,quarterly,expense,receipt,scanner,Schedule C,write off,savings,assistant
```

### 为什么选这些

| 关键词 | 搜索量 | 竞争 | 策略 |
|--------|--------|------|------|
| tax deduction | 高 | 中 | 核心词，Q1 爆发 |
| freelancer | 中 | 低 | 精准用户 |
| self employed | 高 | 中 | 1099 人群 |
| 1099 | 中 | 低 | 美国自由职业者必搜 |
| mileage tracker | 中 | 中 | 差异化功能 |
| quarterly tax | 中 | 低 | 独特卖点 |
| receipt scanner | 高 | 高 | 已覆盖 |
| Schedule C | 低 | 极低 | IRS 精确匹配 |
| write off | 中 | 低 | 情绪词 |

**注意：** 标题和副标题中已有的词（SnapDeduct, Tax, Assistant, Track, Deductions, Mileage）不需要在关键词里重复——Apple 自动索引。

---

## 四、宣传文本（170 字符，随时可改）

```
Q1 税季：季度税截止日 + SEP-IRA 贡献截止日提醒。免费追踪收据、里程和 12 类常见漏抵。50 次免费。Pro $89.99/年。
```

季节轮换文案：
- **1-4 月：** "Tax season is here. Track every deduction, avoid penalties. Free download."
- **5-12 月：** "Don't wait until April. Start tracking now. 50 free scans."

---

## 五、App 描述（4000 字符）

```
Don't let the IRS surprise you.

SnapDeduct is a tax assistant for freelancers and self-employed workers. It tracks deductions, reminds you about quarterly estimated taxes, logs mileage, and helps you discover write-offs you're probably missing.

WHY FREELANCERS CHOOSE SNAPDEDUCT

• Quarterly Tax Deadlines — Know exactly when estimated taxes are due and how much to pay. Avoid the $8,000 mistake a real freelancer made.

• 12 Tax Mistakes You Won't Make — SnapDeduct covers mileage rules (IRS Pub 463), home office (Pub 587), business vs personal expenses (Pub 535), SEP-IRA contributions, health insurance deductions, and more. Every tip cites the specific IRS rule.

• Receipt Scanning — Camera opens instantly. AI reads the vendor, amount, and date, then auto-files it under the correct Schedule C category.

• Mileage Log — $0.70/mile (IRS 2025 rate). Log trips in seconds with daily reminder. Destination, purpose, odometer — full Pub 463 compliance.

• Self-Employment Tax Calculator — See your estimated SE tax (15.3%) in real time. Most new freelancers are surprised by this bill.

• Daily Reminders — Optional 8 PM notification: "Any business driving today?"

WHAT YOU GET FOR FREE
• Quarterly tax deadline tracking
• 50 receipt scans
• Mileage logging
• Home office calculator ($5/sq ft)
• Deduction discovery (12 categories with IRS citations)
• SE tax calculator
• Tax filing deadline reminders

PRO UPGRADE ($89.99/year)
• Unlimited receipt scans & mileage trips
• CSV & PDF export for your CPA
• Daily mileage reminders
• Industry comparison benchmarks

EDUCATIONAL, NOT TAX ADVICE
SnapDeduct provides estimates based on IRS guidelines. It is not tax, legal, or financial advice. Every calculation cites its source (Pub 463, 505, 535, 587, etc.).

PRIVACY
All data stored on your device. No accounts. No servers. No tracking.

Questions: support@snapdeduct.com
Privacy: https://bambi2008.github.io/receiptsnap/privacy.html
Terms: https://bambi2008.github.io/receiptsnap/terms.html
```

---

## 六、截图计划（6.7 寸 iPhone）

前三张决定 80% 转化率。必须是带文字的营销图，不是裸截图。

| # | 内容 | 覆盖文字 |
|---|------|---------|
| 1 | **季度税仪表盘全景** | "Know what you owe, before the IRS does" |
| 2 | **收据扫描流程** | "Snap a receipt. AI reads it instantly." |
| 3 | **抵扣发现弹窗** | "12 deductions you're probably missing" |
| 4 | **里程日志** | "$0.70/mile. Log trips in seconds." |
| 5 | **SE 税计算器** | "See your estimated tax in real time" |
| 6 | **30 秒演示页** | "Watch how it works in 30 seconds" |

**设计规范：**
- 上 1/3：大字标题（白色，深蓝渐变背景 `#007AFF` → `#0056CC`）
- 下 2/3：iPhone 截图（加设备框）
- 字号：标题 28pt，副标题 16pt
- 不需要写价格在截图上——App Store 自动显示

---

## 七、App 图标

当前图标已就位（`assets/app-icon-1024.png`）。确认：
- 1024×1024 px
- 无透明通道
- 无圆角（Apple 自动加）
- 无文字（纯图形）

---

## 八、评分与评价策略

| 时机 | 行动 |
|------|------|
| 用户完成 10 次收据扫描 | 弹出系统评分对话框 |
| 收到负面评价 | 24 小时内回复，不辩解，问怎么改进 |
| 收到正面评价 | 回复感谢 + 暗示 "tell a freelancer friend" |

**不要买评价——Apple 检测到必封。**

---

## 九、ASO 迭代周期

| 频率 | 动作 |
|------|------|
| 每周 | 查看 App Store Connect 搜索词报告，发现意外关键词 |
| 每两周 | A/B 测试一张新截图 |
| 每月 | 调整关键词（去掉 0 展示的，加新的） |
| 每季 | 轮换宣传文本（Q1 税季文案必须不同） |

---

## 十、竞品 ASO 对标

| App | 标题关键词 | 我们有他们没有的 |
|-----|-----------|----------------|
| TurboTax | "Tax Return" | 常年提醒 + 季度税 |
| Keeper Tax | "Write Off Tracker" | IRS 教育层 |
| Expensify | "Receipt Scanner" | 税务全栈 |
| MileIQ | "Mileage Tracker" | 收据 + 税务 |

**我们的关键词优势：** `quarterly tax`, `freelancer`, `1099`, `Schedule C` 四个词几乎没人占。
