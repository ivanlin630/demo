---
from: blueprint
to: qa
status: consumed
topic: "[用戶點名要QA查③完整故事性(『這有點沒道理』)=敘事層對抗判非再一輪funnel·讀seed1337 2mo specimen+json講完整故事+判哪裡沒道理ranked·★數據檔:docs/measurements/2026-08-12-phase3-story-audit-seed1337-2mo.json(curve/leaders/new_delta逐月)+.specimen.jsonl(個體)·★初始值:config warring_states.json seed1337:地圖hex半徑14資源豐度5開局糧倉800/據點42(民0.7軍0.3獨立0.35)/勢力8(權重4:3:3:2:2:2:1:1每勢2-5隊)/流浪6-10/每隊pop8-10記名0.3/headless無玩家;起跑pop444約49隊established=0;月1:105隊pop436 月2:130隊pop299=兩月-32.6%·★systems/measurer已pin(你加敘事別重跑funnel):#3①=0/8 leader過立國門檻(統領全≤0.34<0.4、8領袖cmd0.10-0.34野心0.08-0.57無一gate_all_pass)、#3②=併入82%host『養不起』famine-reject genuine+74%never-reach-host travel、#3③=migrant est_null90% belief-propagation BUG+invest already_farming56% genuine結構、饑荒-32.6%/2mo(genuine-vs-bug中性metric診斷measurer在飛平行)·★用戶『沒道理』targets優先掃:(a)established=0連月1都0=8個預置勢力該不該開局就算established?定義mismatch vs真沒立國(b)勢力領袖帶隊超小pop1-8(f7=1人)但轄3-9子隊=為何領袖本隊這麼小?(c)49→130隊兩月暴增=大量子隊spawn、碎片是不是餓死主體?coherent vs spawn-bug(d)pop-32%/2mo崩=死亡故事說得通嗎(誰死為何死)·★對抗禁預設:別把funnel verdict當全部真相、讀specimen找兜不攏處(genuine別當bug、bug別放過)·output=完整敘事故事線+ranked『沒道理』spots(specimen硬證)→回我→我帶用戶·perf限:只2mo可觀(O(N²)=#1 blocker)、判2mo故事、更深待perf·序:QA故事audit→回我→帶用戶排fix·地基KEEP"
---

# ③ 完整故事性 audit（用戶點名 QA）

用戶看初始值後說「這有點沒道理」→ 要 **QA 敘事層對抗判**（非再一輪 funnel）。讀 specimen 把 seed1337 這 2 個月**當故事講完整** + 判哪裡兜不攏。

## 數據檔（你留 main dir 直讀、勿 checkout）
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-2mo.json`（curve 逐月 teams/factions/established/pop/intent/new_delta + leaders 逐月立國 gate/anon tier/food_days + spawn_dispatch_breakdown）
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-2mo.specimen.jsonl`（個體 specimen）

## 初始值（config warring_states.json, seed 1337, headless 無玩家）
地圖 hex 半徑 14 / 資源豐度 5 / 開局糧倉 800;據點 42（民 0.7 軍 0.3 獨立 0.35）;勢力 8（隊權重 4:3:3:2:2:2:1:1、每勢 2-5 隊）;流浪 6-10;每隊 pop 8-10、記名 0.3。
起跑 pop 444 約 49 隊、established=0。月1: 105 隊/pop436 → 月2: 130 隊/pop299 = **兩月 -32.6%**、隊數卻 49→130 暴增。

## systems/measurer 已 pin（你加敘事、別重跑 funnel）
- #3① = **0/8 leader 過立國門檻**（統領全 ≤0.34 < 0.4、野心 0.08-0.57、無一 gate_all_pass）。
- #3② = 併入 **82% host「養不起」famine-reject genuine** + 74% never-reach-host travel。
- #3③ = migrant **est_null 90% belief-propagation BUG** + invest already_farming 56% genuine 結構。
- 饑荒 -32.6%/2mo genuine-vs-bug 中性 metric 診斷 = measurer 平行在飛。

## ★用戶「沒道理」targets（優先掃）
- **(a) established=0 連月1都0**：8 個預置勢力該不該開局就算 established?= 定義 mismatch vs 真沒立國。
- **(b) 領袖帶隊超小**：pop 1-8（f7 領袖只剩 1 人）但轄 3-9 子隊 → 為何領袖本隊這麼小?
- **(c) 49→130 隊兩月暴增**：大量子隊 spawn → 碎片是不是餓死主體?coherent vs spawn-bug。
- **(d) pop -32%/2mo 崩**：死亡故事說得通嗎（誰死、為何死）?

## ★對抗（禁預設）
別把 funnel verdict 當全部真相、讀 specimen 找兜不攏處。genuine 別當 bug、bug 別放過。

## output
完整敘事故事線 + ranked「沒道理」spots（specimen 硬證）→ 回我 → 我帶用戶排 fix。
perf 限:只 2mo 可觀（O(N²)=#1 blocker）、判 2mo 故事、更深待 perf。地基 KEEP。
