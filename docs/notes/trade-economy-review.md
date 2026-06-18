# 貿易/經濟模型體檢 — 討論註記（DRAFT）

> 2026-06-15 討論捕捉。**非 spec、未定案**，供日後深入 brainstorm 的基底。
> 觸發：02.png 玩測（交易 GUI ×0 幽靈列）→ 延伸到整個貿易/估值模型討論。

---

## 現有兩套貿易模型（分叉）

| | NPC-NPC (`interaction_system._resolve_market`) | 玩家 (`player_trade_system`) |
|---|---|---|
| 結算 | 雙向 coin-only，碰面被動觸發、一站一次 | offer 模型 `{player_gives, player_wants}`，可 spam |
| 留底 | 全物到 target（`_calc_reserve`） | 只 food+武器（`_sellable_qty`） |
| 停止 | `ask<bid` 均衡自停 | `ratio≥threshold`（灌 coin 可破） |
| 以物易物 | 不支援（每腿需買方 coin） | 原生支援（offer 任意貨） |
| 意圖 | 只商隊主動（`_find_trade_target` 找最大價差）；一般團被動 | 玩家手動 |

## 估值公式（兩處 copy，會漂移）

```
target   = pop × TARGET_PER_POP[res]
shortage = (target − stock) / target
if res in SURVIVAL_GOODS and shortage > 0.5:    # 只 interaction_system 有
    shortage = 1.0 + (shortage − 0.5) × 6.0
sr       = clamp(shortage, −0.5, 上限)          # 生存品 4.0 / 其他 1.0
單價     = BASE_PRICE[res] × (1 + sr)
```
- 波動帶：一般 0.5×–2× base、生存品 0.5×–5×、coin 恆 1.0
- **單筆 = 當前 stock 快照單價 × 數量（線性，量不彎曲單價）**；邊際只在批間更新

---

## 發現的問題（淺→深）

1. ✅ **已修（2026-06-19）**：reserve 收進 `TradeValuation.reserve()` 單一源,玩家路徑全資源留底 → 不可刷光。~~玩家路徑可刷光 NPC~~：`_sellable_qty` 只留 food+武器，其餘（material/ore/gem/tools/armor）無留底 → 用 coin 可掃到 0，價只封頂 2×。付 coin 側無自限（coin 永遠 face value 1.0、`MAX_COIN_PER_TRADE` 註解 uncapped）。NPC 路徑因全物留底+均衡+一次性，無此問題。

2. ✅ **已修（2026-06-19）**：`_resolve_market` 加 `_attempt_barter` pass,缺幣團互補 surplus 等值互換（coin_eq 中性）。~~NPC 無以物易物~~：`_attempt_trade_direction` `if buyer_coin<=0: return`，每腿 coin 結算。缺幣團之間即使 surplus 完美互補也換不了 → 破對稱性（玩家能 barter、NPC 不能）+ 疑為 W2 trade 量低根因之一（缺幣不能換）。

3. ✅ **已修（2026-06-19，TradeValuation 單一源）**：抽 `TradeValuation`（canonical 表取 interaction + 合併公式 survival 不對稱+coin guard），interaction/player_trade/DTO 三處 delegate → 天平==接受同源、BASE_PRICE/TARGET 雙副本 drift 消。coin_eq=0。~~兩份 `_local_value` 漂移 + DTO 內部不一致~~：
   - `player_trade_system._local_value` 無生存品非對稱（food cap 2×）；`interaction_system` 有（food 5×）。檔案註解明寫要 sync，實際沒。
   - DTO 天平 `give/want_value` 用 `interaction.local_value`（5×），`npc_would_accept` 呼 `evaluate_offer`→`player_trade._local_value`（2×）→ **食物/醫療交易,顯示天平與實際接受用不同公式** → 「單一真相」承諾對 survival goods 已破。

4. **商隊套利視野窄**：`_find_trade_target` 只對 food/material 用 intel 估對方真實 stock，其他資源 `their_val_est = my_val`→gap=0 → 武器/礦/寶石價差看不到 → 商隊只跑民生品。

5. **靜態 target 需求 → 經濟飽和（疑最深根）**：需求是「填到 target 就停」（value 跌 0.5× 地板），非 X4 式「工廠持續消耗→永久買需求」。各隊補滿後沒人想要更多 → trade 需求歸零。可能比 coin/latch 更底層的 W2 trade 量低主因。

6. **其他**：
   - coin 集中/通縮（總量固定，商隊囤利潤→生產者缺幣→貿易凍結，無 coin 回收）
   - 估值無供給彈性（能產 food 的隊 vs 不能產的同 stock 估值一樣）
   - 武器留底 edge bug：`armed_anon_ratio=0` → 留底 0 → 整批武器可賣光
   - 窄價帶（一般物資 0.5×–2×，4 倍跨度）→ 套利薄 → 商人經濟弱

---

## 提案：buy/sell offer 靠訊息傳播（待深入）

**核心**：teams 發布 buy/sell offer 為訊息 → 經現有 message system 傳播 → 商隊（+玩家）按新鮮度/可信度判斷 → 跑商。

**現有基建幾乎全支援**（`message_system`/`MessageData`）：
- 傳播：`propagate_on_arrival` + `params` 任意 payload
- 新鮮度：`origin_tick` + `_time_decay_factor`
- 可信度：`confidence`（每 hop ×(1−HOP_DECAY)）+ `is_distorted` + `strength`
- TTL：`prune_old_messages`；失真：`_distort_content`

**形狀**：
- 發布：surplus>reserve→sell offer、stock<target→buy offer，閾值跨越時發。payload `{res, side, qty, price, origin_tick, pos}`，strength=急迫度。
- 商隊消費：`預期利潤 × 新鮮度 × confidence / (eta + 風險)` 評分 → 跑最高分。取代 `_find_trade_target`（解問題 4 盲區）。
- 對稱性：玩家看同批 offer（UI 行情/傳聞板）→ 同資訊跑商。

**樞紐決策（未定）**：offer = **線索** 還是 **合約**？
- 線索（傾向）：到場用實際 `_local_value` 重新定價；途中價變/被買走→撲空=自然風險（激情時刻）；失真 offer→追假行情。新鮮度/可信度才有意義。
- 合約：到場保證 offer 價 → 簡單但假、可鑽。

**解/不解**：
- 解：商隊盲區(4)、資訊路由、emergent 風險、對稱性、realism
- 不解但自我調節：需求飽和(5)——offer 在失衡湧現/平衡消失=需求訊號
- 正交：coin 流動性(6)、barter(2)——但 **barter 可併**：buy offer 指定「付 Y 貨」→ 順勢解 2

**範圍**：中大型。v1 收緊：buy/sell offer 訊息 + 新鮮度/confidence 評分 + 線索模型，復用全部現有。失真陷阱、barter-offer 列 v2。

---

## 重構方向（若整治）

- **單一 `_local_value` + 單一 BASE_PRICE/TARGET_PER_POP**（消問題 3 漂移、去重複 copy）
- 玩家路徑套 NPC 的 `_calc_reserve`（全物留底）+ 可選均衡（消問題 1 刷光）
- NPC 加 barter 退路（消問題 2）
- offer-board（消問題 4，部分 5）
- 後續再議：邊際/積分定價、coin 流動性/通貨、供給彈性、需求 flow 化

## 狀態
**全部未定案。** 下次深入：先定樞紐（offer 線索/合約）+ 範圍，再 brainstorm→spec。優先序：對稱性破口(1,2,3) 偏 bug 性質可先修；offer-board(4,5) 是新功能要 spec。
