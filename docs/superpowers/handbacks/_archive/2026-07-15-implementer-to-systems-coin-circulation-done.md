---
from: implementer
to: systems
status: consumed
topic: "[完] coin 循環 B 成員稅回收 — HEAD 574d4a56;只 Fix B;守恆 TDD 7綠+CoinAudit delta=0;headless 3+3;憲法 sites=29"
---
# Hand Back：coin 循環 B 成員稅回收（私囊鎖根治）

branch `feat/coin-circulation` @ `574d4a56`（已 push），base = origin/main `8954ae79`。★只 Fix B（A 自團版冗餘 defer 跨團版，R② 訂正）。

## 實作
`_collect_member_tax(state, team)`（faction_ai，鏡射 `_consider_extraction` pattern）：
- **月 cadence**：掛既有 extraction 呼點旁（`current_tick % TICKS_PER_MONTH == 0`）；**玩家隊不自動**（`leader_id==player_id` return）。
- **稅率人格化**：`tax_rate = clampf(貪婪×MEMBER_TAX_K − 慎重×MEMBER_TAX_K2, MIN, MAX)`。
- **每 named 成員**：`levy = min(coin×rate, coin − PERSONAL_COIN_FLOOR)`（留 floor 不收乾）；levy<=0 跳。
- **守恆 chokepoint**：`ResourceBank.adjust_person_coin(p, −levy)` + `ResourceBank.add(team, "coin", +levy)`（池間搬）。
- **TEST VALUE**：K=0.3/K2=0.2/MIN=0/MAX=0.5/FLOOR=5.0（measurer 校平衡）。

## 守則達成
- **★資源守恆**：只 person.coin→team.coin 池間搬，**CoinAudit delta=0 minted=0**（salary/extraction 既有不破）。
- **determinism 零 randf**；人格化（稅率掛領袖非 flat）。

## 驗（TDD + sanity；log 落地）
- **TDD 7/7 PASS**：★Δperson=−Δteam 守恆、floor 不收乾(留燃料/已在 floor 下不收)、貪婪領袖抽率>慎重(人格化)、玩家隊不自動。
- **CoinAudit delta=0 minted=0**；**headless 3+3 baseline 零新增**；**憲法 sites=29**；seeded warring reproducible。

## 下一站需求（measurer 中性 full-HD，spec §驗收）
- **★no_coin 降 + team.resources.coin 不枯竭 + deals 真發生 + 守恆 CoinAudit=0 + coin census 雙向流動**。

## follow-up（非本刀）
- A 成員消費跨團版 = 下刀 follow-up（別做自團版=冗餘）。accessor/resolver/死常數 = 框架債 backlog。

## 待確認
- 完成判定 = systems + reviewer/QA + measurer 中性 full-HD。context hold warm 等裁決信。
