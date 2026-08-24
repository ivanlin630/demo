---
from: systems
to: implementer
status: open
slice: build-eta-single-source
topic: ★MERGE 准(閘全綠) — 但帳要照實:retention 改善是【數字有、因果未證】;cap 50.6% 未解釋進 cap 票
---

# `build-eta-single-source`：**MERGE 准**

`seam-gate` **HARD 綠**（`spec 1 / handback 11 / R²verdict 1 / measure 1 / QA 1`，`tier=full`）。

## ★但 merge 訊息與 handback 請照這個版本寫
| 項 | 照實的說法 |
|---|---|
| **本票本分** | ✅ **達成**：六處收斂成單一源、**R² 獨立驗過窮盡宣告**、`lineage-scan` 規則2 **綠**、cadence 斷言 |
| ①②③ 世界層 | ★**數字有、因果未證**。measurer 給出「同一條鏈三個出口」（`persist.hold 33→37`／棄置率 92.3%→83.3%／day90 `12 > 11` 且**差異在流失少**）；**但 QA 判不了因果**（這輪 specimen **只有 branch 沒有 main 對照**，且沒抓到「day0 既有 outpost 撐過放棄關頭」那個 profile） |
| ★`CAMP_MARGINAL_CAP` 31.4%→**50.6%** | ★**惡化，且我解釋不了** —— 我的推理（settle_eta 變長 ⇒ camp 值變低 ⇒ 撞頂變少）與觀測相反 ⇒ **不編故事**，**列未解釋、進 `cap-depatch` 票** |
| `won_argmax 5→1` | **待驗**：完工持平、day90 淨態更好 ⇒ 命中率 `1/5 → 1/1`；**「少而準」vs「開始不蓋了」這個窗分不出來**，QA 也說沒證據能坐實或推翻 |

★**不要寫成「retention 改善已驗證」** —— **數字有、因果未證，兩件事分開記。**

## 我自糾一件事（**QA 判不了是我的量測設計漏的**）
主張是「**branch 比 main 多保住 1 個**」⇒ ★**比較型主張需要【兩邊都有 specimen】**，
而且要**先找出「屬於那一類」的 team id**（day0 就有 outpost 且中途瀕臨放棄），**不是隨便抓有紮根活動的隊**。
**這張票我沒把對照組寫進量測設計** ⇒ 已立成 `04_qa` 規則，**下一張票起照做**。

## ★QA 撈到的 team22，我直接餵給工期票了
```
紮根委任成功 → 被【迎戰】打斷 → 重新紮根【連續 7 次全輸給買糧】→ 投靠被拒 → 流浪
```
★★**這條的斷點比工期票原假設【更前面】**：不是「開工後撐不完」，是**根本沒能持續待在紮根上**。
★**「連續 7 次輸給買糧」是 A1 那 111 筆 `root.lost_to.*` 的故事版** ——
**counter 只說輸了 111 次，故事層才看得出「同一隊、連續、輸給同一個對手」。**
⇒ 已寫進工期票 §E：**量測要加一欄「紮根的 `lost_to` 是否集中在少數隊、少數對手」**；
**若是，那是「排不上隊」不是「蓋不完」，修法方向完全不同。**

## merge 時
★跑 `.claude/hooks/merge-verify.sh`；★**別把別 session 的 WIP 掃進去**（我今天自己踩過一次）。

## 下一站
`camp-construction-duration`（★**兩趟法** ＋ **per-action stall 拆分** ＋ **新增的 §E `lost_to` 集中度**）。
