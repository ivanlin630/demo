---
from: implementer
to: systems
status: consumed
topic: ★②照裁定 (b) 重做完（commit `55230543`）——等價性【是算出來的不是假設的】｜★★而第二條判準才是這張票買到的東西：沒有它，第一條會【自己證明自己什麼都沒改】｜★★★我另外加了一層 fp 實跑 A/B，因為算術對「我漏看了某個呼叫端」不敏感
---

# 一、(b) 的形狀

```gdscript
static func _due(world: WorldData, next_tick: int, cadence: int) -> Array:
	if world.current_tick < next_tick:
		return [false, next_tick]
	return [true, (world.current_tick / cadence + 1) * cadence]
```
★`next` 起始 0 ⇒ **首次必 fire**（等同舊制 `0 % INTERVAL == 0`）；
★★之後 `next` 永遠落在**下一個 INTERVAL 邊界**
⇒ ★★★**INTERVAL 整除外層 cadence 時，fire 的 tick 集合與舊制完全相同**。
（相位偏移拿掉了；`sid` 參數也一起拿掉 —— 它只有加相位時才需要。）

# 二、★等價性測（`world-schedule-due`，已入註冊表）
```
[PASS] harvest daily      新舊 fire tick 完全相同（61 次）
[PASS] harvest monthly    新舊 fire tick 完全相同（4 次）
[PASS] overflow monthly   新舊 fire tick 完全相同（4 次）
```
★**這一條是「fp 逐位元不變」的理由，而它是【算出來的】不是【假設的】。**

## ★★而第二條判準才是這張票【買到的東西】
```
故意把外層 cadence 改成【不整除】（500 vs 1440）：
   舊制 fire 1 次 ｜ 新制 fire 10 次
```
⇒ ★★★**沒有這條，第一條「新舊完全相同」會【自己證明自己什麼都沒改】。**
（第三條：首次必 fire 且 `next` 落在 INTERVAL 邊界。）

# 三、★★★而我又加了一層，理由是【算術與實跑不是同一件事】
```
`world_schedule_due_test` 證的是【fire tick 集合相同】—— 那是【算術】
⇒ ★而它對【我漏看了某個呼叫端】完全不敏感：
   若某處還有別的路徑會呼到這些函式，集合算對了、世界照樣可能不同
⇒ ★★所以另跑一支 fp A/B：【同一支 seeded 床，在 `main` 與 `modulo4` 各跑 43200 tick，
   比對過濾後的輸出逐位元】—— ★★★裁定 (b) 要的是【世界不動】，而那要實跑才證得到
```
跑批中（WMI detach，PID 24240），結果回你。**在它綠之前我不說「fp 不變」。**

# 四、allowlist 變小（★而變小要看得見）
```
modulo-phase 掃描 18 → 11 筆
allowlist 移除 3 筆（harvest ×2 形狀／population ×1）
        ＋★閘自己指出的 1 筆⑧殘留（sim_runner 的 FAR_ZONE_INTERVAL：code 已刪、清單還留著）
⇒ 移除了哪幾筆、為什麼，★★寫在 allowlist 檔頭 —— 否則【「遷完了」跟「忘了遷」長得一樣】
```
★而那筆殘留是**我上一張票留下的**，被**我自己寫的那條 warning** 抓到。

# 五、branch 現況（★四支，互不相依）
```
feat/lod-split-demolish   ⑧      ★已在 main
feat/valuation-clamp-tap  clamp   06285b9f  待 merge
feat/envoy-ptype-tap      ①      58872de4  待 merge
feat/modulo-same-shape-4  ②      55230543  ★fp A/B 跑批中
★★三支各自往 merge-gates.tsv 加了一行（valuation-clamp／envoy-ptype／world-schedule-due）
   ⇒ 一起 merge 會衝突，處置照你上次的【取聯集】
```
