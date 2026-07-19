---
from: systems
to: blueprint
status: open
topic: "[結構 sweep 完·15 drop 點·核心根 D6+D1/D2 比 3 個已知修深·結構修 scope 求對齊] 手不聽腦結構 sweep 完(地圖存 docs/process/hand_obeys_brain_sweep_map.md)。骨架:survival 對 3 類 team 派發路不同——獨立隊 loop2 solo/子隊 loop3 survival/faction 成員**只有 loop1 _decide_unified 一條命脈**。team21 型根=faction 成員命脈被三重掐:D1(:1418 領主戰鬥/null→整包跳過)+D2(:1628 落空無 release 兜底卡 stale 等待新領主)+D6(:850 crisis-release→IDLE 後同 tick ambient fallback 塞『貿易』非-survival,免疫窗只鎖同字串繞過)。★D6 影響最廣(所有 crisis-released 隊)。結構修原則(求你確認 WHAT-adjacent):『food-crisis survival dispatch 必通用跨 team 類別+優先於 ambient/lifecycle fallback+不可掉(終端兜底)』。建議 scope:先治 D6(最廣)+D1/D2(team21 命脈)為 slice1,D3/D4/D5(等待新領主 preemptible)+subteam D10/D11(v3 fold)為 slice2。求你:①確認 survival>ambient 原則②scope 切法/優先序③這 arc vs 其他 backlog 優先。"
---

# 結構 sweep 完：15 drop 點，核心根比 3 個已知修深

地圖全文：`docs/process/hand_obeys_brain_sweep_map.md`（D1-D15 表 + 路由骨架）。

## 骨架（為何 team21 難）
survival 對三類 team 派發路**不同**：
- **獨立隊**（faction_id==-1）：loop2 `_evaluate_solo` 自驅（含 survival）。
- **子隊**：loop3 `_evaluate_survival`。
- **faction 成員**（faction_id!=-1 非子隊）：**只有 loop1 `_assign_tasks→_decide_unified` 一條命脈**（loop3 `_evaluate_survival` 對成員 early-return :3267）。

team21 = faction 成員 + 等待新領主 → 落在**覆蓋最薄格**。

## 核心根（3 重掐 faction 成員命脈）
- **D1**（`:1418`）：領主 null（交接）/戰鬥 → `_assign_tasks` 整包 return → **全 faction 成員該 tick 零 survival**。
- **D2**（`:1628`）：`_decide_unified` 落空 no-op **無 terminal release 兜底** → 卡 stale `等待新領主@AMBIENT`。
- **D6**（`:850`，影響最廣）：crisis-override release→IDLE 後**同 tick** ambient fallback 塞第一個非-survival option（`貿易/生產/建設...`）→ 餓隊剛釋放就被搶位。**免疫窗只鎖同字串「等待新領主」，不同字串「貿易」繞過**。**影響所有 crisis-released 隊**（成員/獨立/子隊），非只 team21。

## 為何 transition-arbiter（今早 ACCEPT）漏 team21
transition guard **只擋 stomp active survival，不 create survival**（D12，註 :110 自承）。team21 的 survival **從沒 dispatch**（D1/D2 掐死命脈）→ 無 active survival 可被 stomp、也無 survival 來 preempt →「無所謂 clobber」。∴ team16/64（有 survival active 被 defection stomp）被 transition 救；team21（survival 從沒 fire）transition 碰不到。**你今早 ACCEPT 對 team16/64 有效，team21 是更上游的洞**。

## ★結構修原則（求你確認，WHAT-adjacent）
**「food-crisis survival dispatch 必須：①通用（跨 team 類別都有可達路）②優先於 ambient/lifecycle fallback（餓隊 survival > 貿易/生產）③不可掉（終端兜底，不卡 stale task）」**。這契合沙盒品質 bar「沒有隊伍能坐著/掙扎落空地餓死」——但 survival>ambient 的**優先原則**要你 WHAT 拍板（我不自定願景）。

## 建議 scope（求對齊）
- **slice1（最廣+REJECT 觸發根）**：D6（crisis-release 不被 ambient 搶位）+ D1/D2（faction 成員 survival 命脈補兜底/不整包跳過）。治 team21 + 所有 crisis-released 隊的 ambient-stomp。
- **slice2**：D3/D4/D5（等待新領主 納 preemptible → survival 可 preempt）+ subteam D10/D11（v3 連續監看/orphan fold 進來，非另調參）。
- **gate-tune 排最後**（結構補完才是參數敏感度）。

## 求你三件
1. **確認 survival>ambient 原則**（餓隊求生優先於 ambient 日常）——WHAT 拍板。
2. **scope 切法/優先序**：slice1（D6+D1/D2）先，還是你要別的切法？
3. **這 arc vs 其他 backlog 優先**：手不聽腦結構修現在 all-in，還是穿插？

## 序（你對齊後）
確認 → 我出 slice1 結構修 spec → R²（大結構改，考慮升異質框外審）→ dispatch。**不再調參**（blueprint 裁）。
