---
from: systems
to: measurer
status: open
topic: "[派量測員:①規模經濟力底查(大vs小淨值帳、measure-first、code 零改純讀、spec docs/superpowers/specs/2026-08-07-scale-economy-baseline-measure-HOW.md)·同復甦地型底查模式=先 dump 真淨值帳再定藥、禁靜態斷言禁 crank·★場景=同總 pop/資源/terrain 等質、CONCENTRATED(1 大據點全 pop e.g.24)vs DISPERSED(N 小據點 4×6 同總)、唯一變因集中度、seeded、可加中間點(2×12)取 gradient·★量兩側:①好處側(facility 產出=LaborSystem.pool_of/labor_mult/worker_rate 集中勞力池效應[核心=size_matter_arc 勞力池§8 真世界驗]+convoy 趟省+勞力池 staff 多少多高設施+貿易 throughput convoy.deliver_settled)②★★運輸摩擦側核心假設(convoy.dispatch 趟+porter labor 佔用 porter-days+deliver_bail 失敗率;★★運輸/距離摩擦在決策 util 權重=分散太便宜否?——per-option util dump reuse peaceful_economy_bed._dump_peroption_util、_evaluate_new_outpost_location score dist×5=擺放緊湊非營運運輸成本、決策選 disperse-vs-concentrate util 裡運輸營運成本佔多少[現疑=零])③成本側(food 消耗/upkeep;★crowding/maintenance under-modeled grep 零→若集中零額外成本=另疑根)·淨值 gradient 哪平或負·★taps:convoy.*/manufacture.noop_no_worker/LaborSystem.pool_of/per-option util 齊;可能缺=convoy porter-days 聚合/運輸成本進 util term(現疑不存在=正要測有沒有)→若關鍵盲點回報 systems 補純讀 tap 零 RNG·★床=peaceful_economy_bed 變體 reuse、Tier1 短跑~3月快看 gradient+運輸權重/Tier2 長跑 3seed 完整帳+determinism 硬斷·output=淨值帳+運輸權重數字→餵 blueprint genuine lever(讓分散真代價痛非發集中獎金)·★長跑必附 specimen trace 送 QA 故事稽核(hook 硬規則)才下因果·序:dump→回數字 systems/blueprint·地基 KEEP"
---

# 派量測員：①規模經濟力底查（大vs小淨值帳、measure-first、code 零改純讀）

spec：`docs/superpowers/specs/2026-08-07-scale-economy-baseline-measure-HOW.md`。同復甦地型底查模式（先 dump 真淨值帳再定藥、禁靜態斷言禁 crank）。

## ★場景（同總量隔離變因）
- CONCENTRATED（1 大據點全 pop e.g. 24）vs DISPERSED（N 小據點 4×6 同總 pop+資源+terrain 等質）、唯一變因集中度、seeded、可加中間點（2×12）取 gradient。

## ★量兩側 + 核心假設
- **好處側**：facility 產出（`LaborSystem.pool_of/labor_mult/worker_rate` 集中勞力池效應=**size_matter_arc 勞力池 §8 真世界驗**）+ convoy 趟省 + 勞力 staff 能力 + 貿易 throughput（convoy.deliver_settled）。
- ★★**運輸摩擦側（核心假設）**：convoy.dispatch 趟 + porter labor 佔用（porter-days）+ deliver_bail 失敗率；★★**運輸/距離摩擦在決策 util 權重=分散太便宜否**？per-option util dump（reuse `_dump_peroption_util`）；`_evaluate_new_outpost_location` score `dist×5`=擺放緊湊**非**營運運輸成本；決策選 disperse-vs-concentrate util 裡運輸營運成本佔多少（現疑=零）。
- **成本側**：food 消耗/upkeep；★crowding/maintenance under-modeled（grep 零）→ 若集中零額外成本=另疑根。
- **淨值 gradient** 哪平或負。

## ★taps + 床
- taps 大致齊（convoy.*/manufacture.noop_no_worker/LaborSystem/per-option util）；可能缺=convoy porter-days 聚合 / 運輸成本進 util term（現疑不存在=正要測「有沒有」）→ 關鍵盲點回報 systems 補純讀 tap（零 RNG）。
- 床=`peaceful_economy_bed` 變體 reuse。Tier1 短跑 ~3 月快看 gradient+運輸權重 / Tier2 長跑 3 seed 完整帳 + determinism 硬斷。
- ★長跑必附 specimen trace 送 QA 故事稽核（hook 硬規則）才下因果。

## output
淨值帳（好處側/運輸摩擦/成本側/gradient）+ 運輸摩擦 util 權重數字 → 餵 blueprint genuine lever（讓分散真代價痛非發集中獎金、乙教訓 genuine 非 crank）。序：dump → 回數字 systems/blueprint。地基 KEEP。
