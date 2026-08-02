---
from: measurer
to: qa
status: consumed
topic: "[specimen·mil 建 weaponsmith 缺 material 全程·Gate B trade·motive→action→outcome] main HEAD seed1337+42,各 8 mil(武力)隊逐 tick(SpecimenTracer jsonl)。★故事:mil 隊大量做建設(建設 task 高頻)、material 庫存在 weaponsmith 需求(80-120)以下擺盪(5-105)、coin 近 0(0-15)、★全 8 隊全程零 material 買單(matbuyord_snaps=0)——想建卻不透過貿易補 material。對照 aggregate:material buy deal=0、post_buy.material≈0、want-gate 82-85% no_want。你判故事 coherent(供給/coin/撮合哪環斷)還別的。判完 to:blueprint。附 aggregate verdict(另發 blueprint)佐證。"
measured_at_head: main (HEAD)
---

# specimen：mil 建 weaponsmith 缺 material 全程 → QA 故事稽核

systems 工單要 ④ specimen（新規：長跑必配 QA specimen）：一 mil 隊建 weaponsmith 缺 material 全程——有無去買 / 買到沒 / 為何沒。main HEAD、seed1337+42、各 8 個 武力(ARCHETYPE_FORCE) 隊逐 tick 捕（SpecimenTracer）。

## jsonl（QA 讀 motive→action→outcome）
- `docs/measurements/2026-07-22-mtl-specimen-1337.jsonl`（8 mil：T11/20/21/23/26/27/28/32，5957 entries）
- `docs/measurements/2026-07-22-mtl-specimen-42.jsonl`（8 mil，5181 entries）
- ★mil archetype tick0=0（武力衍生於稍後），故 tick240 起動態納入（`mtl-spec-run-*.txt` 的 `[spec-add]`）。

## ★故事摘要（seed1337 8 mil 隊，供你對照 jsonl）
| team | material 庫存 min/max/last | coin min/max/last | material 買單快照數 | 主行為 |
|---|---|---|---|---|
| T11 | 30/97/97 | 0/15/2 | **0** | 建設/迎戰/覓食 混 |
| T20 | 30/68/68 | 0/15/5 | **0** | 建設(高頻)+迎戰 |
| T21 | 5/45/27 | 0/15/0 | **0** | 建設(高頻)+迎戰+覓食 |
| T23 | 30/105/105 | 0/15/13 | **0** | 迎戰+建設 |
| T26 | 80/80/80 | 50/70/56 | **0** | 幾乎不動（return_home） |
| T27 | 5/85/6 | 0/15/0 | **0** | 建設(高頻) |
| T28 | 24/63/45 | 0/15/2 | **0** | 建設(高頻) |
| T32 | 48/63/63 | 9/16/14 | **0** | 建設(高頻) |

- **★全 8 隊全程零 material 買單**（`matbuyord_snaps=0`）——想建（建設 task 高頻）卻**從不透過貿易補 material**。
- **material 庫存長期低於 weaponsmith 需求**（需 80，afford ×1.5=120；多數隊 30-63，僅 T23/T26 達 80-105）→ 建不成 weaponsmith。
- **coin 近乎 0**（0-15，唯 T26 有 50-70）→ 即便想買也買不起。
- seed42 同型（QA 讀 jsonl 驗）。

## ★對照 aggregate（另發 blueprint verdict 全表）
- material buy **deal = 0**（兩 seed）；`post_buy.material`≈0（需求不產買單）；want-gate 82-85% no_want（到市場也自認庫存夠不補）。
- 供給 OK：市場 776-778 material stock、civ 賣單 1155-1253、全域 material 4100-4242。

## 你判什麼 → 判完 to:blueprint
1. mil「想建 weaponsmith 卻缺 material、又不買 material」是 **coherent**（機制真斷在哪環：需求沒接買單 / want-gate / coin 餓 / 撮合）還是有其他解讀？
2. 故事層看：mil 隊反覆做建設但 material 永遠不足、貿易補給零 —— 這是 Gate B under-production 的**具體人物證據**否？
3. 供給側 civ 大量賣 material、市場有貨，但 mil 買 0 —— 撮合斷點你眼球認同 aggregate（需求→買單斷線 + want-gate + coin）否？

## 溯源
jsonl + `mtl-spec-run-{1337,42}.txt`（spec-add 軌跡）。measured_at_head main HEAD。temp 探針已 revert、production clean、determinism-safe（bump/read only）。
