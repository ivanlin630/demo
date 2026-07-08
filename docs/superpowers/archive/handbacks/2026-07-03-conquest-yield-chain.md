# Hand Back: 征服收益鏈（佔村點火）
> Status: consumed（2026-07-03 merged,系統收編）

分支：`feat/conquest-yield-chain`　commit `afe72de`

## 實作摘要

| 檔案 | 改動 |
|---|---|
| `scripts/simulation/npc_combat_system.gd` | Task1 A 翻旗接治權。`_end_combat`/`_force_retreat` capture 翻旗處計 `_flip_on_loser_village`（原 resident=敗方且已翻旗給勝方）；敗方村隊存活(pop≥`GOVERN_SURVIVE_MIN`=3)→ `_try_subjugate(...,on_captured_tile=true)`，滅/走光→鬼村僅翻旗(`yield.flip_ghost`)。`_try_subjugate` 擴 `on_captured_tile` 參數 |
| `scripts/simulation/manufacturing_system.gd` | `_team_works_tile` 加 `yield.works_tile_pass` 探針（同 faction 代工放行＝收益鏈點火） |
| `scripts/simulation/faction_ai_system.gd` | Task2 B 圍城 margin gate（僅 `_find_occupy_target`）。新常數 `OCCUPY_WIN_MARGIN`=1.3、`OCCUPY_DEF_ARMED_FLOOR`=0.1 |
| `scripts/debug/headless_test.gd` | 3 新測：`_test_conquest_flip_governance` / `_test_conquest_margin_gate` / `_test_conquest_collection_loop` |
| `scripts/debug/longwindow_bed.gd` | 診斷加 yield 收益鏈行 + occupy margin 探針 |

### 治權去重處理（plan Task1 重點）
- capture 翻旗與 `_try_subjugate` **本就同在** `_end_combat`(302)/`_force_retreat`(342) 決勝尾，非兩處新增。改法＝**加旗標到既有那一個 call**，不新增第二個 subjugate 呼叫。
- `on_captured_tile=true`（決勝於村存活）先轉治權（loser 入勝方 faction）；若同一路徑後續還有一般 subjugate（無），或旗標為 false 的一般路：`_try_subjugate` 內 `elif loser.faction_id != -1 ... return` + `loser.faction_id == fid ... return` 兩道早退 → 已轉者不重轉。**同一事件一次處理**。
- 三 case：①獨立村+統領勝方→create_faction+併入；②獨立村+非統領勝方→**授統領 tag 以戰立國**+create_faction+併入；③敵 faction 村→跨 faction 轉入勝方（`set_team_faction` bidir-safe 退舊入新）。

### 弧證據（長窗 LW_SEED=1337 LW_MONTHS=6 LW_DIAG=1，config warring_states，DONE 無 SCRIPT ERROR）

**每段 fire 過（aggregate 全鏈）**：
```
[funnel] conq.intent=43 → prosperity_reached=6 → combat_entered=27 → capture.total=7(by_attack=1)
         → assimilate created=6 → wolf pop growth Σ=+2 → found faction=1
[yield 收益鏈] flip_with_rule(翻旗接治權)=2  flip_ghost(鬼村僅翻旗)=0  works_tile_pass(同faction代工)=93
[occupy DIAG] scan passed=4702  (kill: notweak=55428 margin=2310 unreach=323341)  applicable=1
```
- **翻旗接治權點火（核心新機制）**：`flip_with_rule=2` → 2 次決勝於村存活→治權隨旗；`works_tile_pass=93` → 同 faction 村民代 owner 生產 93 次 = **收益鏈真跑（村產出歸 owner）**。這是本 spec 主根「翻旗村不為新 owner 產出」被閉合的直證。
- **margin gate 生效**：`occupy.scan_kill_margin=2310` → 2310 次候選被「真 armed 不足」擋（弱狼不自殺圍城）；`scan_passed=4702` 過閘。
- **以戰立國**：`found faction=1`（founding 段 envoy accept=1；佔村授統領 path 亦通，flip_with_rule 已 fire）。
- **flow 轉正段**：追蹤狼 Team32（野心 0.92 武力）eff_food 387→958、food_flow 穩定 +3~+4.7、pop 7→9 = 糧引擎正循環複利。
- **段串接**：raid 段 Team36 月 raid 37-57 次（raid 引擎滿轉）；captive 段 asm.created=6。**傳統追蹤 specimen 未剛好是佔村那隻**（佔村落在未追蹤隊）→ 全弧 specimen 串接留軌3 二考（plan 明示「弧不必一跑全走完/全弧=軌3 二考看」）。

