---
from: systems
to: implementer
status: open
topic: "[DISPATCH·大框 TDD] 統一生產框架 v2——R①CLEAN+R²CLEAN 全過。worktree feat/production-framework@origin/main。TDD S1製造precondition+tap→S2 survival-crush+granary seam+常數分層(override留)→★S2 gate驗餓隊farming主導→S3 means-end統一發起(涵蓋faction_id=-1)→S4移override+A3 utility+A4/礦山de-patch。整框架完成handback to:systems(→measurer full-HD)。禁AskUserQuestion"
---

# [DISPATCH] 統一生產框架 v2（生產 arc·甲）

> **[worker 守則] 卡住/授權不明/做不到/疑義 → handback `to:systems`（此 main mailbox 絕對路徑 `A:\GDS\demo\docs\superpowers\handbacks\`），status:open。**
> **★禁 `AskUserQuestion` 中斷用戶**（用戶明言再犯上 hook 強制擋）。雙 handback=正式授權照做，非「teammate mail 不夠格」。卡住報 systems，不問用戶。

## 授權鏈（全綠）
R① CLEAN（premise_contradiction 解，異質手算）+ R② round1→補裁 5 額外閘→R² round2 CLEAN。藍圖 ratify 全 WHAT。**gate 全過，可實作。**

## 工作區
- worktree：`.worktrees/production-framework`，branch `feat/production-framework`（已建，base origin/main `fa004b7a`，含 spec）。
- **code 寫 worktree、handback 寫 main mailbox 絕對路徑**（上）。也 arm inbox-watch（hook 指 main mailbox）→ systems 回覆自動收。

## spec（唯一真相，照做）
`docs/superpowers/specs/2026-07-16-unified-production-framework.md`（v2 + §R² 補裁 5 項）。

## impl 序（★TDD，序照 spec，S2 gate 硬性）
1. **S1** 製造 precondition 規則 + no-op tap（A2+E）：`DecisionContext.has_manufacturing_facility`（重用死碼 `_can_manufacture` 邏輯）→ `options.gd:71` 生產 applicable 補查設施；`manufacturing_system` **全 no-op 路徑**掛 `Probe.bump`（含 `_run_recipe_group` 原料不足 + `tile==null` 殘任務，見 spec S1.3）。tap 禁耗 RNG/禁污染。
2. **S2** survival-crush 項 + granary seam 修 + 常數分層（**★override 留著當安全網**）：`farming_score ×(1+CRUSH×urgency²)`、`food_days` 讀據點局部非 positional、`×0.8` flat/`×7` 人格化/`TARGET_PER_POP` 拆兩常數。
3. **★S2 gate（硬性，spec S2.4）**：TDD/headless 驗**餓隊 farming score 主導可耕地**（直答 R① 駁表：中性人格+餓+鄰森林村 harvest 1.0 farming>workshop）。**過了才准動 S4 移 override**（否則餓死窗口）。
4. **S3** means-end 統一發起（涵蓋 `faction_id=-1`）：獨立隊對自家 outpost 走**同 `_pick_facility` argmax** 自評估+建造 dispatch（非另開平行路）。
5. **S4**（★S2 gate 過才做）：移 `_pick_facility:2942-2950` override（demolish 泛化但 farming 受規則保護不拆）；A3 infra 階梯→utility argmax；A4 govern **移除、單 owner 引擎駐守、infra 不派/不秤**；礦山 civilian override 移除、融 ore 進 `_pick_outpost_type` 人格秤；規則明文（farming 不拆 / survival 蓋產糧不中斷泛化）。

## ★誠實紀律（R① 存在理由，勿違）
兩行為層斷言**待 measurer 坐實、勿寫成篤定 emergent**：①urgency 真 sim fire ②獨立隊 has_facility 真成長。impl log 誠實標，別自宣「已解供給牆」。

## 完成 → 交回
整框架 S1-S4 完成 + headless≥1000 tick 無崩 + 關鍵 print → **handback `to:systems`**（附 S2 gate 驗證數字 + 誠實標待 measurer 項）→ systems 派 measurer 中性 full-HD（has_facility 成長含獨立隊/goods/surplus/deals/人格分化/urgency fire/no-op tap 趨零/無殘補釘/byte-identical）→ 綠才收。

## 溯源
spec + R① CLEAN `production-v2-r1-clean` + R² round2 CLEAN `production-v2-round2-clean` + 藍圖 ratify。
