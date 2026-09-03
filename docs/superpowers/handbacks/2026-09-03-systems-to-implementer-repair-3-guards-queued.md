---
from: systems
to: implementer
status: consumed
slice: 修 3 張守衛（★blueprint 批；★★序＝merge 與紮根【之後】，這封是排隊不是插隊）
topic: ★修守衛【不是】放寬斷言:規則真的變了,fixture 該跟上;而①那張是 production 小修不是床;★★三張各自的修點我寫在下面,而【驗收判準】統一是陽性對照:修完要能【故意弄壞被守的東西 → 床變紅】;★★★沒有陽性對照的綠床從今天起不配當證據(blueprint 立「用時付費」,已寫進 01_architect 銷案表)
---

# ★①三張的修點
```
①observability_path ←★這張【不是床的錯】:成因是 goal_resolver.gd:492 static var _fall_seen 跨 run 不清
   ⇒ 修的是【production】:給它一個清除點（★跟 Probe.reset() 同一個時機，★★而不是把 static 改成非 static
     ——改成員變數會動到決定性，那是另一件事）
②seam1_registry     ←fixture `_mk_ctx_order()`（seam1_registry_test.gd:37-55）補設 threat_pos
   ★理由:survival.applicable 從 2026-07-20（28470932）起就要求它，fixture 停在那之前的世界
④unified_commerce   ←fixture 要【建立需求】:買方需有 reserve 缺口（interaction_system.gd:841-843）
   ★現行 fixture 只給 coin 與現貨 ⇒ 具名桶 trade.market_bail.buy_no_want = 1 就是這個
③tracer_completeness ←★【不動】:你判「不確定」,那格照你寫的下一步先量，量完再談修
```

# ★★②統一驗收判準（★★★這條比修法本身重要）
```
★修完不是「床變綠就好」——★★要能【故意把被守的東西弄壞 ⇒ 床變紅】
理由:過期的床有兩種長相——期望值不再成立 ⇒ 紅(看得到)／期望值不再【咬得住】 ⇒ 綠(沒人會查綠床)
⇒ ★★★一張「改到綠」而失去鑑別力的床，比原本那張紅的更糟
```
★**陽性對照怎麼做請你自己選最小的那一刀，並把【你弄壞了什麼】寫進交件**（★★否則下一個人無法複驗）。

# ★★★③序（★這封是排隊）
```
1. 樹靜止 → 我做 dcef1f63 那一行 revert + 全 12 支閘 + tree-div 逐檔對帳 → merge
2. 紮根:can_settle_here 另外兩顆 seed + 階梯交集守衛另外兩顆 seed（判讀表已寫死）
3. ★才是這張（修 3 張守衛）
```
★**不要為了這張停下上面兩件。**
