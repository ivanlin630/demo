# 設施改制 A 期（需求迴路 + Slot 制 + 專業化）— Design

> 日期：2026-06-12
> 議題：FACILITY_DEF.trigger_check 是死碼（NPC 蓋設施只看 cap+錢，不看缺什麼）→ 馬廄上線 90 天 NPC 建造數 0。設施種類要擴充（消耗品產線），但先修決策迴路，否則加 N 個設施 = N 個裝飾。

## 設計原則

- **缺什麼 = threshold 偵測**（local 資料，簡單）；**專精什麼 = 地利決定**（地圖替 NPC 知道，不需市場推理）
- 補缺 ≠ 專業化：純缺口驅動會讓每村變一樣的萬能村。slot 稀缺 + 地利權重 → 村莊組合分化
- 軍民分工 → 互缺對方產出 → 貿易需求的結構性來源

## 不變量

- NPC 設施決策只用 local 可觀察資料（自身庫存 / 所在與鄰格 tile 資源 / leader 個性）— 不全知
- 每設施類型佔 1 slot（level = 深度不佔額外 slot）
- 設施生產需 tile 上有居民團（軍用 = 軍屯子隊）— 無人 = 停產
- 軍用 outpost 居民只能來自 dispatch 子隊（不收 invite 流民）
- 飢餓 trigger 永遠最高優先（可拆遷搶 slot）

## 1. Slot 制（取代 per-facility cap）

| outpost | Lv1 | Lv2 | Lv3 |
|---|---|---|---|
| civilian | 2 | 3 | 5 |
| military | 1 | 2 | 3 |

（TEST VALUE）`FARMING_CAP` / `MANUFACTURING_CAP` / `STABLE_CAP` / `cap_by_outpost` 全廢，改：

```gdscript
const FACILITY_SLOTS: Dictionary = {
    "civilian": [2, 3, 5],
    "military": [1, 2, 3],
}

static func slots_used(tile: HexTileData) -> int:
    var n: int = 0
    for f in FACILITY_DEF:
        if int(tile.get(FACILITY_DEF[f]["current_level_key"])) > 0:
            n += 1
    return n
```

設施升級（Lv1→Lv3）不佔新 slot，只花錢時間。

## 2. 設施拆分 + 軍民歸屬

| 設施 | level key | 產出（配方）| 歸屬 |
|---|---|---|---|
| 農田 farming | farming_level（既有）| food 採集乘數 | civilian |
| 工坊 workshop | manufacturing_level（沿用）| goods（3 mat）/ **tools（4 mat）/ arrows（3 mat）** — 全可再生原料 | civilian |
| 藥坊 apothecary | apothecary_level（新）| herb → medicine（herb 為 B 期圖塊資源；B 期前無地利 → NPC 不會蓋，dormant）| civilian |
| 鑄幣 mint | mint_level（既有）| ore_gold/silver → coin | civilian |
| 馬廄 stable | stable_level（既有）| food → mounts（B 期改野馬→戰馬拆分）| civilian（B 期拆軍民兩段）|
| **冶煉廠 smeltery** | smelter_level（新）| ore_iron → ore_steel | **military** |
| **武器坊 weaponsmith** | weaponsmith_level（新）| weapon_melee/ranged low（iron+mat）/ high（steel+mat）| **military** |
| **護甲坊 armorsmith** | armorsmith_level（新）| **armor_low（2 iron+2 mat）/ armor_high（2 steel+3 mat）**（新配方）| **military** |

`manufacturing_system._run_recipes` 拆四份：工坊配方 / 冶煉 / 武器 / 護甲，各依對應設施 level 啟用。固定優先序鏈廢除 — 每設施只跑自己的配方組，組內依**缺口排序**（庫存 / TARGET_PER_POP 最低者先做）。

`FACILITY_DEF` 加欄位：`allowed_outpost: Array`（["civilian"] / ["military"]）。

= 村莊造不了兵器（起義軍裝備差）；軍鎮缺糧缺藥 → 軍民互賴。

## 3. 需求迴路（取代死碼 trigger_check）

NPC 設施評估（faction_ai `_evaluate_infrastructure` 重寫核心）：

```gdscript
score(f) = terrain_fit(f) × (1.0 + deficit(f)) × personality_pref(leader, f)
```

**terrain_fit（地利，本格+鄰 6 格觀察）：**

