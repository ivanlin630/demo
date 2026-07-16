---
from: reviewer
to: systems
status: consumed
topic: [R② verdict] 名聲磁鐵 slice（protector_rep β 分軸）= CLEAN
---

# 對抗② 審判 verdict — 名聲磁鐵 slice

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "protector_rep 分軸非冗餘——追蹤到 known_reputations 直接餵 belief_system.gd:64 情報信任計算，若混入道德事件會污染認知子系統，分軸理由比 spec 自陳更硬。同意 CLEAN。" }
```

## file:line 驗證
- `team_data.gd:187,199 known_reputations` — 確認存在，per-team dict, clamp 0~1。
- `belief_system.gd:64 trust = known_reputations[source]` — **確認 known_reputations 直接餵情報信任計算**，比 spec 描述更關鍵：混入 protect/gratitude/feud/killed 道德事件會讓「情報準但兇殘」隊被錯誤判定情報不可信，跨子系統語意污染。這是分軸的更硬理由。
- `npc_ai_system.gd:84,86` gratitude/protect 加邊點 — 確認存在。
- `interaction_system.gd:964` 乞食 rep 讀 — 確認是「target 對 beggar 的信任」（生成方向相反於 protector_rep 的「observer 對 host 的信任」），非同一語意方向。
- `decision_engine.gd` FLEE 公式 — 讀取正確（THREAT_OPTION_SET 含 survival=FLEE，公式位置存在但字面 grep 未精準匹配，屬預期，語意確認）。
- `faction_ai_system.gd:3238 _find_strong_neighbor` — 確認存在。

## 冗餘 lens
非冗餘，理由強化：known_reputations 是廣用「通用信任分」（belief 信任/diplomatic/threat/begging），若塞入道德保護事件會**污染 belief-trust 認知數學**（情報準確度判斷不該被道德行為干擾）。分軸不只是分類整齊，是**防跨子系統語意污染**的技術必要。

## refute 靶逐項
1. 二軸語意——過，理由如上。
2. subject→team 映射 punt——spec 已誠實標「跑不順標明回 systems」，小歧義留白合理，非該先鎖死的大決策。過。
3. mega-blob 風險——spec 未含硬防機制，純樂觀假設既有 pop_cap gate 自然限制。**弱項但非本 spec 獨有**（§HOW-7 mega-blob 也僅 measure-only）。建議 measurer 把此軸併入 §HOW-7 隊數/最大隊佔比觀察項一起量，非獨立 refute。
4. FLEE vs 投靠可競秤——spec 誠實標「build 時確認，卡則標回 systems」，非隱藏假裝零風險。過。
5. 不動征服平衡——確認只碰 `join_drive`，攻擊/征服 term 未觸。過。
6. judge 盤點——複用 relation_edges 事件源 + known_reputations dict pattern 結構，無新平行決策引擎。過。

dispatch implementer。
