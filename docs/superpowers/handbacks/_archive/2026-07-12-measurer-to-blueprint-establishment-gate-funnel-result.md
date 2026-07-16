---
from: measurer
to: blueprint
status: consumed
topic: established=0真根定位——A門主卡gate_fail_pop(82.7%,非A5可達盟友6.6%)+★B門100%卡死於gate_fail_b2_command(統領技能,24311=24311全卡)+B3也89%卡,B4從未觸及
---

# 量測回報：established=0 兩階段 gate funnel 完整定位

工單：`2026-07-12-blueprint-to-measurer-establishment-gate-funnel.md`。既有 probe（`indep.gate_*`）確認**在 code 裡有 bump，但 `WarringHarness` 的 `PROBE_KEYS` 白名單漏收**，既有 run 的 JSON 撈不到——加 6 個 key（L3純白名單擴充）。B 門（`establish.gate_*`）**確實無探針**，補上（同款 `if Probe.enabled` 純觀測插入，原判斷邏輯僅拆成布林變數再 AND，Probe off 時 byte-identical）。2seed×12月 default.json 跑出完整 funnel。

## A門（獨立隊→組faction，2seed彙總）
| | 數量 | 占gate_ambitious比例 |
|---|---|---|
| gate_ambitious（分母） | 35861 | — |
| **gate_fail_pop（A3，人口太小）** | **29667** | **82.7%** ★主卡點 |
| gate_fail_food（A4，7日盈餘） | 2892 | 8.1% |
| gate_fail_nopath（A5，可達盟友，你懷疑候選） | 2369 | 6.6% |
| gate_fail_busy | 197 | 0.5% |
| gate_path_ok（全A過） | 736 | **2.05%** |
| found_ally（真結盟） | 9 | — |
| found_timeout | 4 | — |

**A門主卡是 gate_fail_pop（82.7%），不是你懷疑的 A5 可達盟友（僅6.6%）**——絕大多數獨立隊人口太小，連「有野心去找盟友」的資格都沒有。**這直接呼應先前經濟診斷發現的「月1-3急性危機吃掉~45%人口」**——隊伍還沒長到能立國的population，就已經在早期糧荒裡被砍到太小。

## B門（faction→established，2seed彙總）——★決定性斷點
| | 數量 | 占b1_ok比例 |
|---|---|---|
| gate_b1_ok（≥2成員） | 24311 | — |
| gate_fail_b1_members（<2成員） | 13254 | （占gate_ambitious口徑另算，35%量級） |
| **gate_fail_b2_command（統領技能不足）** | **24311** | **100.0%** ★★完全卡死 |
| gate_fail_b3_ambition（野心不足） | 21678 | 89.2% |
| gate_fail_b4_readiness | **0** | 從未觸及（B2先攔光） |
| gate_all_pass | **0** | 確認全程恆0 |

**`gate_fail_b2_command` 的數值與 `gate_b1_ok` 完全相等（24311=24311）——每一次「faction 有≥2成員」的評估，領袖統領技能一次都沒過關。這不是機率性瓶頸，是 100% 結構性硬牆。** B3（野心）也高達89.2%卡關（但因B2已全擋，B3的計數是在同一次評估裡並行記錄，非後續漏斗）。B4（readiness）因為前面已經全滅，從未真正被測試到——**readiness 門檻本身可能完全沒問題，只是輪不到它顯現**。

## 判讀（我只給數字，不代開藥）
1. **A門**：真根是人口太小（呼應經濟長程危機），非可達盟友稀缺——若要修A門，方向該對「怎麼讓隊伍活到夠大」，不是「怎麼讓盟友更好找」。
2. **B門是更硬的牆**：即使 A 門全過（真結盟成功、faction 有≥2成員），**領袖統領技能門檻(`ESTABLISH_COMMAND`)實質上從未被任何 leader 達到過**。這可能是：(a) 門檻設得脫離現實（leader 技能成長速度追不上），或 (b) 統領技能的成長機制本身有問題（練不起來）。**這是比 A 門更決定性的斷點——即使解決了 A 門的人口問題，established 依然會卡死在 B2。**
3. **修法優先序建議**（供你判斷，非代裁）：B2（統領門檻/成長機制）看起來是比 A 門更根本的硬牆，值得優先查——因為 A 門就算全通過，B2 依然 100% 擋死。

## 產物
- json：`tools/orchestrator/runs/establishment_funnel.json`
- 床改動：`scripts/debug/warring_harness.gd`（PROBE_KEYS加A門6key+B門6key）、`scripts/simulation/faction_ai_system.gd`（B門gate拆解+Probe.bump，L3純觀測，Probe off時byte-identical）
