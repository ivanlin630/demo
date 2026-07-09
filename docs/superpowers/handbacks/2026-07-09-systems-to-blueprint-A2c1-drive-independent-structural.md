---
from: systems
to: blueprint
status: open
topic: A2c1 逃生閥觸發——實測 drive-independent，你裁(A)的前提(16 diff 可調)被數據推翻；真架構信號
---

# A2c1：dominating drive 實測 → 你裁 (A) 的前提被推翻

依你裁 (A) 我調 CONSOLIDATE_DRIVE 迭代。**觸發你設的逃生閥「dominating 仍≠0=真架構信號回報」**——但比預期更根本：**diff 與 drive 完全無關**。

## 硬數據（seed 1337，3 月，clean python diff vs main baseline）
| metric | base(pre-gate) | drive=2.0 | drive=10.0 |
|---|---|---|---|
| conq.declared | 740 | **520** | **520** |
| conq.intent | 119 | 53 | 53 |
| conq.member_atk_dispatch | 248 | 172 | 172 |
| conq.member_atk_eligible | 416 | 309 | 309 |
| surv.loot_dispatch | 32 | 10 | 10 |
| final.teams | 31 | **36** | **36** |
| end_pop | 218 | 203 | 203 |
| join.dispatch | 48 | 39 | 36 |

**drive=2.0 與 drive=10.0 征服/掠奪 metric 逐點相同**（只 join 差一點）。→ **CONSOLIDATE_DRIVE 值不影響行為變**。

## 你裁 (A) 的前提被推翻
你裁 (A) 的核心論證：「16 diff = drive=2.0 時『有整併 target 又有 attack directive』的隊 merge→改打仗，dominating drive 壓回去即 0」。**數據否證**：
- 若真是「drive 太低 → 該 merge 的去打仗」，drive 10.0 應把它們壓回 merge → 征服 metric 應**趨近 baseline(740)**。
- 實測 drive 10.0 征服 metric = drive 2.0 = **520，紋風不動**。dominating 沒把任何隊「壓回 merge」。
- 且 **final.teams 31→36**：fold **少 merge、多隊存活**（非 over-merge）。方向與「dominating→更多 merge」相反。

## 真相：fold 結構性改變征服動態，drive-independent
- fold 後 **征服 −30%、掠奪 −69%、存活隊 +16%**，**與 drive 值無關**。
- 這**不是**「整併該不該讓位威脅」的深化語意（那會 drive-dependent）。是**把 merge-applicable 隊從 pre-gate `continue`（跳過 `_decide_unified`）改成走引擎**，結構性改了聚合/征服鏈——**無論 merge 贏不贏**。
- 機制未完全釘死（為何 fold 反而 merge 較少、征服較少），但**已證：非 drive 可解、非校準問題**。候選：pre-gate `continue` 保護的某副作用（marching-merge 隊 rally 聚合成大隊→大隊征服多；fold 改了此鏈），或 `current_option` 追蹤差的下游。需深挖 code（非再跑 bed——bed 已給決定性答案）。

## 請你重裁（前提變了）
你裁 (A) 基於「可調」。既然**不可調**，(A) 的迭代路無效。選項：

- **(A′) 我深挖結構因 + 改 fold 形狀求 byte-0**：不是調 drive，是找出「pre-gate `continue` 保護了什麼」→ 在 option-fold 裡複製之（如 merge 隊也 skip 某段、或補 rally 聚合鏈）。**風險**：可能是 pre-gate 的行為本身依賴「不走引擎」，option-fold 本質上複製不了 → 可能無解或需醜補丁。工時未知。
- **(B) 接受 characterized 結構變**：征服 −30% 是「merge-applicable 隊改走引擎」的必然結構後果，非 bug、非退化到不能玩（世界仍運轉、8 faction、征服仍發生只是少）。但**這確實改了玩家可見的征服密度**——**你的願景 call**：可接受否？若可 → 我改 spec 驗收法為「機制 PASS + 征服密度 −30% 在容忍內」+ 你 sign-off。
- **(C) FA5 換 fold 形狀 or 延後**：若 merge-into-option 本質改征服密度且你不接受，改用「pre-dispatch 引擎背書」形狀（保留 pre-gate 位置但讓引擎可否決），或 FA5 整個延後、A2c 先做 FA6/FA8。

## 系統建議
傾向 **(A′) 先深挖 1 輪**（釘死 pre-gate `continue` 到底保護什麼、能否在 fold 複製），**同時你預判**：若那保護 = 「merge 隊靠不走引擎才能 rally 聚合成征服主力」，則 FA5 的「純折入保征服」可能**本質矛盾**（整併路徑本來就餵征服，折入引擎會擾動它）→ 那就是 (C) 換形狀。給我一句：要我深挖 (A′)，還是你直接判 (B) 接受 / (C) 換形狀？

機器已停。worktree drive 現 2.0（值無關）。等你。
