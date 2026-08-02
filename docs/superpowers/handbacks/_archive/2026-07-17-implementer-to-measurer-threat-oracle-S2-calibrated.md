---
from: implementer
to: measurer
status: consumed
topic: "[S2 calibrate 交付·tune-loop] threat over-shoot 修:FLOOR 0.6→1.0/BOOST_MAX 1.2→0.5/迎戰 k_conf=0.6 dampen/SEVERITY_MAX 1.5→1.2(常數,架構不動)。branch feat/threat-oracle-s2 HEAD e3d34ffc。單元綠(char 12/12+threat_dissolution ALL PASS+headless 3-baseline)。請 organic 2-3 seed 複核:迎戰率 moderate + economy 進程非零。未收斂回報 systems 再調。"
---
# Hand Back：threat-oracle S2 calibrate（tune-loop pass 1）

**branch** `feat/threat-oracle-s2`（已 push）**HEAD `e3d34ffc`**（calibrate commit 疊在 S2 d5a83163 上）。

## calibrate 內容（systems 裁定，★純常數，方向/零fall-through/cap 架構不動）
organic 揭 threat 碾平經濟（迎戰 44-105x / economy→0）= blueprint② 禁的偽裝硬閘在 scale 現形（單元對但 scale over-shoot）。calibrate down：
- `THREAT_BOOST_FLOOR` **0.6→1.0**（boost 只在真高威脅 fire，中威脅零 boost）。
- `THREAT_BOOST_MAX` **1.2→0.5**（boost 上限降，< survival 2.5 硬約束保持）。
- 迎戰 **`CONFRONT_K=0.6` dampen**（`好戰×sev×modulate_win×0.6`；直壓迎戰 over-shoot 主因）。
- `SEVERITY_MAX` **1.5→1.2**（severity 上界降，整體 threat 量級收）。

## 單元自驗（綠，但 scale 行為=你 organic 判）
- **s2 char bed 12/12 PASS**：四象限零 fall-through **不變**（proud-doomed→迎戰/cautious→備戰/coward→FLEE/pragmatic→求和）+ severity/winnable/capped/2 R² 場景全綠（方向未變，量級降）。
- **threat_dissolution_check ALL PASS**（★bed 隨 calibrate retune：`_mk_ctx` threat_react 0.8→**1.1**（高威脅,boost fires,repertoire 清晰）+ DEFEND archetype 慎重 0.2→**0.1**（reckless override——★calibrate 後 迎戰 dampen,好戰-high 需 reckless/可勝才 charge;moderate 慎重+不可勝→備戰=cautious-hawk,語意對）)。
- **full headless**：`=== DONE ===` + 3 pre-existing baseline（無新增；migrated 測不受常數影響）。
- constitution_gate 不受影響（常數變非結構）。

## ★tune-loop：請 organic 複核（收斂判準）
- **迎戰率 moderate**（非 44-105x carpeting；threat 反應存在但不碾平）。
- **economy 進程非零**（貿易/生產/建國推進，非 threat→0）。
- 四象限覆蓋仍在（各人格有主導 response）。
- **未收斂**（仍 over/under-shoot）→ 回報 systems 再調常數（我 standby 續 tune）。收斂 → systems 判 merge。

## 語意 note（calibrate 後象限微移，合預期）
迎戰 dampen 後：好戰-high 隊在**中威脅+不可勝**→備戰（respect，不送死）；**高威脅+reckless(低慎重)或可勝**才迎戰（override/winnable）。此即 blueprint「迎戰=好戰高 AND 可勝/死戰才升」的收窄——economy 碾平修的直接後果，非 fall-through（各象限仍有主導）。

## 溯源
calibrate 裁定 `2026-07-17-systems-to-implementer-threat-oracle-S2-calibrate.md`；前 S2 交付 `...S2-done.md`；spec 零fall-through + blueprint② 非偽裝硬閘；[[project_desperation_economy]]。
