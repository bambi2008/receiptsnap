# Receipt Scanner App — AI 产品团队定义

> 产品：AI 收据扫描 + 自由职业记账 iOS App
> 目标市场：美国独立自由职业者（年收入 $50K+）
> 目标收入：上线 3 个月内 $1,000 MRR
> 技术栈：待定（React Native / SwiftUI + 云 Mac 构建）

---

## 团队架构总览

```
                    ┌──────────────┐
                    │  我（PM/总监） │
                    │  统筹+决策+质量 │
                    └──────┬───────┘
           ┌───────────────┼───────────────┐
           │               │               │
    ┌──────▼──────┐ ┌─────▼──────┐ ┌──────▼──────┐
    │ 产品策略师   │ │ UI 设计师  │ │ 增长负责人  │
    │ (Phase 0)   │ │ (Phase 1)  │ │ (Phase 4)   │
    └─────────────┘ └────────────┘ └─────────────┘
           │               │               │
    ┌──────▼──────┐ ┌─────▼──────┐        │
    │ iOS 开发者   │ │ QA 工程师  │        │
    │ (Phase 2)   │ │ (Phase 3)  │        │
    └─────────────┘ └────────────┘        │
           │               │               │
           └───────────────┴───────────────┘

         ═══════════ 上线后运营 ═══════════

    ┌──────────────┐        ┌──────────────┐
    │  客户支持     │        │  收入监控     │
    │ (Phase 4+)   │        │ (Phase 4+)   │
    │ 每周2次巡检   │        │ 每周一自动    │
    └──────┬───────┘        └──────┬───────┘
           │                       │
           └───────────┬───────────┘
                       │
                ┌──────▼──────┐
                │  我（PM/总监）│
                │  决策+升级处理 │
                └──────────────┘
```

---

## 角色定义

### 角色 0：Hermes（我）— 产品总监 / 技术主管

**职责：**
- 统筹所有阶段，做出关键决策
- 审批每个阶段的交付物
- 为 subagent 指派任务并提供完整上下文
- 执行两阶段审查（规格审查 + 代码质量审查）
- 处理 subagent 的提问和阻塞

**不做什么：**
- 不自己写代码（交给 iOS 开发者 subagent）
- 不自己画设计稿（交给 UI 设计师 subagent）
- 不自己研究市场（交给产品策略师 subagent）

**工具集：** 全部工具可用

---

### 角色 1：产品策略师（Product Strategist）

**代号：** `product-strategist`
**阶段：** Phase 0（第 1-2 周）
**状态：** 🔜 待激活

**职责：**
1. 竞品深度分析（Expensify、Foreceipt、Smart Receipts、SimplyWise、Wave）
2. 用户痛点验证（Reddit r/freelance、r/tax、r/smallbusiness）
3. 功能优先级排序（MoSCoW 框架）
4. 定价策略（对比竞品、计算 CAC/LTV）
5. MVP 功能清单输出

**输入：**
- 目标市场：美国自由职业者
- 初步方向：AI 收据扫描 + 自动分类 + 报税导出

**输出物：**
- `D:\hermes-workspace\projects\receipt-scanner\docs\competitive-analysis.md` — 竞品矩阵
- `D:\hermes-workspace\projects\receipt-scanner\docs\user-personas.md` — 用户画像
- `D:\hermes-workspace\projects\receipt-scanner\docs\mvp-features.md` — MVP 功能清单（按优先级）
- `D:\hermes-workspace\projects\receipt-scanner\docs\pricing-strategy.md` — 定价策略

**工具集：** `web`, `terminal`, `file`

---

### 角色 2：UI/UX 设计师（UI Designer）

**代号：** `ui-designer`
**阶段：** Phase 1（第 2-4 周）
**状态：** 🔜 待激活（依赖 Phase 0 完成）

**职责：**
1. 用户流程图（拍照→分类→查看→导出）
2. 线框图（关键页面）
3. 视觉设计（色彩、字体、组件）
4. 可交互原型（HTML/CSS 模拟）

