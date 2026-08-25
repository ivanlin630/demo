---
from: measurer
to: systems
status: consumed
slice: acquisition-paths-wire-in
topic: "224去重結果：224→31（按fname+target+task三元組）；task=TASK_TRADE佔62/224=27.7%（同時回答task與target兩問）；跑main(9ec8c936)，380筆=母體非截斷"
---

# ①去重前／去重後（單位=`(target, build_type, task)` 三元組，`build_type`=既有欄位`fname`）

| | |
|---|---|
| identity samples 原始筆數 | **380**（cap 500，**未被截斷**——380<500） |
| `unique_no_existing` 去重前 | **224** |
| `dup_existing_present` 去重前 | **156**（224+156=380 零殘差） |
| ★**`unique_no_existing` 去重後**（按 fname+target+task） | **31** |
| 全部 380 去重後 | **57** |

★去重後掉很多（224→31），照原樣回報，不替你解釋掉了什麼。

---

# ②你要驗的假說：`task=TASK_TRADE`（去買材料穿著蓋label）佔多少

224 筆裡 `task` 欄位分佈（raw）：

| `task` 值 | 筆數 | 佔比 |
|---|---|---|
| `貿易`（`TASK_TRADE`） | **62** | **27.7%** |
| `weaponsmith`（與 `fname` 同名） | 48 | 21.4% |
| 空字串 | 114 | 50.9% |

★**這個資料構造上 `task=TASK_TRADE` ⟺ `target=市場位置`**（買料 candidate 的 `to_task` 本身就是
`{task:TASK_TRADE, target:市場}`）——所以「task 是 TASK_TRADE 多少筆」與「target 指向市場多少筆」
是**同一個數字**，62/224。

★**另有 50.9%（114 筆）`task` 是空字串**——不屬你那個假說能解釋的範圍，如實列出，不強行歸因、不下結論。

---

# 落地
`docs/process/verdicts/means-end-224-dedup.measure.json`（commit 附下）
raw: `docs/measurements/breed-deathcause/means-end-224-dedup-warring10d.txt`
dedup 計算: `docs/measurements/breed-deathcause/means-end-224-dedup-RESULT.json`

跑 main（@9ec8c936，二選一票允許，選了 main 因 tap 已進 main）、
`LW_CONFIG=warring_states PERF_SEED=1337 ADHOC_DAYS=10`（與 implementer 原 224 交件同參數）。
床（`goal_delegate_diag_bed.gd`）加印既有 sample 一段，SCRIPT ERROR=0，無新增量測點、無動控制流。
