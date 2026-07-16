---
from: blueprint
to: systems
status: consumed
topic: 多工unblock package(用戶定)——LG下游平行(等用戶直接授權)+量測員併行+full_probe床(process我授權寫)
---

# 多工 unblock package（用戶定案 2026-07-09）

## 病根（用戶診斷）
mailbox 角色是**單例 owner**：自動撿信 → 同角色信在那一 session **序列排隊**。多開同角色終端 = 撞 owner，不並行。量測員同病：多工單 beds 一件件阻塞 = 塞車。→ **真並行需 LG；但只需下游。**

---

## Part A：LG 下游平行（★design-direction，**等用戶直接授權才動 code**）

**用戶會直接對你說「改 LG 下游」——在那之前 LG code 凍結不動**（authority 課：經藍圖轉述不算授權；本段是設計對齊，非工單）。

設計（用戶+藍圖成形）：
- **上游（blueprint→factcheck→systems→review）留 mailbox**：單例、要人判、串行 OK。**LG 這幾節點不碰。**
- **下游（implement→measure→gate→merge）走 LG `--from-impl`**：平行跑多條已 specced slice = 真並行實作引擎。
- **`rn_qa` 保留自動判**（不搬藍圖 pass）：LG 下游 = **autonomous lane**（你 fire N 條走開）= 正是 QA 硬閘該在的時候。**呼應前 workflow-qa-measurer-change 的 caveat「autonomous→QA 回」——LG 下游就是那個 autonomous lane 的具體化。**
- **`rn_measure` 升 full_probe**（見 Part C）：治 bounce，讓 rn_qa 判在完整數據上。
- scope 小：只動下游 `--from-impl` 進場 + rn_measure；rn_qa 保留；上游不碰。graph.py `n4→n5→n6→n7` + entry-point flag，動 test_graph.py。

**兩 QA 模型定位（不衝突）**：
| 軌 | 模式 | QA |
|---|---|---|
| mailbox / 單 slice（用戶盯） | in-loop | 砍 QA，藍圖 pass |
| LG 下游平行（fire N 走開） | autonomous | rn_qa 硬閘 |

**cost**：$27/slice → 值得時機 = 手上有一批獨立 specced slice 想一次平行。1-2 條 mailbox 串著跑。

---

## Part B：量測員併行（process doc 03b，★藍圖 route 授權寫）

**收工單 → bed 背景 launch（run_in_background）、非同步收、不序列阻塞。** 多工單 → 多背景 bed 併行，誰完先收誰。
- **併發上限**：sim compute-bound、godot 進程搶 CPU → cap ~2-3 條，別 thrash。（HOW 你定。）
- **適用**：mailbox 軌單例量測員（解塞車）。LG 軌併行來自 worker spawn，不靠此。
- 寫進 `03b_measurer.md`。

---

## Part C：量測員標準 full_probe 床（process doc 03b，★藍圖 route 授權寫）

（接前 workflow-qa-measurer-change，此處確認並具體化）
- **acceptance/診斷跑標準 full_probe 床**：全維度一次抓齊（衝突/生存/**決策-option 去向**/結構/食物經濟），結構化 JSON、不靠 print 刮、無 quiet/缺維度死路。
- **∴ 量測員永遠量得出** → 藍圖/rn_qa 判得動 → 不再 bounce/量不了。
- full_probe merge 探針已起頭（PROBE_KEYS + faction_ai bump）→ 續補齊全維度成標準模式。
- 寫進 `03b_measurer.md`（+ rn_measure 節點若 Part A 啟動時同步）。

---

## 授權分工（明確）
- **Part B + C = process doc（03b_measurer.md）→ 藍圖 route 授權，你即可寫。**
- **Part A = LG code → 等用戶直接對你說「改 LG 下游」才動。** 我這封只給設計對齊，非授權。

## 綜合
三件齊 = 多工塞車解：LG 給平行實作、量測員併行不卡、full_probe 不 bounce。B/C 先寫（mailbox 軌即受益：量測員不再塞）；A 待用戶授權（真有一批平行活時解凍）。

用戶說會直接找你談 LG。B/C 你先寫。
