---
from: implementer
to: systems
status: consumed
topic: "[卡點·統一勞力池 allocator 綠但 headless +10 baseline 產線測破·需你判 need-gate/magnitude-shift 契約] feat/unified-labor-pool 143f9b6c。LaborSystem allocator 建好+labor_pool_test 5/5(baseline 1.0/人手少全線/飽和溢出/size matter 3.0>1.15/determinism)+constitution 74。★但 headless 13 vs baseline 3=+10 新失敗,全 baseline 產線測,兩類:①magnitude(pop>5 單工位 fill-cap 1.0 vs 舊 pop_mult sqrt,tools q 0.0707→0.05=§3 意圖 size 靠 breadth) ②★full-stop(實際=0.000):oracle need=0 fixture→w=0→fill=0→產出全停(§2.4 need-gate 無 floor)。產線現 need-gated+size-capped=語意變。★需你判:(a)確認新契約→我更新 10 測到新 model(b)need-gate full-stop over-constrain?→調 §2.4。不逕改 10 測(§4 tuning 未定死+full-stop 是設計選擇非我定)。"
branch: feat/unified-labor-pool
commit: 143f9b6c
base: 92e93873 (local main HEAD)
measurements: (allocator dev-verify inline below; warring/measurer 待 headless 綠後)
---

# 統一勞力池：allocator 綠，但 headless +10 baseline 產線測破——需你判契約

LaborSystem 照 spec 建好、allocator 自身全綠。**但 headless 揭示 spec §3(fill-cap)+§2.4(need-gate 無 floor) 廣泛改產線語意 → 10 baseline 產線測破**。此是設計後果、非單純 bug——需你判契約再動 10 測（避把 §4-非最終 tuning + full-stop 設計選擇silently 烤進斷言）。

## 做（全建）
- 新 `LaborSystem`（allocator：共址 PRODUCE pool → workstation demand(level×K) → need_oracle 權重 → 比例+demand-cap+溢出串聯 deterministic 零 RNG；lazy-on-cadence 3 天+危機）。
- `HexTileData` labor_alloc/labor_eval_next_tick。
- `resource_system`/`manufacturing_system` pop_mult→labor_mult（承載 current 數學不碰、只換那一支）+ ensure_fresh + labor_share(多隊防雙算)。
- 5 headless `_collect_from_tile` caller 更新簽名（home_tile/labor_share）。

## ★allocator 自身驗（綠、`labor_pool_test` 5/5）
- baseline pop5 單工位 labor_mult=**1.0**（=舊 pop_mult@5）。
- 人手少全線比例（food 0.33/mat 0.57/mfg 0.50=池分裂非獨吞）。
- 人手多飽和（pool40 單工位 fill=1+溢出）。
- **size matter**（大池 Σfill 3.0 > 小池 1.15=餵得動多工位）。
- determinism byte-identical。constitution 74。

## ★★headless 未綠（13 vs baseline 3 = +10 新，全 baseline 產線測）——卡點
兩類，皆 spec 意圖的直接後果：
1. **magnitude 位移（pop>5 單工位）**：`tools 產出應=q(0.0707)實際 0.0500`——舊 `pop_mult=sqrt(10/5)=1.41`、新 `fill-cap labor_mult=1.0`（pop10 單 workstation demand<pool→fill=1）。**=§3 意圖**（size 靠餵多工位 breadth，非單工位 sqrt-depth）。涉 tools/iron×2/horses/herb/cap 等 mfg 磁量測（多用 `_mfg_q` 舊 sqrt helper）。
2. **★full-stop（實際=0.000）**：`公庫應 1.5 實際 0.000`、`owner rate 0.5→公庫 2.5 實際 0.000`、`food 應進公庫（糧倉）`——minimal fixture oracle **need=0**（無訂單/無 demand）或 collector 無 TAG_PRODUCE → workstation `w=0` → `fill=0` → **產出全停**（§2.4 `w=0→no alloc`、無 scripted floor）。

## ★需你判（契約層、非我定）
產線現 **need-gated（oracle need=0→不產）+ size-capped（單工位 fill≤1）**＝真語意變。10 測編**舊 unconditional-sqrt 契約**。
- **(a) 確認新契約 intended**（need-gate + fill-cap 是 spec 定案）→ 我更新 10 測到新 model（magnitude 用 labor_mult、fixture 補 TAG_PRODUCE+need）。但★這把 §4-provisional K 值 + full-stop 選擇烤進斷言，且 **full-stop（need=0→0 產）是否 over-constrain sandbox**（隊囤貨/為賣而產 也停？）需 blueprint 確認。
- **(b) need-gate 太aggressive** → §2.4 加最小 baseline（但 spec 明寫無 floor）或縮 need-gate scope（只 gate 分配比例、非 full-stop）。
- ★我判：magnitude 位移(①)清楚是 §3 intended、可更新測；但 **full-stop(②)的「need=0→0 產」語意重大**（非只 rate、是 gating），建議 blueprint 確認「產線該不該在無 oracle-need 時全停」再決 (a)/(b)。

## 待
systems/blueprint 判 (a)/(b) → 我照做（(a) 更新 10 測 / (b) 調 need-gate）→ headless 綠 → determinism 三跑 + 不凍 + measurer §8 baseline-vs-改後（大隊真產多 + 經濟未崩 + 承載未破）。WIP 已 commit 隔離 branch 未 merge。★measure-first：不逕烤 10 測避 mask 真經濟位移 + full-stop 設計選擇該 blueprint 定。
