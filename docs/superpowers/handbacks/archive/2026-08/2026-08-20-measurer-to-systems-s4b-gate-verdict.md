---
from: measurer
to: systems
status: consumed
topic: "s4b-gate-verdict"
---

# §4b bounded gate：⑤③①部分綠、②④部分、★具名科目UNTESTABLE

`.measure.json`落地：`docs/process/verdicts/settlement-s4b-gate.measure.json`
3個run：peaceful_economy(45天/90天) + warring_states(30天)，全seed1337

## ⑤機械閘：全PASS

constitution PASS(75/0)、headless 0-new(全部match既知baseline fail)、determinism PASS(peaceful 5天跑兩次，唯一diff在[TickPerf]的wall-clock計時、遊戲state/決策全部byte-identical)。

## ③零新常數：CONFIRMED

code-read坐實diff僅population_system.gd新增POP_OVERFLOW_MARGIN=1.15一個常數，expand三項邊際帳全委派既有_inflow_est/BUILD_TICKS/PLANNING_HORIZON_DAYS，零換算係數。

## ①動機分化：部分確認

**紮根(無家/L0)確認活著且bounded**：peaceful45天start=1/resume=11/camp_l0=4；warring30天start=4/resume=36/camp_l0=22——resume遠多於start，代表『續建/恢復』多於『重新起工』，符合設計預期非runaway。

**擴點(有家)：applicable閘三個run全部從未滿足過，s4b.expand_fire=0（含peaceful_economy 45天+90天+warring_states 30天，三次獨立跑法全部零次）**。Root cause：applicable要求population>=settler(6)*2=12，但三個run的PRODUCE隊population從未超過10（peaceful穩定卡在median=6/max=6整整90天無變化）。

## ②overflow機械觸發+pop不卡cap：PARTIAL

warring 1次/peaceful 0次觸發，方向符合『小超額留決策層』設計意圖，但★因population本身很少接近cap，這個gate沒被真正壓力測試到——不是決策層主動接住很多case（畢竟擴點也從未fire），是雙方都沒被逼到需要出手的規模。pop不卡cap本身確認成立（從未觀察到population卡在cap之上出不去）。

## ④§4a deferred empirical：兩項都有答案

**(a)餓死在工地**：peaceful 20起死亡0起task==BUILD、warring 2起死亡0起task==BUILD——PASS，樣本偏小但方向乾淨。

**(b)威脅頻繁區中斷續建循環**：peaceful(無威脅)resume=0.244次/天 vs warring(高威脅)resume=1.2次/天——**約5倍**，CONFIRMED存在此現象。但這可能是abandoned-corvee-recovery機制正常運作的證據(隊記得自己的未完工地、回頭能接著蓋)非死鎖，好壞判斷交blueprint。

## ★★具名科目（飽和區擴張自然剎車）：完全UNTESTABLE——不是剎車踩不住，是油門沒踩下去過

(a)(b)(c)三個子問題全部N/A：population在peaceful_economy(90天)/warring_states(30天)兩個標準場景下都遠遠沒長到pop>=12(擴點applicable門檻)、更別說pop>=20(你原本擔心的飽和線)。peaceful_economy從day5到day90整整90天population median/max都精確卡在6，看起來像穩定均衡而非成長中。

**這代表你原本擔心的『飽和區擴張』情境的前提本身(村莊真的長那麼大)在這兩個標準場景下沒出現**。可能原因：(1)population成長機制本身速率慢/有其他均衡點(需code-read population成長來源才知道是config問題還是機制問題)(2)需要專門設計的『大村economy』config或更長窗口(數月級)才能重現(3)若這反映『正常遊玩中村莊本來就很少長這麼大』，具名科目本身優先序可能需要重新評估。

**我沒有勉強湊數字或用小樣本硬答——如實回報『測不到』，這是本輪最大的懸而未決問題，交你/blueprint判斷下一步**：要不要先開一個cheap的population成長速率量測(獨立小題)，或直接設計快速拉大村的專門config再測一輪具名科目。

## cleanup

worktree（.worktrees/settlement-s4b）保留未移除（implementer真feature worktree）；temp tap(faction_ai_system.gd/resource_system.gd)已revert確認乾淨；temp bed已刪；`--headless --import`乾淨編譯確認。

## 總結+交你裁

⑤③PASS、①紮根PASS但擴點applicable閘從未觸發、②方向對但未受壓測、④(a)PASS(b)CONFIRMED現象存在(好壞待判)、★具名科目完全測不到(population規模不足)。是否要gate通過交你判斷；具名科目這條我建議不算「通過」也不算「失敗」，是「還沒能測」——需要額外一輪針對population成長速率的量測才能真正回答。地基KEEP，接著處理EWMA解耦行為面補驗(已排隊)。
