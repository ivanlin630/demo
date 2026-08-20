# F2 treasury 域模組切 HOW（systems、②結構首刀、byte-identical 純程序）

status: DRAFT（spec 自檢 → R² 結構審）
owner: systems（HOW）← 兩硬綠 program §2.3、grounding 結構線 (B)
date: 2026-08-07
★純結構搬移（②）：**只搬位置、零行為變**。§2.2 硬規：F0 fp 三跑一致 + 多 seed regression 不變（byte-identical、對 ce201650 baseline）；任何 fp 漂=夾帶行為變=停查非 merge。禁夾人格化（①track、分 slice 不混）。此為結構 track 第一刀、示範乾淨切法。

## §1 選 treasury/coin 域（spec 自檢:最乾淨 cohesive 域）
faction_ai 大雜燴無完美乾淨 chunk。treasury/coin 域=cohesive resource-lifecycle、邊界清（自檢實查）：
- **域函式**（faction_ai 內）：`_extract_treasury`(3175)/`_extract_buffer`(3222)/`_consider_extraction`(3226)/`_collect_member_tax`/`coin_need`（+ treasury-only helper）。
- **cross-boundary 入口（少、清晰）**：
  - `_consider_extraction`←faction_ai loop（cadence）
  - `_collect_member_tax`←faction_ai loop:836（cadence）
  - `_extract_treasury`←player_command:248（玩家）+ resource_system:177（飢餓緊急）
- **shared 用（留原處/既有模組）**：`ResourceBank.adjust_person_coin`（已模組化）、granary/extinction helper（非 treasury 域、留 faction_ai、treasury 經介面呼）。
- `coin_need` 零外部 caller=域內純移。

## §2 切法（byte-identical 純 code-move）
新 `CoinTreasury` static module（`scripts/simulation/coin_treasury.gd`）：
1. 域函式**逐字移**（verbatim、零 logic 改）到 CoinTreasury。內部互呼（extract↔buffer↔consider↔tax↔coin_need）內化=模組內。
2. **介面**（3 entry）：`CoinTreasury.consider_extraction(state, team)` / `.collect_member_tax(state, team)` / `.extract_treasury(state, team, ratio, reason)`。
3. **caller 更新**：faction_ai loop（consider/tax cadence 呼改 CoinTreasury.）+ player_command:248 + resource_system:177（`FactionAISystem.new()._extract_treasury`→`CoinTreasury.extract_treasury`）。
4. **shared helper**：treasury 若呼 faction_ai 的 granary/extinction helper→經 static 呼（`FactionAISystem.xxx`）或傳入；**不移 shared**（域外）。★R² 核:有無 treasury→faction_ai 反向耦合殘留（若多=邊界不淨、re-scope）。

## §3 守 / 驗（★byte-identical 命門）
- ★**純 code-move、零 logic 改**（逐字搬、只改函式位置+caller 路徑）。
- ★**F0 fp byte-identical**：跑 `state_fingerprint_bed` 對 **ce201650 baseline**、**27 fingerprint 全同**（三跑一致+多 seed 不變）=證只搬位置零行為變。**任一 fp 漂=夾帶行為變=停查非 merge**。
- determinism 3-run byte-identical + constitution 綠（純移無新閘；taskarbiter site 若隨移=同函式同語意、baseline 路徑更新非新增）+ headless 0-new + 既有 arc 回歸綠。
- ★**禁夾人格化/邏輯改**（那是①track、分 slice 不混）。

## §4 序
spec 自檢（本檔）→ R²（結構審：邊界乾淨否/介面/反向耦合/無行為變）→ build（fp byte-identical 驗）→ QA → merge = F2 收（結構 track 第一刀示範）→ F3+ 剩模組逐切。地基 KEEP。

---
## ★§2.3 訂正（R² CLEAN+必查項:caller 清單補 debug/test、2026-08-07）
R² 親讀確認**零反向耦合**（5 域函式全呼已模組化外部 AnonTreasuryBank/ResourceBank/LoyaltyBank/UnrestBank/TradeValuation/NeedOracle/ResourceSystem/DecisionTerms、比 spec 保留疑慮還乾淨）+ 純 code-move 零邏輯改。但★我 caller 清單**漏 debug/test**（GDScript `_prefix` 非強制 private、test 直呼、函式移走全 Invalid-call）：

**完整 caller 清單（exhaustive grep、全改呼 `CoinTreasury.xxx`）**：
- **production 外部**：`player_command_system.gd:248`（extract）/`resource_system.gd:177`（extract）/`faction_ai_system.gd:835`（consider loop）/`:836`（tax loop）。
- **faction_ai internal**（3233/3236/3237）：隨函式移入 CoinTreasury=模組內、不算外部 caller。
- **★debug/test（漏補、必改）**：`extraction_need_driven_test.gd`（:54/55/65/66/75/76/85/86/94/98/105/106 全篇 extract/buffer/consider/coin_need）/`material_hold_test.gd:97`（coin_need）`:107`（consider）/`unified_commerce_test.gd:224,260`（tax）/**★`headless_test.gd:8521`（extract=CLAUDE.md 交付標準 headless entrypoint 本體、非 player_command 那條已涵蓋路徑、不補會當場炸 deliverable 測試）**。

★**通則（全結構 slice 適用）**：模組切 caller-enumeration 必 **exhaustive grep 含 debug/test**（`_prefix` 非 private、test 直呼移走即炸）——同 F1 incomplete-enumeration 家族、R² 接住。
