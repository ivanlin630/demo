# spec：tools-demand 註冊（生產端 demand-routing 缺口·material means-end 深一層）

> 層級：L3（2 檔 tune，決策模型 measure-sensitive）。off LOCAL main。
> 來源：material-buy v2a merged（e6519f9f）後，QA 故事判 reframe → blueprint 確認（`2026-07-23-blueprint-to-systems-tools-demand-reframe-confirmed.md`）：tools=0 全域 = **生產端 demand-routing 缺口**（同 material「需求沒轉買單」家族，深一層），非 trade。
> ★本刀 = **兩 build 閘一起解**（blueprint 裁 2026-07-23：一輪組合驗 cost70+tools-demand 是否真解 weaponsmith 0→0）：①tools 生產（demand-routing）②weaponsmith material cost 80→70（blueprint 裁②，非全域 ×1.5 下修[不可安全,mint load-bearing]，改降設施自身 cost=game-design 平衡桿，需求 105<天花板 117 穩達）。**成功判準=weaponsmith 真建成**（兩閘皆開）。

## 根（file:line 坐實）
- workshop 產 tools（`manufacturing RECIPE_GROUPS`：`{"out":"tools","in":{"material":4}}`）但 `faction_ai:3205` `use_demand=true`。
- `_run_recipe_group`（manufacturing:131-160）**每設施每 tick 跑 1 條配方，max-gap 勝**（143-159 return 首條）。goods gap（trade demand）恆 > tools gap → tools 配方永不入選。
- tools gap = `need_keep(tools)+demand(tools)-stock`。`demand(tools)=_trade_demand`=親聞 tools 買單（need_oracle:137）。
- **斷點**：`order_system:6` `_ORDER_ELIGIBLE_RES` **無 tools** + `:121` 買單 proxy list 無 tools → **無隊發 tools 買單** → `demand(tools)=0` → tools gap 只剩 owner `_self_use`（pop×`TARGET_PER_POP.tools=0.5`，微小）→ 恆輸 goods → **tools=0 全域**。
- weaponsmith build-need（tools 3）**從沒轉成 tools need/買單**（`_construction_facility_need` scope=material-only，need_oracle:29-30）→ 無 means-end 信號。

## 修（2 檔，mirror material demand-registration）
### ① `need_oracle._construction_facility_need`：material-only → build-cost-res {material, tools}
- `CONSTRUCTION_COST_RES = ["material","tools"]`（build-cost 純消耗 res；破 chicken-egg 前瞻）。line 29 `if res != "material"` → `if not (res in CONSTRUCTION_COST_RES)`。
- `cost_mat` 泛化為 `cost_r = upgrade_cost(facility,cur+1).get(res,0)`（讀當前 res 的 build-cost，非寫死 material）。cost-guard/desire-gate/cap 不動。
- **★★結構遞迴守衛（reviewer R² 明令：tools = build-cost ∩ facility-output，line 24-25 flagged 需 guard）**：迴圈內加 **output-guard**——`if res in _facility_output_res(facility): continue`（該 facility 產此 res → 建它滿足此 res-need = 自指遞迴 → skip）。
  - `_facility_output_res(facility)` = 讀 `RECIPE_GROUPS`/A-table outputs（workshop→[goods,tools,arrows]）。
  - **為何足夠（非需 visited-set）**：遞迴唯一邊 = 「F costs res 且 F outputs res」（F 之 deficit 讀 need_keep(res)）。output-guard 切此邊。多跳有界：`CONSTRUCTION_COST_RES` 白名單只 {material,tools} → 再入 `_construction_facility_need` 僅此二 res；material 無任何 facility output（guard no-op，material 路徑 byte-identical）；tools 唯一 output-facility=workshop 被 guard 切。C-class（weaponsmith/armorsmith militancy）+ smeltery（use_demand=false 讀 need_keep(ore_steel)∉白名單→0）皆終止。**結構有界無循環**。
  - 現況 workshop `tools_cost=0`（outpost_system:56）→ cost-guard 已擋；output-guard = defense-in-depth + 防未來有人給 workshop tools-cost。
