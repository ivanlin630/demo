---
from: implementer
to: systems
status: open
slice: 走查文件第二版（中文欄位名）｜★**三件全做完，產物已落地**
topic: ★**產物 exact path**：`A:/GDS/demo/docs/measurements/2026-09-17-c1-walkthrough-v2-clean.txt`（**175 行 / 12020 bytes**，我 `wc -l` + `head`/`tail` 核過）｜★★**而做這張票的過程本身撞到票要防的那個病**：**中文層自己是壞的** —— `ctx-exposure.tsv` 第五欄 **18 列**帶簡體／錯字（`粮`×14／`块`／`滞`／`撒`／`擐`），★★★**而它一路綠到今天，因為【沒有任何閘讀中文】**｜★**種子錯已換新位置**：`材料缺口 20 → 165`，同頁 `材料總需求 = 100` ⇒ 一眼違反「缺的最多就是全部」｜★★**請 blueprint 通知用戶來抓**（③那一件我交不到用戶手上：我不對用戶說話）
---

# 交件：branch `feat/walkthrough-v2` @ `97380f3e1`（worktree `.worktrees/walkv2`）

```
產物（給用戶讀的那一份，已複製到 main dir）：
  A:/GDS/demo/docs/measurements/2026-09-17-c1-walkthrough-v2-clean.txt      175 行
同一份也在 branch 裡（隨 code 一起進版本）：
  .worktrees/walkv2/docs/measurements/2026-09-17-c1-walkthrough-v2-clean.txt
console 原始輸出（★標成 LOSSY，理由見 §3b —— ★★不要拿它當產物讀）：
  A:/GDS/demo/docs/measurements/2026-09-17-c1-walkthrough-v2-console-LOSSY-raw.txt
```

# ① 所有代碼名欄位翻成中文人話 —— ★**做的時候發現中文層自己是壞的**

```
`docs/process/ctx-exposure.tsv` 第五欄 18 列帶簡體／錯字：
  粮 → 糧（14 處：passive_food_daily / join_host_flow / net_food_flow / food_stock /
           camp_flow_delay_days / has_food_market / food_market_pos / food_market_dist /
           has_buyable_food / food_seek_target / home_food / home_food_productive /
           food_seek_delay_days / occupy_target_flow）
  块 → 塊（occupy_target_id「想佔哪一块」）
  滞 → 滯（survival_stall_active「生存停滞中」）
  撒 → 撐（food_days「粮食還能【撒】幾天」）
  擐 → 撐（food_runway_days「還能【擐】幾天」）
```
★★**它們全部通過了每一個閘** —— 因為**沒有一個閘讀中文**。
★★★**而票①的目的就是「讓用戶看得懂」** ⇒ **「看起來可讀」正是它要防的病，而它自己就是那個病。**

**修法（★不是眼睛看，是機械的）**：
1. **真值從 repo 既有用字取**，不從我腦子裡打：`糧` 由 `docs/*.md` 的 `X食` 統計抓到 **U+7CE7**、
   `撐` 全庫 **1137 處**驗過 ⇒ **U+6490**。
2. ★**我第一輪自己打成 `糋`（U+7CCB）** —— **同一族的錯，當場又犯一次** ⇒
   所以第二輪改成【**改完 dump 全檔唯一字集再比對**】：**261 → 258 unique**，壞字全滅、沒有新字混進來。
   ★**這個檢查不靠我下次記得**：它是一支腳本，輸出的是【已處置的結果】不是【要被解讀的狀態】。
3. 順手把 `food_runway_days` 的「**糧食跑道**」換掉（runway 直譯**不是人話**）
   ⇒ 「**糧食淨流算下來還能撐幾天**」。

★**值也會是代碼**（欄位名翻完只是一半）：`team_data.gd` 裡剩三個 ASCII 常數
（`idle` / `return_home` / `rest`）—— 除了對照表，再加**一道機械偵測**：
任何**純 ASCII 識別字**的值就地標「★這個值還是代碼，沒翻成人話」
⇒ ★★**人話層清單自己長出來**，不必靠我下次回頭檢查。

# ② 種子錯換【新位置】

```
本輪實際種到：材料缺口（material_shortfall）：20 → 165
              同一頁上：材料總需求（material_need_total）= 100
              鐵則：缺口不可能大於總需求（缺的最多就是全部）
```
- `food_days` **進 `FORBIDDEN_SEED_FIELDS`，而不是只從清單刪掉** ——
  ★下一個改這支的人會看見「**為什麼不能用它**」（用戶已知 ⇒ 那格恆綠 ⇒ 證明不了任何事），
  而不是只看見「它不在清單上」。
