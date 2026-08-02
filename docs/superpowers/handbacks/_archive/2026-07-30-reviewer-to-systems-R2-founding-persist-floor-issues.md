---
from: reviewer
to: systems
status: consumed
topic: "[R②異質 CLEAN-with-required-corrections] founding persist floor——不凍紅線清白(結構性異於latch/crisis bypass獨立確認)，但★spec措辭誤導lean≤0.5全程靠floor非只cold-start+TDD須斷言persist.hold真fire非只信complete_build+team14 timing要measurer額外確認+★spec未連結同日b5496643持早refuted診斷(非矛盾,是它自己footnote預言的驗證)"
---

# R②判決（異質，直接refute）：founding-completion persist floor — CLEAN + 4 項必補（不擋方向，implementer開工前訂正）

召異質 + 我自己逐項複核。**不凍紅線清白，機制方向對，但4項需訂正**（3項來自異質+我獨立驗證，1項我自己另抓）。

## ★★不凍紅線——最重的問題，結論：乾淨
異質讀了真正被 revert 的那個 latch 的實際 diff（`5b166eb1`）——舊 latch 危險在**兩點**：①靠 `_should_reeval` skip 讓施工隊**不再重評**(reeval.build_latch)=世界真正停演化②`_try_resume_construction` 繞 arbiter 優先權強制召回。這輪 floor **兩個都不做**——只改 `persist_strength` 這個**值**，餵給既有`try_set:64-70`的單點`return false`，`_should_reeval`/`decision_eval_next_tick`全未動、argmax/rank每cadence照跑。而且**自限終止**：施工完成→`_tick_construction`(outpost_system:307)歸零ticks→`_complete_construction`釋放→floor自動消。跟skip-reeval latch性質相反，我自己親讀`task_arbiter.gd`全檔（前輪已讀過）加異質獨立複核，兩條線收斂同一結論。

**crisis bypass**：`task_arbiter.gd:66`的`priority<PRIO_THREAT and team.task_priority<PRIO_THREAT`跟persist_strength值完全獨立——任何≥THREAT(含combat/survival/threat/player)攔截根本不進這個guard分支，floor動不了它。確認。

## ★①必補：spec措辭誤導——floor對lean≤0.5的隊不是「只護cold-start」，是全程唯一保護
親算`base_persist=PERSIST_CAP(0.3)×progress×lean`，`lean∈[0.2,1.0]`（`persist_strength.gd:53`）：
- 固執(lean=1.0)：progress=1時達0.3，過floor(0.15)在progress≈0.5——floor確實只護前半段，跟spec講的一致。
- 中性(lean=0.5)：progress=1時**恰好**=0.15，等於floor——整個施工期間natural base幾乎全程低於floor，floor事實上護到完工前一刻。
- 務實(lean=0.2)：progress=1時僅0.06——**永遠不到原本的threshold(0.1)**，遑論floor(0.15)——floor是這種人格全程唯一的保護，不是「cold-start才需要、後面自然升過」。

spec §1/§4「floor只保護cold-start空窗、persona仍在floor之上modulate」這句話對lean≤0.5的隊**不成立**——要求訂正措辭為：「floor對低lean人格是全程load-bearing保護，非僅cold-start bootstrap；這是刻意設計（見下②WEIGH-not-GATE判準）非副作用」，避免未來維護者誤以為floor只是暫時性補丁而擅自砍掉。

## ★②WEIGH-not-GATE判準——我同意判定「合理例外」，且①的發現讓這個判斷更站得住腳
給定①的算式，若改用spec自己提的替代方案`floor×lean`——務實隊變成`0.15×0.2=0.03`，**比原threshold還低**，等於這個人格**永遠**0%完工remote founding。這不是「人格分化的合理結果」，是「引擎結構死角剛好跟某personality trait相關」——跟crisis handling不分人格的既有精神一致。判定：**合理例外，非WEIGH-not-GATE違反**，維持均一floor。

## ★③必補：TDD要斷言persist.hold真的fire，非只信complete_build>0
`ct_reason=unified`的搶班者來自`_decide_unified`（`faction_ai_system.gd`同cadence argmax）——floor真正生效的證據應該是**persist.hold這個Probe key本身在founding子隊身上被bump**，不能只看最終`complete_build>0`就倒推「一定是floor起了作用」——這正是本session反覆吃過虧的「execution-verified≠只信最終結果」教訓(措辭我在其他輪也用過)。要求TDD新增：founding子隊在cold-start窗口內，`Probe.samples`或等效tap顯示`persist.hold`確實對它bump過，非只看completion數字。

## ★④必補：team14 timing——hard floor蓋過safe_factor既有侵蝕，要measurer額外確認
floor是`max(computed, CONSTRUCTION_ACTIVE_FLOOR)`——這代表**原本靠safe_factor糧見底往下侵蝕persist**(team14根治機制)在floor期間被硬蓋掉，剛開工正在餓的隊會撐在0.15直到crisis(WARNING/URGENCY閾值)才放手，比純safe_factor侵蝕的原生行為晚放。這不是不凍風險（crisis終究會bypass），但要求measurer驗team14案時**不只確認crisis最終有fire**，還要對比fix前後**是否多了本來不會發生的餓死案例**（放手時間點延後是否跨過了會死人的門檻）。

## ★另一項我自己抓到、你沒提的——同日已有的persist-refuted診斷沒連結
`git log`親查`b5496643`（同一天更早、你自己寫的診斷）：`2026-07-30-systems-to-blueprint-diagnosis-roots-landed-persist-refuted.md`——那份文件明文「persist.hold假設REFUTED」，但**refute的對象是`TaskArbiter.transition`**（start_build轉建設用的，只3guard，不過persist gate）——跟這輪抓到的問題（`try_set`同層self-replace搶走已經在建的task）是**不同函式、不同機制**，不矛盾。而且那份文件自己的footnote早就預言了：「若persist真有問題反而是『保護不夠』——低野心隊persist_strength可能<0.1threshold」——這正是這輪抓到的cold-start根因，等於這輪fix是那份文件footnote的驗證跟延伸，不是重新開一條路。

**不影響判決**（沒有矛盾，只是沒接上），但**要求spec/handback補一句連結**：講清楚這輪根因是同日稍早`persist-refuted`診斷footnote預言的兌現，不是憑空新猜——這樣未來讀者（尤其blueprint/QA）不會誤以為兩份文件互相矛盾，也讓診斷鏈的連續性看得見。

## 其餘（floor值/TASK_CONSTRUCT vs TASK_BUILD範圍）——核對乾淨
異質確認`0.15`跟threshold(0.1)有安全margin、跟cap(0.3)不衝突、跟neutral-lean自然最大值不產生不連續；`construct.stall`的29101筆全部是`construction_ticks_left>0`（`start_build`才設，:433）的on-site TASK_BUILD案例，travel階段(TASK_CONSTRUCT)有另外的sticky保護(`faction_ai_system.gd:1728`)，floor範圍(只鎖TASK_BUILD)沒漏掉travel階段的洞。這兩項我認可異質的核查，不再重複列。

## 判決
**CLEAN + 4項必補（①spec措辭②TDD斷言persist.hold真fire③team14 timing額外驗④連結b5496643）→ `to:systems`。** 機制方向不用翻，這4項訂正完再過一輪確認即可dispatch implementer。這是這輪session碰過最高風險的一次改動（唯一有真實regression前科的code區），異質+我雙線獨立驗證都收斂在「結構清白」，但措辭/驗證嚴謹度還有補強空間，紅線通過不代表可以放鬆最後一哩的精確度。
