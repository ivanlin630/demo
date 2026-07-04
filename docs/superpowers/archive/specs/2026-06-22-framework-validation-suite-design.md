# 框架驗證套件實作（可做子集）

> 藍圖 `framework-validation-suite`：Part 1 行為測試(TC1-7) + Part 2 魂觸發場景(S1-6)。TC1/4/6/7 已隨引擎落地驗。本塊補**可做子集**：TC2/TC5（headless DecisionEngine）+ S1-6（場景 probe 斷言）。**唯 TC3**（feud→脫軌打仇人需引擎攻擊 option）卡他域（未決）。

## 病
驗證套件未成形：TC2/3/5 + S1-6 無自動斷言 → 框架 believability + 魂 fire 無回歸閘。多數魂系統已 merged（feud/vendetta/scout/ambush/mint/立國/economy），但無「驗它們 fire」的測。default world_sim 量測：`faction_found=1`(S1✓)/`detect_*`(S3✓)/`order_fulfilled=3`(S6✓) fire；feud_formed/vendetta/scout_dispatch/ambush/mint default run **=0**（未觸發=需場景 config）。

## 修：framework validation 套件
### Part 1 — headless DecisionEngine 行為測（補 TC2/TC5）
- **TC2 survival override**：糧近 0 隊 → survival-class option（覓食/survival/返家補給）util 量級壓過其他（驗 survival=高權重輸入非 latch）；義氣 leader→覓食 flavor。（**搶劫 flavor=殘忍→loot 卡他域 loot option**，本塊驗 survival-as-input 核心 + 覓食 flavor。）
- **TC5 經濟+情報**：商業隊有貨 + belief 說 X 有 arb 單 → `decide`=貿易 target X；belief 過期/假（無對應實單）→ 撲空（無成交）。驗經濟狀態 + 殘缺情報為輸入。
- **TC3 標記未決**（feud→脫軌攻擊需引擎攻擊 option=他域）：寫 skip + 註明，待他域。

### Part 2 — 魂觸發場景斷言（`scripts/debug/framework_validation.gd` 新 harness）
每魂：最小 config setup → 跑 N tick → 斷言 probe fire（或報 dormant）。
- **S1 立國**：野心 tail leader + 資源 + 弱鄰 → `g2.faction_found > 0`。（default 已 fire=1，斷言守住。）
- **S2 feud+vendetta**：預置屠殺/暴行（殘忍 raider 屠隊留餘部）→ `g2.feud_formed > 0` + `g2.vendetta_trigger > 0`。
- **S3 scout 查證**：矛盾情報 + 慎重 leader → `g3.scout_dispatch > 0`（+ detect_* 已 fire）。
- **S4 ambush 誘殺**：偽弱餌（假低報 armed intel）+ 莽攻擊者 → `g1`/ambush probe fire（**確認 ambush probe 名;無則加**）。
- **S5 mint 鑄幣**：faction 控金礦 + 鑄幣廠設施 → `g1.mint > 0`（**W8 dormant:上游挖金礦從不發生→可能需挖礦觸發 config;若觸發後仍 0=報 dormant chain backlog,非本塊修**）。
- **S6 經濟閉環**：商業隊 + 市集 + 缺糧買家 → `g1.order_fulfilled > 0` + `[Market]成交`（default 已 fire=3，斷言守住=已達）。

**dormant 揭露**：場景觸發後仍 0 的魂 → **報 dormant finding（backlog）非驗證 fail**（套件目的=揭 dormant，見藍圖）。

## 驗收
- TC2/TC5 headless 過（DecisionEngine 行為）。
- framework_validation.gd 跑：各魂場景 → probe 斷言 fire 或明確報 dormant。
- 已 fire 魂（S1/S3/S6）斷言守住（回歸閘）。
- 觸發後仍 dormant 的魂（如 S5 mint chain）→ 記 known_issues backlog。
- headless 全綠、coin_eq/InvariantAudit 0。
- 2 年 world_sim 跑（魂 fire 數對照）。

## 檔案
- 新 `scripts/debug/framework_validation.gd`（Part 2 場景 harness）。
- `headless_test.gd`：TC2/TC5 + 註冊；TC3 skip 註明。
- known_issues：觸發後仍 dormant 的魂（backlog）。
- 2 年 world_sim 驗收。

## 非本塊（未決/backlog）
- **TC3**（feud→脫軌攻擊）= 引擎攻擊 option = 他域（未決）。
- TC2 搶劫 flavor（殘忍→loot）= loot option（他域/loot-join 債）。
- 觸發後仍 dormant 的魂（mint chain 等）= 各自 backlog 修（非驗證套件本身）。
