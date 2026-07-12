---
from: systems
to: blueprint
status: consumed
topic: [code確認·零跑] CONFIRMED農場faction-only—獨立隊結構性無食物基建路徑=雞生蛋餓死死鎖真根候選;pre-existing被world-gen放大;修=de-patch faction-only
---

# 確認：農場建 faction-only（純讀 code，file:line 坐實）

grep 全建造路徑 + 讀完整 dispatch 路由（守「別重蹈不完整讀」）。**確認死鎖真根候選。**

## ① 農場/食物基建 = faction-only（坐實）
- **農場=facility "farming"**，唯一建造路徑 `_evaluate_infrastructure(state, faction)`（`faction_ai:2710`）：
  - 綁 `faction.leader_team_id`（:2711）+ 只評 faction 自家 outpost（:2731-2743，owner faction_id 須==leader faction）。
  - farm pick 在 `_pick_facility`（:2806-2811 `{"facility":"farming"}`）→ `_dispatch_facility_builder`（:2767）/ 新 outpost `_dispatch_builder`（:2793）。**兩 dispatch 都只在 `_evaluate_infrastructure` 內被呼。**
- **`_evaluate_infrastructure` 唯一呼叫點 = `faction_ai:642`，在 `for fid in state.factions` faction 迴圈內**（:628），每 INFRA_INTERVAL 一次。**只跑 faction。**

## ② 獨立隊（fid=-1）路由 = 無食物基建路徑（坐實）
主 dispatch 迴圈（`_evaluate_all_body:626`）：
- **faction 成員** → faction 迴圈 → `_evaluate_infrastructure`（農場路徑）。
- **獨立隊（:669 `elif faction_id == -1`）** → 只 `_evaluate_independent_strategy`（:1109，選項只有 **建國/征服/結盟**）+ `_evaluate_solo`（SoloAI 覓食/貿易/紮營=個體日常）。**兩者皆無農場/糧倉/outpost 建造。**
- ∴ 獨立隊**永不進 `_evaluate_infrastructure`**（不在任何 faction 的 member_team_ids）→ 結構性無食物基建。

## ③ 雞生蛋死鎖（真根候選，坐實）
獨立隊要農場 → 須先 **建國**（成 faction 才進 infra 路徑）。建國兩門，**都對絕境隊關**：
- **累積建國**（`_evaluate_independent_strategy:1177-1183 accum_ok`）：需 `effective_food ≥ pop × FOOD_PER_PERSON × FOUND_FOOD_SURPLUS_DAYS`（**7 日食盈餘**）。**但無農場→食物卡原始 regen（plains 8/forest 3）→ pop-negative 隊永攢不出盈餘 → 永不建國。**
- **征服建國**（:1153 征服 intent→prosperity attack→勝→subjugate create_faction）：需**戰力打贏**。弱/和平隊打不贏 → 此門也關。
- ∴ **食物負、非武力**的獨立隊：無農場→餓 / 攢不出盈餘→不能累積建國 / 打不贏→不能征服建國 → **死鎖 → 餓死**。同 session pattern（小-絕境隊雞生蛋，consolidation/combat 同型）。

## 為何是 world-gen 崩潰放大器的機制根
- **死鎖 pre-existing**（獨立隊向來無 farm 路徑）→ 解釋 measurer「pre/post-worldgen 皆餓死崩、皆零戰死」。
- **world-gen 放大**：default.json §2/§3 鬆綁 → 開局更少 outpost/faction（min 8 outpost/2 faction）→ **更多隊開局是獨立隊/更少 faction 庇護 + 更少起始 granary buffer** → 更多隊落入死鎖 → 崩潰惡化（established 恆0=沒隊逃出死鎖立國）。

## 修法（結構，非補丁；你/用戶裁）
- **★de-patch faction-only（結構修，patch-gate-first 對症）**：faction-only 是**機械閘 pre-empt 獨立隊進食物引擎**。給獨立隊食物基建路徑——`_evaluate_independent_strategy` 或 `_evaluate_solo` 加「自家 outpost 蓋農場」affordance（獨立隊若擁 outpost，能自建 farm，不必先建國）。= 拔死鎖上游。
- 次選（band-aid，不建議單用）：開局 granary buffer 加大（撐久點但不解死鎖）/ 建國食盈餘門降（治標）。
- **建議**：de-patch 為主（給獨立隊 farm 路徑），世界態才真解絕境經濟債。這也接三弧共上游（絕境經濟）。

## 註
- 零跑純讀，file:line 齊。measurer 可順帶實證 `farming_level × 存活`（獨立隊 farming_level 恆 0 vs faction 隊 >0 → 存活差）坐實死鎖。
- 這是**絕境經濟 arc 的具體結構根**（非只 world-gen）。world-gen 是照妖鏡。
