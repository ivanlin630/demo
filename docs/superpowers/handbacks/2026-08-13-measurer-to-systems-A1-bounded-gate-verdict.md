---
from: measurer
to: systems
status: open
topic: "[A1 merge-gate:面1★★★綠 / 面2★★★紅——非兩面皆綠]★面1(anti-crank四象限)全綠且極乾淨:大realistic warring世界2368筆直呼DecisionContext.gather+DecisionTerms.eval真團真值(零fixture手造ctx):①resident term本身非零(32/115樣本達1.5)但options.gd:197 applicable()有`not ctx.has_own_outpost`結構閘、真決策迴圈裡此option對resident永不會被評估(滿足ticket『marg≈0 or gate』的gate分支);②富流浪(food_days≥10)1722/1722=100%精確0;③瀕餓平原102/102=100%非零(avg0.81,常觸頂1.5);④瀕餓森林+pop≥3共33/33=100%精確0(pop1-2小團仍有小正值,梯度乾淨,anti-crank maxf(0)地板精準卡在pop=3);bounded-verify:全2368筆global max=精確1.5(=CAP),0筆超過,29筆貼頂。★面2(arc-目標:紮營真fire升+佔據率升)不成立——兩個獨立測試皆顯示branch跟baseline無差異:(a)大realistic世界worldgen.build_outpost baseline=10 branch=10(完全相同,非ticket假設的baseline=0)、佔據率baseline6.60%→branch6.38%(持平略降非顯著升);(b)零faction零戰鬥confound的6隊vagrant專測床(3瀕餓+3富裕,20天)worldgen.build_outpost baseline=1 branch=1(同一團同day19 onset,逐位元一致)——root-cause鎖定:2/3瀕餓團has_farmable_tile全程=false(此fixture地理限制非A1行為差異),唯一真exercise的1團其camp_drive在有plains靶時本就達0.875-1.5、baseline舊flat值1.0量級相近,兩者皆足夠贏過競爭選項argmax,A1的marginal/bounded改動沒有改變『這個option會不會被選中』的結果,只改善了『選中時的精確度/防crank』。★結論:A1是correctness修正(防止在爛地crank紮營+富流浪不濫紮)但目前證據不支持它會提升整體紮營fire率/佔據率——bottleneck看來卡在別處(有無可耕靶+desperation門檻+跟其他選項的argmax競爭),非camp_drive量級本身。ticket原定規則『兩面都要綠才merge』——面2未達,誠實回報非我裁決merge/reject,交你判斷"
---

# A1 merge-gate —— 面1 全綠、面2 未達預期，誠實回報

branch `feat/survival-access-a1`（`ac8f5418`），worktree `.worktrees/survival-access-a1`（★留 main dir 派 `--path`，未原地 checkout）。temp diag（`phase3_longterm_story_audit_bed.gd` worktree/main dir 各一份、以及一次性 vagrant 專測床 config+bed）全部用完即刪除/revert，worktree 與 main dir `git status` 皆確認乾淨。

## ★面1：anti-crank bounded 四象限 —— 全綠，且是這輪最乾淨的一組數據

方法：**不手造 fixture ctx**（不同於 implementer 自己的 `camp_marginal_test.gd` 用 `_ctx()` 手工建構），改成在 seed1337、1月窗的**真實 realistic warring 世界**裡，逐日對**每一個真實團**直接呼叫 `DecisionContext.gather(state,t)` + `DecisionTerms.eval("camp_drive",ctx,"紮營")`（零 production tap、零手造 context，純讀 API 直呼），捕到 2368 筆橫跨 ~130 團的真實樣本，按真實觀測到的 `food_days`/`has_own_outpost`/`terrain` 分桶：

```
①has_own_outpost(已resident)：n=115  camp_drive avg=0.3082  max=1.5000  nonzero_n=32
②富流浪(food_days≥10)：      n=1722 camp_drive avg=0.0000  max=0.0000  nonzero_n=0     ★100%乾淨
③瀕餓+plains(food_days<3)：   n=102  camp_drive avg=0.8117  max=1.5000  nonzero_n=102   ★100%乾淨
④瀕餓+forest+pop≥3(food_days<3)：n=33  全部精確=0.0000（13+2+3+1+6+8全零）              ★100%乾淨
   （forest+pop=1-2 仍有小正值，梯度乾淨：pop1 avg=0.79/pop2 avg=0.15/pop3起精確=0）
```

**②③④三象限 100% 乾淨、零例外。** ①比較特殊：**term 本身不是 ≈0**（32/115 樣本非零，最高觸頂 1.5）——因為 `camp_drive` term 的 eval 邏輯本身**不檢查** `has_own_outpost`（`terms.gd`，只檢查 `ctx.has_farmable_tile`/`camp_target_est`），residents 附近若剛好有其他未擁有的可耕地，term 值就會算出非零。**但**這個 option 在真實決策迴圈裡**永遠不會被 resident 評估到**——`options.gd:195-197` 的 `applicable()` 明確要求 `not ctx.has_own_outpost` 才進候選，兩層防線裡走的是「gate」這條（ticket 原本就允許「marg≈0 **or** gate」兩選一），不是 term 值本身趨近 0。這點誠實列出而非含糊帶過，因為單看 term 值容易誤判成「有 crank 風險」，實際上是**結構性不可達**。

