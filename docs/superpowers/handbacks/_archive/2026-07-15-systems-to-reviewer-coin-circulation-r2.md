---
from: systems
to: reviewer
status: consumed
topic: "[R²·設計審] coin循環(私囊鎖根治)——B成員稅回收(鏡射_consider_extraction,直補no_coin,floor不收乾)+A成員消費(人格化戲);★守恆核心CoinAudit=0;premise file:line坐實免R①"
---

# R²：coin 循環 spec（私囊鎖根治）

> **[worker 守則] 卡住/疑義 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

spec：`docs/superpowers/specs/2026-07-15-coin-circulation.md`。
blueprint 願景（用戶定 A+B）：`2026-07-15-blueprint-to-systems-coin-cycle-vision.md`。
真根定音：`2026-07-15-systems-to-blueprint-economy-real-root-siku`（no_coin 91%=私囊鎖，measure 第 4 次破非-binding 假設）。

## premise 已 file:line 坐實（免 R①）
salary `team.resources.coin→person.coin` 單向(`salary_system:65-66`)、person.coin 唯一 outflow=死亡(`npc_combat:745`)、living named 無回流 → team.coin 單調枯竭 → no_coin 91%（measurer 27020 bail 中 24600）。

## 審什麼（機制 add，coin 雙向流動）
1. **Fix B 成員稅（★直補 no_coin）**：`_collect_member_tax` 鏡射 `_consider_extraction:2235`（leader 貪婪-慎重→rate）；對 named 成員 `levy=person.coin×rate`，**留 PERSONAL_COIN_FLOOR 不收乾**（blueprint 平衡意圖）；`adjust_person_coin(-levy)`+`add(team,coin,+levy)`。**驗**：守恆（person→team 只搬）？floor 邏輯對（不透支/留燃料）？cadence（月/同 extraction）合理？
2. **Fix A 成員消費**：named 成員 person.coin 花個人需求→先做「向自團買個人口糧」（person.coin→team.resources.coin）+ 人格化（貪婪囤/匱乏花）。**驗**：A 向自團買＝person→team，與 B 同向（都回團池）——**A 是否與 B 冗餘**？我判 A=成員 agency/戲（bottom-up 消費）、B=top-down 稅，互補非冗餘（都回池但驅動不同）——你裁這判斷；若你認 A 冗餘/該 cross-team 才有意義，flag。
3. **★守恆核心**：所有 coin 走 ResourceBank/adjust_person_coin chokepoint，只池間搬。**CoinAudit delta=0 硬驗**。**驗**：有無漏池/憑空/蒸發？
4. **人格化 + determinism**：稅率掛領袖、消費掛成員（非 flat）；零 randf（或 seed 化）→ 同 seed 兩跑 bit-identical。

## 特別看
- **B floor vs A 燃料耦合**：稅留 floor → A 消費有錢花。驗 floor 設太高（稅無效補不了 no_coin）or 太低（收乾 A 沒燃料）的平衡（TEST VALUE 待 measurer 校，但設計上兩者不打架）。
- **salary↔稅↔消費 淨流**：salary 出、稅+消費入。驗淨流不會反向爆（team.coin 無限漲）或死循環。
- **accessor/resolver/死常數**＝框架債 backlog（非本刀，spec 已標）——確認不誤納。

## 流向
CLEAN → dispatch implementer（feat/coin-circulation）→ measurer 中性 full-HD（no_coin 降 + deals 發生 + 守恆 CoinAudit=0）→ QA → blueprint 批。
premise_contradiction 或守恆漏 → to:systems halt。
