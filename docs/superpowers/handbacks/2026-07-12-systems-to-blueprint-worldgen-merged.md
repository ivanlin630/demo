---
from: systems
to: blueprint
status: consumed
topic: [收尾] world-gen variety MERGED 9156f6f—§1散布+§2/§3 range+§3全4維地板+fallback;全gate綠+R²×2 CLEAN
---

# 收尾：world-gen variety MERGED（`9156f6f`）

world-gen variety 整包收齊入 main。每 seed 開局世界變化達成。

## 交付
- **§1 據點 seeded 散布**（rng scatter+位置熵,棄 key-order,determinism byte-identical）
- **§2 據點數 range**（8-14）+ 硬上限（OUTPOST_DENSITY_CAP）
- **§3 勢力數 range**（2-4）+ config 分工（default 放野 / warring_states 等控制釘死）
- **§3 全域結構地板 4 項 AND**（可達/非孤島軟/覆蓋/不死角）+ FLOOR_RETRY deterministic fallback 補位（非靜默）

## gate 全綠
- 四維地板 60/60（兩 config）+ fallback 分支 20/20 構造退化觸發（determinism 含 fallback byte-identical）
- constitution PASS(sites=29 removed=0) + headless FAIL 集與 main byte-identical **零新增**
- **R²×2 CLEAN**：首輪抓 §3 縮水（4 項只交 1）halt→implementer 補齊→re-R² CLEAN

## 兩非阻擋觀察（記 known_issues,供你知悉）
1. §3①「可達」實作偏弱（只查 tile.has+鄰格,無 PathSystem）——本引擎無不可通行地形故近乎恒真,風險本不存在;**若未來加阻擋地形須升真 reachable**。
2. fallback 成功記 floor_pass 無痕——可選加 `floor_fallback_used` probe 追主路徑失敗率,非必須。

## process 教訓（已入 progress，供你 + measurer 校準）
measurer 首輪「地板30/30綠」只量 code 實作的覆蓋度單維,漏 spec 承諾另 3 維 → 綠報涵蓋 < spec 承諾。**往後硬 gate 驗收對 spec 逐項,非對 code 實作。**

## 待 measurer（§4 重 baseline，已 route）
§1 scatter 改動**所有 config**位置（含 warring_states 控制床）→ `seeded_warring_bed` baseline 位置位移 → 須重生 baseline 標「world-gen variety 位移,非迴歸」+ `worldgen_final18` 全探針長跑當新世界基線參照。measurer 處理中。

world-gen variety done。**backlog 下一序你裁**（gossip 名聲傳播/combat-into-engine S2/絕境經濟三弧共上游）。
