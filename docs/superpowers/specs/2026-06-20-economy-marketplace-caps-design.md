# #1 經濟真活 — 架構 arc HOW design（市集 + 上限 + 糧倉；主角=NPC 決策）

> 來源：藍圖 ruling `2026-06-20-blueprint-to-systems-economy-direction`（選 B 市集 + 硬上限 + 糧倉，腐壞砍）。
> 承 economy-architecture 數據診斷（貿易 2 年 5 次成交，多因結構縫）。
> **主從鐵則（藍圖）**：主角 = NPC 經濟決策（滿→賣/缺→買 去市集）。上限/市集/糧倉皆**僕人**——不改變某 NPC 局部決策 = 死概念，砍。

## 病（數據定位，非 archetype 調參）
1. **決策沒 fire**：商業 archetype 隊全卡在不貿易的角色（faction leader 跑勢力 AI / 獨立隊覓食分數蓋過 / 子團不派 / member 被 SETTLE + faction goal 鏈攔截）。
2. **co-location 幾不可能**：漫遊商隊追「訂單發出時的舊位置」，下單隊早移走 → 撲空。
3. **食物幽靈囤**：`resource_system:213` food 不在 `PUBLIC_RESOURCES` → 走 else **uncapped** 塞 `team.resources` → 4-5萬 無封頂（= 滿信號永不觸發）。

## 架構決定：固定市集會合點 + 硬上限給「滿」信號 + 解角色卡死讓決策 fire

market = **既有 outpost tile**（不造新 tile 類型）。NPC 滿/缺 → 去最近**已知** outpost 市集固定點交易。路上順路交易**保留疊加**（兩隊碰到照換）。

## Workstream 分解（依賴序；每條獨立 plan + 子 session）

### WS-1：食物 route 進 capped 糧倉 + 硬上限（僕人：定居隊「滿」信號 + 囤糧崩）
- `resource_system._collect_from_tile`：food 改走 outpost public_storage capped 路徑（**像礦**），非 else uncapped。無 outpost fallback 進 team（小隊，本就少）。
- 食物**專屬 per-level cap array**（非通用 `[100,300,800]`——L3 800≈50人6天會餓死）：放大到合理糧儲（TEST VALUE）。
- 消耗端 `resolve_consumption` 從糧倉提領吃（既有 withdrawal 流；定居隊 food 在 public_storage）。
- **驗 NPC 決策改變**：囤糧封頂 → surplus 溢出 → `_can_trade`/sell order 觸發「該賣」。囤糧峰值崩。
- 守恆：food route 是私產↔公庫轉移（守恆），cap 溢出留私產（既有礦路徑模式，不蒸發）。

### WS-2：市集節點 + 解角色卡死 + NPC 去市集決策（**主角**，最重要）
- **訂單匯市集**：order pos 改 route 到下單隊最近 outpost 市集 tile（非隨隊移動的舊位置）。
- **解角色卡死**：商業 archetype 隊（含 faction member / 獨立 / 子團）貿易決策不被覓食/faction goal 鏈無條件攔截——貿易意圖達閾時可勝出（複用 `_can_trade`/`_merchant_trade_target`/派工，**非造新系統**）。
- **去固定市集**：merchant target = 最近已知有單市集 outpost（固定會合 → 成交必發生），非追移動隊。
- 路上順路交易保留。
- **驗 NPC 決策改變**：`[Market]成交` 2 年 5 次 → 常態；商業隊真被派貿易（不卡覓食/faction goal）；履約率 >> 0。

### WS-3：移動隊硬 carry cap + 救活馬車（僕人：移動隊「滿」信號 + 馬車）
- `get_carry_capacity` 已存在但超載只**軟速度懲罰** → 改**硬上限**（超額存不下，非只變慢）。
- 馬車/獸 = carry cap 加成 → 「商隊能多搬多少貨去市集」= 馬車終於有正經工作。
- **驗 NPC 決策改變**：移動隊滿 → 觸發去市集賣；馬車增載量對商隊有感。

### WS-4：糧倉設施 + 容量=據點尺寸（僕人：經濟容量戰略化）
- 加「糧倉」facility（farming 線或獨立）：蓋/升 → 拉高食物上限 = 玩家/經濟投資點。
- 效果：據點尺寸=經濟容量 → 大據點囤更多、更值得搶/圍（接 G2 控據點=經濟力）。
- **驗 NPC 決策改變**：糧倉設施改變「能囤多少→何時該賣」+ 玩家投資決策點。

## 建議實作序
1. **WS-2 市集 + 角色卡死（主角）** — 最高槓桿、直接讓貿易 fire、可獨立量測（`[Market]成交` 暴增）。先做主角證明架構通。
2. **WS-1 食物糧倉 route + 硬上限** — 殺幽靈囤 + 給定居隊滿信號（餵 WS-2 的賣決策）。
3. **WS-3 carry cap 硬 + 馬車** — 移動隊滿信號 + 馬車。
4. **WS-4 糧倉設施** — 容量戰略化（最後，enrichment）。

> 序理由：藍圖點名「核心壞在決策沒 fire」= WS-2。先讓貿易動起來（market 解 co-location + 角色卡死解 dispatch），再用上限/糧倉把「滿」信號做乾淨。WS-1 雖殺 bug 但若 WS-2 沒通，囤糧崩了也沒人來買 = 半套（同腐壞教訓）。**WS-2 先證主角，其餘僕人補足。**

## 全域守恆 / 邊界
- 各 WS 守恆：WS-1 food route=私↔公轉移（守恆）；WS-2 純決策/派工/order pos（不碰 resources）；WS-3 carry=移動約束（不碰 resources 數值，只擋採集入帳？見 plan 定）；WS-4 facility=建設既有守恆。
- 全程 coin_eq=0、InvariantAudit 0（回歸閘）。
- world_sim **非確定**（[[reference_multi_sanity_unseeded]]）→ `[Market]成交`/履約率僅趨勢煙霧；機制正確性靠 headless 確定性測（含**確定性 2-隊互補貿易場景**驗 dispatch→市集→settle 整鏈）。
- 全數值 TEST VALUE。

## 驗收（藍圖方向）
- 履約率/`[Market]成交` 大幅 > 0（2 年 5 次 → 常態）。
- 囤糧峰值崩（4-5萬 → 糧倉 cap 封頂）。
- 商業隊真被派貿易（不卡覓食/faction goal）。
- 馬車對商隊載量有感。
- 路上順路交易仍偶發（未被市集滅）。
