---
from: reviewer
to: systems
status: consumed
topic: [R② verdict] world-gen variety 技術 spec = CLEAN
---

# 對抗② 審判 verdict — world-gen variety 技術 spec

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "tile評分(世代生成/ground-truth) vs _belief_richness(decision-time/belief) 層次分開非冗餘；地板(結構可達性)vs放野(誰贏/份額)正交不衝突；retry走同seeded rng bounded N次不破determinism。" }
```

## file:line 驗證
- `game_setup.gd:29-30 rng.seed = int(config.get("seed", 42))` — 確認 seeded rng 已存在於 setup 入口，`pick_start_positions` 現況確未使用（spec 加 rng 參接上既有流，非新建）。
- `resource_system.gd:33 REGEN_RATE` — 確認存在，資源評分基礎複用合理。
- `faction_ai_system.gd:263 _belief_richness` / `:3150 _find_forage_tile` — 確認存在，但屬 **decision-time 對其他隊的 belief 評估**（runtime、per-observer、主觀認知），與世代生成時 **tile ground-truth 資源評分**（one-time、無 belief、無 team）完全不同層。

## refute 靶逐項
1. **位置熵護欄**：top-K(K=剩餘需求×ENTROPY_MULT)/per-tile 噪聲，屬 TEST VALUE 平衡問題（K 大小），非結構缺陷，留 measurer 校準符合本專案一貫 TEST VALUE 慣例。過，非阻擋。
2. **retry vs determinism**：同一 seeded rng 續抽 + bounded N 次——rng 消耗序列在同 seed 下固定，retry 是 deterministic control flow（非牆鐘/非未 seed randf），同 seed 仍 byte-identical。過。
3. **地板 vs 放野界**：地板只管結構可達性（每勢力≥1可達+連通+覆蓋度+無死角），不管誰贏/人口平衡份額——與放野（勢力數/份額/獨霸稀疏仍全甩）正交不衝突，是前輪 blueprint 已批准靶C修正的技術落地，一致。
4. **據點評分 term 冗餘 lens**：如上，時機/對象/真值vs認知三維皆分開，非冗餘。
5. **build-outpost dispatch>0**：處置與前輪 blueprint spec 批准的獨立待驗項一致（機制存在+實測fire+罕則回報，非留空地自動推論）。過。
6. **重 baseline**：一次性程序，對應 design 約束#3（用戶已認可基線位移），流程合理。

CLEAN，dispatch implementer。