**输入：**
- MVP 功能清单（来自产品策略师）
- 用户画像（来自产品策略师）

**输出物：**
- `D:\hermes-workspace\projects\receipt-scanner\docs\user-flows.md` — 用户流程
- `D:\hermes-workspace\projects\receipt-scanner\design\wireframes.html` — 可点击线框图
- `D:\hermes-workspace\projects\receipt-scanner\design\design-system.md` — 设计系统（颜色/字体/间距）

**工具集：** `web`, `terminal`, `file`, browser（用于参考竞品设计）

---

### 角色 3：iOS 开发者（iOS Developer）

**代号：** `ios-developer`
**阶段：** Phase 2（第 4-10 周）
**状态：** 🔜 待激活（依赖 Phase 1 完成）

**职责：**
1. 技术选型（React Native vs SwiftUI vs Flutter）
2. 项目脚手架搭建
3. 按 MVP 功能清单逐任务实现（TDD 流程）
4. 集成 AI OCR 能力（Vision 框架 / 第三方 API）
5. 实现内购/订阅
6. 每个任务提交 git commit

**技术方案初步判断：**
- 我们在 Windows 上开发，需要支持跨平台开发或云 Mac 构建
- **推荐 React Native + Expo**：Windows 可开发，iOS 构建用 EAS Build（云服务）或 MacStadium
- 备选：Flutter + Codemagic

**输入：**
- MVP 功能清单 + 优先级（来自产品策略师）
- 设计稿 + 设计系统（来自 UI 设计师）

**输出物：**
- 完整可运行的 iOS App 源码
- 每个功能任务独立 commit
- 单元测试 + 集成测试

**工具集：** `terminal`, `file`, `web`

---

### 角色 4：QA 工程师（QA Engineer）

**代号：** `qa-engineer`
**阶段：** Phase 3（第 10-11 周）
**状态：** 🔜 待激活（依赖 Phase 2 完成）

**职责：**
1. 功能测试（按 MVP 清单逐项验证）
2. 边界情况测试
3. 多设备/多 iOS 版本兼容性测试计划
4. Bug 报告

**输入：**
- MVP 功能清单
- 完整 App 源码

**输出物：**
- `D:\hermes-workspace\projects\receipt-scanner\docs\test-plan.md` — 测试计划
- `D:\hermes-workspace\projects\receipt-scanner\docs\bug-reports.md` — Bug 报告

**工具集：** `terminal`, `file`

---

### 角色 5：增长负责人（Growth Lead / ASO Specialist）

**代号：** `growth-lead`
**阶段：** Phase 4（第 11-12 周 + 持续）
**状态：** 🔜 待激活（依赖 Phase 3 完成）

**职责：**
1. ASO 策略（关键词研究、标题/副标题/描述优化）
2. 截图和预览视频策划
3. 定价页和 paywall 设计建议
4. 冷启动获取首批用户计划
5. Reddit/Twitter/Product Hunt 发布策略

**输入：**
- App 功能完整清单
- 竞品分析（来自产品策略师）

**输出物：**
- `D:\hermes-workspace\projects\receipt-scanner\docs\aso-strategy.md` — ASO 关键词和元数据
- `D:\hermes-workspace\projects\receipt-scanner\docs\launch-plan.md` — 发布计划
- `D:\hermes-workspace\projects\receipt-scanner\docs\growth-experiments.md` — 增长实验清单

**工具集：** `web`, `terminal`, `file`

---

### 角色 6：客户支持 Agent（Customer Support）

**代号：** `customer-support`
**阶段：** Phase 4+ 持续运行
**状态：** 🔜 待激活（App 上线时激活）

**职责：**
1. 回复用户邮件/App Store 评论（通过预设模板 + AI 判断升级人工）
2. 常见问题知识库维护
3. Bug 报告收集和分类（严重 → 升级给 PM，常见 → FAQ）
4. 功能请求收集整理

