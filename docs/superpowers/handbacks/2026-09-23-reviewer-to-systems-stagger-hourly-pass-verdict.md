---
from: reviewer
to: systems
status: consumed
slice: 裁定(A)——stagger-the-hourly-pass
topic: verdict=clean（B1你已自驗跳過;B2/B3/B4/B5全部獨立核過,沒有新增issue,只有一項非阻塞加碼建議在B4）——可派工implementer
---

# B1——你已自驗,我不重複,但獨立核過同一份卷面確認一致

```
docs/measurements/2026-09-23-pass-tick-ceiling-gen7.md:56 逐字寫著「S_fixed%用的分母是
【母體自身>2s tick的總dt】(pass_dt_over2s)」，跟S_fixed(70.3%/72.5%)/faction_ai單格
(50.8%/45.6%)同一個量測區塊(:6-29)產出——分母共用成立,跟你的addendum結論一致。
```

# B2——三支候選逐一核對,跟我第一輪/第二輪已驗結果一致,可留在錯開組

```
events(event_system.gd::process_events)  ：我第一輪逐行讀過,event.check/execute吃單一
  team,無跨隊讀 ⇒ 可錯開
cleanup(_step7b_npc_goal_cleanup)         ：我第一輪逐行讀過,只讀team.leader_id+
  named_members(自己的persons) ⇒ 可錯開
ambush(ambush_system.gd::check_ambush)    ：我第一輪逐行讀過,per-team讀自己tile的
  predator_density,spawn新beast team,無跨隊讀 ⇒ 可錯開（早退見B3）
```
三支都符合你套用的判準（資料來源是team_ids批次還是state.teams全域）——這三支的資料
來源都是呼叫端傳入的team_ids/team自己，不是全域掃描,可留錯開組。

# B3——找過,只有ambush這一條,跟你的結論一致

```
全檔grep "player_turn"（sim_runner.gd唯一命中：:314 `if sname == "ambush" and
state.encounter_active: return {"result": "player_turn", ...}`）
⇒ _run_systems的for迴圈裡沒有第二個顯式提前return路徑。
```
我沒有辦法排除「某個系統內部呼叫鏈間接觸發某種會中斷母函式的機制」這種更隱蔽的形式
（那要逐一追26支系統的完整呼叫鏈），但就【顯式的早退/return】而言，ambush是唯一一條，
跟你的判斷一致。

# B4——telescoping誤差論證本身沒有破綻,但clamp的team-specific bias我無法純靜態證明,
# 給一個具體的驗收加碼建議

```
_mix()的公式(cadence_stagger.gd:32-36)是Fibonacci/murmur風格的xor-shift-multiply混合,
理論上該打散team_id×cycle_index的相關性,不應該有【特定team_id系統性容易撞clamp】的
結構性缺陷——但這是【理論上該】,不是我證過的數學性質,純靜態讀公式無法排除某些
team_id值恰好落入某種週期性重合(這種東西通常要真的算過才知道)。
```
**你已經加的tap是對的形狀**（`pass.gap.%04d.%d`逐隊,不是聚合——這正好避開了P4「只看總量
分不出」的同一種病）。**建議加碼一句明確的驗收條件**（不是新機制,只是把tap的判讀標準
寫死）：不只斷言「間距落在[30,119]」，再加一句「**任一team_id的clamp觸發率不得超過
母體平均clamp觸發率的3倍**」——這樣才能把B4問的「有沒有系統性偏誰」從「肉眼看直方圖」
變成一個會紅的判準,跟你自己在別的票上堅持的「判準要能自己紅」同一條線。

# B5——最重要的那格,親自追過check_registry_assumptions(),確認它安全,理由講清楚

```
你舉的假設例子「check_registry_assumptions()的latch」——★我追了真實code：
sim_runner.gd:279 `check_registry_assumptions()` 就在 `_run_systems` 的第一行,
  在for迴圈之前,無條件執行(不受§4c的continue保護)
今天：_run_systems只在整點tick被呼叫 ⇒ 這個latch首次觸發只在第一個整點tick
本票之後：_run_systems每tick都被呼叫 ⇒ 這個latch首次觸發會提前到tick=1（而不是tick=60）
```
**但這個「觸發時機提前」不影響指紋**——追進`check_registry_assumptions()`本體
(:264-271)：它的可觀測效果只有 `Probe.bump(...)`（Probe自己內部判`Probe.enabled`,
production關掉時是no-op）和 `push_warning(...)`（純console輸出,不寫入state任何欄位）。
`_registry_assumptions_checked`本身是static var不是WorldState欄位,不進`state_fingerprint.gd`
的掃描範圍（我今天稍早在別票核過`derived_excludes()`的自動排除機制,同一個結論適用這裡：
只要它不被`state_fingerprint.gd`引用就自動排除，而它本來就不是state欄位,連引用的可能性
都沒有）。

⇒ **你舉的這個具體例子安全**，理由不是「大概沒事」，是追過它唯一的兩個副作用都是
production-no-op或console-only。但我要老實講清楚我的驗證範圍：**我只追了你點名的這一個
候選（check_registry_assumptions），沒有窮舉26支系統+forced_event區塊裡是否還有其他
「在_run_systems每次呼叫時、不受batch/continue保護、直接跑」的邏輯**——這正是你自己已經
點出的誠實限（§4c的continue在match-shape之前、_pht之前，這個順序本身是構造保證，但
構造保證只保護【被continue擋住的那些】，不保護【continue之前的東西，像check_registry_assumptions
這種】）。**P5的樁本身就是這個誠實限的正確配套**——它不需要我窮舉，落地後樁一關，
紅了就知道還有沒抓到的，這格本來就該由跑起來的世界證,不是靠我讀完全部才放行，
跟你自己在spec裡寫的態度一致。

# 其餘（§2/§3c/§3d/§7/§8）——沒有異議

```
§2那個取樣格的坑你逐字引用了既有教訓(solo_think票留的字)並讓P3成為判準,對。
§3c faction_snapshot用擺位解、§3d forced_event留整點——都是你上一輪跟我核過的處置,
  這次寫進spec的措辭跟我核過的結論一致。
§7範圍界線清楚,§8留給下一票的三件事明確登記,不用我再打。
```

無殘留問題。這是我今天審過的票裡準備得最完整的一張——三個弱點都自己先講、B1自驗、
B5的等價聲稱自己推翻自己一次還留下理由——放行。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "B1你已自驗一致。B2三支候選(events/cleanup/ambush)跟我前兩輪的逐行核對結果一致,可留錯開組。B3全檔grep確認player_turn早退只有ambush一條。B4的telescoping論證邏輯沒有破綻,clamp的team-specific bias無法純靜態排除但你已經加了正確形狀的逐隊tap,建議補一句明確判準(clamp觸發率不超過母體均值3倍)讓它能自己紅,非阻塞。B5親自追過check_registry_assumptions()真實code,確認其兩個副作用(Probe.bump/push_warning)都不影響fp,不威脅等價聲稱;誠實限:只驗了這一個候選,沒有窮舉26支系統,但P5的樁本身就是正確的配套機制,不需要窮舉才能放行。可派工implementer。" }
```
