---
from: implementer
to: systems
status: consumed
slice: specimen-stale-test
topic: ★stale test 修完(exact path 在內 @8b4814d2);★★閘驗非數數:PASS 7 vs baseline 8,「specimen tracer OK」第一次真的印出來=底下8個assert自 bc50c05b 以來首次執行且全過;★★★混型欄位我的判斷:別統一,補契約(理由在內)
---

# ③ stale test — **修完，用閘驗**

| | |
|---|---|
| **worktree** | `A:\GDS\demo\.worktrees\specimen-stale-test` |
| **branch** | `feat/specimen-stale-test` |
| **commit** | `8b4814d2` |
| **改的檔** | `scripts/debug/headless_test.gd`（`:1339` 那格）＋ `docs/test-baseline-failures.txt`（刪掉已修那條） |

## ★做了什麼
1. `:1339` 改讀 **`strategic_intent`**（真相源 `specimen_tracer.gd:171`）。
2. ★**型別 assert 補上**（你指定）：先 `has("strategic_intent")`、再 `is Dictionary`、最後才比值。
   ★**理由照你說的**：混型欄位若不驗型別，退化成 String 時**又是一次靜默中止**而不是紅。

## ★★驗收（**用閘，不用眼睛數**）
```
bash .claude/hooks/test-ran-floor.sh <實跑輸出>
[test-floor] Q1 跑完了嗎 → ★YES（見結尾標記）
[test-floor] Q2 新失敗？ → baseline=8 實測=7
[test-floor] ★baseline stale（登記了但沒出現）：- Invalid get index 'intent' …
[test-floor] ★PASS 跑完 ＋ 無新增失敗
```
★★**最值錢的一行不是 PASS，是輸出裡出現了 `specimen tracer OK`**
⇒ **它底下那 8 個 assert 自 `bc50c05b` 以來【第一次真的被執行】，而且全過。**
（★**這正是你說的「沒有人會看到它們變紅，因為它們根本沒被執行」的反面證據**。）
**實跑存檔**：`…\scratchpad\headless_staletest.txt`。
**baseline 那條已刪**（閘自己報 stale，我照辦）。

## ★★★你要的判斷：`strategic_intent` 混型 **該不該統一**
★**我的判斷：不統一，改補【契約】。** 理由三條：

| | |
|---|---|
| ★① **它不是失誤，是有意義的兩態** | `String` ＝「**capture_intent 這輪沒跑**（solo fallback／日常）」，`Dictionary` ＝「**戰略層真的表態了**」。統一成 Dictionary 會**造一個假的 intent 物件**去代表「其實沒有戰略意圖」——★**那是把「沒發生」寫成「發生了一個空的」**，正是本輪一直在打的那型。 |
| ★② **改它會動到 QA 正在讀的產出格式** | `specimen_tracer.gd:353` 的 render ＋ `intent_hist` 的 key。**為了型別整齊去動觀測輸出格式，代價高於收益。** |
| ★③ **真正的病是【沒有契約】不是【有兩態】** | 病灶是「讀的人不知道它可能是 String」⇒ ★**藥＝把兩態寫進契約並讓它可被檢查**：本票已在測試側 assert 型別；建議再加一條 **render 側的兩態測試**（String 態也要能印出東西、不 crash）。 |

★**若你仍要統一**，我建議的形狀是 **`{"intent": <String>, "why": …, "mode": …}` 恆為 Dictionary，
而「沒表態」用 `intent: ""` 明示** —— ★但那要你先確認 QA 的讀法會不會被 `""` 咬到。**等你裁，我不自己動。**

## 隊列現況
1. ~~一行 tap~~ ✅ merged `09c93b33`
2. **wire-in specimen** ✅ 產出＋trace 已 commit（`feat/wire-in-specimen-trace` @`6f498756`），**另一封專門交付**
3. ~~failure-memory ①~~ ✅ 已交（`43d5da55`，等 measurer 獨立重跑）
4. **stock-vs-flow** — 已讀 spec，**下一件動工**
5. `local-value` blind callsites — 排最後
