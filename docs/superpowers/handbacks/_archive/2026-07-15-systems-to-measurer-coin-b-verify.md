---
from: systems
to: measurer
status: consumed
topic: "[量測·經濟真章] coin循環B成員稅@574d4a56——★no_coin降?市場revive?team.coin不枯竭+deals真發生+coin雙向流動+守恆CoinAudit=0;5層調查後真根修驗"
---

# 量測：coin 循環 B 成員稅（經濟真章 — 市場 revive?）

> **[worker 守則] 卡住/量不到/授權不明 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

branch `feat/coin-circulation` @ **`574d4a56`**（base 最新 main）。systems 驗 diff PASS：`_collect_member_tax` 鏡射 `_consider_extraction`（月 cadence、玩家 skip、稅率 greed−prudence clamp、留 PERSONAL_COIN_FLOOR 不收乾）、守恆 person.coin→team.coin。TDD 7 綠+CoinAudit=0、headless 3+3、sites=29。

## 這是 5 層調查後的真根修（私囊鎖）
真根＝salary 單向抽 team.coin→person.coin、named 唯死亡回流 → team.coin 枯竭 → no_coin 91% → 市場死。B 稅週期回補 team.coin。**驗真根修對否＝市場 revive**。

## 要驗（★中性 full-HD force_full_hd，before[main]/after[branch] 對比）
1. **★no_coin 降（headline）**：你上輪 co-loc bail 的 **no_coin 從 91%(24600/27020) 大降**？（team.coin 回補→買方有錢）。
2. **★deals 真發生**：`order_fulfilled`/`trade.deal_merchant` 從 ~0 回升（買方有 coin 買）→ 市場活。arb_hit 若也升更好（有錢成交）。
3. **★team.resources.coin 不枯竭**：coin census team_pool 不再單調趨零（月切面回補可見）；person_pool 不再單調漲（稅抽回）＝**雙向流動**（非單向死牢）。
4. **★守恆**：CoinAudit delta=0、InvariantAudit=0（coin 只搬不生不滅，salary/extraction/tax 三流守恆）。
5. **人格戲**：貪婪領袖抽稅重 vs 慎重輕（specimen 可讀差異）。
6. **無回歸**：同 seed 兩跑 bit-identical、憲法 sites=29、headless 零新增、既有 salary/extraction 不破。

## 判定
- no_coin 降 + deals 回升 + team.coin 不枯竭 + 守恆 → **私囊鎖修對、市場 revive** → handback `to:blueprint`（含 no_coin/deals/coin census 前後）→ QA → blueprint 批 merge → 觀察 revived 經濟定下步。
- **no_coin 仍高 / deals 仍~0**（稅補不夠 or 別的 binding）→ halt `to:systems`（貼數字，可能 floor/rate TEST VALUE 要校 or 更深層）。
- 守恆破（CoinAudit≠0）→ 硬 halt。

## 註
- floor/rate 是 TEST VALUE——若 no_coin 降但不夠（稅太輕/floor 太高），回報數字，systems 校 or blueprint 定平衡（別自己調）。
- 掛單噪音（order_placed/arb_kill_nostock）順帶對比（B 修後噪音降否）。

## 下游
數字一封信 `to:blueprint`（no_coin 前後 + deals + coin census 雙向 + 守恆 + 噪音）。溯源 raw + measured_at_head `574d4a56`。log/jsonl UTF-8。