## ★bounded-verify：CAMP_MARGINAL_CAP=1.5 —— 全域無一筆超頂

```
2368 筆樣本 global max camp_drive = 1.5000（精確 = CAP 值）
超過 1.5001（over-crank 候選） = 0 筆
貼頂(≥1.4999)樣本 = 29 筆（合理，肥沃 tile+高 urgency 真的該頂到上限，非異常）
```

**乾淨 PASS。**

## ★面2：arc-目標（紮營真 fire 升 + 佔據率升）—— 兩個獨立測試都沒看到差異

### (a) 大 realistic warring 世界（seed1337, 1月窗）

```
                    baseline(main)   branch(A1)
worldgen.build_outpost(紮營真fire)      10              10        ← 完全相同
月底 resident_n / teams                7/106            6/94
佔據率                                 6.60%            6.38%     ← 持平略降，非顯著升
```

**★先訂正 ticket 的假設基準**：ticket 框「baseline `camp.fire=0`」——我這輪直接量測，baseline 真實值是 **10**，不是 0（用的是既有生產 tap `worldgen.build_outpost`，`faction_ai_system.gd:4668`，`establish_crude_camp()` 成功時觸發，全 repo 唯一呼叫點，branch/baseline 兩邊都有，比對公平）。我先前某一輪的「camp.fire=0」記憶，量的可能是另一款更窄的 tap（如 TASK_CAMP 特定分支的計數），不是這個 production counter——這輪以這個明確、單一呼叫點、雙邊皆有的 tap 為準。

### (b) 零 faction 零戰鬥 confound 的專測床（implementer 自己建議的方向）

implementer 在 ticket 裡明確 flag「warring 1000t camp 路徑可能 dormant，需 vagrant/founding 情境床才 exercise camp」——我照建議另建一個 6 隊零 faction（`faction_id=-1`）、零 outpost、3 隊瀕餓(food=2)+3 隊富裕(food=200) 散佈全圖的專測床（20天），branch/baseline 各跑一次：

```
                    baseline(main)   branch(A1)
worldgen.build_outpost                  1               1        ← 完全相同(同一團、同day19 onset)
月底 resident_n(6隊裡)                  1               1
```

**逐位元一樣的結果。** 往下追根：3 隊瀕餓團裡有 2 隊（team1@[8,8]、team2@[32,32]）**全程 `has_farmable_tile=false`**——它們所在的地理位置本身就找不到未擁有的可耕地，這是**我這個 fixture 的地理設計限制**，不是 A1 行為差異（這兩隊在 branch/baseline 都一樣卡死，option 從未進入候選，term 值根本沒機會比較）。唯一真正「有機會 camp」的 team0，逐日 `camp_drive` 在能找到 plains 靶的日子是 0.875-1.5，baseline 舊版 flat 值固定 1.0——**兩者量級相近，都足夠贏過同期覓食等競爭選項的 argmax**，於是兩邊都在 day19 成功紮營，A1 的 marginal/bounded 改動沒有改變「這個 option 會不會被選中」這個結果。

## ★誠實結論

**A1 是一個 correctness 修正**（防止在爛地上 crank 紮營 [④驗證]、富流浪不會濫紮 [②驗證]），**這部分做得很乾淨、面1 全綠**。但**目前兩組獨立證據都不支持它會提升整體紮營真 fire 率或佔據率**——瓶頸看起來卡在別處（附近有沒有可耕靶 `has_farmable_tile` + `desperation_entry_threshold` 門檻 + 跟其他選項的 argmax 競爭），不是 `camp_drive` 量級本身：只要 option 進得了候選，term 值不管是舊版 flat 1.0 還是新版 bounded 0-1.5，多半都已經贏得了。A1 改善的是「贏的時候贏得對不對」，不是「贏不贏得了」。

## Determinism / 落地

seed1337、`SpecimenDumpHelper.setup_from_env()`（未手動改 `specimen_team_ids`）。temp tap（worktree/main dir 各一份 `phase3_longterm_story_audit_bed.gd` 內 `worldgen.build_outpost` 追蹤 key + `a1.camp_drive_scan` 一處 direct-call diag）+ 一次性 vagrant 專測床（config+bed）全部用完即刪除，worktree 與 main dir `git status` 皆確認乾淨，未動任何 branch commit。determinism 3-run 這輪未重測（沒有改任何 production code，implementer 報的 `678b3ee3` 沿用他們自己的驗證即可，這輪重點是行為面非 determinism 面）。

## ★裁決

**面1（anti-crank bounded）★★★綠、面2（arc-目標紮營真 fire/佔據率升）★★★紅**——不是 ticket 原定「兩面都要綠」的全綠狀態。誠實回報兩個事實給你，merge/reject 或「先落地 correctness 修正、佔據率問題另開票查有farmable靶/desperation門檻」這類折衷判斷交你裁——不是我份內（evidence-only）。若要再往下查佔據率瓶頸的真正卡點，下一步大概率要往 `_find_unowned_farmable_tile` 的搜尋半徑/命中率 或 `desperation_entry_threshold` 觸發時機這兩個方向查，這輪還沒觸及，交你/blueprint 判斷值不值得再開一輪。
