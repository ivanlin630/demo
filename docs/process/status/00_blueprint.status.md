# Blueprint 交接快照(2026-08-25、compact 前)

## ★懸決=用戶桌上三題(工作流凍改令下,討論→核可→才動)
1. **a3e0b4af(watchdog 分類器提序)追認 or 退回**——附註:未被真實 fire 驗證過(systems 自報)。
2. **零產出偵測補不補**:三道防線全是「有產出物才檢查」,沒人問「做了事卻什麼都沒送出去?」(hook 診斷已完成=唯讀,細節見 2026-08-25-systems-to-blueprint-readonly-diagnosis-stop-hook.md);我的傾向=Stop 時查「main 落地而無信」warn-only、先 implementer 一週觀察。watchdog 修好後此型最多漏 1h,不裸奔不急。
3. **doc 瘦身案**(docs/notes/2026-08-25-doc-slimming-one-rule.md):一條規則(規則/證據不同居)+四檔處置(invariants 824→150 分家判例/game-design 拆 belief.md/00_roles→80 行+新 01b_blueprint.md/status 目錄刪)+讀單合一+CTX 省 57-78%。我標的討論點:判例外移防護 trade/status 提前刪毀約(README 承諾 8/28)/前三步純搬家零風險。核可粒度(六步逐勾 or 整案)用戶定。

## ★現行憲令(勿忘)
- **工作流凍改**(2026-08-25):工作流/hooks/流程 doc 改動=先討論、用戶核可才動;既有批次授權全失效。**凍結範圍=工作流側;sim 專案票照推**(已與 systems 確認)。
- **改時全線暫停制**:屆時 HOLD(收完落地)→改→驗→廣播重啟(同 harness 大修流程)。
- 憲章三分法:已知壞禁上考/未知=診斷目的/未實裝=豁免但考卷明標。

## 主線在飛(sim,不受凍改影響)
- means-end 磚(手段模型)merged 標 dormant+空真第四型已立;A 型(food 從 REGEN 導出)落地、acceptance=build 候選時間分佈 day000-only→全 90 天(我原「236 掉多少」指標=我指定錯,已認+立通則 acceptance 必因果下游)。
- camp-access **merged**:真戰果=**文明化首次發生+去文明化止住**(main 11→9+0 vs branch 11→11+1);棄置率 89→92 掛 A1(§F1)。
- 失敗記憶磚:結構身分 key(構造性覆蓋 100%)+記錄側擴(=失敗律原文要求,進料口=A1 typed 事件)+三分流(前提型不折價記 blocked/執行型折價/失效型 T0)——regression 事件後「折價反傷探索」假說被否證,真根=紮根是四端同秤漏的**第五端**(尺不同,[0,1] vs 折現流),同尺化=折現磚裁定補完已授權直接修;rooting 解封條件在 measurer 隊尾。
- factioned 床上線(用戶裁:床照世界造;三證據鏈重測處);cap-depatch(31.4%+未解釋 50.6%);convoy 驗收新法波(陽性對照/分母也是結果/驗收判準隨票走)。
- 子隊求生階梯(R² CLEAN)在隊列;懸仇③+死目標 T0 批等 ladder 後併 A1。

## 完工清單/考程
- 清單=docs/superpowers/specs/2026-08-21-model-completion-checklist.md(長考閘正典;09_exam_gate=一閘兩模式);考期以清單為準。豁免:脊椎(疊磚制進行中:折現磚✓/means-end 磚 dormant)/戰爭三斷(warring 戰爭欄廢考)/D4 質地=擋考。
- 時間重錨+層級制 spec LOCKED(排效能 arc 後);效能 arc=事件比例計算五刀(B/C 重定靶後:真 N² 嫌=team_discovered 成長;命令戳記-34.5% 已入袋)。
- 新基線考規格:死亡明細 tap/政治拆欄/prefix 修/game_over guard/facility-score 快照/**peaceful 卷預塞初始政權**(用戶裁=世界模型)。

## 本週立法(權威位置)
意圖帳=docs/mechanism-intents.md(建國雙層/延遲折現+蟑螂地板/執行失敗律/生育 per-capita/玩家附身/零 LOD/遭遇時間尺/估算器禁手抄...);流程法在 process docs+invariants(疊磚制/缺件通則/死水兩欄/機制已立≠已覆蓋/計時相對錨定/承諾即檔名/三態誠實/P9 HARD/proto=N/跨代=誰跑哪版是交付一部分/acceptance 因果下游/床有效性/argmax 雙儀器/陽性對照/靜態讀不出 runtime)。

## harness 現況
watchdog v4.3 我持哨(proto=4,✅ARMED);inbox 六支=舊碼「已修未部署」自然重 arm 生效;tg 單一消費者(進出站已驗);模板 repo 已同步 @1cca53a。

## token 統計(用戶問過,方法留檔)
transcript JSONL 的 usage 欄逐回合精確;腳本模式:掃 ~/.claude/projects/A--GDS-demo/*.jsonl 按 sid 對 peers 表歸角色;本週 8/18-25 總輸出 ~18.4M(大考 33%/settlement17%/harness10%/時間憲法 9%/磚 9%/建材 7%...)。

## compact 後開場(必做)
arm 三 Monitor(inbox-watch/tg_poll/watchdog,冪等;watchdog 若被同代持有=等待正常)→讀 CLAUDE.md+00_roles+本檔+mechanism-intents→查 open handbacks→**先看懸決三題有無用戶回覆**→續鏈。凍改令持續有效直到用戶解除。
