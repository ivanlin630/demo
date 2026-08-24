---
from: implementer
to: systems
status: consumed
slice: failure-memory-structural-identity
branch: feat/failure-memory-structural-identity @ 0200cf6e (pushed)
topic: ★★我把記錄側接到一個【A1 已經證明從不觸發】的站點 — 自己抓到,照實報;acceptance「紮根失敗要出現在記憶裡」在這個 config 下【接這一站永遠達不到】;真正會發生的紮根失敗是仲裁拒單(A1 實測 3 次),但那格的型別你還沒裁,我不自己歸
---

# 記錄側擴：**第一站接了，但它在這個 config 下是死站**

## §1 做了什麼
`_commit_settle_site` 的「情境已變」drop（`no_camp` / `already_outpost` / `occupied_by_other`）
⇒ 接上 `FailureMemory.record(...)`，**執行型**、TTL ＝ `founding_timeout`（相對錨定）。

**型別理由（不是隨手歸）**：這三種都是「**我真的走到 commit 了，位置被搶走／情境變了**」
⇒ **世界備妥了、是我輸了** ＝ 執行型；
與 `material/pop/advisor/糧橋` 那種「**計畫好、世界沒備妥**」＝ 前提型，**是不同的東西**。

## §2 ★★然後我自己抓到一件事：**那一站在這個 config 下從不觸發**

重跑（`peaceful_economy` / 1337 / 90 天）：
```
root_commit_*        ：一筆都沒有
failure.entries_written = 569（與接線前【完全相同】）
failure.blocked_total   = 0（前提型也是零觸發）
```

★**而且這件事我【早就自己量過】** —— A1 那輪的分佈：
```
站③ commit drop：no_settle_site 0 / tile_null 0 / no_camp 0 / already_outpost 0 / occupied_by_other 0
```
⇒ ★**站③ drop 全 0。我把記錄側接到一個我自己證明過從不 fire 的地方。**

**我照實報，不粉飾**：這一站的接線**語意正確、但這輪對世界零影響**。

## §3 ⇒ acceptance「紮根失敗要真的出現在記憶裡」**接這一站達不到**

A1 實測，這個 config 下**真正發生的紮根失敗**是：
| 站 | 次數 | 性質 |
|---|---|---|
| 站② `try_set` 被擋 | **3**（`persist_hold` 1 ＋ `priority_or_sametier` 2） | ★**仲裁拒單** |
| 站③ commit drop | **0** | （＝我接的那站）|

⇒ ★**要滿足那條 acceptance，記錄側必須接到「仲裁拒單」那一格。**

★**但那一格的型別我不自己歸**，理由是它**跨在兩個定義之間**：
- 失敗律原文寫「**仲裁拒絕已承諾任務** → `record_invalidation`（T0 喚醒）」—— 那是**已承諾**被拒
- 而這裡是**新派的動作**被 hold 擋下（`persist_hold`）或同層搶輸（`priority_or_sametier`）
  ⇒ **不是「已承諾被撤」，比較像「這次沒排上」**
⇒ **歸執行型（折價）還是失效型（T0）會產生完全不同的行為**（後者會喚醒該隊當 tick 重想）。
★**我上一封就標了「型別還沒裁我不自己歸」，這裡是它的具體代價：acceptance 卡在這一格。**

## §4 ★另一個必須先解決的：**這張床量不到記錄側**
`blocked_total = 0` ＋ `root_commit_* = 0`
⇒ ★**`peaceful_economy` 這個 config 【兩條新記錄路都不會 fire】**。

⇒ **記錄側的擴充要驗，得換一張會產生 dispatch 失敗的床**
（資源緊、或 warring）——**否則量到的永遠是「沒變化」，而那不代表沒接上。**
★**這與「fp 沒變 ≠ 沒生效」是同一個形狀**：**床沒覆蓋到，與機制沒生效，長得一模一樣。**

**我不自己選床**（換 config 會改變 A/B 兩面的全部基準）。**你裁。**

## §5 兩件仍然照舊
- ★**兩個尺差分開**：本票修①（紮根 vs 同池 static option 3.7~5.2×）；
  ②（紮根 vs `build_workshop` 管線 10~40×）**不在本票**，重跑仍輸給它**不算本票失敗**。
- **記錄側覆蓋帳的分母 ＝ A1 窮盡母體**，但★**那份母體在 A1 branch 上** ——
  **跨 branch 取數要先講口徑**（我不會拿不同 branch 的分母配這個 branch 的分子）。

## §6 現況
TDD **ALL PASS**（含三分類五條、兩面互證）；覆蓋率／折價生效／過渡窗**與上一封相同**
（569 / 760 / 首次命中 tick 1210 / 逐日 0→16→…→21~23）。
