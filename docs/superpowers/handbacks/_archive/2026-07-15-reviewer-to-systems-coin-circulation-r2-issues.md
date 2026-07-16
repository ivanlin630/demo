---
from: reviewer
to: systems
status: consumed
topic: "[R²判決·issues] coin循環spec——premise/守恆/floor/determinism皆CLEAN,但你請裁的A/B冗餘題我判：A現行scope(自團版)確屬冗餘求解器,跟B同結構同終點池,真正非冗餘版本(跨團)被推遲——建議本刀只出B,A留待跨團版才上"
---

# R² 判決：coin 循環 spec（私囊鎖根治）

verdict: **issues**
premise_contradiction: false

## premise 驗證（file:line 全查證）

- `salary_system.gd:65-66`：`ResourceBank.remove(team,"coin",paid,...)` + `ResourceBank.adjust_person_coin(p,paid,...)`——team→person 單向確認。
- `npc_combat_system.gd`（死亡處理段）：`if p.coin>0: ResourceBank.add(team,"coin",p.coin,...) + adjust_person_coin(p,-p.coin,...)` 接著 `persons.erase(p.id)`——確認 person.coin 唯一回流路徑是死亡（erase 前搶救退回團），活著的 named 成員無任何機制把 coin 送回團——私囊鎖診斷坐實。
- `faction_ai_system.gd:2235-2245 _consider_extraction`：`extract_score = greed - prudence*0.5`，人格化抽取公式確認存在，Fix B 聲稱鏡射此模板屬實。
- `adjust_person_coin`（`resource_bank.gd:26`）chokepoint 確認存在，CoinAudit 稽核機制確認存在（`headless_test.gd`/`game_sim_multi.gd`）。

## 你請裁的判斷：A 是否冗餘

**判定：現行 scope 下，A 確屬冗餘求解器**（套本專案 R② checklist「框架內冗餘求解器」smell test）。

- **結構同一**：Fix B（`_collect_member_tax`）與 Fix A v1（`_member_consume` 自團版）都做完全相同的機械操作——`adjust_person_coin(-x)` + `ResourceBank.add(team,"coin",+x)`，同 chokepoint、同方向（person→team）、同終點池（team.resources.coin）。差別只在觸發公式：B 是週期性、領袖人格驅動、對象=全體 named 成員；A 是條件性、成員自身人格+需求驅動、對象=有消費需求的成員。
- **spec 自己承認真正的差異化版本被延後**：`spec:25`「或到市集向賣方團買（cross-team coin 擴散，市場活）...**先做向自團買**...cross-team 消費留 follow-up」——你原本設想 A 的價值在於**真實跨團交易**（創造真正的市場成交量），但這版 spec 出貨的是「自團」版，本質上只是**同一根弦的第二個拉桿**：兩個機制都只是把同一隊的 named 成員錢包搬回自己團的口袋，不創造任何 B 沒有的經濟能力（不增加 order_fulfilled、不創造 inter-team coin flow、不產生真實市場活動）。
- **smell test 直接命中**：「兩 option applicable 域重疊+結果殊途同歸嗎？」——是。「能不能用既有的某個+參數分流達成？」——能：B 的稅率公式可以直接擴充成「per-member 人格化+需求加權」（例如貧窮/飢餓成員抽少、囤積成員抽多），用**同一個週期性 sweep** 達成 A 想要的「人格化戲」敘事差異，不需要另開一條平行的 `_member_consume` cadence。
- **故事/敘事差異是真的，但不足以撐住兩套機制**：specimen trace 上「member 為何花錢」vs「leader 為何抽稅」的敘事確實不同，值得記錄——但這是**同一個 term 內可以吸收的細節**（一個 `spend_or_be_taxed` 式的統一週期抽取，公式裡吃領袖 rate 和成員 need/greed 兩個變數），不必要兩個獨立的呼叫點/cadence/驗收線去維護同一件事。

## 建議收斂方向

**本刀只出 Fix B**（直接命中 no_coin 91% 根因，premise 已驗、設計已 CLEAN，measurer 驗收指標①②③④全部靠 B 就能達成——B 本身已是「team.resources.coin 週期回補」的完整解）。**Fix A 的自團版本延後不出**：它現在不創造新經濟能力，只增加維護面（兩套 cadence/兩套 TDD/兩套驗收）換一個能被 B 公式吸收的敘事差異。**真正該做 A 的時機＝跨團版本就緒時**（那時它才創造 B 做不到的東西：真實 inter-team 市場交易量），屆時再開一輪 spec+R²，不是本刀 scope。

若 systems/blueprint 認為「成員 agency 敘事」現在就有獨立價值（不只是等跨團版），我建議至少把 A 的公式**併入** B 的 `_collect_member_tax`（同一 cadence、同一次 sweep，稅率一項加成員 need/greed 修正項），而非維持兩個獨立函式/cadence——這樣敘事差異保住，冗餘的執行面收斂為一。

## 其餘設計驗證（CLEAN，若收斂為單一機制後仍適用）

- **B floor 邏輯**：`person.coin - levy >= PERSONAL_COIN_FLOOR` 不收乾，設計對，與既有 `_consider_extraction` 的人格化抽取模板一致。
- **守恆**：全走 `ResourceBank`/`adjust_person_coin` chokepoint，CoinAudit delta=0 驗收硬斷合理。
- **determinism**：純人格+狀態公式算，零 randf，驗收「同 seed 兩跑 bit-identical」措辭一致。
- **人格驅動**：稅率掛領袖人格（貪婪/慎重），非 flat 死常數，合決策模型精神。

## 框外審評估
同意——機制新增（非治症/非繞過既有架構），標準審足夠；此輪的冗餘求解器判斷正是標準審該做的把關，非需升異質。

## 結論
premise/守恆/floor/determinism 全 CLEAN。**issue＝你請裁的 A/B 冗餘題——我判 A 現行 scope 確屬冗餘，建議本刀只出 B、A 延後到跨團版本才有獨立價值**。**issues → halt，退回收斂方向後可 CLEAN**（範圍收斂決定，非重新設計 B）。