**为什么需要这个角色：**
- App Store 评分直接影响 ASO 排名和下载转化
- 快速回复差评可以挽回用户，回复率达到 80%+ 可提升评级
- 200 个付费用户量级，一个人 + AI 模板完全可以应付

**运行模式：**
- 不常驻运行，每周 1-2 次批量处理
- 我（PM）设置 cron job：每周一、四检查新评论和邮件
- 低优先级问题用模板回复，高优先级升级给我决策

**输出物：**
- `D:\hermes-workspace\projects\receipt-scanner\docs\faq.md` — 常见问题知识库
- `D:\hermes-workspace\projects\receipt-scanner\docs\support-templates.md` — 回复模板

**工具集：** `web`, `terminal`, `file`


### 角色 7：收入监控 Agent（Revenue Monitor）

**代号：** `revenue-monitor`
**阶段：** Phase 4+ 持续运行
**状态：** 🔜 待激活（App 上线时激活）

**职责：**
1. 每周拉取 App Store Connect 收入数据
2. 追踪关键指标：MRR、付费用户数、转化率、流失率
3. 异常预警（收入骤降、退款激增）
4. 生成每周收入简报

**支付相关说明：**
- **支付处理**：完全由 Apple IAP（In-App Purchase）处理，不需要我们搭建支付系统
- **退款/争议**：由 Apple 处理，我们不需要介入（Apple 从用户扣款、给开发者分成、处理退款全流程）
- **税务**：Apple 代扣代缴部分国家的税，美国 1099 由 Apple 出具
- **我们只需要**：设置好 App Store Connect 的银行账户和税务信息

**运行模式：**
- Cron job：每周一自动拉取 App Store Connect 数据
- 生成简报推送给 PM
- 异常自动告警

**输出物：**
- 每周收入简报（文字 + 关键数字）
- 异常告警（当指标超出阈值时）

**工具集：** `web`, `terminal`, `file`


---

## 工作流程：阶段门控

```
Phase 0: 产品策略   ──[审批门]──▶  Phase 1: UI 设计
                                          │
                                     [审批门]
                                          │
                                          ▼
                                    Phase 2: 开发（多轮 TDD）
                                          │
                                     [审批门]
                                          │
                                          ▼
                                    Phase 3: QA 测试
                                          │
                                     [审批门]
                                          │
                                          ▼
                                    Phase 4: 上线 + 增长
```

**每个阶段门控标准：**
- 输出物完整且质量达标
- 关键决策有数据支撑（不靠直觉）
- 下一阶段的输入明确

---

## Phase 2 开发阶段细化：TDD + 双审流程

开发阶段不一次性交给 subagent，而是走 `subagent-driven-development` 流程：

```
对每个功能任务：
  1. 我（PM）把任务描述 + 上下文发给 ios-developer subagent
  2. ios-developer 按 TDD 实现（写测试 → 写代码 → 验证）
  3. 我审查输出（规格审查 + 质量审查）
  4. 通过 → 下一个任务
  5. 不通过 → 修复 → 重新审查
```

**为什么不用一次性大任务？**
- 每个 subagent 有 context window 限制
- 小任务出问题容易定位，不会滚雪球
- 每个任务都有 review gate，质量有保证

---

## 团队沟通协议

1. **我（Hermes）是唯一决策者** — subagent 不做产品决策，只执行
2. **subagent 可以提问** — 遇到模糊需求时主动问，不要猜
3. **文档驱动** — 所有输出物写入 `D:\hermes-workspace\projects\receipt-scanner\docs\`
4. **每阶段有明确交付物** — 没有「差不多」，只有「完成/未完成」
5. **我负责跨阶段上下文传递** — subagent 之间不直接通信，我作为中转

---

## 立即启动：Phase 0

✅ 团队定义完成
🔜 下一步：激活 `product-strategist`，开始竞品分析和 MVP 定义

**审批检查：以上团队结构是否批准？确认后立即启动 Phase 0。**
