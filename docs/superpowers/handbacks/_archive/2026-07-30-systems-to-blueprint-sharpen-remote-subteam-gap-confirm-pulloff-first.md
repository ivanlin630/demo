---
from: systems
to: blueprint
status: consumed
topic: "[★接受steer(persist-hold cover非skip-reeval latch,不凍紅線)+measurer sharpen診斷+紀律:pin拉走機制再設計fix別再盲從線索·★新洞:complete_upgrade_facility=6(own-outpost升級真完工)vs complete_build=0(remote founding零完工)=gap是remote founding子隊專屬(own-outpost施工正常,非persist-block因升級也用persist)=派出的remote子隊完工前被拉走·★但拉走機制未坐實:argmax try_set搶班(persist floor可修)vs 10天timeout release(:48#3,需timeout修,transition繞persist gate)vs其他——bed 4Q dump缺construct.stall/ct_reason/ct_task(只有start/complete)·紀律:剛refute persist-block靠親驗,同理pin拉走機制再設計fix(fix方向依機制:argmax→persist floor罩住施工子隊;timeout→timeout persist-aware)·下步dispatch implementer bed補dump construct.stall/samples→pin→設計non-freeze fix·不凍TDD(seed1337 attrition非→0紅線)] 接受steer。sharpen:gap是remote founding子隊(own-outpost升級完工6/founding 0)。拉走機制(argmax vs timeout)未坐實,先pin再設計fix別盲從。dispatch implementer補dump。" 
---

# 接受 steer + sharpen 診斷 + 先 pin 拉走機制（別盲從線索）

## 接受你的 steer
- founding fix＝**用已 RELEASED non-freeze 持守 hold 罩住施工隊**、**別再追 skip-reeval latch 的凍**（死路：skip-reeval 停演化＝持守 arc 用 util-bias 刻意避開的）。
- 硬約束＝**世界不凍 invariant（latch 凍過＝紅線）**。HOW 我 own。收到。

## ★measurer 資料 sharpen 診斷（新洞）
`complete_upgrade_facility=6`（own-outpost 升級**真完工**）vs `complete_build=0`（remote founding **零完工**）——**同一 construction pipeline，own-outpost 升級完工、remote founding 零完工**。
- ∴ **gap 是「派出的 remote founding 子隊完工前被拉走」專屬**，**非 persist-block**（own-outpost 升級也走 persist 卻完工）、非整條 pipeline 壞。
- 對應 measurer 故事：T0（①founding 隊）task=**貿易**、mat 緩爬 0→52 從未達 need_mat=138——founding 子隊沒在建、母隊在 trade。

## ★但「拉走機制」未坐實——先 pin 再設計 fix（紀律，別重蹈盲從）
剛 refute「persist-block」靠**親驗 code**（transition 繞 gate）。同理，**拉走 remote 子隊的機制未坐實**、有三候選、fix 方向依機制**不同**：
- (a) **argmax try_set 搶班**（warring ct_reason='unified'，known_issues:51）→ fix＝**persist floor 罩住施工子隊**（保證 persist_eff≥threshold→argmax try_set 被 persist.hold 擋，non-freeze）。
- (b) **10 天 timeout release**（known_issues:48 #3：子隊抵達/建程 >10 天→timeout release→IDLE→被 trade 挑；timeout 走 transition **繞 persist gate**）→ fix＝**timeout persist-aware**（施工中不 timeout-release），persist floor 無效。
- (c) 其他（子隊 TASK_BUILD 有 :1717「return 不打斷」保護→若真在 TASK_BUILD 不該被 _evaluate_subteam 拉，那拉走發生在**到 TASK_BUILD 之前**[MIGRATE/CONSTRUCT 階段]）。
- **bed 4Q dump 缺 `construct.stall`/`ct_reason`/`ct_task`（只有 start/complete）→ 拉走機制看不到**。WarringHarness.run 內部**有** capture `probe_samples`（CONSTRUCT_SAMPLE_KEYS 含 construct.stall），bed 只是沒 print。

## 下步（我 proceed，HOW）
1. **dispatch implementer**：bed 4Q dump 補印 `construct.stall`/`construct.progress`/`construct.timeout_cancel` + `probe_samples`（ct_reason/ct_task/task_after）→ 已 captured data、小改。
2. **re-run → pin 拉走機制**（argmax vs timeout vs pre-TASK_BUILD）。
3. **設計 non-freeze fix targeting 坐實機制**（persist floor 或 timeout-aware）→ R² → implementer → **不凍 TDD（seed1337 attrition 非→0 紅線）+ founding 完工（complete_build>0）**。

**trade GATE-A/B 照修（另線）、T9 valuation 等你問用戶、runway A/B1 banked B2/B3/C 暫停、RELEASED 持守不動**維持。先 pin 再修，不盲從。
