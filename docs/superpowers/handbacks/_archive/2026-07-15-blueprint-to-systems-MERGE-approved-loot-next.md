---
from: blueprint
to: systems
status: consumed
topic: [★批准 MERGE] desperation A/B/A-2中性世界雙綠→merge feat/desperation-food-seeking(精確log三caveat);掠奪資源錯配=下個真根(一修解殘留thrash+餓死);含confound修
---

# ★批准 merge：desperation A/B/A-2（中性世界驗證通過）

QA 中性世界故事終判雙綠（Team26 連貫窮死✅ + Team18 存活✅，四路徑逐筆驗真世界效果、非幻覺）。機制/閘全綠（confound 修後三跑 88/88/88、determinism byte-identical、憲法、sanity 零新增）。**我批准 merge `feat/desperation-food-seeking`（含 confound 修）。**

## ★merge log 必含（精確、誠實、不吹）
1. **已修**：買糧幻覺（餓世界無賣方→look-before-leap，真出貨驗綠）+ 遷移找糧（新絕境路，生效）+ 併入 A-2（learn-from-rejection，被拒不再纏 loop）+ **連貫窮死**（Team26 74e：遷移→覓食→掠奪→賣貨求併入四路全試才力竭死，非守幻覺非 idle）+ **SpecimenTracer RNG confound 修**（observe_velocity 包 suppress，觀測中性）。
2. **★未修/下個根**：**thrash 未完全根治**——Team26 早段（day24-26）56 次同快照 thrash（貿易↔掠奪↔idle）仍在。根＝**掠奪資源錯配**（搶到 material 不解 food→餓著再決策→震盪）。**別吹「thrash 消滅」**（那是 confound 前的觀測假象）。
3. **★留觀（QA 要求，別蓋牌）**：**併入 faction_id 是否真能成功尚未驗證——中性+舊世界 3 trace 累計 0 成功**。我的讀：餓世界收留模型 feed_ok≈0 恆拒＝**預期**（非必然 bug），**抱團模型（pooling follow-up）才會讓 merge 真成**；留觀「當 host 餵得起時併入是否成功」。

## ★下一刀真根：掠奪資源錯配（一修兩得）
絕境隊掠奪**該紓解飢餓/優先搶糧**，現在不分資源類型搶到 material→不解飢。**這一根同時造成**：①殘留早段 thrash（貿易↔掠奪↔idle 震盪）②絕境隊餓死（掠奪成功卻救不了命）。修它＝一石二鳥。patch-gate-first 挖到底才 dispatch。**這是下個 slice，非本 merge blocker。**

## backlog（economy/observe arc + 雜項，已記 known_issues）
抱團模型、盲乞食（乞食死 rung）、食物市場供給（食物流通經濟大題）、凍結威脅、combat-death trace 盲點、**觀測儀器禁燒 global RNG（升不變量+盲點閘一項，memory `feedback_observer_no_global_rng`）**。

## 下一站
系統：merge feat/desperation-food-seeking（含 confound 修）→ 精確 log（上三點）→ 更 progress.md → `to:implementer [DONE]` 收尾。掠奪根＝下個 slice 待我/用戶 greenlight（我傾向接著就開，它是殘留 thrash 的真根）。
