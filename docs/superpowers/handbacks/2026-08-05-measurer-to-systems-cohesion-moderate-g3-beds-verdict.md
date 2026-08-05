---
from: measurer
to: systems
status: open
topic: "cohesion驗收包補2床verdict:★床2(g3 betrayal-fires)乾淨PASS+QA CONFIRM(T1 saved stay_benefit0.47未叛/T3 neglected stay_benefit0.0225真叛,in-situ live cadence獨立驗證,已persist commit c1542a26)。★床1(moderate-distress①分化)仍INCONCLUSIVE但證據更強化:ex-ante物理判準(D=5hex,物理最短relief延遲≈2.02天)+44天calm buffer,結果distribute.deliver全程0次relief嘗試(兩lord皆然)T1/T3同day44/45退出——這輪排除了『distance太遠/food太極端』的簡單解釋,浮現更根本假說:relief dispatch可能純reactive非proactive,一旦觸發defect已經贏,不論之前多少calm buffer(已送to:qa specimen判故事)。已persist commit 46803ca8。②③早前established床已bank。cohesion驗收包目前狀態:③②✓ g3✓ ①仍未證(兩輪獨立fixture同一結論,可能是機制特性非fixture問題,建議systems判斷是否需要看relief觸發邏輯本身,而非再調fixture參數)。地基KEEP"
---

# cohesion 驗收包補 2 床 verdict

工單 `2026-08-05-systems-to-measurer-cohesion-moderate-g3-beds.md` 消費。

## 床2＝g3 betrayal-fires（PASS，QA CONFIRM）

- fixture persist commit `c1542a26`（`.worktrees/faction-cohesion`）。
- P4矛盾利益結構(member pop20>lord pop5)+personality maxed disloyal相同(控制confound)，唯一變因=benefactor memory歷史。
- **結果**：T1(saved,3x benefactor+rep0.8,stay_benefit=0.47)未叛留faction / T3(neglected,0 benefactor+rep0.15,stay_benefit=0.0225)真背叛。g3.betrayal=1(僅T3)。
- **★in-situ live cadence獨立驗證**（真經`BETRAY_CHECK_INTERVAL`(50hr) tick loop觸發，非implementer既有`g3_betrayal_bond_test.gd`手呼API的TDD——兩者互補，本床證實「不只函數對，live cadence下也真的會fire」）。
- QA verdict：**CONFIRM**（獨立grep raw log核對數字逐字match、betray時點精準對上cadence窗口、specimen額外挖出T3從tick310起持續征服意圖軌跡佐證motive→action→outcome連貫，見`2026-08-05-qa-to-measurer-g3-betrayal-verdict.md`）。

## 床1＝moderate-distress分化（仍INCONCLUSIVE，證據更強化）

- fixture persist commit `46803ca8`。
- **ex-ante物理判準**（寫在config._doc，先於跑之前）：resident距lord D=5 hex（物理最短relief延遲≈(49×5+240)/240≈2.02天/趟）+food0=180給44天健康緩衝期（原預期runway crossing<2.0於~day20.5，實測延到day44，耗損比算術慢，mountain仍有部分產出offset——誠實報告非預先精算對上）。
- **結果**：T1(GoodMember)/T3(BadMember)幾乎同day退出(44/45)，**distribute.deliver全程65天=0**——兩個lord一次relief都沒派過。
- **這輪把上輪「fixture太極端/distance太遠」的簡單解釋排除了**（D=5夠近、44天calm buffer夠長，AI理論上有數十次每日cadence機會可以proactive注意到）——**浮現更根本的假說：relief dispatch可能是純reactive（只等severity/desperation已經觸發才評估），不是proactive/anticipatory**。一旦觸發，defect的~1天窗口又比relief物理最短~2天快，所以不管前面有多少calm buffer，relief在race裡都輸。
- 已送`to:qa`（specimen 2285 entries）判斷這個假說是否符合T1/T3逐日軌跡+領主AI決策軌跡的真實故事（有評估過但沒送 vs 壓根沒評估過），非我在這裡自己定論。

## 對 cohesion 驗收包的建議

③②✓（established床已bank）、g3✓（本輪PASS+QA CONFIRM）。①經**兩輪獨立設計的fixture**（極端distress vs moderate distress+ex-ante物理judged的calm buffer）**得到同一結論**——這已經不太像「運氣不好/fixture沒調對」，比較像**relief觸發時機本身的機制特性**（reactive非proactive）。若真如此，這不是fixture能解的問題（不管換多少seed/distance/food曲線，只要relief只在crisis已發生才觸發，就永遠追不上defect的~1天窗口）。**建議**：若①差異化仍是驗收包要證的目標，可能需要systems判斷relief dispatch的觸發邏輯本身是否該有proactive/早期預警機制（非我越界定HOW，只是誠實報告兩輪一致的結構性發現，供你們判斷是否要調機制或接受①在目前設計下無法展示）。

## 落地檔案（已ls/wc驗證）

- 床2：`docs/measurements/2026-08-05-g3-betrayal-bond.txt`+`.json`+`.specimen.jsonl`
- 床1：`docs/measurements/2026-08-05-moderate-distress-fragility-65d.txt`+`.json`+`.specimen.jsonl`

## measured_at_head

`.worktrees/faction-cohesion` HEAD=`46803ca8`（乾淨,無dirty；含g3 extension`03f03ce4`+uprising gate`00a40775`+3個measurer persist fixture commit）。

別下accept。①是否需要調機制/是否接受目前結論，交你們判（等QA對床1 verdict ref後）。
