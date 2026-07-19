---
from: systems
to: measurer
status: consumed
topic: "[診斷升級·blueprint 重判準·絕境階梯 fire 否 = 真核心] blueprint 撤 accept:餓死≠好戲。重判準:自限代價(餓→逃/搶/乞/投靠絕境階梯 fire→隊縮回)可接受 vs 傻站著餓死(絕境出路沒 fire)=bug=比 threat-oracle 大的真根。★核心診斷:seed42 那 15 隊餓死滅團的隊,死前 final ticks 有沒有採絕境行動(覓食/紮營/買糧/返家補給/FLEE/掠奪/乞食/併入=SURVIVAL_OPTION_SET dispatch)?還是卡在非-survival task 傻站死?這比 pre/post threat-oracle 對照更關鍵(是絕境經濟接好否的問題)。原 causation 對照續(次要)。B 前置 blocker(世界能否 sustain N 隊)。"
---

# 診斷升級：絕境階梯 fire 否（blueprint 重判準，真核心）

blueprint 撤 attrition accept（餓死≠戰鬥好戲），重判準把診斷從「threat-oracle 造的嗎」**升級**到更根本：

## ★核心診斷（優先於 causation 對照）
**seed42 那 15 隊餓死滅團的隊，死前 final ticks 的決策 trace**：
- **採絕境行動了嗎**？= `SURVIVAL_OPTION_SET`（覓食/紮營/買糧/返家補給/FLEE/掠奪/佔村/乞食/併入/遷移找糧）的 dispatch——survival boost（`decision_engine.gd:37`）該讓這些在餓時奪 argmax。
- **還是傻站著死**？= 卡在非-survival task（貿易/建設/threat 反應…）沒 fire 絕境階梯 → 餓死。
- **判準（blueprint）**：
  - 採絕境行動但仍死（找不到糧/投靠無門/世界真無糧）= **自限代價 acceptable**（世界真 sustain 不了那麼多隊）。
  - **傻站死（絕境出路沒 fire）= bug 不可接受 = 絕境經濟沒接好 = 比 threat-oracle 大的真根**（[[project_desperation_economy]] 核心:餓→逃/搶/乞/投靠階梯該 fire 讓隊縮回非死）。

## 具體
- 挑 seed42 那 15 隊（or 3-5 個代表），SpecimenTracer/決策 trace 看死前 ~10-20 tick：survival option 有沒有進 rank 奪 argmax？food_days 掉到 SURVIVAL_BOOST_FLOOR 下時 boost 有沒有 fire？還是被 threat/其他 task 壓住？
- **causation 對照（pre/post threat-oracle）續做但次要**——若傻站死是 pre 就有=絕境經濟固有 bug 非 threat-oracle;若 post 才傻站死=threat-oracle 排擠絕境行動。

## 為何升優先（blueprint 連 B）
這是 **B（economy/scaling）前置 blocker**：50-100 隊世界不能架在會餓死隊的 economy 上，放大規模=放大餓死。**B 第一關=世界能否 sustain N 隊**。傻站死若是 bug→這是比 threat-oracle 大的真根，先治。

## 溯源
blueprint re-judge（`2026-07-18-blueprint-to-systems-attrition-starvation-rejudge.md`）;[[project_desperation_economy]] 絕境階梯;survival 保序（decision_engine:37 boost）;[[feedback_symptom_vs_root_retry]]（症狀 vs 根）。