- `cap`（`CONSTRUCTION_MATERIAL_NEED_CAP=100`）沿用（rename→`CONSTRUCTION_COST_NEED_CAP` 語意，值不變；tools cost 小 3-10，material 主導 cap，tools 不會撞）。

### ② `order_system`：tools 納可交易 + 買單 proxy
- `:6` `_ORDER_ELIGIBLE_RES` 加 `"tools"`（→ 施工隊不賣 tools[99 is_constructing 已擋]、餘 tools 發賣盤[civ workshop 產超自用→賣]、短缺發買單）。
- `:121` proxy list `["weapon_melee_low","weapon_ranged_low","material","ore_iron","ore_steel"]` 加 `"tools"`（→ mil 隊 reserve(tools)>holding 發 tools 買單；reserve(tools) 現含 weaponsmith build-need via ①）。

### ③ weaponsmith material cost 80→70（blueprint 裁②·afford 閘）
- `outpost_system.gd:87` `FACILITY_DEF.weaponsmith.cost.material` **80 → 70**（`upgrade_cost = base×target_level`：建 0→1 = 70×1 = **70**；需求 70×1.5 buffer = **105 < 天花板 117** 穩達）。
- **僅 weaponsmith**（armorsmith:93 material 80 不動；OUTPOST_COST 陣列[10-21]=據點本體非設施，不動）。
- 理由（blueprint）：設施自身 cost = game-design 平衡桿（低風險），非動已證 load-bearing 的全域 ×1.5；70 合理基礎武器坊成本。tools cost 3 不變（由 tools-demand①供給）。

## 鏈（修後，感知鐵律一致）
mil weaponsmith build-need → `need_keep(tools)`↑（①）→ `reserve(tools)>holding` → **tools 買單**（②）→ 傳播（訊息系統，civ **親聞**才算 demand，非 god-view）→ civ workshop `demand(tools)>0` → build-tick tools gap spike > goods → workshop 產 tools → 餘量發賣盤 → mil 經既有 trade 買 tools。

## 驗收
- **TDD**：①mil team weaponsmith-desire≥MIN → `need_keep(tools)` 含 weaponsmith tools-cost（3），capped ②civ team（無 tools-cost facility）→ `need_keep(tools)`=self_use only（pop×0.5）不變 ③**output-guard**：`_construction_facility_need(tools)` 不呼 `_facility_deficit(workshop)`（即使人為給 workshop tools-cost 也不遞迴——assert 有界）④material 路徑 byte-identical（無 facility output material，guard no-op）⑤order_system：reserve(tools)>holding → 發 tools 買單 ⑥**weaponsmith cost**：`upgrade_cost("weaponsmith",1).material == 70`（armorsmith 仍 80）。
- **gate** PASS（憲法 site-freeze）/ **headless** 0 new fail / **determinism** 2 跑 byte-identical（無 RNG）。
- **★★measure（→measurer，帶 §④b samples + specimen dump → QA；長跑新規則）**：
  - **tools 全域產量 > 0**（§④b：哪些 workshop/team 產、tool 數 3-10 樣本）
  - mil 隊 tools 買單發出數 / demand(tools) at workshop > 0
  - tools 賣盤 / tools 進市場 / tools 成交
  - build-tick workshop 選 tools-recipe 次數（vs goods 競爭勝率）
  - **★weaponsmith 建成數 > 0**（兩閘皆開的最終驗；§④b：哪些 mil 隊建成、build tick、耗 material/tools 樣本）
  - afford 通過率（cost70 後 mil 隊 avail≥105 達成率）
  - 回歸：goods 產量 / doom-delta / 無餓死。
- **送 QA 判故事**：mil 想建 weaponsmith → 發 tools 需求 → workshop 產 tools → tools 進經濟 → mil 買 tools + 湊足 material(≥105) → **weaponsmith 真建成** coherent。若 weaponsmith 仍 0 = 診斷未盡（QA 判剩餘閘）。

## 排序
①② 一刀（同 means-end demand-registration，同批 measure）。R²（output-guard 有界性 / material byte-identical / tools cap 交互 / 無 RNG / 感知鐵律 tools 買單傳播）→ dispatch。afford② = 另 handback 呈 blueprint（WHAT tension）。
