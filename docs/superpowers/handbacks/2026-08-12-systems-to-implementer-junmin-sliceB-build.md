---
from: systems
to: implementer
status: consumed
topic: "[build 军民混编 Slice B(spec §3 LOCKED、R² CLEAN、charter/mobilization split 避 Track②A)·新 branch feat/junmin-militia-slice-b 自 main HEAD·★systems grounding 硬讀坐實:finding④ manufacturing:86 labor_share=team.population/pool_of 現分子分母都 full-pop 一致=1.0、但 Slice B pool_of 分數化後分子仍 raw→>1 膨脹=分子須同步分數化(真 coupling);finding③ ensure_fresh+labor_eval_next_tick cache 動員改 pool 須觸重算·★★§HOW-binding:①新 mobilized_fraction 欄(TeamData、動態[0,1]=戰力配置比、labor 配置=1−此):genuine 從 belief-threat(Slice A _max_belief_threat 已鋪)+charter 基底(專業軍團高/居民團低)+人格(好戰/慎重)湧現、隨威脅升動員/和平降解甲、bounded clamp[0,1]、★禁死常數②charter=現 TAG_PRODUCE/TAG_MILITARY 保留當穩定團型(不動)、mobilized_fraction 是新獨立正交欄③mobilization 驅動消費者改讀 fraction:B 勞力(labor:27/37 pool_of 分數化=Σ pop×(1−mobilized_fraction)+manufacturing:86 分子同步分數化 labor_share≤1 finding④)+F 裝備(faction_ai:3002/3037 讀 mobilized_fraction 非靜態 TAG_MILITARY)+D 脆弱度(interaction:395/301/303/521+diplomatic:263 讀 fraction/armed=解甲民兵可劫)④charter 驅動 UNCHANGED 零改:A 路由(uses_unified:2394 讀 TAG 不動、★reviewer bonus 若未來要改走單點 wrapper 但本批不改)+E 薪資pop(population:30/salary:30)+C 居民鎖(faction_ai:502 is_resident_static)=★正交性硬保證 byte-identical⑤團型梯度=charter 分級(專業軍團純軍 base fraction 高/後備半兵半農中/居民團民兵低才召)⑥guns-vs-butter=威脅→mobilized_fraction 升→labor 池降→產出掉(真戰爭成本)、和平→降→解甲回田⑦finding③ 動員態變→labor cache 觸重算(mobilized_fraction 改 or 威脅變→ensure_fresh 失效重算)·★★命門:genuine 非死常數(動員 belief-threat+charter+人格湧現)、bounded、感知鐵律(belief-threat 非 god-view Slice A 已達)、統一非補丁(分數化既有機制非加平行旋鈕)、無新 randf determinism·★★驗收(spec §5、硬數據、machine-demonstrate+realistic):①★威脅→動員→產出掉(machine:mobilized_fraction 0→高→labor_share/worker_rate 掉、guns-vs-butter 真成本)②★和平解甲(威脅除→mobilized_fraction 降→labor 回、產出回)③團型梯度分化(專業軍團 vs 後備 vs 居民 mobilized_fraction base 不同+威脅回應不同)④★labor_share≤1 硬證(finding④ 修:分子分母都分數化、多隊 Σ≤1、machine-demonstrate)⑤★charter 消費者零 churn(路由 uses_unified/薪資/居民鎖 byte-identical=正交性驗、村動員民兵時路由不翻)⑥finding③ cache 動員觸重算⑦determinism+constitution(★TAG_MILITARY 靜態 gate 移除記錄)+regression(junmin_guard/active_promotion/named_scarcity_ab)·★行為變 slice=fp 分化 intended·完成 handback to:systems merge-gate 硬讀(核 fraction genuine 無死常數+finding④ labor_share≤1+charter 消費者正交零 churn+感知鐵律+finding③ cache+bounded)→QA→merge→blueprint 推用戶(军民混编完整)·地基 KEEP"
---

# build 军民混编 Slice B — charter/mobilization split（spec §3、避 Track②A）

