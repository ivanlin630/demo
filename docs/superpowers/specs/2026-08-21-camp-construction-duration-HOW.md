---
slice: camp-construction-duration
tier: full
qa: required
from: systems
topic: camp-access 工期票 —— 「開工 1 → 完工 0」與 75% 棄置同源:人走了工地就停
---

# camp 工期端：`1 → 0`

**來源**：blueprint 裁定 2026-08-21，`camp-access` 四端同秤實測。
**`8 → 1` 歸 A1 建設族（另票）；本票只做 `1 → 0`。**

## §1 病灶（code-read，已坐實的部分）
- `outpost_system.gd:311` `ticks_left -= max(pop,1)` —— ★**要有人站在工地上才推進**
  （`faction_ai:5033` 註解自述：「走回工地（`_tick_construction` 需站上才推進）」）
- `harvest_system.gd:36-37`：無人 ⇒ `camp_ticks_left` 遞減 ⇒ **`camp_level = 0`**
- `resource_system.gd:75`：有人採集 ⇒ reset（「有人在＝不棄置」）
⇒ **「人走了工地就停」與「營地棄置 75%」是同一個機制的兩個出口。**

## §2 與已修的部分的關係（**別重做**）
`camp-access` 四端同秤**已經**讓「留在自家營地」有真實估值
（覓食讀腳下 tile 真實流）⇒ 棄置率 **89% → 75%**。
★**本票要回答的是：剩下那 75% 為什麼還走。**
**不准的做法**：加硬鎖把隊釘在工地上（`TASK_CAMP` 入 hold list 已被駁回，理由：紮營無終點 ⇒ 永久 latch）。

## §3 待驗（**先量再開藥**）
1. **那 1 個開工的工地，隊是什麼時候離開的、被什麼選項叫走的**（`camp.lost_to` 同款分佈，但限施工中隊）
2. ★**持守有沒有覆蓋到它**：`persist_strength.gd:84` 的 active-construction floor 要求
   `construction_ticks_left > 0` —— **紮根工地有設這個欄位**（`_commit_settle_site` 有寫）
   ⇒ **理論上該被 floor 保護**，**但實測沒保住** ⇒ **要查 floor 是沒生效還是被蓋過**
   ★依 `patch_gate_first` 追加判準：**分清「floor 沒擋」與「floor 沒執行到」**
3. **`build_eta_days` 修正後重量** —— `persist_strength.gd:95` 現在**高估工期 24×**
   ⇒ `safe_ratio = runway / eta` 分母暴增 ⇒ **`safe_factor` 塌 ⇒ 提早放棄**
   ★**這是 `build-eta-single-source` 票的直接下游** ⇒ **本票應排在它之後**，否則量到的是被污染的數字

## §4 排序（**寫死**）
`build-eta-single-source`（修 #3 的 24× 高估）→ **本票** → 重量 §7 三條。
★**先修工期估值再量棄工**，否則「為什麼提早放棄」的答案會被一個已知的 24× 錯誤蓋掉。

## §A ★★acceptance 頭條（blueprint 升格 2026-08-25）

**普查坐實**：`peaceful` 90 天 **outpost day0 ＝ 11 → day90 ＝ 9、中途新增 ＝ 0**
⇒ ★**這個世界只會失去據點、不會產生據點**（文明化從未發生、去文明化正常運作）。
**併同 `construct.progress 344 / stall 5871 ＝ 94.5% 停滯`。**

⇒ **本票與另一票（A1 建設族 ／ camp 工期）的 acceptance 頭條升格為**：
> ★**「從無到有蓋成一個 outpost」＞ 0 —— 文明化二值閘。**

**二值、無旋鈕可假造**（同 §7 #1 的設計理由）。**兩票落地後同床重量。**
★**blueprint 明示不開新案**：修法就是這兩票，**排程零調整**。

## §5 閘
`headless` ／ `det×3` ／ `constitution_gate` ／ `seam-gate`（HARD）／
世界驗收：**`outpost.l0_to_l1 > 0`**（§7 #1，二值）—— ★**本票 ＋ A1 票落地後同床重量**
