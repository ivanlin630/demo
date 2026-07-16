---
from: blueprint
to: blueprint
status: consumed
topic: [★交接·重開讀我] session 狀態——主線=經濟死鎖修(農場faction-only雞生蛋),真根已確認,待建造條件表+用戶點頭
---

# ★ 交接：blueprint session 狀態（重開後先讀）

## 主線（NOW）：修經濟長程供給崩潰 = 讓玩家世界真正活過來
**崩潰真根已 CONFIRMED（systems file:line 坐實）**：
- **農場（食物基建）= faction-only**（`_evaluate_infrastructure(faction)` 只在 faction 迴圈跑 `faction_ai:642`）。
- **獨立隊（fid=-1）結構性無食物基建**（只走 `_evaluate_independent_strategy:1109` 建國/征服/結盟 + `_evaluate_solo` 覓食/貿易/紮營，都不蓋農場/糧倉/outpost）。
- **雞生蛋死鎖**：獨立隊要農場須先建國;但累積建國需 7 日食盈餘（無農場→食物卡原始 regen plains8/forest3÷0.8→pop 10/4 承載力<起始pop 8-10→永攢不出盈餘）、征服建國需打贏（弱隊打不贏）→ **死鎖餓死**。
- 數字：`resource_system:259` 農場 +50%食物/級;`FOOD_PER_PERSON_PER_DAY=0.8`;regen plains8/forest3/mountain0.5。
- **修法方向（systems+我判）= de-patch faction-only**（patch-gate-first）：給獨立隊食物基建 bootstrap 路徑（擁 outpost 能自建農場,不必先建國）。**非灌糧**（拔引擎）。
- world-gen 是照妖鏡（放大非病根;§2/§3 鬆綁→更多獨立隊落死鎖）。這是**絕境經濟 arc 具體結構根**。

## 在飛（open handbacks，等回報）
1. **systems**：完整據點+設施建造條件表（`build-conditions-audit`，剛推，零跑純讀）——修死鎖前摸清全鏈閘（農場需 civilian outpost 為前置？outpost 建也 faction-only？糧倉怎麼生？），免只 de-patch 農場漏 outpost/糧倉。
2. **measurer**：經濟長程診斷（食物供需儀表化）跑中 + 農場×存活實證（接現跑後加 probe，別重跑；現有 JSON 撈=空）。

## 待用戶裁（重開後問）
**de-patch faction-only 願景方向**：獨立隊該能自力 bootstrap 食物基建（農場/糧倉/outpost）擺脫死鎖嗎？（我判是=合「世界活」願景，但改「獨立隊本該弱/過渡」原語意，待用戶點頭）→ 點頭 → brainstorm 設計 de-patch → 對抗 → spec → build。

## 下一步序
建造條件表回 → 看清全鏈閘 + 用戶點頭方向 → **brainstorm「獨立隊食物基建 bootstrap / de-patch faction-only」** → 對抗① → systems spec → build → measurer 驗（default.json 12mo 能撐/建國）。

## 存著（經濟死鎖解了再回來）
- **中長期計畫層 design**（`2026-07-12-midlong-term-plan-layer-design.md`，成熟）：對抗①打回**四靶待修**（①state-machine 誠實定性為 feedback controller ②進度訊號抗噪趨勢窗 ③survival 即時繞 rung 遲滯 ④湧現誠實化）。**是決策模型完善,但非崩潰解**（矩陣證食物供給撐不起爬升）→ 經濟死鎖解、世界能活後才回來建。

## 本 session 已完成（merged + pushed origin）
敗北逃 rev2 / combat-into-engine S1 pursuit(絕對straggler) / consolidation S-A(名聲磁鐵跨faction歸附) / world-gen variety。量測協議入 memory `reference_measurement_protocol`。

## 關鍵脈絡/紀律（延續用）
- **經濟「戲成✓」是短窗假象**（3mo/控制config）;玩家世界 default.json 12mo 崩（0/8立國）。連控制32隊世界12mo也崩73%=duration普遍病。
- **紀律紅利**（這 session 靠這些擋白工）：深度窗抓長程 / 2×2控變因 / 多seed破幽靈 / build前等矩陣 / **零重跑靜態讀code逼近真根** / 補丁閘優先查(never-fire→查閘) / 對抗①放早 / 別灌糧拔引擎。
- **caveman**：重開會被 SessionStart hook 自動重啟(full)。用戶要**關 caveman 但保留禁廢話恭維**——重開後打「stop caveman」再關一次。
- **量測**：別重跑已完成的;靜態讀code優先;分層Tier1迭代/Tier2確認。

## 一句話
玩家世界從沒活過,真根=農場faction-only雞生蛋死鎖,已確認。待建造條件全表+用戶點頭de-patch方向→設計修法。計畫層存著等這個地基。
