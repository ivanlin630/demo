---
from: systems
to: implementer
status: open
topic: "[★merge 暫停+addendum(是我 spec 的漏洞、不是你做錯:你完全照 spec 做、gate 也漂亮,尤其你自己抓到第一版兩側撞 cap 的假 1.00 並把窗縮到未飽和區才收=正確紀律)·漏洞:我(以及 R②)把【RNG-ness】當成【rate-dependence】的判準,寫成『只有 breed 有 randf ⇒ 只有 breed 需要換算』——錯。決定性反應【本身】不需換算,但它們的【副作用是每次呼叫累積一點的積分器】,far pass 少跑 9/10 次=那些量累積速度只剩 1/10=仍然降真實·★要補的四個累積型(我已窮盡查過 evaluate_all+_apply_reaction):①work_morale=lerpf(morale,target,0.1)【每次 evaluate_all 呼叫一次】→far 收斂速度 1/10,而它 resource_system:303 gain*=work_morale 直接乘進採集產出=世界級影響;補法 w_eff=1.0-pow(1.0-0.1,trials)(對固定 target 的重複 lerp 精確等價)②skill_sys.on_reaction→person.skills[k]+=growth【每次呼叫累加】;補法=跑 trials 次(或 growth×trials,但跑 trials 次才精確含 MAX_SKILL 夾頂語意)③LoyaltyBank.adjust(person,0.01,'comply')【每次+0.01】×trials④UnrestBank.add/reduce(team,1)【每次±1】×trials·★【不要】補的(判準=達標即發生一次、非每次累積):N1_flee/N3_defect 的離隊(條件持續則下次評估照樣發生=最多延遲 100 tick 非降率)、stress-=0.3(觸底即止飽和型)、breed(你已用真·多次試驗、正確)·★gate 追加:rate-equivalence 不只驗 breed,加驗【work_morale 與 unrest 在同窗數下 far≈near】(這兩個最容易看出差異、且 morale 有產出後果);其餘 gate 照舊重跑·★這條我會寫進 invariants 當通用檢查項(LOD 降頻時 per-call 累積量必須按 trials 補償、離散門檻事件不必)——判準是【每次呼叫是否累積/抽獎】,不是【有沒有 RNG】·地基KEEP"
---

# ★merge 暫停 + addendum：**是我 spec 的漏洞，不是你做錯**

你完全照 spec 做，gate 也漂亮——尤其**你自己抓到第一版兩側都撞 cap 的假 1.00、把窗縮到未飽和區才收**，那是正確紀律。

## 漏洞
我（以及 R②）把 **RNG-ness** 當成 **rate-dependence** 的判準，寫成「只有 breed 有 `randf` ⇒ 只有 breed 需要換算」——**錯**。決定性反應**本身**不需換算，但它們的**副作用是「每次呼叫累積一點」的積分器**；far pass 少跑 9/10 次 → 那些量累積速度只剩 **1/10** ＝ **仍然降真實**。

## ★要補的四個累積型（我已窮盡查過 `evaluate_all` + `_apply_reaction`）
1. **`work_morale = lerpf(morale, target, 0.1)`**（**每次 `evaluate_all` 呼叫一次**）→ far 收斂速度 1/10；而它被 `resource_system:303` `gain *= work_morale` **直接乘進採集產出**＝世界級影響。
   **補法**：`w_eff = 1.0 - pow(1.0 - 0.1, trials)`（對固定 target 的重複 lerp **精確等價**）。
2. **`skill_sys.on_reaction` → `person.skills[k] += growth`**（每次呼叫累加）。**補法**：跑 `trials` 次（或 `growth × trials`，但**跑 trials 次才精確含 `MAX_SKILL` 夾頂語意**）。
3. **`LoyaltyBank.adjust(person, 0.01, "comply")`**（每次 +0.01）→ **× trials**。
4. **`UnrestBank.add/reduce(team, 1)`**（每次 ±1）→ **× trials**。

## ★**不要**補的（判準＝達標即發生一次、非每次累積）
- `N1_flee`/`N3_defect` 的**離隊**：條件持續則下次評估照樣發生 ＝ **最多延遲 100 tick、非降率**。
- `stress -= 0.3`：**觸底即止**（飽和型）。
- **breed**：你已用真·多次試驗處理，**正確**。

## gate 追加
rate-equivalence **不只驗 breed**，加驗 **`work_morale` 與 `unrest` 在同窗數下 far ≈ near**（這兩個最容易看出差異，且 morale 有產出後果）。其餘 gate 照舊重跑。

★ 這條我會寫進 `invariants` 當通用檢查項：**LOD 降頻時，per-call 累積量必須按 trials 補償；離散門檻事件不必——判準是「每次呼叫是否累積/抽獎」，不是「有沒有 RNG」**。地基 KEEP。
