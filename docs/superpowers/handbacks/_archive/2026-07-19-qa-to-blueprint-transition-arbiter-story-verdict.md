---
from: qa
to: blueprint
status: consumed
topic: "[transition-arbiter 故事稽核·NOT 乾淨 PASS] 主靶 team16/team64 SURVIVES ✓=fix 對它瞄準的機制(等待新領主 defection-stomp)有效,那部分可接。★但 team84 不是孤例:bed 自己的 classifier 標 branch 有 6 隻 broken stuck 死(stuck-task ×5:team62/71/73/79/90 + 手不聽腦 ×1:team84),全同 subteam-idle-latch 家族(food OK 2.5-4.58 + committed=覓食 卻 idle/不執行 + would_succeed=true + reason=subteam)。measurer 只報 team84 一隻=undercount 6→1(只讀『手不聽腦』label 漏了同族『stuck-task』5 隻)。這 6 隻 food-OK 死→starve metric 不計=盲點重演;『starve 5→7=metric-lens 假象』只對 11 famine 成立,遮掉 6 stuck。建議:fix 當 incremental 接(救等待新領主家族)+開 systems arc 治 subteam-idle-latch(committed 求生 task 不執行=根未 de-patch)。A/B 你裁。"
measured_at_head: 93966d15
---

# transition-arbiter 故事稽核判決（QA 故事性判官）

**源**：`2026-07-19-blueprint-to-qa-transition-arbiter-story-audit.md`
**讀**：branch 死 dump `docs/measurements/2026-07-19-transarbiter-lockpoint-deaths-branch-93966d15.txt` + baseline `...-baseline-649f7070.txt`（head 93966d15）
**注**：bed 死因 classifier 已升級（現標 famine/stuck-task/手不聽腦/food-ok-vanish，取代不可信的「純窮死」——上輪教訓已被 systems 修入床，好）。

## 判決一：主靶 team16/team64 = fix SUCCESS ✓（那部分可接）
- **team16**（今早戳破你 crisis-immunity release-pass 那隻，等待新領主凍死）：baseline 649f7070 **VANISHED** → branch 93966d15 **NOT in death dump = SURVIVES** ✓。
- **team64**（subteam idle-stuck）：baseline vanish → branch **SURVIVES** ✓。
- **team68**：branch = **food-ok-vanish**（逃跑 food_days=9.19-13.77 足、flee_from=(26,0) 真威脅 = healthy merge/absorb 非死）✓。
- → transition-arbiter 3 guard（combat/crisis-免疫/emergency-respect）**對它瞄準的機制（TaskArbiter.transition 等待新領主 defection-stomp）有效**，救活了主靶。**這部分我判 coherent，可接**。

**⚠ 誠實 caveat（coherent-survival 驗證 gap）**：死 dump 只含**死隊**逐 tick trace，team16/64 存活 → **無存活逐 tick trace 可讀**。我只能坐實**二元存活**（不在死 dump），**無法逐 tick 確認 team16 存活後是否真轉覓食/定居 coherent**（vs stuck-alive）。**但**：它「SURVIVES」本身意味 guard 有 dispatch 求生（有行動非凍結），比原本 300 tick 凍死已是質變 → 我傾向 coherent，但**若你要滿分確認，需 measurer 補一份 team16 存活 decision-trace**。

## 判決二：★team84 不是孤例——6 隻 broken stuck（measurer undercount 6→1）
bed 自己的 classifier 逐隊標籤（真隊，非野獸）：

| 死因 | 隊 | 數 |
|---|---|---|
| **famine（coherent 窮死 ✅）** | 9,19,25,38,41,48,65,70,76,80,89 | 11（would_succeed=false，階梯耗盡真沒糧） |
| **★stuck-task（broken ❌）** | **62,71,73,79,90** | **5** |
| **★手不聽腦（broken ❌）** | **84** | **1** |
| food-ok-vanish（healthy） | 67,68 | 2 |

- **6 隻 broken stuck（62/71/73/79/84/90）全同一家族**：`food_days 足（2.5–4.58）+ committed=覓食/遷移找糧 卻 task=idle 不執行 + reason=subteam + survival_dispatch_would_succeed=true`。bed 註直接寫「committed=X 卻消失＝任務卡住非餓」「food足 + dispatch 可派卻 idle 坐死＝控制層不執行」。
- **team84 = 此家族一員，非「1 個新獨立案例」**——它跟 team64/68（上輪）同 subteam-idle-latch 機制。**measurer 報「1 個新手不聽腦 team84」是 undercount**：它只讀「手不聽腦」label，**漏了同義的「stuck-task」5 隻**（stuck-task 與 手不聽腦 是 bed 對同一 broken 態的兩個 label 名：都是 food OK + task 不執行 + would_succeed=true 坐死）。實為 **6 隻**。
- 抽樣佐證（idle+would_succeed=true+reason=subteam）：team73 tick20299、team90 tick39399、team71 tick20299、team84 tick27398 皆同 signature。

## 判決三：對「starve 5→7=metric-lens 假象」的修正
- **starve 5→7 UP 本身**：對 **11 隻 famine 死**成立——它們 would_succeed=false、試遍階梯真沒糧 = coherent 窮死（basin 分岔多死幾隊，合法）。pop flat 佐證這批非世界惡化。**這層 measurer 判對**。
- **★但 6 隻 stuck 死 food OK（2.5-4.58）→ 根本不進 starve 分母**（starve=food<1.5 famine 死）。∴「starve 只升 2、是 metric-lens」**遮掉了 starve metric 從頭到尾看不到的 6 隻 broken stuck**——**同今早 team=-1000000 / 純窮死標籤的盲點型態**：broken 死不被聚合 metric 計，數字漂亮但故事有病。

## 為何 NOT 乾淨 PASS（QA 建議）
fix **治了症狀（救活 team16/64 兩個具體 等待新領主/transition 受害者），但沒 de-patch 根（subteam-idle-latch：committed 求生 task 不執行→idle 坐死）**——該根在 branch basin 仍 fire，殺 6 隊。這正是 memory `症狀vs根` / `補丁閘優先查` 的型態。

**建議**（A/B 你裁）：
1. **transition-arbiter 本體**：對它瞄準的 等待新領主/defection-stomp 機制有效（team16/64 SURVIVES）→ **可當 incremental 接**（別回退，它真修好一條）。
2. **★開 systems arc 治 subteam-idle-latch**（`to:systems`，補丁閘優先查）：`task=idle prio=0 reason=subteam + committed=覓食 + would_succeed=true` 為何 committed 求生 task 不執行→坐死？= de-patch（subteam dispatch 該執行 committed 求生），非 tuning。6 隊同 signature = 這是**獨立於 transition-arbiter 的第二條 stuck 機制**（transition 路已修、subteam 路未修）。
3. **不能只憑 measurer「1 隻不否定 fix」二次放行**——實為 6 隻，且 metric 看不到。你今早的直覺（不憑聚合放行、先讀故事）再次抓對。

（QA 只找不修不裁 HOW；6 隊 broken 血統/機制歸 systems 坐實，A/B 你決策。**教訓：bed classifier 分「stuck-task」與「手不聽腦」兩 label 但同 broken 家族——快讀只抓一個 label 會 undercount;故事判須跨 label 歸族 + starve metric 天然看不到 food-OK stuck 死**。走 handback 交 systems 提煉 memory。）
