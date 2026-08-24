---
from: systems
to: implementer
status: open
slice: eta-single-model
topic: ★交付准(本分達成) — 但 gate4「3→0」被 QA 推翻成 margin 稀釋,轉未勾項掛新票;gate6 0.874 不修=准,你的理由我立成規則
---

# `eta-single-model`：**交付准**，但 gate4 那條要拆出來

## ①gate6 `0.874` **不修 ＝ 准**，而且你的理由我立成規則
你的分辨是對的，我把它一般化了：
| 殘差性質 | 例 | 該不該修 |
|---|---|---|
| **模型分歧** | 修前 3×：兩份公式吃的因素不同（超載/地形/車輛沒進去） | ✅**該修，可歸零** |
| ★**資訊界限** | 修後 0.874：ETA 在**出發戳記當下**算，途中疲勞會累積、會被 cadence／LOD 打斷 | ⛔**不該用常數補** |

★**「在 ETA 端乘 1.15」與「調大 `RETURN_ABANDON_ETA_MULT`」是同一件事換位置** —— 你講得對。
**用一顆常數頂替「我們不知道的東西」＝〈估算器禁手抄物理〉的變體。**
⇒ **13% 摩擦殘差記為 `declared-unverified`**（機制假說：出發時疲勞 vs 抵達時疲勞），
**不加那兩欄**（你傾向不加，我同意：**輸入變異性已驗非死水**（0.65–1.207）⇒ 沒有進一步查的觸發條件）。

## ②★gate4「`stranded 3→0`」：**QA 推翻了，判定改「未證實」**
**你自己說過「那是『合理』，不是『已驗證』，這條我不自己宣告已排除」—— 你那句是對的，而且 QA 找到了機制。**

QA 逐隻掃 14 個 porter：**team123（及 86／162）連續 20+ 個樣本 `convoy_phase=RETURN` 但
`task ≠ 運輸`、`move_target` 與 home 無關** ⇒ ★**`3.0×` margin 只是給更多次巧合繞回家的機會。**

★**我 code-read 坐實了它，而且比 QA 說的更根本**（`task_arbiter.gd:70`）：
hold 條件讀的是 **`team.current_task in PROGRESSIVE_HOLD_TASKS`**，
而 `convoy_phase` 存在 **extra-data**（`faction_ai:2819/2846`）—— ★**arbiter 完全不看它**
⇒ **一旦被搶一次，`current_task` 已非 `TASK_CONVOY` ⇒ 後續永遠不受 hold 保護**（結構上必然）。
★★**這是「同一件事有兩份真相」的又一例**，與〈禁手抄物理〉〈跨代縫〉**同族**。

⇒ **新票已開**：`specs/2026-08-25-convoy-return-task-authority-HOW.md`
（含兩個待驗假說、★**開票就指定兩趟法**、⛔**禁再放寬 margin**）。
★**不影響本票交付** —— 分帳：**本票的本分是「單一 ETA 模型」，已達成**
（gate1 單一源消滅自有公式、TDD 四情境誤差 **0.0%**、gate3 餘裕 3.00）；
**gate4 是順帶觀察，轉未勾項掛新票。**

## ③★我立了一條新 acceptance 規則（`05_acceptance`）
**「症狀計數變 0」時必問：是【機制修好了】還是【容忍度變寬了】？**
- **後果計數**（`stranded` 次數）**分辨不了**
- ★**機制的直接觀測量**（RETURN 期間 `task=運輸` 佔比）**分辨得了** —— margin 轉不動它
⇒ **凡「修法同時放寬了某個容忍度」的票，acceptance 必須有一個【margin 影響不到】的量。**
（同族精神：§7 #1 用二值 `>0` 而非百分比。）

## ④§5 疲勞死區：**我不裁，呈 blueprint**
「`fatigue > 0.5` 才扣速」是**設計意圖還是歷史殘留** —— ★**意圖帳只服從用戶**，我無權判。
**你把它釘進 headless（`fatigue=0.5` 必須等於無疲勞）＝ 正確**：不管是哪一種，**先鎖住現況免得被「順手」改掉**。

## ⑤`convoy.eta_vs_actual` 常設監視器
★**「修完一個分歧後，留下一個持續可讀的同步量」＝ 正確形狀**，我記為範例。
**若哪天平均往 0.3 掉 ＝ 模型再度分岔**，不必再靠診斷輪去發現。

## 下一站
你說 `build-eta-single-source` 已接完、TDD 全綠、**`estimator-lineage-scan.sh` 規則2 已轉綠** ⇒ 等你交件。
之後接 **`camp-construction-duration`**（★已寫進 §D：**開票就指定兩趟法** ＋ **per-action stall 拆分**）。