- ★★**每個候選都自帶【對帳夥伴＋一條算得出來的鐵則】**，造假值是**撐到違反鐵則**，
  **不是亂乘倍數** —— ★★★**隨機倍數有可能剛好還是合理值，那顆錯就沒有人抓得到**
  （四個候選：材料缺口/總需求、寄賣待收錢/待收金額、閒置人手/人數、覓食產出/糊口底）。
- ★**沒種到時大聲印**「本份沒有種到錯 ⇒ 不能拿來判可讀性」——
  **沉默會讓「用戶沒抓到」與「根本沒東西可抓」長得一樣，而這兩件事的結論相反。**

# ③ 兩個渲染缺陷（★都是「看起來好好的」那一型）

**a) 事件流印的是物件編號，而它一直是綠的**
```
player_api_mapper.gd:797  只認 Dictionary，其餘走 str(m)
真世界寫進 global_messages 的是 MessageData（RefCounted）
  ⇒ 玩家看到的每一則事件是 `<RefCounted#-922337…>`
★★它一直綠：兩支床餵的是自己 append 的 Dictionary
   （agent_verbs_c1_bed.gd:164 / c1_info_reconciliation_bed.gd:168）
   ⇒ 測到的是【那條真世界走不到的分支】
修好後（真世界實測，clean 檔 161-165 行）：
  · Team22 向 Team24 徵收（rate=0.05）
  · Team41 售 material ×19
```
★**殘留一筆給人話層清單**：`rate=0.05` / `material` / `weapon_melee_low` ——
**那是引擎自己組的訊息字串，不在走查這一層**，動它會擴到 message 文案（我沒動，留給你裁）。

**b) ★★console 那條路【無聲吃字】**
```
v2 第一版經 console 落檔後：
  標題「C1 票②」    → 「C1 票」      （② U+2461 消失）
  分隔線 `━`         → 整條不見        （U+2501 消失）
★★★而句子還是通順的、沒有任何錯誤訊息。
另一半問題：要讀的東西被埋在【1200 行引擎 log 之後】（走查從第 1203 行才開始）
  ⇒ 「可讀」在用戶滑到之前就已經輸了。
```
⇒ **走查改成自己 `FileAccess` 寫 UTF-8**（`WALK_OUT` 可改路徑）。
**修完實測**：`②` 與 `━` 都原樣落地（clean 檔第 3、17 行）。
★**那個 LOSSY 檔我留著沒刪**（改名標記）—— **它是這個缺陷的證物**。

# ④ ★驗收在用戶那一手，不在我這裡 —— **請 blueprint 通知**

> 你的驗收句：**用戶抓得到那個種子錯 ⇒ 走查文件真的可讀；抓不到 ⇒ 它只是看起來可讀。**

⇒ ★**所以「已交付」不等於「已通過」**，而**③「通知用戶來抓錯」那一件我做不到**：
**我不對用戶說話**（下游角色禁直接問／通知用戶）。
**請轉 blueprint**，內容只要三句：
```
①走查文件第二版好了：docs/measurements/2026-09-17-c1-walkthrough-v2-clean.txt（175 行，中文欄位名）
②裡面埋了【1 顆】已知錯（開頭就講明了，位置不講）
③抓到／抓不到都請說一聲 —— ★抓不到就是這份文件還不夠可讀，那是這次要量的東西，不是你的問題
```

# ⑤ 機器與其它票的現況

```
FreeMB 量到 9272（早先 4271）⇒ ★這一輪的兩次 sim 都跑完了、沒被殺
★但【掠奪票 merged 樹的完整閘】仍未跑 —— 那是恢復令點名的第一件，
  我沒有擅自插隊到它前面跑閘：本次只跑了走查這支（單支、短窗）。
  等你點，我就對 `feat/raid-expected-value` @ `eebac5649` 跑全 56 閘。
`feat/grudge-ledger-a` @ `7f2d8ae2d`：最後一輪 FAIL 只剩 `bed-arm`（＝基線）⇒ ★可以 merge。
  raw：docs/measurements/2026-09-16-grudge-merge-gates-final3.txt
`feat/walkthrough-v2` @ `97380f3e1`：★**閘還沒跑**（它碰了 `player_api_mapper` ⇒ 不是純文件改）。
```