**不 over-war / attrition sanity**：teams 102→36、pop 615→266（6 月）＝ warring_states 既有衝突消耗。本 spec 改動**只減不增戰**（margin gate 過濾佔村目標、治權轉移使敗村存活為屬民而非殲滅）→ 未引入 over-war。跑滿 6 月無全滅、DONE 正常。

**asm 分流（順記，非本 spec 主根）**：created=6 completed=0 interrupted=6（scatter 暴動 1 / escaped 逃 2 / released 釋放 3）＝ (c) asm 鏈殘留（spec 明示隨 (a)(b) 修後長窗再看）。同化 cadence churn 屬 pre-existing known issue，未動。

### margin 值
- `OCCUPY_WIN_MARGIN = 1.3`（TEST VALUE）：己方真 armed ≥ `pop_est × OCCUPY_DEF_ARMED_FLOOR(0.1) × 1.3`。
- 依 plan 公式原文實作；此為村防**下限**估（belief pop × 武裝下限比），mild gate。與既有 `OCCUPY_POP_RATIO(0.6)`（pop 明顯小才圍）疊加：pop gate 擋大村、margin gate 擋「pop 夠但真 armed 不足」的空殼狼。

### 收取鏈洞（Task3 結論：**無洞**）
- 追鏈：村隊採集 food → `_collect_from_tile` 直入 `tile.public_storage`（**faction 無關**，line 264-272）；製造產出 → `_add_output` 入 tile 公庫（受 `_team_works_tile` faction gate，治權轉移後放行）。
- owner 收取：站村上 → `own_granary_tile` 回該 tile → `effective_food` 含庫；**異地 roam** → `effective_food` 現格制不含遠村庫，但決策讀者 `DecisionContext._home_granary_food`（掃全自有 outpost）含 → 驅動 restock/返家補給環（`options.gd:47`）。守恆：庫累積不滅，返家取。
- **結論**：`effective_food` 現格制是**既有設計**（即時可用糧），異地收取由決策層 home_food→restock→返家閉環，非漏洞。**未動 `effective_food`**（全域讀者，改之風險大且違「最小洞」）。測 `_test_conquest_collection_loop` 固定兩路（站村 effective_food 增 / 異地 home_food 反映遠庫）。

### TEST VALUE 清單（本 spec 新增）
- `npc_combat_system.gd::GOVERN_SURVIVE_MIN = 3`（翻旗後村隊存活 pop 下限）
- `faction_ai_system.gd::OCCUPY_WIN_MARGIN = 1.3`
- `faction_ai_system.gd::OCCUPY_DEF_ARMED_FLOOR = 0.1`（mirror combat `ARMED_RATIO_FLOOR`）

## 連動風險
- `faction_ai_system.gd`（margin gate）：只加濾條、只在 `_find_occupy_target`，不改其餘攻擊/掠奪路徑。弱狼佔村頻率下降屬預期（序列成長門檻）。
- `npc_combat_system.gd`（以戰立國授統領 tag）：非統領勝方佔村→獲統領 tag+建 faction。理論上罕見 subteam/無 leader 勝方也會授 tag；佔村路由由獨立野心狼驅動，實務主體為有 leader 獨立隊。若需限制「僅野心≥閾值才立國」可後續加 gate（目前依 spec「以戰立國」無條件）。
- `effective_food` **未動**——若藍圖/系統認為異地佔村者該即時收遠村庫（plan Task3.2 字面），需系統裁定是否改 `effective_food` 全域語意（大改，跨所有生存決策），本 session 判為不宜擅動。

## 待主 session 確認
- **doc 更新（progress.md/invariants.md = 系統單寫者，未由本 session 改）**：建議 progress.md 記「征服收益鏈 merged：翻旗接治權閉合 works_tile、margin gate 序列成長、收取鏈驗無洞」。
- **effective_food 異地語意**：plan Task3.2 字面要「異地 effective_food 增」，實作判為 home_food 決策層已閉環、不動全域 accessor。請確認此取捨（若要改為全域含遠庫＝架構決策）。
- **margin/GOVERN_SURVIVE_MIN 平衡**：全 TEST VALUE，正式平衡 pass 再校（長窗 over-war/attrition sanity 見弧證據）。