| 設施 | 地利條件 → 係數 |
|---|---|
| 藥坊 | 鄰格 herb > 0 → ×3，否則 ×0（沒藥草不蓋藥坊）|
| 冶煉/武器/護甲坊 | 鄰格 ore_iron > 0 → ×3，否則 ×0.5（可靠貿易進料但分數低）|
| mint | 鄰格 ore_gold/silver > 0 → ×3，否則 ×0.3 |
| 馬廄 | 平原 + 鄰格 wild_horses → ×3；平原 ×1；非平原 ×0（既有 required_terrain）|
| 農田 | tile.harvest_factor（0.1–2.0 直接當係數）|
| 工坊 | 鄰格 forest（material 富）→ ×2，否則 ×1 |

**deficit（缺口，自身庫存 threshold）：**

| 設施 | 缺口訊號 |
|---|---|
| 農田 | food < pop × 2.4 × 14 天 → deficit 高 |
| 工坊 | goods/tools/arrows 任一 < TARGET_PER_POP × pop |
| 藥坊 | wounded > 0 且 medicine < 門檻 |
| 武器/護甲坊 | armed_ratio 低 / armor 存量 < pop×0.3，且近期有威脅 |
| 冶煉廠 | 武器/護甲坊存在且 steel 缺 |
| mint | 公庫 ore 屯積 > 門檻 |

**飢餓 override：** food < pop × 2.4 × 7 天 → 農田 score 強制最高；slot 滿且無農田 → **拆除 score 最低設施改建農田**（demolish 既有機制）。

**personality_pref：** 沿用既有 leader_pref dict（慎重→農田、貪婪→mint、好戰→武器坊…）。

## 4. 建造成本：三級制（coin 完全退出建設經濟）

| 級 | 成本構成 | 設施（基準成本 / 工期）|
|---|---|---|
| **低（基礎）** | material only | 農田 30/3天（720t）、工坊 60/7天（1680t）、馬廄 40/14天（3360t）|
| **中（工藝）** | material + **tools** | 藥坊 50+2t/7天、冶煉 80+3t/14天、武器坊 80+3t/14天、護甲坊 80+3t/14天、鑄幣 100+5t/30天（7200t）|
| **享樂（未來）** | material + tools + **goods** | 市集/廟宇…（B 期後）|

- 升級 Lv2 = 基準 ×2、Lv3 = ×3（含 tools、工期同倍率）。全 TEST VALUE
- **建造守恆原則：有限資源及其子鏈（ore_*/gem/weapon/armor/coin）永不入建造成本** — 建造只消耗可再生資源（material、tools[純 mat 製]）
- **outpost 本體**：civilian = **純 material**（50/150/400）；military = material + tools（80/200/500 + 3/6/10 tools，weapon 成本移除）。TEST VALUE
- **無雞生蛋**：拓荒 → 民用據點（純 mat）→ 內建工坊 → 產 tools → 才蓋得起軍用據點與中級設施 = 自然的文明階梯（先民後軍）
- coin 保留用途：薪資 / 貿易 / anon 升等 / 玩家招募 / 勒索進貢 — 專職人力與市場，建設歸實物
- 依賴鏈：工坊低級純 mat 起步 → 產 tools（4 mat，可再生）→ 中級設施 + 軍用據點全要 tools → 軍鎮向民間買 tools（軍民貿易線）
- 農田工期最短（3 天）→ 飢餓 override 拆遷改建不會餓死在工期裡

## 4b. 有限資源守恆審計（終局經濟）

**Invariant：有限資源（ore/gem/weapon/armor/coin）總量恆定 — 只有開採增加，任何系統不得銷毀，只能轉移。**

挖完 = 時代轉折（武備珍稀紀元 / coin 通縮 → 為 D 期信用貨幣鋪敘事），不是滅絕。

| 現有 sink | 改 |
|---|---|
| anon 升等 PROMOTION_COST coin（5/15/50）蒸發 | → 入 `team.anon_treasury`（訓練餉銀，本來就是給兵的錢）。food/material 成本照舊消耗（可再生）|
| 玩家招募 RECRUIT_COST（50/150）蒸發 | → 轉給目標 team（買人付給對方）|
| 武器/護甲銷毀路徑 | 實作時 audit：確認戰鬥/死亡只走 歸還/loot/abandoned 轉移；發現銷毀點 → 改轉移 |

## 5a. 軍屯（military outpost residency）

`_try_dispatch_or_invite` 加 filter：

```gdscript
var tile_type: String = tile.outpost_type
if tile_type == "military":
    _dispatch_subteam_settle(state, team, tile)   # 只派子隊，跳過 invite
    return
```

