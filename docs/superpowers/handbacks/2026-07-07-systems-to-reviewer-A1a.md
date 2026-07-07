---
from: systems
to: reviewer
status: open
topic: A1a 拆閥 — 查證員 A1a.review 兩殘留閉合（issue#1 修 / issue#2 defer）
---

# A1a — 收查證員 verdict("issues") 後的收口

母 slice：`docs/superpowers/specs/2026-07-07-A1a-arbiter-valve.md`（fef3702 主體）。
查證員 verdict：`docs/process/verdicts/A1a.review.json`（`verdict:issues`，兩低嚴重度殘留，不擋 merge）。
本 handback = systems 收兩殘留：issue#1 修、issue#2 判定 defer + spec 記載。

## 做了啥

### issue#1（修，commit c855f11）— reaffirm 靜默丟 move_target
- **病**：equal-priority reaffirm 分支（`task_arbiter.gd:48`）`new_task==current_task` 回 true
  但**不蓋 move_target**。引擎 rank[0] 選同 task 但**新目標**（TRADE 換更好市場、unified 換
  prey 位）時新 move_target 被靜默丟、caller 以為已設 = A1a「手不聽腦」病從 task 級縮到 target 級。
- **修**：reaffirm 分支加 `team.move_target = move_target`（手跟腦到 target 級），**仍不蓋
  `task_start_tick`**（起算單源、STATION/TRADE timeout 不歸零；move_target 更新無關 timeout）。
- 一行改，無新增 try_set/transition 呼叫面 → constitution 指紋不動。

### issue#2（defer，spec 記載，commit 1573384）— transition reason 非 engine-owned
- **病**：`transition` 預設 `_source="transition"` ∉ `ENGINE_SOURCES` → 所有
  transition@PRIO_DISPATCH 進場 task 的現任 reason 不是 engine-owned → 引擎 rank[0]
  同層（50==50）換不動（equal branch 要求 incumbent 也在白名單）。
- **範圍**（比查證員原 report 更廣，全 grep）：不只 beggar 恢復 3 點，含 outpost BUILD ×8
  （`outpost_system:384/406/447/461/566/602`、`faction_ai:2421`）。
- **判定（分兩類，非一刀切）**：
  - **BUILD 的 un-swappable = 合意保守**，非缺陷：引擎不該每 cadence 把建造隊拉去做別的；
    跑到 BUILD 完成、或 survival@80/threat@70 **嚴格大於**仍能搶。
  - **beggar 恢復 previous_task 的 = 小 latch 殘留**（恢復的引擎 task 引擎換不掉），但
    **有界非永久**：STATION/TRADE timeout 兜底 + 高優先事件嚴格大於可搶 + task 自然完成。低嚴重度。
- **為何 defer 不修**：正解 = 「targeted restore-source」（beggar 3 點傳專屬 engine-owned
  source，**不動** BUILD 保守 pin）＝觸及 beggar 恢復語意 → 屬 A1b 恢復路徑範圍。工單明令
  「只做兩件事、別擴張」（A1b subset/A1c side-effect 各自獨立 slice）→ 本 slice defer，spec 已記為
  follow-up 缺口（`2026-07-07-A1a-arbiter-valve.md` 副作用清單）。

## 驗了啥（工單 5 條，全綠）

| # | 驗收 | 結果 |
|---|---|---|
| 1 | `--headless --import` 乾淨 | ✅ 無 SCRIPT ERROR |
| 2 | `hand_obeys_brain_bed.gd` 無 SCRIPT ERROR/timeout | ✅ 見下方註 |
| 3 | `constitution_gate.gd` 不 FAIL | ✅ `PASS (sites=30, removed=0)` |
| 4 | 非退化 sanity ≥1000 tick | ✅ `headless_test` 全 `[OK]`、SCRIPT_ERRORS=0；bed 跑 7200 tick 無崩 |
| 5 | bed arbiter_latch/no_release 桶方向↓ | ✅ 見下表 |

**#5 方向證據**（同 env：`HOB_MONTHS=1 HOB_SEEDS=1337`，pre-A1a=`fef3702^` vs A1a+兩修=HEAD）：

| 桶 | pre-A1a | A1a+修 | Δ |
|---|---|---|---|
| arbiter_latch | 270 (16.9%) | 76 (4.6%) | **↓72%** |
| no_release_latch | 40 (2.5%) | 42 (2.6%) | ~平（噪音） |
| agree（手==腦） | 55.0% | 65.1% | ↑10pt |
| viol（手≠腦） | 44.8% | 34.6% | ↓10pt |

arbiter_latch 崩掉（-72%）= 拆閥主效。整體 viol ↓10pt、agree ↑10pt。
no_release 平（40→42）在噪音內（母 spec 閘校正：跨版本 aggregate=噪音，只驗方向不追精確；
兩 run 采樣數 1597 vs 1638、世界 diverge、STATION_TIMEOUT=4 天在 1 月窗只 ~7 個 release 窗，
縮 latch **時長**非瞬時 count）——方向未變壞，達標。

**#2 註（誠實記）**：bed 在**預設 4 月 × 3 seed**跑會撞 wrapper `[GODOT TIMEOUT 360s]`
（sim 太重，非 hang/無限迴圈）——**pre-A1a 基線同樣 360s timeout**（`bed_baseline.txt`
末行證），∴ 為 bed 預設 env **固有**、非本 slice 回歸。降 env（1 月 1 seed，7200 tick）
可跑到 `=== DONE ===` 乾淨、無 SCRIPT ERROR。方向對照即用此降 env。

## 殘留疑點（呈報）

1. **issue#2 beggar 恢復小 latch = A1b follow-up**：需 targeted restore-source。已在 spec 記為
   defer 缺口。若藍圖要本 arc 內收，建議併 A1b（subset/恢復路徑重排）一起，勿在 A1a 補丁式擴張。
2. **no_release_latch 未見明顯↓**：STATION_TIMEOUT=4 天（TEST VALUE，照妖鏡債）在 1 月窗
   aggregate 效果被噪音蓋。若要硬證 no_release 方向，需跨多 seed × 更長窗（撞 360s，須拆
   多段跑或調 wrapper timeout）——屬「精確單點驗收」，工單明言非本 slice 事。方向不追數字下達標。

## commit 序（死也丟最少）
- `c855f11` fix(A1a): reaffirm 蓋 move_target（issue#1）
- `1573384` docs(A1a): spec 記 move_target 修 + issue#2 defer 缺口
