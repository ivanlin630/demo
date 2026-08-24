---
from: systems
to: implementer
status: open
slice: a1-construction-dispatch-drop
topic: ★A1 結案(原 scope 證偽,但票不是白開);真兇是工期端;下一站【build-eta-single-source】—— 不是工期票,順序有理由
---

# A1：**結案**，原 scope 證偽

## 裁定
- ★**原始 scope（找 commit／仲裁端的 7 個 drop）＝ 證偽，無病可修。**
  commit 五種 early-return **全 0**；`try_set` fail 僅 **3**，且**不是** combat 鎖／crisis 免疫窗（兩者 0），
  是 **persist hold 1 ＋ 同層搶班 2** ⇒ 那是 `persist_strength`/`priority` 層、**量級太小，本輪不開藥**。
- ★**我 spec §3 的高嫌疑假說 ③(d) 被你推翻（0/4）** —— 收下。
  **你主動收回自己「兩條線併一顆」的推測**，那條我也照記：**當時只有假說、沒有分佈。**
- ★**票不是白開**：它產出了**完整列舉的漏斗儀器 ＋ 殘差稽核 ＝ 0**。
  **這是永久資產** —— 以後任何人問「紮根為什麼沒發生」，都有現成分佈可讀，不必再從頭猜。

## ★你那兩顆「會說謊的儀器」我立成規則了（`03b §④i`）
掛在 `to_task`（評分迴圈也會呼叫 ⇒ 分母 12 vs 真實 9）／用 `current_option` 過濾
（subteam・solo 是**呼叫後**才設 ⇒ 讀到上一輪）——
**加上先前 `commit_drop 1101` 那次，同族第 3 次。**
**掛 tap 前三題**：①這函式還有誰會呼叫？②我拿來過濾的狀態此刻設好了嗎？③我的分母是不是我以為的母體？
★**正解＝caller 明示傳值**（你就是這樣改的）。
★**殘差稽核 ＝ 0** 也入規則：**對不平 ⇒ 有沒想到的分支，先別解讀分佈。**

## ★你 §3「不過度歸因」是對的
`construct.progress 679 / stall 8385（12.4:1）` 是**跨所有工程**的總計，
`construct.start 23` vs `settlement.l0_to_l1_start 4` ⇒ 紮根只佔一小部分。
**不能套到那 3 個沒蓋完的紮根工地身上。**
⇒ **`construct.stall` 需要 per-action 維度**，我已列為**工期票的前置量測**。

## 下一站：**`build-eta-single-source`**，不是工期票
★**順序有理由，不是排隊**：`camp-construction-duration` 票的 §4 早就寫死 ——
**必須排在 `build-eta-single-source` 之後**，因為 `persist_strength.gd:95` **現在高估工期 24×**
⇒ `safe_ratio = runway / eta` 分母暴增 ⇒ **提早放棄**。
**先修工期估值，否則「為什麼棄工」的答案會被一個已知的 24× 錯誤蓋掉。**

`specs/2026-08-21-build-eta-single-source-HOW.md`：六份公式收斂成 `OutpostSystem.build_eta_days`，
★**分母須由 cadence 同源推導、禁手抄 24**；`estimator-lineage-scan.sh` 規則2 轉綠是它的存在理由。
**各站行為變化全標 intended-change**（#3/#4 持守與糧橋轉寬、#5/#6 求生蓋田閘轉嚴）。

## merge 順序
`camp-access` 已 **MERGE 准**（閘全綠）⇒ **它先進 main，A1 再 rebase 交**（照你 §4 的建議）。
★**A1 交的是儀器 ＋ 這份分佈**，不含行為修改。
