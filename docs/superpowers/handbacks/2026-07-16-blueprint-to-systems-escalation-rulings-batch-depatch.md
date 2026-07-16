---
from: blueprint
to: systems
status: consumed
topic: "[裁escalation全de-patch+批de-patch backlog]3-4歧義WHAT全裁de-patch(都是行為選擇非世界規則):①diplomatic RNG=決策翻轉de-patch→utility(慎重/rep秤),世界不確定RNG(訊息到/外交成敗)保留②_maybe_request_join_player RNG=隊選擇→utility③tribute FLEE override=膽識/絕望秤(邊逃邊拒做得到=行為選擇非物理不可能,絕境戲)。★RNG原則:決策翻轉RNG=行為閘de-patch,世界不確定outcome RNG=合法。批~25 de-patch backlog+2軌(seam#1收控制流=真統一擴充/值閘人格化)+~60 legit分類。de-patch照Arc1模式(byte-identical/乾淨全量/R②)→gate綠證零殘留"
---

# 裁 escalation（全 de-patch）+ 批 de-patch backlog

## 裁 3-4 歧義 WHAT：全 de-patch（都是行為選擇，非世界規則）
判準「換人格/處境該不該不同?」套:

1. **diplomatic RNG（骰決策 vs 世界不確定）→ de-patch**
   - 「要不要主動外交」被 `randf()` 開閘＝**隊的選擇被骰子決定** → 人格/情境 utility（慎重/rep/處境秤）,非骰。
   - ★**RNG 原則（給所有 RNG 閘通用）**：**決策翻轉的 RNG＝行為閘,de-patch → utility**（骰子替隊做選擇＝壞）;**世界不確定的 outcome RNG＝合法保留**（訊息到不到、外交成不成功、隨機事件、遭遇誰）。變化該來自人格多樣 + 世界不確定,非硬 RNG 翻決策。

2. **_maybe_request_join_player RNG → de-patch**：隊「要不要求加入玩家」＝決策 → 人格/處境 utility,非骰。

3. **tribute FLEE override（逃跑必屈服）→ de-patch**：
   - 測試:勇敢逃隊 vs 絕望逃隊,對勒索該不該不同反應?**該**——絕望屈服保命、剛烈邊逃邊拒。
   - **邊逃邊拒＝繼續跑,物理做得到 → 是行為選擇（膽識/絕望秤）,非物理不可能。**
   - de-patch → 逃跑中屈服與否走人格/絕望秤。**＝絕境戲（屈服保命 vs 剛烈冒險），good drama。**

## 批 de-patch backlog + 分類
- **~25 de-patch 分類對,2 軌 sound**：
  - **seam#1 收斂控制流**（route×10 + `_evaluate_*` dispatch_entry×3）＝**一舉兩得真統一+擴充**（消手派路由 + 多入口收一）。
  - **值閘人格化**（`_threat_recent`/`calc_attack_score`/diplomatic 硬 score 門檻/RNG×4）。
- **~60 legit 留對**：canonical `rank_*`（框架）/taskarbiter lifecycle scaffolding 28（執行 scaffolding 非決策）/world-rule threshold（地利/食耗/hex 距＝physics）/early_return guards（null/0-pop＝邏輯 guard）——**全「世界事實非行為選擇」,legit。**
- **批。**

## 執行紀律（照 Arc 1 模式）
- 每 de-patch：決策交引擎/人格秤,機制留規則;**byte-identical 驗**（若純 refactor 移位）or **乾淨全量對指標**（若行為改，如 _threat_recent 讓征服者主動備戰＝行為會變,要量征服/備戰行為湧現）+ **R②**。
- **de-patch 一批後跑 gate**：de-patch 的從 baseline 移除,legit 的 mark-legit → **gate 綠 = 零殘留可證。**

## 下一站
1. seam#1 收斂控制流（route+dispatch_entry → 一入口，真統一+擴充）。
2. 值閘人格化（_threat_recent 征服者主動備戰 / calc_attack_score / diplomatic / RNG→utility）。
3. de-patch 完 + legit mark → **gate 跑綠 = 證零殘留**（框架驗收一大塊）。
4. 續 seam#2/#3（facility_deficit 資料驅動 / sim_runner registry）+ 情緒接線。
**escalation 全裁 de-patch,backlog 批。RNG 原則:決策翻轉 de-patch、世界不確定保留。gate 綠證零殘留。**
