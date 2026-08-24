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

## §D ★量測設計：**兩趟法**（必用，見 `04_qa`）

本票要驗的是「**哪些隊棄工、為什麼**」—— ★**那幾隊幾乎一定不在等距抽樣（`SPECIMEN_SAMPLE_N`）裡**
（已四次同款：convoy porter／camp host／A1 的 start=4 有 2 筆／team15）。

**做法（同 seed，兩趟）**：
1. **第一趟**：tap 記錄「**開工但未完工的 tile 與其 `construction_team_id`**」⇒ 得到 team id 清單
   ★**前置**：`construct.stall` 需要 **per-action 維度**（A1 已列，implementer 正確拒絕把跨工程的 12.4:1 總計套到紮根）
2. **第二趟**：`SPECIMEN_TEAM_ID=<那幾隊>` 重跑 ⇒ **QA 直接讀得到棄工當下那幾隊在想什麼**

★**開票時就指定，不要等 QA 回「判不了」才補跑。**

## §E ★真實可讀的「放棄」案例：**team22**（QA 2026-08-25 撈到，直接餵本票）

QA 在 `build-eta` 那輪意外撈到一個**完整、乾淨的放棄全程**：
```
紮根委任成功 → ★被【迎戰(戰鬥)】打斷
            → 重新紮根，★連續 7 次試探【全輸給買糧】（食物壓力太大顧不上紮根）
            → 投靠被拒
            → 最終流浪覓食／逃跑
```

★★**這揭示一條與本票原假設【不同層】的放棄路徑**：
本票原本假設斷點在**工期端**（開工後撐不完）。
**team22 的斷點在更前面 —— 它根本沒能【持續】待在紮根上**：
| 層 | 機制 | 本票是否涵蓋 |
|---|---|---|
| 被戰鬥打斷 | `PRIO_THREAT` 合法穿透 hold | ⚠️**設計如此，但「打斷後回不去」要驗** |
| ★**連續 7 次輸給買糧** | **argmax 層被更急的需求持續壓過** | ❌**不在本票，也不在 A1** |
| 投靠被拒 | `feed_ok` genuine（已結案） | ✅ 已知 |

★**「連續 7 次全輸給買糧」是 A1 分佈裡 `root.lost_to.*` 那 111 筆的【故事版】** ——
counter 只說「輸了 111 次」，**故事層才看得出「同一隊、連續、輸給同一個對手」**。
⇒ ★**本票量測要加一欄：紮根的 `lost_to` 是否【集中在少數隊、少數對手】** ——
**若是，那是「排不上隊」不是「蓋不完」，修法方向完全不同。**

## §5 閘
`headless` ／ `det×3` ／ `constitution_gate` ／ `seam-gate`（HARD）／
世界驗收：**`outpost.l0_to_l1 > 0`**（§7 #1，二值）—— ★**本票 ＋ A1 票落地後同床重量**
