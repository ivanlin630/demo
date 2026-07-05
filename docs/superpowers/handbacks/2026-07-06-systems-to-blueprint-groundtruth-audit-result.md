---
from: systems
to: blueprint
status: consumed
topic: 感知腳接線清單交回(唯讀audit完,先盤不修)——❌真值違規4類(threat pop fallback/nearest_independent讀faction真值/trade裸鍵瞎/戰力欄無寫端硬編0.3)+⚠系統性位置god-view(team_discovered累積,正解模式已存沒接);belief遠vision只pop_est;工量sizing S/M/L交你排脊椎
---

# 決策讀別隊真值 audit — 感知腳接線清單交回

用戶令的唯讀 audit 完成，清單在 `specs/2026-07-06-groundtruth-perception-audit.md`。**先盤不修。**

## 違規總結
- **❌ 真值違規 4 類（多快修）**：①threat belief-miss fallback 掉 `other.population` 真值 ②`_nearest_independent`/`_has_independent` 讀任意隊 faction_id 真值（獨立否=隱藏 affil）③trade finder 查裸鍵恆 miss=貿易估價瞎 ④**戰力欄整欄無寫端**——threat 硬編敵戰力=`pop_est×0.3`，敵方 combat 技能全隱形。
- **⚠ 系統性（最大單點）位置 god-view**：`team_discovered` 累積曾見（無 erase）→ ctx/options 讀 live `tile_pos`=脫視隊位置全知。正解模式（best_estimate last-known）code 內已存但沒接（~18 散落點）。
- **✅ 模範已存**：`find_prosperity_prey` 全 belief（明文禁讀真值 faction_id）——接線有現成樣板照抄。

## belief 深度
遠 vision 只 `pop_est`+`tile_pos`；armed/food/faction/資源**僅近身交手(tier2)可知**=**設計特徵（遠看不清=感知鐵律的迷霧，好戲）**非 bug。決策 fallback 品質（缺 armed→pop_est 代）可調。**情報捏造維度**（你 roadmap）落在此層。

## 工量 sizing（供你排脊椎）
- **快修 S**：trade 鍵、threat fallback、faction_id 早濾 → arc 尾順手可清。
- **系統性 M**：位置 god-view（~18 點改 best_estimate，模式已存）。
- **新欄 M**：combat/power_est belief 欄（寫端+threat 讀，牽誘殺 S4 假情報語意）。
- **belief 深度 L（roadmap）**：遠 vision 缺欄=感知迷霧設計，情報捏造維度在此。

## 待你排（決策模型接線脊椎）
記憶腳（只寫不讀）+ 感知腳（本 audit：讀真值 + belief 缺欄）+ 情緒腳（序7 team_panic 起步）= **同一條脊椎**。你排：(a) 快修 bundle arc 尾（憲法溶入完順手）(b) 系統性/新欄=脊椎正題另軌（何時開）？我建議快修 arc 尾清（低險高潔癖收益）、脊椎正題(位置god-view+戰力欄+記憶腳)另開「決策模型接線」軌（arc 溶完後，大工）。

不擋序7/序8。你排我照做。
