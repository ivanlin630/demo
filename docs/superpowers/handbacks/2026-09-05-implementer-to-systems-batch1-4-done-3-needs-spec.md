---
from: implementer
to: systems
status: consumed
slice: ★④【做完】（branch `feat/arbiter-deny-by-option` @ `181dfd33`）★★而③【沒有 spec】—— 我停下來問，不自己挑形狀
touches: `task_arbiter.gd`／`faction_ai_system.gd`／`three_tickets_bed.gd`
topic: ★★★④做完:`try_set` 擋因帶 option 名,**零 caller 改動**(新增有預設值的 `_opt`)、**零行為改動**(不動 `_source`——它會寫進 `task_reason` 並與 `ENGINE_SOURCES` 比對);★8 日 smoke 逐項對帳平:優先序不足 46＝7+23+3+3+7+3、持守擋班 15＝15 ⇒ ★★徵收吃掉 61 次引擎路被擋裡的 **38 次**;★★★而③【新鮮度洗白】**`docs/superpowers/specs/` 裡沒有它的 spec** —— 而它有【兩種形狀】(逐欄位時戳 vs 只帶真的觀察到的欄位),★我不挑
---

# ★①④做完（★而做法比原本設想便宜很多）
```
★原本我報的形狀是「要在 `try_set` 帶 option 名 ⇒ 動到全站 59 caller 的簽名」
⇒ ★★而實際做法：**新增一個【有預設值】的參數 `_opt: String = ""`**
   ⇒ ★★★59 個 caller 【一個都不用改】（簽名相容），而只有引擎統一路那一個站點傳它
★而【不動 `_source`】的理由要留著：`_source` 會被寫進 `team.task_reason`，
   ★★而那個值要與 `ENGINE_SOURCES` 白名單比對（`task_arbiter:127-128`）
   ⇒ ★★★把 option 名塞進 `_source` ＝ **改行為**，而它會安靜地改掉 self-replace 的判定
```
★★**8 日 smoke（★逐項對帳平）**：
```
引擎路被擋：優先序不足 **46** ｜ 持守擋班 **15**
   優先序不足／建設 7 ＋ 徵收 **23** ＋ 求和 3 ＋ 生產 3 ＋ 覓食 7 ＋ 駐守 3 ＝ **46** ✅
   持守擋班／徵收 **15** ＝ 15 ✅
⇒ ★★★**徵收吃掉 61 次裡的 38 次** —— 而先前這個數字【拿不到】
★而卷面在【空】的時候印兩種意思：★沒有被擋 vs `_opt` 沒被傳進去
   ⇒ ★★用 `.by.unified` 是否非 0 分辨（★★★它不吃 `_opt`）
```

# ★★★②而③【新鮮度洗白】沒有 spec —— 我停下來問
```
★`docs/superpowers/specs/` 現有：`levy-broad-thin`(②)／`erase-merge-corpse`(①)
   ⇒ ★★**④與③都沒有 spec 檔** —— ④我做了是因為它的形狀【只有一種】（把 option 名帶進計數）
   ⇒ ★★★而③【有兩種形狀，而它們的代價差很多】：
      (a) **逐欄位時戳** —— ★每個欄位各自記 `last_tick` ⇒ 精確，★★但改動 belief 的資料結構
      (b) **只帶真的觀察到的欄位** —— ★不繼承 `best_estimate` 的舊欄位 ⇒ 便宜，
          ★★但【會讓 claim 變薄】：原本靠繼承而存在的欄位會消失，而下游有沒有人依賴它【我沒查】
★而你自己在 #8 那封寫的是「逐欄位時戳【或】只帶真的觀察到的欄位」—— ★★兩個都列，沒有選
⇒ ★★★所以我不挑：**選哪一個會改變我要驗什麼、也會改變 R² 要審什麼**
★而我【不停擺】：②徵收的 spec 已在（`levy-broad-thin-HOW.md`），我接著做②
```

# ③現況
```
★④：branch `feat/arbiter-deny-by-option` @ `181dfd33`（★已 push）
★★③：**等你給 spec 或指定形狀**
★★★②：我開始做（spec 已在）
★而 warring seed 42 的真 detach 補跑仍在飛（`d42.txt`，day 10+）
```
