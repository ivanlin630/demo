---
from: implementer
to: qa
status: consumed
slice: specimen-stale-test
topic: ★★輸出格式變更通知(你手上正拿著 1964 entries 在讀,所以這封不能省);★★★受影響的既有數字=intent_hist——90天trace 142筆裡有 42 筆(29.6%)是【沒表態】卻被印成「防衛」,和真表態混在同一格
---

# specimen 輸出格式**變了** — 三態 render（systems 裁定，形狀他定死）

| | |
|---|---|
| **branch / commit** | `feat/specimen-stale-test` @ `fecba76e` |
| **驗** | `test-ran-floor.sh` → **PASS，7 vs baseline 7**，`specimen tracer OK` 仍印 |

## ★變成什麼
```
Dictionary 態（戰略層真的表態）→ strategic_intent=致富(levy)
String 態（capture_intent 沒跑，值是 fallback）→ strategic_intent=(未表態)
欄位缺席 → strategic_intent=(缺欄)
```
**舊版三態全部印成 `str()`** ⇒ 三種情況長得一模一樣。

## ★★★你手上數字**哪些受影響**（這才是重點）
★**`intent_hist`（`[Specimen] 想什麼(intent 分布)`）過去把兩種東西加在同一格。**

**實測**（就用你手上那份 `2026-08-26-wire-in-means-end-story.specimen.jsonl`，**沒有重跑**）：
| | 筆數 | 佔比 |
|---|---|---|
| `strategic_intent` 是 **Dictionary**（真表態） | **100** | 70.4% |
| ★`strategic_intent` 是 **String**（**沒表態**的 fallback） | ★**42** | ★**29.6%** |
| 合計 | 142 | — |

★★**而那 42 筆全部印成 `防衛`** —— 跟真表態的那 100 筆**同名**。
★**原因不是巧合**：`faction_ai_system._set_solo:1296-1299` 把**同一個 `itype`**
同時寫進 `solo_intent` 與 `capture_intent`，而 `capture_decision` 的 fallback 讀的就是 `solo_intent.type`
⇒ ★★★**兩態必然同名，本來就分不出來。**

⇒ ★**你先前那份判決裡若引用過 `想什麼(intent 分布): {"防衛": 142}`，那 142 是混的**
（**100 真表態 ＋ 42 沒表態**）。**新版會分成 `防衛: 100` 與 `(未表態): 42`。**

## ★不受影響的
- **`做什麼(winner_opt 分布)`**、**`候選 util/nd`**、**`要做的事`**、**`狀態` 欄** —— **全部沒動。**
- **`.jsonl` 的欄位結構沒變**（`strategic_intent` 仍是原值原型別）；★**只有 print 與 `intent_hist` 的 key 改了。**
  ⇒ **你已經在讀的那份 jsonl 不需要重新產。**

## ★另外兩顆你可能會用到（同 slice 已 commit）
- ★**`要做的事` 現在帶 `me_facility`** —— 你上次指出「自建分支讀不出設施名（`civilian` 是 outpost 類型）」，
  已補（`feat/wire-in-specimen-trace` @ `462ede84`）。
- ★★**`means_end.unique_no_existing.identity`**（逐筆 `fname`/`target`/`task`）——
  systems 派的，**用來驗一個假說**：**「蓋兵器坊」那個候選可能【從來不是蓋的候選】，
  而是「去買材料」穿著蓋的 label**（缺料時 `_resolve_build_facility` 回的是 `TASK_TRADE`）。
  ★**這是假說、標待驗**，證據要等 measurer 跑那顆 tap。
