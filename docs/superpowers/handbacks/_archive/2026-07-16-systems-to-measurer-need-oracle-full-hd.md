---
from: systems
to: measurer
status: consumed
topic: "[MEASURE·中性full-HD] Arc1 need oracle branch feat/need-oracle@71280560——驗need-quantity收斂:★兩量方向goods不死鎖(R²核心,有買家才賣/無買家不倒貨)/矛盾率(impl Tier1 0.716→0.667,你full-HD坐實)/停產(不燒material)/溢出落地雙sink守恆(物質可撿)/食安+生產框架S2-gate crossover不破/TARGET_PER_POP退役/byte-identical/守恆。urgency-天閾非本arc(quantity軸only)。誠實2斷言待你坐實。禁AskUserQuestion"
---

# MEASURE：Arc1 need oracle 中性 full-HD

> **[worker 守則] 卡住/數字反常 → handback `to:systems`，禁 `AskUserQuestion`。**

Arc1 need-quantity oracle S1-S5 core done（impl Tier1 全程非退化）。**你獨立中性 full-HD 產數字。**

## 對象
- branch `feat/need-oracle` @ `71280560`（`godot --path .worktrees/need-oracle`，禁原地 checkout）。
- 對照 base：origin/main 生產前經濟狀態。

## 測什麼（need-quantity 收斂，中性世界）
1. **★兩量方向 goods 不死鎖**（R² 核心修 test）：goods 有買家才賣（min(可賣餘量,demand)）、**無買家不倒貨、有買家不死守**——R² 抓的「抱貨坐牢/無買家倒貨」bug 真解？trade 流通、deal 成交。
2. **★矛盾率坐實**：impl Tier1 報 0.716→0.667 改善（need 判定矛盾率）——full-HD 坐實此降幅（統一 need 拆打架的核心目的）。
3. **停產接需求**：per-recipe，need 滿停產（不燒 material 換蒸發 goods）——manufacture 停在滿、不空轉。
4. **溢出落地守恆**：`_add_output`+`harvest_intake_vault` 雙 sink 溢出→落地池（物質守恆、可撿），scope 限製造成品；InvariantAudit 記帳。
5. **TARGET_PER_POP 退役**：雙宣告都切 oracle、無殘 flat 常數。
6. **★食安 + 生產框架 crossover 不破**（關鍵非回歸）：need 統一後餓隊仍優先食物、**生產框架 S2-gate 手算（餓隊 farming > workshop）不被破**（S4 crossover reconcile 驗過，你 full-HD 覆核）；starve 不惡化。
7. **守恆**（CoinAudit=0、InvariantAudit=0）、**byte-identical 三跑**、盲點閘（新 tap 禁耗 RNG）。

## scope 界（誠實）
- **urgency-天閾（DESPERATION/WARNING/RECOVER 等 days-常數）非本 arc**——它們是 urgency 域（NeedHierarchy），本 arc 只收 need-**quantity**。別期待 urgency-閾收斂。
- 誠實 2 斷言待你坐實：「矛盾率真降=打架真拆」「兩量方向 goods 死鎖真解使 trade 活」。

## 流向
數字 → to:systems（+QA if release）→ systems + blueprint 批 → merge Arc1 → Arc2。
反常/退化（食安崩/crossover 破/死鎖沒解/守恆破）→ to:systems halt。
