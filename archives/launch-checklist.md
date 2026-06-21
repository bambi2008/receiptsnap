# SnapDeduct — 投放执行清单（照着做）

> 网站已上线：https://lively-dango-84cbb0.netlify.app
> 邮箱捕获：Formspree（已验证可用）
> 目标：一周内引 300-500 个精准访客，看转化率决定生死

---

## 一、即用投放链接（复制粘贴）

每个渠道一条专属链接，末尾的 `?utm_...` 用来区分流量来源。

```
Reddit r/freelance:
https://lively-dango-84cbb0.netlify.app/?utm_source=reddit&utm_campaign=freelance

Reddit r/SideProject:
https://lively-dango-84cbb0.netlify.app/?utm_source=reddit&utm_campaign=sideproject

Reddit r/juststart:
https://lively-dango-84cbb0.netlify.app/?utm_source=reddit&utm_campaign=juststart

Reddit 司机/卖家细分（r/uberdrivers, r/Etsy）:
https://lively-dango-84cbb0.netlify.app/?utm_source=reddit&utm_campaign=niche

付费广告（Reddit/Facebook/Instagram）:
https://lively-dango-84cbb0.netlify.app/?utm_source=paid_ads

Twitter / X:
https://lively-dango-84cbb0.netlify.app/?utm_source=twitter

冷启动私信 DM:
https://lively-dango-84cbb0.netlify.app/?utm_source=dm
```

---

## 二、一周行动表（逐天照做）

### 📅 第 1 天（周一）— Reddit 故事帖
1. 登录 Reddit，先花 10 分钟在 r/freelance 正常浏览、给几个帖子点赞/评论（养号，别一上来就发广告）
2. 发帖：复制 `reddit-ad-copy.md` 里的 **Post A**
3. 标题：`I lost ~$2,000 in tax deductions last year because I couldn't find my receipts. So I built something.`
4. **链接不要放正文** —— 发完后，自己在评论区回一条，放 r/freelance 的 UTM 链接
5. 接下来几小时盯着，每条评论都回

### 📅 第 2 天（周二）— Reddit 建设者帖 + 开广告
1. 发 **Post B** 到 r/SideProject（用 sideproject 链接）
2. 开第一个付费广告：
   - 平台：Reddit Ads 或 Facebook Ads（二选一，先试一个）
   - 文案：用 `reddit-ad-copy.md` 的 **Ad Set 1（痛点型）**
   - 预算：$10/天
   - 链接：用 paid_ads 那条
   - 定向：美国 + 自由职业/自雇/Uber司机/Etsy卖家，25-45岁

### 📅 第 3 天（周三）— 细分人群 + 冷启动私信
1. 发 **Post D** 到 1-2 个细分版（r/uberdrivers 或 r/Etsy，用 niche 链接）
2. 私信 10 个自由职业者（Reddit/Twitter 上找），用 `reddit-ad-copy.md` 的 **冷启动 DM 模板**

### 📅 第 4 天（周四）— Twitter + 更多私信
1. 发 **Twitter 三连发**（reddit-ad-copy.md 里的 Tweet 1/2/3）
2. 在报税相关的推文下真诚回复，自然带出工具
3. 再私信 10 个人

### 📅 第 5 天（周五）— 助人帖
1. 发 **Post C** 到 r/smallbusiness（价值优先，科普 IRS 数字收据规则）

### 📅 第 6-7 天（周末）— 算账，做决策
1. 数据汇总（见下方"怎么读结果"）
2. 对照决策门，决定：全力做 / 谨慎推进 / 换方向

---

## 三、怎么看数据（两个数字）

### 数字 1：访客数
- 去 **Netlify 后台** → 你的项目 → **Analytics**（如果没开，去 Site settings 开 Netlify Analytics，或在落地页加 Plausible）
- 或者粗略估：Reddit 帖子的浏览量 + 广告后台的点击数

### 数字 2：邮箱数
- 去 **Formspree 后台** → SNAPDEDUCT → Submissions
- 数有多少真实邮箱（排除你的测试那条）

### 转化率 = 邮箱数 ÷ 访客数

```
> 8%    🟢 强需求 → 回到 Mac，flutter run，全力上线
4-8%    🟡 真实但小众 → 谨慎推进，优化定位
2-4%    🟠 偏弱 → 重新想价值主张或换更精准人群
< 2%    🔴 需求不足 → 省下3个月，换个点子
```

---

## 四、三条保命规则（别踩雷）

```
1. 每个 Reddit 版块先读规则 —— 很多版直接禁链接，违规会封号
2. 链接放评论，不放正文 —— 正文带链接最容易被当广告删
3. 别把同一段文字发多个版 —— Reddit 反垃圾会 shadowban 你
   → 每个版的帖子都要重写，不能复制粘贴
```

---

## 五、比转化率更重要的：跟真人聊

数字告诉你"有没有需求"，对话告诉你"为什么"。本周务必找 **5 个真实美国自由职业者**聊 15 分钟（Reddit私信、朋友的朋友、Upwork都行），问：

1. "你现在怎么处理收据和报税？"
2. "报税季最痛苦的是什么？"
3. "现在用什么工具？最讨厌它哪点？"
4. "如果有个工具解决了 [他说的痛点]，你愿意付多少钱？"
5. "$40/年你会买吗？为什么会/不会？"

**听他们会不会主动描述出我们假设的痛点。** 如果 5 个人里有 3 个说"对，这就是我的问题，我愿意付钱"——绿灯。如果都说"还行吧用不上"——红灯。

---

## 六、今天就做的第一件事

```
1. （可选）删掉 Formspree 后台那条测试数据
2. 打开 docs/reddit-ad-copy.md，复制 Post A
3. 登录 Reddit → r/freelance → 发帖
4. 评论区贴这条链接：
   https://lively-dango-84cbb0.netlify.app/?utm_source=reddit&utm_campaign=freelance
5. 守着回复，每条都认真回
```

**别再加功能、别再改代码。现在唯一重要的事：让真实的人看到、并决定要不要留邮箱。**
