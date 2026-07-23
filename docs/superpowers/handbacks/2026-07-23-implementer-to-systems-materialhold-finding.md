---
from: implementer
to: systems
status: consumed
topic: "[finding·material-hold 守護對(starve 0/無抱料餓死)可能可 merge·但脫貧核心未達=真瓶頸 material INFLOW 非賣壓(root④)·★三階段 facility 一路降需 methodology 裁] material-hold reserve decouple 守護乾淨(starve 0 vs baseline 1、跨 seed 穩健)但 peak_material≥105 兩 seed 0%、avg holding 卡~50-52 高原、facility Δ+1(三階段 +4→+2/3→+1 一路降)。measurer 疑真瓶頸=material 進帳速率(生產/貿易流量)非賣壓,連結 material-afford-trace/facility-build-binding(demand 不缺 accumulation 卡死)。★三階段降是 causal-regression 還是累積世界分岔=需 systems methodology 裁(勿盲 merge 若 causal)。root④候選=material inflow。呈裁。"
branch: feat/material-hold-protection
commit: 1017fe31
---

# finding：material-hold 守護對；脫貧核心未達=真瓶頸 material INFLOW（root④）+ ★三階段降 methodology 疑

measurer material-hold 量測（cc consumed）。**reserve decouple 守護乾淨，但脫貧鏈核心目標仍未達，真瓶頸疑轉向 material 流入速率**。
[[project_established_chain]] + [[feedback_avoid_rabbithole]] → 呈裁，**不逕改**（尤其三階段降需先釐清 causal vs drift）。

## ✓ 守護對了（可能可 merge-partial）
- 兩 seed **starve=0**（優於 baseline 1/1）——沒隊死於抱著要蓋的材料不放。守護方向正確、跨 seed 穩健。
- TDD ②acute 釋放硬驗綠 + runtime 無致死。determinism 採信、無新餓死。

## ✗ 脫貧核心目標未達（甚至比前一腿更低）
- `peak_material≥105`（afford proxy）兩 seed **0%**；avg material holding 卡 **~50-52 高原**（遠低 105，兩 seed 高度一致）。
- facility built 兩 seed **Δ+1**；三階段：baseline +4 → post-extraction +2/+3 → **post-material-hold +1**（一路降）。

## ★真瓶頸疑轉向 = material INFLOW（生產/貿易流量），非賣壓（root④候選）
- avg holding 卡同一高原 ~50-52 → 問題不在「賣不賣」（本刀治的、且守護對）→ 在 **material 進帳太慢**（根本沒足夠料流進來被保護到 105）。
- 連結 measurer 更早 `material-afford-trace`/`facility-build-binding` verdict：**demand 不缺（想蓋 desire 夠）但 accumulation 卡死** = 進帳速率問題。
- material INFLOW 來源（我 scout 常識）：harvest（REGEN forest material 12/plains 0.5——**plains food-productive home 隊幾乎不產料**）+ trade（買料，rate-limited）。plains 隊想蓋卻無料源 → 靠 buy 但流入慢。= **生產/貿易流入速率**根，非持有政策。

## ★★三階段 facility 一路降 = methodology 疑（需 systems 裁，勿盲 merge 若 causal）
- +4→+2/3→+1 一路降：measurer 提**可能受累積世界分岔**（三次疊加各自 world trajectory 略異，非單一 fix 因果）——但也**可能 material-hold causally 降 facility**（如守料不賣→少 coin 流轉→其他環受抑）。
- ★這是**merge 前必釐清**：若 causal-regression（本刀真降 facility）則不該 merge；若 drift（小樣本 Δ+1 vs +2 高變異 + 世界分岔）則守護乾淨值 merge。
- 建議 methodology：same-baseline A/B（material-hold on/off 對同一 post-extraction world）比 facility Δ 隔離 causal，非跨三階段累積比。

## 呈裁（HOW owner）
1. **material-hold merge 決策待三階段降釐清**（same-baseline A/B 隔離 causal vs drift）；守護乾淨（starve 0）若非 causal-regression 值 merge-partial。
2. **root④ = material INFLOW**（生產/貿易流入速率）：脫貧核心真 blocker 疑在此非賣壓。建議下步查 material 生產/流入（forest harvest 分布 / 買料成交速率 / plains 隊料源），非續調 reserve。
3. coin_urg 非 robust（seed42 平 92%/seed1337 79%）也記。
- 等裁 merge 決策 + root④序。**避免在賣壓層繼續下注**（measurer 戳破=真瓶頸在流入，[[feedback_avoid_rabbithole]]）。
