# 全頻率盤點(時間定案討論素材、2026-08-20)

status: WORKING(用戶要求「時間定案前先討論所有東西的頻率」;本檔=code 全掃描原始表,value 以 code 為準)
owner: blueprint(討論素材);審計執行時歸 systems HOW
來源: Explore agent 全掃 scripts/(45 tool calls);基準 1 tick=6min/240=1天
★本檔=舊法快照(2026-08-20 掃描當時值);WORLD_SPEED_MULT/近遠分班/收成 6h 重擲等已由 time-reanchor spec+背景律取代;審計以 debug/time_const_check.gd 為準。

## 設計層總覽(遊戲時間)

**思考決策**:近區隊全 pipeline 每 1h/遠區每 10h(補償等價)。faction 意圖/威脅/整併/俘虜待遇=每 1 天(危機 6h);繁榮 3 天(軍 1.5);戰略 10h;個人目標 10h;野心階梯 10h;goal 生成 3 天;徵收 30h(人格調變 15~67.5h);結盟查 30h;背叛查 50h;基建 50h。

**經濟**:採集/消耗/製造/outpost=每 1h(near,×day_fraction);收成因子每 6h 重擲;野味/藥草/野馬=每月機率再生;勞力池 3 天(危機即時);薪水 7 天;掛單 12h、訂單壽命 5 天;farm/regen 每日率×day_fraction。

**人口生命**:生育擲骰每反應窗(1h,15%/窗,~3.6 骰/日)+per-capita 門檻(重製中);minor 成年每月 10%(保底 1);餓死結算每日(寬限 7 天);飢餓 20 天滿/10 天回;疲勞 ~21 天滿/4.2 天回。

**移動戰鬥**:世界 4.8h/hex(16~144t clamp、地形/tier/騎乘/車隊調變);遭遇動作 1h(速度調變 2~50t);俘虜檢查每 5 round。

**資訊**:訊息 TTL 7/14/30 天(15 型別);belief 過期 3 天;信度 30 天全衰;斥候逾時 3 天;訊息強度 -0.005/h。

**timeout 家族**(天):逃 5/貿易 6+0.5·hex/JOIN 6+0.5·hex/站樁 4/佔領 3/遷村 25/工地 30/失聯 30/居留 cd 7(重複×4=28)/建材運 10。

## ★盤點抓到的病(時間定案時一起裁)

1. **「回合」定義打架**:sim_runner:336 turn=60t(6h) vs ui/sim_bridge:4 TICKS_PER_TURN=24t——兩個 turn 不同長。
2. **EWMA cadence 相依**:need_hierarchy:19 α=0.25 未除 day_fraction → near(4h 窗)/far(40h 窗)**不等價**=LOD 率等價原則漏洞。
3. **決策端移動信念錯**:goal_resolver:525 MOVE_TILES_PER_DAY=2.0 vs 物理真值 5 hex/天——估算器形狀家族(信念不追物理)。
4. **manufacturing 率疑未 ×day_fraction**(manufacturing_system:4-16)[?]——若真,near/far 產能不等價,須 systems 核對。
5. **裸魔法數週期**:harvest 6h(TICKS_PER_DAY/4 inline×2)/「2 天 timeout」6 處裸寫/player_trade 1000t(4.17 天不對齊任何單位)/日夜段界 0.1/0.75/0.9/月長 30 硬編(UI)/危機除數 4 三處重複。
6. **命名說謊**:HP_REGEN_PER_TICK 實為 per-cadence;FOOD_RESERVE_TICKS 實為量係數;PRISONER_CHECK_INTERVAL 單位=round 非 tick。
7. **debug 鏡像 drift**:ui_logic_test:77 TICKS_PER_DAY:=24(真值 240);food_ledger_bed 鏡常數 ×2。

## 原始全表

(全表 11 節請見 git 本 commit 的 agent 掃描輸出;關鍵行已抄錄上方。完整逐行表過大,審計執行時 systems 以 debug/time_const_check.gd 為入口重掃驗證,不依賴本檔靜態抄本。)

### 根錨
- world_state.gd:4-9 TICKS_PER_DAY=240/HOUR=10/MONTH=7200/SEASON=21600/YEAR=86400/SECONDS_PER_TICK=360
- time_scale.gd:14-18 BASE_ACTION=10/MAP_SCALE=24/WORLD_SPEED_MULT=5/MOVE=48
- sim_runner.gd:3-5 LOD_NEAR_RADIUS=3/FAR=100/NEAR_CADENCE=10
