# Spec：coin 循環（私囊鎖根治，經濟 binding 真修）

status: draft（待 R² → dispatch implementer）
owner: systems
premise_verified: ★file:line 坐實——salary `team.resources.coin→person.coin` 單向(`salary_system:65-66`)、person.coin 唯一 outflow=死亡(`npc_combat:745`)、living named 成員無回流路徑 → team.resources.coin 單調枯竭 → no_coin 91%(measurer)
blueprint_vision: `2026-07-15-blueprint-to-systems-coin-cycle-vision.md`（用戶定 A 消費 + B 回收，成員成經濟 agent，coin 雙向流動非單向死牢）
governing: `invariants.md`（資源守恆 — coin 只在既有池間移，總量守）

## 根因（私囊鎖，code-verified）
coin 4 池（`coin_audit:7`）：team.resources.coin（貿易花的流通池）+ anon_treasury + person.coin + tile。salary 每 cycle 抽 team.resources.coin → person.coin（named）/treasury（anon）。**anon_treasury 有 `_consider_extraction:2235` 回收；named person.coin 唯死亡回流**（`npc_combat:745`）→ living named 成員囤 coin 黑洞 → team.resources.coin 單調枯竭 → 買方到 market 口袋空（no_coin 91%）→ 市場死。

## Fix（coin 雙向流動，守恆，A+B）

### Fix B：成員稅回收（★直補 no_coin，鏡射 _consider_extraction）
團週期收 named 成員 person.coin 部分 → team.resources.coin。
- **`_collect_member_tax(state, team)`**（faction_ai，cadence＝月/同 extraction；玩家隊手動不自動）：
  - `tax_rate = clampf(leader 貪婪×K − 慎重×K2, TAX_MIN, TAX_MAX)`（人格化，鏡射 extraction 的 greed-prudence；貪婪領袖抽多）。
  - 對每 named 成員：`levy = person.coin × tax_rate`，但**留 floor**（`person.coin − levy ≥ PERSONAL_COIN_FLOOR`，★不收乾＝留成員錢消費，blueprint 平衡意圖）。
  - `ResourceBank.adjust_person_coin(p, −levy)` + `ResourceBank.add(team, "coin", +levy)`（守恆，chokepoint ledger）。
- **這是 no_coin 直解**：team.resources.coin 週期回補 → 買方有錢買。

### Fix A：成員消費（★R² 訂正：本刀 defer，跨團版才上）
**R² 判：A「向自團買」版＝冗餘求解器**——person.coin→自團 team.coin，與 B 稅同結構、同終點池、同方向。兩機制做同一 coin 移動＝多求解器反模式。**A 的真價值（成員經濟 agent、市場需求擴散）只在跨團版兌現**（成員買**外團**賣方 → coin cross-team 擴散、市場活）。∴ **本刀只出 B**（直補 no_coin，load-bearing）；**A 跨團版 = follow-up**（併經濟後續，成員成 market buyer 新 actor，較大 add）。blueprint A+B 願景保留，A 非刪＝推遲到非冗餘的跨團形式。

### 平衡（blueprint 意圖：稅別收乾）
B 稅 floor（PERSONAL_COIN_FLOOR）留成員錢 → A 消費有燃料 → 雙向流動（salary 出、稅+消費入）。全 TEST VALUE 待 measurer 校。

## invariant 守
- **★資源守恆**：所有 coin 移動走 `ResourceBank`/`adjust_person_coin` chokepoint（既有 ledger），coin 只在池間移、總量守。**CoinAudit delta=0**（硬驗）。
- **determinism**：稅率/消費率純人格+狀態算，零 randf（或若用 randf 需 seed 化）→ 同 seed 兩跑 bit-identical。
- **人格驅動**：稅率掛領袖人格、消費掛成員人格（非 flat 死常數）＝合決策模型人格化精神。

## 驗收（★中性 full-HD + 守恆）
1. **★no_coin 降**：`team.resources.coin` 不再單調枯竭（週期回補）→ co-loc bail 的 no_coin% 從 91% 大降。
2. **★deals 真發生**：order_fulfilled/trade.deal_merchant 從 ~0 回升（買方有錢買）→ 市場活。
3. **coin 三池動**：team_pool/person_pool 雙向流動（非 person_pool 單調漲）；coin census 顯循環。
4. **★守恆**：CoinAudit delta=0、InvariantAudit=0（coin 只搬不生不滅）。
5. **人格戲**：貪婪領袖抽稅重/貪婪成員囤 coin（specimen 可讀差異）。
6. **無回歸**：同 seed 兩跑 bit-identical、憲法 sites=29、headless 零新增、既有 salary/extraction 不破。
7. **中性世界判**。

## dispatch 註
- 新分支 `feat/coin-circulation`，base 最新 main。
- **R²**（機制 add，標準審）：dispatch 前 to:reviewer 審設計（B 稅守恆+floor、A 消費 plumbing、人格化、determinism、CoinAudit=0）。premise file:line 坐實→免 R①。
- 完成判定 = systems + reviewer + measurer（中性 full-HD：no_coin 降 + deals 發生 + 守恆）+ blueprint 批。
- TDD：B 稅（person.coin→team.coin 守恆+floor 不收乾）；A 消費（person.coin→team.coin 守恆+人格 rate）；CoinAudit=0；同 seed 兩跑 bit-identical。
- **accessor/resolver/死常數 = 框架債 backlog**（非本刀；coin 修驗市場活後，accessor local_value +114% 等小改善順手 or 併框架債）。
- **修後 → measurer 驗市場 revive → blueprint 批 → 觀察 revived 經濟定下步**（發展模型/threat 韌性 B 等）。
