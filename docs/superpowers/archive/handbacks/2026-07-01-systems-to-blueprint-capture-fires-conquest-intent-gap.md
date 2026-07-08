---
from: systems
to: blueprint
status: consumed
topic: 失能-capture merged 量證 — P1 captive 從 dormant→fire(capture5/assimilate2,(a)機制活);但 CONQUER 意圖仍0、established 仍1=蓄意征服未湧現(下游);求向
---

# 失能-capture merged：(a) 機制活了，但征服意圖仍 0（measured）

失能-capture（潰逃勝方俘 wounded→captive）merged，守恆綠。warring 2yr 重跑量證——**(a) 吸收機制從活世界 dormant 變 fire**，但揭下游 gap。

## MEASURED（vs baseline）
| 指標 | baseline | 失能-capture 後 |
|---|---|---|
| `[Capture]`（潰逃俘）| 0 | **5** ✓ fire |
| `p1.assimilate`（同化=pop 累積）| 0 | **2** ✓ fire |
| `p1.flee` | 0 | 3 |
| Combat Start / Exhaust | 13/4 | 33/21 |
| feud / vendetta | 0/0 | 98/4 |
| **CONQUER 意圖** | 0 | **0**（仍）|
| established | 1 | 1 |

## 進展（真的活了）
- **P1 captive 系統從 100% dormant → fire**：[Capture] 5×、**同化 2×**。「決勝在潰逃非對撞」work——潰逃丟下 wounded → 控地勝方俘 → 同化 → **pop 累積從戰鬥真發生**。守恆綠（coin_eq 0、InvariantViolation 0）。
- = (a)-征服鏈的**吸收機制這環活了**（你 spec §3b 對）。

## ⚠ 但揭下游 gap：蓄意征服未湧現
- **CONQUER 意圖仍 0、established 仍 1**：commander 仍**不選征服 intent**（commander-v2 _select_intent 的征服 gate=established + viable 弱敵 + 好戰 leader，仍少滿足）。
- captures 是**機會性**（combat 潰逃留下的 wounded）**非蓄意征服 campaign**。volume 低（2 同化/2yr）。
- = 「征服 pay → means-end 選征服 → 征服者湧現」的**後半（蓄意選征服）還沒通**。卡兩處下游：①established 稀（前面攀爬「立國」段，T32 卡 rung2→3 那條，獨立另案）②征服 viability gate（需強 leader + 可打贏弱敵）。

## 判讀（誠實，不粉飾）
- **吸收機制（你要修的上游）= 活了** ✓。combat 現在會俘虜+同化，pop 從戰鬥累積。
- **但蓄意征服者湧現 volume 低**——因為 commanders 還沒「決定去征服」（CONQUER intent 0）。這接 **rung2→3（攀爬第二段，立國→稱霸轉換）** + 征服 viability，你已列獨立另案。
- 兩讀：**(讀 a) 機制活=keystone 達成**（捕俘/同化 fire，pop 從戰鬥累積，(a) 上游通）；**(讀 b) 蓄意征服者湧現**還要 rung2→3 + viability（下游另案）。

## 待你
①失能-capture 這環**驗收通過**？（機制 dormant→fire，capture/同化 真發生、守恆）②「蓄意征服者湧現」（CONQUER intent>0）= 接 **rung2→3（攀爬第二段）** 你裁要不要現在排（那是 T32 卡的「擴張→立國」轉換，measure 已標獨立另案）？還是先平行 G3/讀 B、征服湧現靠長期 emergent？
- 存儲統一（prisoner_population→captive）= 子 session 卡 seed 沒做（Phase 2，不阻塞）。

P1+失能-capture 機制備齊。(a) 攀爬累積（食物統一讀A + 捕俘同化）兩源都活了；蓄意征服頂端（rung2→3）待你排。
