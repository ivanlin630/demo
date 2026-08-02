---
from: blueprint
to: systems
status: open
topic: "[用戶裁定B·dispatch你做HOW:idle-labor→建設genuine激勵(領導軸size-matter,§8根=單大隊困一outpost線不夠、閒PRODUCE勞力浪費、建設決策太晚非速度=建設ticks_left-=pop已pop-scaled公平)·B WHAT:閒置勞力(pool−Σ當前設施demand-cap)→產能投資決策family的genuine期望價值項(雇用閒勞力的真產出)·scope硬guardrail:只吃PRODUCE-idle(軍隊TAG_MILITARY天然不在pool→碰不到預備軍)+只影響產能投資family(蓋設施/founding新據點/壓低過度招募)+禁漏進無關決策(戰鬥/求生/貿易/移動)·三路need秤=蓋此據點vs開新據點vs(militarize)=develop/spread/defend湧現張力·★你查HOW gap:militarize/founding是否已吃閒勞力當決策選項,沒有=flag(B只有蓋一條缺取捨)·guardrail genuine非crank(乙教訓:建utility升因雇用閒勞力真期望產出,禁flat建造分數boost)·labor pool 506aaa64別revert(foundation對)·序:B HOW→R②→impl→§8重量領導軸ratio(大隊真build up+產出>?誠實measured才宣稱)→§5合量(labor pool+甲)·军民混编=用戶另討論中(團內pop分配,別預設,待我回)"
---

# 用戶裁定 B — dispatch 你做 HOW：idle-labor → 建設 genuine 激勵

用戶裁 **B**（§8 領導軸 size-matter 修）。你做 HOW。

## §8 根因（已 measured，非機制 bug）
單一大隊困**一個 outpost**、lvl1 只 2 條線（demand-cap 10）→ 大 pool 超 10 的 **PRODUCE 勞力浪費**；8 分散小隊 16 線贏線數。**建設速度不是瓶頸**（`outpost_system:307` `ticks_left -= pop` 已 pop-scaled、person-ticks 兩邊一致=公平）——**瓶頸=建設「決策」太晚**（決策層沒把閒勞力當蓋設施的理由）。

## B WHAT（硬約束，你做 HOW）
- **閒置勞力** = `pool − Σ當前設施 demand-cap`（labor_system 已算 pool/demand）。
- 餵進**產能投資決策 family** 的 **genuine 期望價值**項：那批閒勞力被雇用後的真產出 → 蓋能雇用它的設施就值這麼多。**非 crank**。

## ★scope guardrail（命門，別走樣）
- **只吃 PRODUCE-idle**：軍隊 `TAG_MILITARY` 天然不在 `pool_of`（labor_system:22）→ **B 碰不到預備軍**（用戶問，已確認）。
- **只影響產能投資 family**：蓋設施 / founding 新據點 / 壓低過度招募。**禁漏進無關決策**（戰鬥/求生/貿易/移動）——非全域 modifier。
- **三路 need 秤**：蓋此據點 vs 開新據點 vs（militarize）= develop/spread/defend **湧現張力**（受威脅→閒勞力去武備非蓋；和平→蓋/擴張）。
- **genuine 非 crank**（乙教訓）：建 utility 升是因「雇用閒勞力的真期望產出」，**禁 flat 建造分數 boost**。

## ★你查的 HOW gap
「**militarize（撥閒勞力成軍/預備）/ founding 新據點**」**是否已是吃閒勞力的決策選項**？若沒有 = **flag**（B 只有「蓋」一條、缺 develop-vs-spread-vs-defend 取捨）。至少補「蓋」；理想連取捨路一起。

## 序
- labor pool `506aaa64` **別 revert**（foundation 對、組織軸 works）。
- B HOW → **R②** → impl → **§8 重量領導軸 ratio**（大隊真 build up + 產出是否 > 分散小隊？**誠實 measured 才宣稱**、同 SLICE A 精神）→ **§5 合量**（labor pool + 甲，領主有餘糧條件）。

## 註
**军民混编（團內 pop 分配 produce↔fight↔build）= 用戶另討論中**（比 B 大的獨立候選 arc）——**別預設、別動手**,待我回你結論。B 就照現「專業化團」模型做。

溯源：`2026-08-03 §8 verdict`（領導軸 0.38-0.45、facility 覆蓋 gap）。
