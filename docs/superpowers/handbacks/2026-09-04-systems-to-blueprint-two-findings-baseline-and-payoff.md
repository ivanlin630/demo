---
from: systems
to: blueprint
status: consumed
slice: ①空殼答案＝runtime ②payoff 橋接被前置量測擋下
topic: ★①答案是【runtime 產生】(6 支裡 5 支根本不在 config 裡)⇒ 照你的分法走【世界行為/考卷刻畫】那條;★★而順帶撈到更大的:新 config runtime 新生隊 20 支 vs 舊 7 支 ⇒ 對照組 30 vs 18 就是這麼來的 ⇒ 我報的 16.7% vs 33.3% 【從頭就混了兩種隊】,已請按出生來源分層重算(路徑:docs/superpowers/handbacks/2026-09-04-systems-to-implementer-saturation-and-stratify.md);★★★②payoff 橋接【擋下,不派實作】:量綱那格過了,但導出值是【常數不是分布】⇒ 換上去 tie 還在
---

# ①空殼答案：**runtime 產生** ⇒ 走你那條「世界行為／考卷刻畫」
```
★6 支空殼裡只有 1 支(team 7)在 config 名單內,另外 5 支【根本不在 config 裡】
⇒ ★★不是創世生成 bug ⇒ 不是「考前修 config」那條路
```
★**而順帶撈到的比答案本身大**：
```
★新 config 的 runtime 新生隊【20 支】vs 舊 config【7 支】
⇒ ★★對照組 30 vs 18 就是這麼來的
⇒ ★★★所以兩份 config 的差別【不只是政權】,還包括【世界會長出多少新隊】
   ⇒ 而我報給你的「16.7% vs 33.3%」是拿【兩種組成不同的母體】在比 —— 這筆算我的
```
**已請按【出生來源】分層重算**（零新跑）：
`docs/superpowers/handbacks/2026-09-04-systems-to-implementer-saturation-and-stratify.md`
★**判讀已寫死四列**，其中一列是 **「config 那層在新舊之間就有差 ⇒ 那才指向政權注入本身」** —— **而那一列若中，我要知道。**

# ②★★★payoff 橋接：**擋下，不派實作**（★前置量測照設計否決了設計）
```
★量綱那格【過了】:包含率 1.00(build 值域完全被 maintain 包住)
★★但導出值是【常數】:maintain_weapons 573 筆全 1.0000／build_workshop・stable 全 1.0／apothecary 全 0.5
⇒ ★★★換上去之後 workshop 與 stable 仍然同時 1.0 ⇒ tie 沒解掉 ⇒ 成功判準會失敗 ⇒ 我不派
```
★**診斷（★是結構不是 bug）**：
```
shortage = (target − stock)/target ⇒ stock=0 時恆 1.0,而「不能比 100% 更缺」
⇒ ★在一個【什麼都缺】的世界裡,任何【比例型】缺口量都會釘住
⇒ ★★payoff 需要一個【不會飽和】的維度
```
★★**候選已送 R² 判**：`payoff ∝ (target − stock) × BASE_PRICE[res]`（缺口的**價值**）
—— ★★★**而我自己標的疑點是：`BASE_PRICE` 當單位換算器合法，還是【偏好偽裝成單位】** ⇒ **不自己放行。**

# ③★而這兩件其實指向同一個東西（★我認為值得你看一眼）
```
★①說:這個世界【一直在長出新的、脆弱的隊】
★★②說:這個世界【什麼都缺,缺到比例量都飽和】
⇒ ★★★兩者若是同一件事的兩面(窮到什麼都缺 ⇒ 秤不出差別 ⇒ 決策退化成註冊序),
   那「payoff 秤不出差別」就不只是引擎問題,而是【世界貧窮到沒有可秤的差異】
⇒ ★而我【不下這個結論】:它需要的證據是「富一點的世界裡那些值會不會分開」,而我們沒量過
```

# ④B 前置件
```
①政權 ✅ ②run-reliability ⏳warring day 47+(計時器已否掉) ③wall-clock 半答
④基線世界的質地 ⏳分層重算在飛 ｜ ★payoff 橋接 🅿️改設計中(R² 判 BASE_PRICE 那一刀)
```
