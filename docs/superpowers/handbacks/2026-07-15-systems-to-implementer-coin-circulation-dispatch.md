---
from: systems
to: implementer
status: open
topic: "[DISPATCH] coin循環B成員稅回收(私囊鎖根治,經濟binding真修)——R²過(A自團版冗餘→defer,本刀只B);新分支feat/coin-circulation;TDD守恆CoinAudit=0"
---

# Dispatch：coin 循環 B 成員稅回收（私囊鎖根治）

> **[worker 守則] 卡住/授權不明/做不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-coin-circulation.md`（★R² 訂正：本刀只 B，A 自團版冗餘 defer 跨團版）。
R² 判決：`2026-07-15-reviewer-to-systems-coin-circulation-r2-issues.md`（premise/守恆/floor/determinism CLEAN；A 自團版=冗餘求解器 defer；reviewer 預 clear「只出 B 後 CLEAN」）。

## 根（經濟 binding 真根，measure 第 5 層）
salary `team.resources.coin→person.coin` 單向、person.coin 唯死亡回流 → team.coin 枯竭 → no_coin 91%（買方口袋空）→ 市場死。B 稅回收直補。

## 在哪：新分支
`feat/coin-circulation`，base 最新 main（`31b6fb9c`+）。

## 做什麼（★只 Fix B，A defer）
**`_collect_member_tax(state, team)`**（faction_ai，鏡射 `_consider_extraction:2235` pattern）：
- cadence＝月（`current_tick % TICKS_PER_MONTH == 0`，同 extraction 量級；或掛 salary 步後）。玩家隊不自動（`leader_id==player_id` return，同 extraction）。
- `tax_rate = clampf(貪婪×K − 慎重×K2, TAX_MIN, TAX_MAX)`（領袖人格，鏡射 extraction greed−prudence）。
- 對每 named 成員：`levy = min(person.coin × tax_rate, person.coin − PERSONAL_COIN_FLOOR)`（★留 floor 不收乾）；`levy<=0` 跳。
- `ResourceBank.adjust_person_coin(p, −levy, "member_tax")` + `ResourceBank.add(team, "coin", +levy, "member_tax")`（守恆 chokepoint）。
- **TEST VALUE**：K/K2/TAX_MIN/TAX_MAX/PERSONAL_COIN_FLOOR 標 TEST VALUE（measurer 校平衡）。

## 守則
- **★資源守恆**：只 person.coin→team.coin 池間搬，**CoinAudit delta=0**（硬驗，salary/extraction 既有不破）。
- **determinism** 零 randf → 同 seed 兩跑 bit-identical。
- **人格化**：稅率掛領袖（非 flat）。

## TDD
1. named 成員有 person.coin → 月 tick 團收稅 → person.coin 降、team.resources.coin 升（**守恆：Δperson = −Δteam**）。
2. **floor 不收乾**：`person.coin − levy >= PERSONAL_COIN_FLOOR`（留燃料）。
3. 貪婪領袖抽率 > 慎重領袖（人格化）。
4. 玩家隊不自動收稅。
5. CoinAudit delta=0；同 seed 兩跑 bit-identical；headless 零新增；憲法 sites=29。

## 完成後
→ handback `to:systems` → measurer 中性 full-HD（★no_coin 降 + team.resources.coin 不枯竭 + deals 真發生 + 守恆 CoinAudit=0 + coin census 雙向流動）→ QA → blueprint 批。
scope 疑義走 `to:systems`。A 成員消費跨團版=**下刀 follow-up**（別在本刀做自團版=冗餘）。accessor/resolver/死常數=框架債 backlog（非本刀）。
