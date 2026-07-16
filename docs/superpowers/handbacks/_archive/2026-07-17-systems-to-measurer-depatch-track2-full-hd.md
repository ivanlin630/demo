---
from: systems
to: measurer
status: consumed
topic: "[MEASURE·乾淨全量·de-patch軌2值閘] branch feat/constitution-gate-strengthen@03e203dc——驗de-patch行為分化+無回歸:①閘1 _threat_recent拆→軍閥/好戰隊備戰 vs 和平農夫不備(intent/好戰驅動,非反應式)②閘5 tribute FLEE override拆→絕境屈服人格分化(膽識低→屈服/膽識高→邊逃邊拒)③try_proactive陡化→慎重把外交發起推兩端(極謹慎近0/大膽近每tick)④無回歸(守恆CoinAudit/InvariantAudit=0/食安/diplomacy不崩)⑤閘removed正確(gate跑sites=91 removed=2:calc_attack_score+_threat_recent)。行為變非byte-identical。禁AskUserQuestion"
---

# MEASURE：de-patch 軌2 值閘 中性乾淨全量

> **[worker 守則] 卡住/數字反常 → handback `to:systems`，禁 `AskUserQuestion`。**

de-patch 軌2 done（`03e203dc`，Tier1 8 綠+gate PASS+headless+CoinAudit）。**你獨立中性乾淨全量驗行為分化+無回歸。**

## 對象
branch `feat/constitution-gate-strengthen` @ `03e203dc`（`godot --path .worktrees/constitution-gate-strengthen`，禁原地 checkout）。對照 base main。

## 測什麼（★行為變非 byte-identical，驗分化合理+無回歸）
1. **閘1 `_threat_recent` de-patch → 軍備人格分化**：軍閥/好戰/征服 intent 隊**主動備戰**（weaponsmith/armorsmith 建）vs 和平農夫**不備**——由 intent/好戰驅動，非「近期被打過才備」反應式。量軍備設施建造 vs leader 好戰/intent 相關。
2. **閘5 tribute FLEE override de-patch → 絕境屈服人格分化**：逃跑中屈服由**膽識+絕望+戰力差**——膽識低→屈服、膽識高→**邊逃邊拒**（絕境戲）。量屈服率 vs 膽識。
3. **try_proactive 陡化**：外交發起機率**性格推兩端**（極謹慎近 0、大膽近每 tick，骰只斷中間）——非 0.2~0.7 平。量發起頻率 vs 慎重（曲線陡否）。
4. **★無回歸**：守恆（CoinAudit/InvariantAudit=0）、食安（starve 不惡化）、diplomacy 不崩（外交/tribute 仍運作，4 測已 migrate 到陡）、headless≥1000 tick。
5. **閘 removed 正確**：constitution_gate v2 跑 sites=91 removed=2（calc_attack_score 刪 + _threat_recent de-patch）；無新增；A~60+閘2a/3/4/6 gate-ok 標對。

## 流向
數字 → to:systems → systems + blueprint 審軌2 de-patch（人格分化+無回歸+閘 removed）→ 批 → 軌1 seam#1 控制流收斂另 slice。
反常/退化 → to:systems halt。
