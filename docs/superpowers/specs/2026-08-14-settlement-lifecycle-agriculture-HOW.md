# 定居生命週期 + 農業歸位 + 戰略蓋點（HOW / systems）

status: DRAFT→R²（2026-08-14）
owner: systems（HOW）← design `2026-08-14-settlement-lifecycle-agriculture-design.md`（blueprint WHAT、R² CLEAN）
溯源：12mo 期末考 → founding arc 證據包（六組 file:line）→ 用戶設計討論定案。

## §0 接點圖 + 命門（HOW 守）
- **禁 crank / 禁死常數 pop 曲線**：viability 由**工期+地形物理湧現**（付不付得起工期=過濾器）、L0 採集低倍率**單旋鈕**（禁 pop-curve、R² 點名易翻車）。
- **感知鐵律**：認領決策讀 **belief**（四通道=既有機制家族、★R² 訂正真 class name：`VisionSystem`(vision_system.gd) 共位親見 / **斥候=`FactionAISystem._try_scout_side` + `SubteamSystem.dispatch_anon_messenger`**(非獨立 ScoutSystem 類) / **資訊網傳聞[可失真]=`SimMessageSystem`(message_system.gd)+`BeliefSystem`** / 失聯帳本推斷=`BeliefSystem`)——**零新管道**、抵達才見真章（belief 過期→既有遭遇機制）。
- **守恆=可溯源**：farm_yield 走 chokepoint（`TileBank.deposit(...,"farm_yield")` 同 ResourceBank reason 慣例、守恆稽核含農業）。resource 分類學入 invariants（零生成 礦寶 / 自然再生 野味藥草野馬 / 生產類 食物 / 木材=採集加速維持）。

## §1 據點生命週期
### S1a 死亡釋放（機械修、R² 點名精確修點）
`erase_teams`（world_state:286-349、謹慎 chokepoint 清一堆欄**唯漏 outpost_owner**）→ 清 dead tid owned tile `outpost_owner=-1`。★**R² 效率**：**單 pass over `state.world.tiles` 配既有 `dead:Dictionary` membership**（同 :315 附近 `for otid in teams: if dead.has(...)` pattern）、**非對每 dead team 各掃全圖**（避 O(dead×tiles)）。
- **★fp intended-change**（解鎖認領=行為變、非 byte-identical）；不廣播（知情走 §0 四通道 belief）。
### S1b 撿鬼城 = 既有 settle 補全 + 目標池擴充（★用戶訂正③④：非新認領動詞）
**★HOW-binding 硬禁（用戶訂正④、code 只准兩處）**：
1. **settle 補 owner=-1 分支**：`_tick_solo_settle`（A4 solo-convert）現只 convert same-faction outpost（owner==同faction）→ **加 owner=-1（無主營）分支**：抵達 outpost_level>0 且 owner=-1 → solo 接管入住（`set_owner(team)`+convert resident）。修繕成本 << 新建工期=撿比蓋划算物理基礎。
2. **安家選項目標池擴充**：settle/invite 候選目標池 **納入 owner=-1 outpost tile**（既有 settle 決策的 target 集擴充、非新 action）。
- **★禁新增任何搶城類 action**；**occupy 不碰**（occupy 仍只打活 resident）；需新 action=**停下呈報**（不自作主張）。
- **★感知鐵律**：owner=-1「空」判定用 **belief**（team_discovered/tile belief、過期→抵達發現有人→既有遭遇機制談判/入夥/衝突/離開）。
- **★② 搶鬼城競爭（用戶訂正②）**：先到先得（首個 convert 者 `set_owner` 認領）；後到發現 owner≠-1（belief 過期）→ 既有 settle-fail/遭遇路；情報時效回報（belief decay=誤判自然）。

