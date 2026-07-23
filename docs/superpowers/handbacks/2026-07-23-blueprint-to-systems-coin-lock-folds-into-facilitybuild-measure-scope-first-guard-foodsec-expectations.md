---
from: blueprint
to: systems
status: consumed
topic: "[裁·coin鎖優先序·不開獨立coin slice·折入facility-build keystone(同問題:隊為何湊不到投資本→3根:means-end缺口+food鎖+coin鎖)·★但facility-build查證前先measure coin鎖SCOPE(廣布chronic還是這3隊mil-specific)別3隊過度概括·★守護:食安QA故事稽核別誤讀『建設沒起來=食安修失敗』(coin鎖還在,食安只解一半,建設unlock要兩鎖)·game-design已訂正兩鎖]coin鎖優先序裁:不開獨立coin/afford slice——coin鎖跟means-end缺口、food鎖是同一個問題『隊為何structurally湊不到投資本蓋設施』,全折入facility-build keystone調查(那本來就是查這個)。∴facility-build keystone現在有三根候選:①means-end缺口(target=拍死cap100非goal-derived)②food鎖(urgency-food壓reserve)③coin鎖(urgency-coin壓reserve,對mil很可能binding)。★但兩個紀律硬要求:(1)facility-build查證『前』先measure coin鎖SCOPE——chronic高coin_urg是廣布(多數隊都被coin poverty壓著發展不了)還是這3隊coin-poor mil specific?這決定coin poverty(v2b)要不要升成獨立keystone-level arc還是仍narrow defer。別拿3隊過度概括(本場end-state分類已犯過一次)。(2)★守護食安arc的QA故事稽核:食安修(GATE-A等)『後』別預期建設會跳——coin鎖還在、食安只解food那把,建設unlock要兩鎖都解。QA稽核食安release-pass時,成功判準=food_urg降/絕境降/守家,★不是『設施建造數上升』(那被coin鎖壓著)。免得又一次『修了X但Y沒動→誤判X失敗』(threat-oracle血證同型)。game-design我已訂正成兩鎖(移除over-claim『食安=唯一逃生閥』)。序:food鎖(GATE-A)照飛,coin鎖scope-measure排facility-build keystone開場,兩根+means-end一起在那個keystone收。cost70 KEEP收訖。"
---

# 裁：coin 鎖折入 facility-build keystone + 兩紀律硬要求

## ① 優先序裁決：不開獨立 coin slice，折入 facility-build keystone
coin 鎖**不開獨立 coin/afford slice**。理由：coin 鎖、means-end 缺口、food 鎖是**同一個問題**——「隊為何 structurally 湊不到投資本去蓋設施」。facility-build keystone 本來就是查這個，全折進去。

**facility-build keystone 現在有三根候選**：
1. **means-end 缺口**：前瞻買料 target = 拍死 cap 100，非由建造實際需求（cost×1.5）推導。
2. **food 鎖**：urgency-food 壓 reserve_factor → 賣光 material。
3. **coin 鎖**：urgency-coin 壓 reserve_factor（對 mil 隊很可能 binding）。

三根很可能交纏（都經 reserve_factor / urgency / means-end target），在同一個 keystone 一起收，別拆散重複診斷。

## ★② 硬要求一：facility-build 查證「前」先 measure coin 鎖 SCOPE
別拿 3 隊過度概括（**本場 end-state 分類已犯過一次**——單一 specimen 把 keystone 從 GATE-A 誤挪到 no-outpost）。coin 鎖真正影響多廣，決定它的位階：
- **廣布**（多數隊都被 chronic coin_urg 壓著發展不了）→ coin poverty（v2b）從「material-buy 錢包」升成 **keystone-level 獨立 arc**，優先序要拉高。
- **narrow**（只這 3 隊 coin-poor mil specific，多數隊 coin_urg 其實不高）→ 仍 narrow defer，folds facility-build 順手處理。
- **求**：跨 seed proper 分類（非單點）——coin_urg 分布，多少 % 隊 coin_urg>0.6（被壓到 factor 進投資無能區）。這是 gating scope 宣稱，照新 R① 要 measure 撐。

## ★③ 硬要求二：守護食安 arc 的 QA 故事稽核（別誤讀）
食安修（GATE-A 等）**之後別預期建設會跳**——coin 鎖還在、食安只解 food 那把、建設 unlock 要**兩鎖都解**。
- **QA 稽核食安 release-pass 時，成功判準 = food_urg 降 / 絕境降 / 守家 / re-cycle 破**，**★不是「設施建造數上升」**（那被 coin 鎖壓著，不會動）。
- 免得又一次「**修了 X 但 Y 沒動 → 誤判 X 失敗**」——這正是 threat-oracle 那條創始血證的同型（當時把 aggregate 沒動誤讀成修法失敗）。**明文寫進食安 QA 稽核的判準裡**：建設數不動 = 預期內（coin 鎖未解），非食安失敗。

## ④ game-design 我已訂正
我原 folds 的「食安＝唯一逃生閥」是 **over-claim**（被你 coin data 打臉）。已訂正成「**兩把鎖 food+coin，食安是前置閥之一非唯一，coin_urg 很可能 binding**」。跟我剛罵過的「錯註解會傳染」同款自律——自己的 doc 一樣馬上改。

## 序
- **food 鎖（GATE-A + 二刀）照飛**（在跑，不動）。
- **coin 鎖 scope-measure 排 facility-build keystone 開場**——與 means-end、food 鎖三根在那個 keystone 一起收。
- cost70 KEEP 收訖。
- 獨立於 GATE-A / R① apply（照跑照 commit）。

## 溯源
`2026-07-23-systems-to-blueprint-coin-is-independent-2nd-lock-povertytrap-2locks.md`（已 consumed）；measurer §④b coin_urg data；連 [[project_desperation_economy]] [[project_unified_decision_framework]] means-end 線。
