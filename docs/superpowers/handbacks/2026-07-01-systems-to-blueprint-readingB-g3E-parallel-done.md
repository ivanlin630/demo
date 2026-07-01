---
from: systems
to: blueprint
status: consumed
topic: 轉平行兩軌 merged(讀B 覓食苟活地板 + G3 Phase E enforce) + team-ref 根因修;但兩沙盒維度 emergence 皆「機制到位/活世界戲未顯」;讀B 真閘=granary 自填非覓食(另 slice)
---

# 轉平行兩軌收官 + team-ref 根因修

回 `a-milestone-go-parallel`（轉平行推讀B/G3 Phase E）。兩軌平行子 session 實作、我收 handback + 驗證 + merge。**全 merged、合體綠**（headless 1 FAIL=pre-existing baseline、0 SCRIPT ERROR、coin_eq 0、InvariantAudit 全 OK、warring 24 月 DONE）。

## ① 讀 B 覓食=苟活地板 ✅ merged（機制✓ / 「繁榮須交易」emergence ✗）
- **做**：覓食來源食物 net-bank cap 到 subsistence buffer（`hunt_system` source-gate，達 buffer→不獵不耗 wild_game，守恆乾淨）。只封 team private food 非 granary → 地形 regen/決策權重不動。3 測綠。
- **★但真閘不在覓食**（measure 出，誠實）：覓食 cap 正確封住覓食路徑，但 **定居隊 granary 自填**（forest regen 3 也把 granary 填到 ~cap）→ 成長由 granary 驅動非交易 → **trade loop 仍不 fire**。「繁榮須交易」emergence **未到**（覓食封了、granary 旁路未封）。
- **待你裁**：granary 自填屬 **granary/harvest 域**（食物統一 arc 下一 slice），需 measure「forest regen 3 為何 granary 也填滿」（harvest 產出/storage cap/tile 食物池 init）→ 定居隊 granary 亦須特化受限才逼交易。**要不要開這 slice**？覓食 cap 是必要地板層（已鋪，granary 修好後覓食不能 backfill 成長），但單靠它不足以讓交易網轉。

## ② G3 Phase E enforce ✅ merged（機制✓ / 「自信地錯」emergence 需 Phase D 才量得到）
- **做**：5 god-view leak 補 `best_estimate`（求貢/收貢/強鄰/施援/背叛 ally 實力，無情報→保守 fallback 非偷讀真值）+ 背叛去純 RNG（driver=人格+belief「盟弱我利」，取代 `randf()<0.1`）。同 faction 協調/tally/位置=刻意豁免（納 invariants）。5 測綠、warring g3.betrayal=21 合理。
- **★誠實**：enforce 到位（決策真跟 belief 走、欺敵可有後果的地基就位），但**「自信地錯」emergence 需 Phase D（植假 primitive）+ 專屬 probe 才量得到**（短窗 seed 量不到「按假 belief 行動被咬」）。本 phase 只證「決策跟 belief 走」。
- **接續**：Phase E 是 Phase D（欺敵/離間/假和 = 你的玩家錨 C 心臟、anchored-pre-player 承諾 arc）的前提，已備好。**要不要接推 Phase D**？

## ③ team-ref 根因修（非計畫內、foraging 掀出的 pre-existing bug）✅ merged
- foraging warring seed RNG-shift 掀出 **pre-existing 結構 bug**：`create_faction` 直寫 faction_id 沒退舊 faction 成員籍 → 獨立戰略層 rung2→3 建國時舊 faction `member_team_ids` 懸空 → `require_team` crash flood（17850 次）。
- 修=create_faction 走 bidir-safe `set_team_faction`（單源非補丁）。warring seed 1337 驗 **17850→0**。**子 session 正確沒打 null-guard 補丁（team-ref=系統 domain）呈報我裁**——review 紀律生效。

## ★ 沙盒 bar 現況（兩維度都「機制底✓ / 活世界戲✗」）
與 (a) 同型：**機制到位但活世界大規模 emergence 未顯**。
- 經濟維度：覓食封了但 granary 旁路 → 交易網未轉。
- 資訊維度：enforce 到位但欺敵後果（自信地錯）需 Phase D。
- **不打勾自欺**。兩維度各差「最後一哩」（經濟=granary slice、資訊=Phase D）。

## 待藍圖排序（下一步候選）
1. **granary 自填 slice**（讀B 真閘、逼交易網轉）— 經濟維度收尾。
2. **G3 Phase D 植假**（欺敵/離間/假和，玩家錨 C）— 資訊維度收尾 + 玩家面地基。
3. consolidation（founded 守不住）+ emergence 平衡 = 你先前標「經濟穩後 revisit」；granary slice 後經濟才算穩。

兩軌機制底鋪好，但沙盒「活世界戲」兩維度都差最後一哩。你排哪個先？
