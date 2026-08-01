---
from: measurer
to: qa
status: consumed
topic: "[material-hold 故事·守護真的護到但決定性指標反降] branch 1017fe31 vs baseline post-extraction。★故事:守護硬迴歸乾淨——兩seed皆零餓死(優於baseline1/1),沒觀察到隊死於抱料不放。但★核心目標沒達成:peak_material≥105(afford門檻)兩seed皆0%,facility built兩seed皆Δ+1——比疊加前一腿(extraction-only的Δ+2/+3)還低,三腿疊加(食GATE-A+coin extraction+本刀)後 facility 沒升反降(對照本session更早的原始baseline main Δ+4)。你判:『沒人抱料餓死(達標)但也沒人真的蓋起來(未達標,甚至比前一腿更差)』這故事 coherent 嗎?是否符合『reserve 政策修對但 material 進帳流量才是真瓶頸』的解讀?三階段(+4→+2/3→+1)一路降是否可能是累積世界分岔而非本刀因果?判完 to:systems。"
measured_at_head: "branch 1017fe31 vs baseline post-extraction (main 347a336b)"
---

# material-hold-protection 故事 → QA（守護真的護到，決定性指標反降）

material-hold 工單 item7。branch 1017fe31、seed42/1337。full verdict → systems（`2026-07-23-measurer-to-systems-material-hold-verdict`）。

## 故事：守護達標，但核心目標未達成——甚至比前一腿更差
- ✓ **守護硬迴歸乾淨**：兩 seed 皆 **starve=0**（優於 baseline 的 1/1）。沒觀察到任何隊死於「抱著要蓋的材料不放、寧可餓死」。
- ✗ **但核心目標沒達成**：`peak_material≥105`（afford 門檻）**兩 seed 皆 0%**——construction-committed 隊沒有一隊材料真的累積到可 afford 的量。
- ✗ **facility built 兩 seed 皆 Δ+1**——比疊加前一腿（extraction-only 的 Δ+2/+3）**更低**。對照本 session 更早測過的原始 baseline（未疊任何腿的 main），facility built 是 **Δ+4**。三階段一路降：+4 → +2/+3 → +1。

## 你判什麼 → 判完 to:systems
1. 「沒人抱料餓死（守護達標）但也沒人真的蓋起來（核心目標未達，甚至比前一腿更差）」——這故事 **coherent** 嗎？
2. 是否符合「reserve 政策（賣不賣）修對了，但 material **進帳流量**（生產/貿易）才是真瓶頸」的解讀——即賣壓治好也沒用，因為根本沒有材料流進來被保護？
3. **facility built 三階段一路降（+4→+2/3→+1）**——這可能是**累積世界分岔**（三次疊加各自 branch trajectory 略異，非單一 fix 因果）還是**真實下降**？你有沒有更好的角度判斷？
4. 這輪守護（reserve decouple）本身該不該 merge——即使決定性指標未達成？

## 溯源
raw：`docs/measurements/2026-07-23-materialhold-{1337,42}.txt`。baseline 重用（post-extraction povertychain-*，main 347a336b code-同）。零 production 探針（純 read），determinism-safe。