spec `docs/superpowers/specs/2026-08-12-junmin-militia-mobilization-design.md §3`。新 branch `feat/junmin-militia-slice-b` 自 main HEAD。

## ★systems grounding 硬讀坐實（兩 bonus finding）
- **finding④**：`manufacturing:86 labor_share = team.population / pool_of` 現分子分母都 full-pop 一致=1.0；但 Slice B pool_of 分數化後**分子仍 raw → >1 膨脹** = **分子須同步分數化**（真 coupling）。
- **finding③**：`ensure_fresh` + `labor_eval_next_tick` cache；動員改 pool → cache 須觸重算。

## ★★§HOW-binding
1. **新 `mobilized_fraction` 欄**（TeamData、動態 [0,1] = 戰力配置比、labor 配置=1−此）：genuine 從 belief-threat（Slice A `_max_belief_threat` 已鋪）+ charter 基底（專業軍團高/居民團低）+ 人格（好戰/慎重）湧現、隨威脅升動員/和平降解甲、bounded clamp[0,1]、★禁死常數。
2. **charter = 現 `TAG_PRODUCE`/`TAG_MILITARY` 保留當穩定團型**（不動）、mobilized_fraction 是新獨立正交欄。
3. **mobilization 驅動消費者改讀 fraction**：
   - **B 勞力**：`labor:27/37 pool_of` 分數化（= Σ pop×(1−mobilized_fraction)）+ `manufacturing:86` 分子同步分數化（labor_share≤1、**finding④**）。
   - **F 裝備**：`faction_ai:3002/3037` 讀 mobilized_fraction 非靜態 TAG_MILITARY。
   - **D 脆弱度**：`interaction:395/301/303/521` + `diplomatic:263` 讀 fraction/armed（解甲民兵可劫）。
4. **charter 驅動 UNCHANGED 零改**：A 路由（`uses_unified:2394` 讀 TAG 不動、★reviewer bonus：若未來要改走單點 wrapper、**本批不改**）+ E 薪資pop（`population:30`/`salary:30`）+ C 居民鎖（`faction_ai:502`）= ★**正交性硬保證 byte-identical**。
5. **團型梯度** = charter 分級（專業軍團純軍 base fraction 高 / 後備半兵半農中 / 居民團民兵低才召）。
6. **guns-vs-butter** = 威脅→mobilized_fraction 升→labor 池降→產出掉（真戰爭成本）、和平→降→解甲回田。
7. **finding③**：動員態變 → labor cache 觸重算。

## ★★命門
genuine 非死常數（動員 belief-threat+charter+人格湧現）、bounded、感知鐵律（belief-threat 非 god-view、Slice A 已達）、**統一非補丁**（分數化既有機制、非加平行旋鈕）、無新 randf determinism。

## ★★驗收（spec §5、硬數據、machine-demonstrate + realistic）
1. ★**威脅→動員→產出掉**（machine：mobilized_fraction 0→高→labor_share/worker_rate 掉、guns-vs-butter 真成本）。
2. ★**和平解甲**（威脅除→mobilized_fraction 降→labor 回、產出回）。
3. **團型梯度分化**（專業軍團 vs 後備 vs 居民 mobilized_fraction base 不同 + 威脅回應不同）。
4. ★**labor_share≤1 硬證**（finding④ 修：分子分母都分數化、多隊 Σ≤1、machine-demonstrate）。
5. ★**charter 消費者零 churn**（路由 uses_unified/薪資/居民鎖 byte-identical = 正交性驗、村動員民兵時路由不翻）。
6. **finding③** cache 動員觸重算。
7. determinism + constitution（★TAG_MILITARY 靜態 gate 移除記錄）+ regression（junmin_guard/active_promotion/named_scarcity_ab）。
★行為變 slice = fp 分化 intended。

## 序
完成 handback `to:systems` merge-gate 硬讀（核 fraction genuine 無死常數 + finding④ labor_share≤1 + charter 消費者正交零 churn + 感知鐵律 + finding③ cache + bounded）→ QA → merge → blueprint 推用戶（军民混编完整）。地基 KEEP。
