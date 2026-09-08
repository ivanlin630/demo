# Medieval World Evolution – 中世紀世界模擬器

## 專案定位

Godot 4.2.2 GDScript 世界模擬器:**無玩家也要好玩**——世界自己說故事(勢力演化/經濟流轉/資訊傳播/人口興衰),玩家是可插拔的附身鏡頭,不是世界結構。核心願景見 [docs/game-design.md](docs/game-design.md)。

三條硬憲法:util=真實期望價值禁 crank;一個資訊模型零特例(認知非真相,fog 靠衰減);模擬層零 LOD(計算跟隨事件密度,不跟隨觀察者)。全表見 [docs/invariants.md](docs/invariants.md);機制意圖的 WHAT 權威=[docs/mechanism-intents.md](docs/mechanism-intents.md)(code 服從表、表只服從用戶)。

## 目前世界有什麼(2026-09 快照)

- **統一決策引擎**:所有隊伍行動走同一個 utility 秤(生產/貿易/遷徙/求生/建設),人格 MODULATE 真值,零腳本走廊。
- **經濟**:金本位貨幣(創世推導+鑄幣龍頭)、物價=主觀短缺浮動(無上下限,地板 0=白送可成交)、市場寄賣制(到場掛單+押貨 escrow+待領帳+自報價板)、雙層薪資(匿名供養/記名薪資,付不出=離心非叛亂)、徵收積少成多。
- **資訊網**:belief 四源(親見/相遇/順風車/事件信使),傳聞失真、共位必見、死訊也是資訊;組織對成員的知識隨往來而定,失聯就是失聯。
- **人口管線**:生育(盈餘驅動連續速率)→小孩→成年進匿名層→多管道晉升記名;成人死光小孩同滅;滅團/合併記帳。
- **戰爭**:遭遇戰同一時鐘 1:1、潰退人格化、據點易主=接收經濟體。
- **玩家層(C1 已定案,實作中)**:附身=繼承記憶/創隊=point-buy 純霧;記憶模型一流四頁+as-of 戳;歸因可發掘(≤2 跳保證路徑);時間控制=UI 第一公民。

進度快照與各系統 log:[docs/progress.md](docs/progress.md)。

## 怎麼跑

**一律用 wrapper**(強制 UTF-8,避免 CP950 亂碼;並自動蓋產地/beacon 戳):

```powershell
# 觀測 GUI(主要看世界用):god-view 地圖+事件 ticker+隊伍 inspect+速度四檔
.\tools\godot.ps1 scenes/ObserverMain.tscn -- --obs-seed=1337

# headless 世界大事記落檔(讀故事)
.\tools\godot.ps1 --headless scenes/ObserverMain.tscn -- --obs-seed=1337 --obs-ticker-dump=story.txt --obs-run-months=6

# headless 回歸測試
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd

# 新增 class_name 檔後必跑
.\tools\godot.ps1 --headless --import

# merge 前跑全部 merge-gate(閘清單=註冊表 docs/process/merge-gates.tsv,runner 讀)
bash .claude/hooks/merge-gates.sh
```

`--obs-*` 參數:`--obs-config=warring_states|default`、`--obs-shots=t1,t2`、`--obs-out=dir`。`--` 分隔符必帶。

## 程式結構

```
scripts/data/          資料結構(PersonData, TeamData, TileData, WorldData, FactionData, MessageData)
scripts/simulation/    模擬系統(sim_runner, decision_engine, resource, faction_ai, message,
                       order/market, salary, population, reaction, movement, event, worldgen…)
scripts/simulation/events/  事件(base_event + event_*.gd)
scripts/debug/         headless 測試床(種類標記 @bed-kind;僅註冊表所列會被閘讀)
tools/                 godot wrapper 等工具
docs/                  設計文件
docs/process/          工作流(六角色信箱制)/merge-gates 註冊表/defers 延後帳/量測判決
docs/measurements/     量測產物(.measure.json+跑面;產地戳=世界/seed/窗長/commit)
```

## 文件地圖(按需讀)

| 檔 | 內容 |
|---|---|
| [docs/game-design.md](docs/game-design.md) | 願景/玩法/世界觀(玩家循環/貨幣三幕/薪資敘事) |
| [docs/mechanism-intents.md](docs/mechanism-intents.md) | ★機制意圖帳=WHAT 權威,改機制先查 |
| [docs/invariants.md](docs/invariants.md) | ★跨系統規則(session 開頭讀) |
| [docs/progress.md](docs/progress.md) | 進度 dashboard+系統 log |
| [docs/world.md](docs/world.md) / [person.md](docs/person.md) / [team.md](docs/team.md) | 各域模型 glance-aid |
| [docs/event.md](docs/event.md) / [message.md](docs/message.md) | 事件/訊息傳播 |
| [docs/known_issues.md](docs/known_issues.md) | 已知問題(入口非工單,取用前驗現況) |
| [docs/glossary.md](docs/glossary.md) | 術語表 |
| CLAUDE.md | 專案工作指引+六角色工作流 |

## 注意事項

- `.godot/` 與 `tools/godot/*.exe` 在 .gitignore。
- 所有時間/數值常數多為測試值,正式需大幅調整([docs/tick_parameters.md](docs/tick_parameters.md))。
- 量測紀律:數字必附產地(世界/seed/窗長/commit);一個數字沒有窗口長度就不是一個數字。
