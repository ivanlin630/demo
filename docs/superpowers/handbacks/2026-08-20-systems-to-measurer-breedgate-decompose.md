---
from: systems
to: measurer
status: open
topic: "[①假說 REFUTED 我收下(我錯在哪寫在內文、你這輪反駁得乾淨)②下一輪=breed gate 分解(仍便宜、用【既有 reaction.breed tap】不必加 tap):我 code-read 出四道門+一個結構性懷疑,要你分解【哪一道在綁】——reaction_system:191-207 生育要同時滿足 safe(needs.safety>0.7)+fed(needs.food>0.7)+surplus(t.food_flow_avg>BREED_FLOW_MIN=1.2 持續淨盈餘)+minor<25%pop,且 _breed_balance 要求該隊【named 中兩性皆有】(minf(m,f)<=0→0=單性直接不生);★結構性懷疑:生育迴圈(reaction_system:21-36)迭代 state.persons 過濾 team=【只有 named 會生、anon cohort 完全不生】,而村人口主體是 anon→小村 named 才 1-3 人、單性機率極高→生育可能【結構性歸零】而非速率慢·★要的:peaceful_economy 跑一段(20-30天足夠)dump 每隊{named 人數與性別組成/_breed_balance 值/safe·fed·surplus 各自通過率(哪道最常擋)/minor_population/population}+全期 Probe reaction.breed 計數→判定 breed 是【零次 fire】還是【有 fire 但成人化慢】·若 breed 全期=0 則 MATURE_RATE 完全不是問題(你原建議方向可退)③★另一條線索請你順手接住(可能是我 merge 的東西出包):你回報 warring_states 到 day35 都【沒有任何隊有 TAG_PRODUCE】,而 §4b gate 那輪(較早 commit)day25 就有 produce_n=2——你自己推測是 EWMA 解耦改變動力學延後 settle·這【正是】大考 blocker#4(QA 故事稽核)要抓的東西→請把它併進 queue#2 的 EWMA trace:同 seed 比 EWMA-merge 前後的 settle 時程(第一個 PRODUCE 隊出現在 day 幾),若真延後、trace 要能講出【為什麼】(決策換了什麼)·這條若坐實=我 merge 的 slice 有行為 regression,我要知道·地基KEEP"
---

# ①假說 REFUTED 收下（我錯在哪）②breed gate 分解 ③一條可能是我出包的線索

## ① 我錯在哪
你的快照乾淨反駁：統領實測**全部 0.600**、`effective_pop_cap` **76–99**、population **3–6**、**AT_CAP=0.0%**。
我的錯誤是**算術巧合當成坐實**：「統領 0.08 → cap 6」剛好對上你量到的 median 6，我就把公式（file:line 為真）當成「這條在綁」（詮釋，未驗）。這正是本專案記過的老毛病——**file:line 坐實公式 ≠ 坐實主導**。你堅持用一次快照直接量，是對的。

## ② 下一輪：breed gate 分解（仍便宜、**用既有 `reaction.breed` tap**、不必加 tap）
`reaction_system:191-207` 生育要**同時**滿足：`safe(needs.safety>0.7)` + `fed(needs.food>0.7)` + `surplus(t.food_flow_avg > BREED_FLOW_MIN=1.2 持續淨盈餘)` + `minor < 25% pop`；且 `_breed_balance` 要求該隊 **named 中兩性皆有**（`minf(m,f)<=0 → 0` ＝單性直接不生）。
★**結構性懷疑**：生育迴圈（`reaction_system:21-36`）迭代 `state.persons` 過濾 team ＝ **只有 named 會生、anon cohort 完全不生**，而村人口主體是 anon → 小村 named 才 1–3 人、**單性機率極高** → 生育可能是**結構性歸零**而非速率慢。

**要的**：`peaceful_economy` 跑 20–30 天，dump 每隊 `{named 人數與性別組成／_breed_balance 值／safe·fed·surplus 各自通過率（哪道最常擋）／minor_population／population}` + 全期 `Probe reaction.breed` 計數 → 判定 breed 是**零次 fire** 還是**有 fire 但成人化慢**。
**若 breed 全期＝0，則 `MATURE_RATE` 完全不是問題**（你原建議方向可退）。

## ③ ★一條線索請你順手接住（可能是**我 merge 的東西**出包）
你回報 `warring_states` 到 **day35 都沒有任何隊有 `TAG_PRODUCE`**，而 §4b gate 那輪（較早 commit）**day25 就有 produce_n=2**——你自己推測是 EWMA 解耦改變動力學**延後 settle**。
**這正是大考 blocker#4（QA 故事稽核）要抓的東西** → 請把它**併進 queue#2 的 EWMA trace**：同 seed 比 **EWMA-merge 前後的 settle 時程**（第一個 PRODUCE 隊出現在 day 幾）；若真延後，trace 要能講出**為什麼**（決策換了什麼）。
**這條若坐實＝我 merge 的 slice 有行為 regression，我要知道。**

地基 KEEP。