- 軍屯子隊 = SUBTEAM+PRODUCE dual tag（同民用派駐機制）
- 殘餘風險保留：紀律失效脫離 / 起義（loyalty<0.2 + unrest≥60）皆既有 — 苛待守軍 → 兵工廠叛變（低頻高戲劇性，feature）

## 5b. 建造執行鏈（實作期定案，2026-06-12 回寫）

實作驗收時發現決策層之外整條執行鏈斷裂（歷史上 stable 0 建造的真因），定案如下：

1. **評估範圍 = faction 內所有 outpost**（不限 leader 自有）；以該 outpost **owner 團的 local 資料 + owner leader 個性**評估（子隊安頓後的居民團據點也被評，且比用 faction leader 全知資料更符合不變量）
2. **執行優先序：就地施工 > 居民出工 > 派子隊** — owner 站在 tile 上直接開工；否則 tile 上同 faction 居民團出工出料；最後才派子隊
3. **子隊派工資金**：`_fund_subteam_cost` — dispatch 後 owner 補足建造費差額給子隊（純轉移守恆）；無多餘 named 時 `_pick_or_promote_advisor` 升 anon 當工頭
4. **飢餓豁免（窄）**：team 站在自己工地且**蓋的是農田** → survival 不中斷（自救邏輯，工期僅 3 天）；其他設施照常被中斷
5. **復工掃描**：`_try_resume_construction`（infra cadence）— 卡住工地由在場 owner/居民強制復工；owner 在外 → 召回
6. **工期單位 = person-ticks**（`_tick_construction` 每 cadence 扣 pop 數）：FACILITY_DEF ticks 以 1 人施工 = 設計天數 校準（農田 72 / 工坊 168 / 中級 336 / 鑄幣 720），人多更快

## 5c. 投降抽成（守恆 audit 衍生定案）

投降 = **半繳械**：30% 轉移給受降方，清單含 food/coin/goods + 武器 ×4 + 護甲 ×2（`SURRENDER_TRANSFER_RES`）。戰場配發裝備於投降中止時歸還原主（audit 修復，不再蒸發）。

## 5d. 生產人力規則

設施日產 tick（mint/stable/製造類）統一加 gate：**tile 上有居民團（PRODUCE tag）才生產**。
- 既有 mint/stable 的 tick_all 補此 gate（行為變化：無人軍堡/空村停產）
- 解「設施蓋了沒人用還在魔法生產」的不一致

## 測試

1. slots_used 計數正確；slot 滿 → try build 失敗
2. 軍用 outpost 蓋 civilian 設施失敗（allowed_outpost gate）；反向亦然
3. terrain_fit：鄰格有 ore → 武器坊 score ×3；無 herb → 藥坊 score 0
4. 飢餓 override：food 低 → 農田 score 最高；slot 滿 → 拆最低分設施
5. 軍屯 filter：military tile residency 只 dispatch，不 invite
6. 工坊配方：tools / arrows 產出；護甲坊：armor_low/high 產出
7. 配方組內缺口排序：arrows 存量最低 → 先做 arrows
8. 生產人力 gate：無居民團 tile 設施不產
9. 建造成本三級制：低級純 mat 可蓋；中級無 tools 蓋不了；建造不扣 coin / 不扣任何有限資源（grep 驗證建設路徑無 coin/ore/weapon 扣除）
10. outpost 本體：civilian 純 mat / military mat+tools（weapon 成本已移除）
10b. tools 配方純 mat（4 mat）— 建造鏈全程可再生
10c. 守恆審計：升等 coin → anon_treasury（總量不變）；招募 coin → 目標 team；全 sim 90 天 coin 總量（teams + persons + treasury + 公庫 + abandoned）恆定
11. multi 90 天：NPC 建造設施 > 0（baseline stable = 0）、**村莊設施組合差異度**（≥2 種不同組合）、ALL INVARIANTS PASSED

## 風險

- `_evaluate_infrastructure` 重寫範圍大（faction_ai 既有擴建邏輯 + outpost_system caps 全動）
- manufacturing_system 拆分影響既有測試（製造優先序測試全要改）
- 生產人力 gate 讓現有 multi 的 mint/stable 產量歸零（沒居民的 outpost）→ 經濟雪上加霜，需與 residency AI 配合觀察
- slot 數 / 地利係數 / 缺口門檻 全 TEST VALUE
- 藥坊 A 期 dormant（herb B 期才有）— 預期行為，multi 中藥坊建造 = 0 屬正常
- 起義奪軍火庫 path 未實測（multi 起義 0 次）— 留觀察
