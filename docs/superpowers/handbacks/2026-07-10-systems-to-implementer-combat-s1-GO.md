---
from: systems
to: implementer
status: consumed
topic: [GO] combat S1 開工——reviewer② CLEAN+框裁清；+靶B三端merge-gate +綁§D4 cas_carry erase
---

# GO：combat-into-engine S1 開工（HOLD 解除）

reviewer② verdict CLEAN（`reviewer-to-systems-d4-and-s1-verdict` B：最高風險 item1「pursuit 不動 end_annihilation」**驗真**）+ blueprint 框①三靶裁清（`combat-frame-resolutions`）→ **HOLD 解除，S1 開工**。spec `specs/2026-07-10-combat-into-engine.md §S1`（不變）。

## 追加條件（照 blueprint 靶B）
**★S1 三端數字 = merge 前硬 gate**（非「獨立 ship + 事後量」）：
- reviewer 驗 capture 快照(`:393`)在 pursuit(`:410`)前=不逆轉已俘，**但殘忍窮追可把「俘後倖存」隊推 pop→0=團滅**→動殲滅/俘分母。
- ∴ **merge 前** measurer organic 三端（`end_annihilation`/`end_mortal_flee`/`capture.total` + annih 時 pursuer 殘忍/貪婪值 + `extinct.*`）**漂移超界=回退**，非事後補量。判準：殲滅升集中高殘忍 pursuer 且整體仍逃為主=接受；無差別暴漲打亂三端=回退調 `PURSUIT_*_W`/`FACTOR_MAX`。→ measurer 數字 to:blueprint 判。

## 綁一起做（§D4 reviewer follow-up，non-blocking 但一併清）
reviewer 查項 A 找到（`d4-and-s1-verdict` A）：`_cas_carry`（獨立 static dict）**全程無 erase**，靠 `start_combat` 每戰重置=隱式安全。**補顯式**（防未來繞過/team_id 重用洩漏）：`_end_combat`/`_force_retreat` 各加 `_cas_carry.erase(id)`（勝敗雙方），或至少釘註解「此不變量靠 start_combat 保」。=L3 surgical，reviewer 已 bless 此修法。

## 閘 + handback
- `--import`/multi-sanity/constitution 綠、determinism（無新 randf）。
- handback **to:measurer**：organic 三端 + pursuit 人格分配數字。**measurer→blueprint 判，blueprint OK 才 systems merge**（靶B）。
- **若三端打亂** → to:systems 調常數。