## §2 L0 營地階梯（S2）
**露宿(免費隱含不動)→ L0 營地 → L1 村(工期)→ L2/L3(既有)**。
- **新 `outpost_level=0`→L0** 需一個中間態：現 `establish_crude_camp` 直建 L1（免費瞬間）→ 拆成 **紮營=建 L0**（幾小時快搭、拔營無沉沒、`outpost_level` 引入 L0 語意或 tile flag `camp_level`）+ **建點=L0→L1**（數天勞力工期）。
- **L0 有**：**最低採集=短期看圖塊存糧**（★訂正①：讀 tile **池現量**、低倍率**單旋鈕**、無田無具只撿周邊；**遊牧循環湧現**=池吃乾就移；**再生率只定久留線**非產糧公式）/ 過夜安全 / 極小快取 / 體驗選址（住著持續觀察地力威脅→餵紮根決策）/ 行軍中繼（既有軍民分型掛）。**L0 無**：設施/農田/糧倉/稅/領土宣稱/居民身分（勞力池從 L1 起=居民/流浪界線）。
- **L0 衰敗**：棄置 N 天自動消失（物理、地圖自清潔）；只 L1+ 留廢墟（=可認領鬼城）。
- **L1 工期=viability 過濾**：L0→L1 數天勞力（期間不覓食=機會成本）；★**工期中斷用既有 `busy-preemptible`（faction_ai:414-415、高門檻威脅才打斷）不新發明**；付不付得起工期=湧現過濾（瀕餓碎片算不完→轉撿/投；健康團付得起）=零硬門檻。
- **★B6 落位**：小團 L0 吊命（能苟不能興、無倉無積累）；翻身=歸隊 or 攢底氣紮根。B6 原題（勞力池地板）不動。

## §3 農業歸位（§2 恢復原設計）
- **食物雙源互不相干**：①野地池（採集/覓食、再生率物理、L0 吃這口、維持現狀）②**農田=獨立生產線**：`農田產出/天 = farming_level × 單位產量 × labor 工位 × harvest_factor(季節)` → **入糧倉、標 `farm_yield`**（守恆 chokepoint）。
- **要勞力**（農田=勞力池工位→guns-vs-butter 自動生效）、**吃季節**（harvest_factor）、**等級=投資**（大村 size 出口 [[project_size_matter_arc]]）。
- **ROI 估算器不改**（物理跟上信念、錯配自動解=design-drift 事故修）。
- **resource 分類學入 invariants**（systems owner）。

## §4 戰略蓋點決策（§3、思考層第一戰）
建點=第一個完整深思熟慮決策通用樣板（立國承諾的泛化起點）：
- **三動機（全從真 state 算）**：①求生建家（無家→挑好地=體驗選址+邊際經濟地力帳、非鄰 7 格亂抓）②擴張建點（舊家 labor/地力/倉飽和→溢出產能=供應鏈帳；**吸收 `overflow_split` 機械閾值→決策化**=碎裂機械源除、★fp intended-change 大）③軍事要地（parked、本 arc 不建 military-siting）。
- **替代比較同秤**（邊際經濟一模型）：撿現成(認領鬼城) vs 投靠(merge/settle) vs 紮根(L1 工期) vs 續流浪——無寫死偏好、湧現。
- **★結果反饋（第一條反饋迴路）**：建點/認領後結局（活/棄/死）寫回 memory/belief→修正下次估值（蓋過失敗地不重蹈）=反射弧補「過去」邊。

## §5 invariants（本 arc 硬守、systems 落 invariants.md）
1. **感知鐵律**：認領讀 belief（四通道既有）、owner=-1「空」判定 belief-gated、抵達才真章。
2. **守恆可溯源**：farm_yield chokepoint tagged、守恆稽核含農業。resource 分類學（零生成/自然再生/生產類/木材採集加速）。
3. **禁 crank / 禁死常數 pop 曲線**：viability=工期+地形物理湧現、L0 低倍率單旋鈕。
4. **L0/L1 界線**：勞力池/居民身分/領土宣稱從 L1 起（L0 無=居民/流浪界線有意義）。
5. bounded machine-demonstrate=merge 硬 gate（§4 量測）。

## §6 slice 序（HOW 細排）
**S1（死亡釋放+認領=機械修、先解鎖 300 家）→ S2（L0 階梯+L1 工期）→ §3 農業（可平行）→ §4 戰略決策+反饋（壓軸、吃前面地基）**。每 slice bounded gate 硬、fp intended-change 標注（S1a/overflow-決策化/農業 皆行為變）。

## §7 界外（design §6）
軍事選址本體 / 植林 / L0 生產能力 / 長程計劃脊椎全套（next arc）/ LOD-perf / coin 鑄幣點（順手 grep 另記）。

序：R² 審此 HOW → CLEAN → S1 plan → dispatch implementer。
