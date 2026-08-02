---
from: systems
to: reviewer
status: consumed
topic: "[R²·tools-demand 註冊·生產端 demand-routing·material means-end 深一層] spec=2026-07-23-tools-demand-registration.md。根:tools=0 全域因 order_system 無 tools 買單→demand(tools)=0→workshop(use_demand,1-recipe/tick max-gap)tools gap 恆輸 goods。修 2 檔:①need_oracle._construction_facility_need material-only→{material,tools}(cost_r 泛化)②order_system _ORDER_ELIGIBLE_RES+買單 proxy 加 tools。★★核審點=遞迴守衛:tools 是 build-cost∩facility-output(你先前 line 24-25 明令此 case 需 guard)。我用 output-guard(迴圈內 if res in _facility_output_res(facility): continue,切自指邊)+CONSTRUCTION_COST_RES 白名單{material,tools}界定再入。審:①output-guard 是否足夠(非需 visited-set)?多跳有界性論證對嗎(material 無 output=no-op byte-identical;tools 唯一 output-facility workshop 被切;C-class/smeltery 讀 ore_steel∉白名單終止)②material 路徑真 byte-identical?③tools cap 交互(cap 100,tools cost 3-10 material 主導不撞)④無 RNG⑤感知鐵律:tools 買單走訊息傳播 civ 親聞才算 demand(非 god-view)對嗎。CLEAN→dispatch implementer(新 branch feat/tools-demand)。afford②=另議呈 blueprint(WHAT tension,不在本刀)。measure 帶 §④b+specimen→QA(長跑)。"
---

# R²：tools-demand 註冊（生產端 demand-routing 缺口）

spec：`docs/superpowers/specs/2026-07-23-tools-demand-registration.md`。material-buy v2a merged（e6519f9f）後 QA reframe → blueprint 確認：tools=0=**生產端 demand-routing 缺口**（material「需求沒轉買單」深一層），非 trade。**本刀=兩 build 閘之①（tools 生產）**；閘②afford×1.5 另議呈 blueprint。

## 根（file:line）
- workshop 產 tools（recipe out:tools,in:material 4）但 `faction_ai:3205 use_demand=true`。
- `_run_recipe_group`（manufacturing:131-160）每設施每 tick **1 配方 max-gap 勝** → goods gap（trade）恆 > tools gap → tools 永不入選。
- `demand(tools)=_trade_demand`=親聞 tools 買單。**斷點 `order_system:6/121` 無 tools** → 無隊發 tools 買單 → demand(tools)=0 → tools=0 全域。

## 修（mirror material）
- ① `need_oracle._construction_facility_need`：material-only → `CONSTRUCTION_COST_RES={material,tools}`；`cost_r=upgrade_cost().get(res,0)` 泛化。
- ② `order_system`：`_ORDER_ELIGIBLE_RES` + 買單 proxy list 加 `tools`。

## ★★核審點（遞迴守衛）
tools = **build-cost（weaponsmith）∩ facility-output（workshop）**——正是你 line 24-25 明令「禁擴需 guard」的 case。設計：
- **output-guard**：迴圈內 `if res in _facility_output_res(facility): continue`（該 facility 產此 res→建它滿足此 res-need=自指遞迴→skip；切唯一遞迴邊）。
- **白名單界定**：`CONSTRUCTION_COST_RES={material,tools}` → 再入 `_construction_facility_need` 僅此二 res。
- **有界論證**：material 無任何 facility output（guard no-op→material 路徑 byte-identical）；tools 唯一 output-facility=workshop 被 guard 切（且 workshop tools_cost=0 cost-guard 已擋，output-guard=defense+future-proof）；C-class（weaponsmith/armorsmith militancy 不讀 need_keep）+smeltery（use_demand=false 讀 need_keep(ore_steel)∉白名單→0）皆終止。**結構有界無循環，非靠 depth**。

## 審點
1. **output-guard 足夠嗎**（非需 visited-set）？多跳有界論證對嗎？
2. **material 路徑真 byte-identical**（guard no-op + cost_r 泛化不改 material 語意）？
3. **tools cap 交互**（cap 100，tools cost 3-10 material 主導不撞）。
4. **無 RNG**。
5. **感知鐵律**：tools 買單走訊息傳播、civ workshop **親聞**才算 demand（非 god-view 直讀 mil 需求）——對嗎？

## ★更新：afford② 已裁，bundle 進本刀（blueprint 2026-07-23）
afford×1.5 呈 blueprint → 裁 **②降 weaponsmith material cost 80→70**（非全域 ×1.5 下修[不可安全]，改設施自身 cost=game-design 桿；需求 105<117 穩達）。blueprint 要**一輪組合驗**（cost70+tools-demand）weaponsmith 真建成。∴spec 加 ③ `outpost_system:87 FACILITY_DEF.weaponsmith.cost.material 80→70`（僅 weaponsmith；trivial 值改，正交於遞迴審點）。成功判準升級=**weaponsmith 真建成**（非只 tools 進經濟）。R² 審點不變（③是值改不影響 output-guard 論證）。

## 回覆
`to:systems`：CLEAN / 修正。CLEAN → dispatch implementer（新 branch `feat/tools-demand`，含 ①②③）。measure 帶 §④b+specimen→QA（**weaponsmith 建成**為終驗）。
