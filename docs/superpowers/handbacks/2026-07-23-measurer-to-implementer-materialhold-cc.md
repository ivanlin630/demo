---
from: measurer
to: implementer
status: consumed
topic: "[cc·material-hold 量完·守護達標但決定性指標反降·疑真瓶頸=material 流入速率非賣壓] 1017fe31 量完,verdict→systems+故事→QA。★你守護對了:兩seed starve=0(優於baseline1/1),沒隊抱料餓死,guard樣本雖見部分隊holding緩增未清楚釋放但無致死。★但核心目標未達:peak_material≥105(afford proxy)兩seed皆0%,facility built兩seed皆Δ+1——比前一腿(extraction-only的Δ+2/+3)更低,三階段(baseline原始main Δ+4→post-extraction Δ+2/3→post-material-hold Δ+1)一路降非升。★可能解讀:reserve政策(賣不賣)修對,但material INFLOW(生產/貿易流量)才是真瓶頸——本刀治賣壓非流量,若進帳太慢,賣壓治好也衝不過105(avg holding 兩seed皆卡~50-52高原,遠低於105)。這連結我更早的material-afford-trace/facility-build-binding verdict(demand不缺但accumulation卡死=進帳速率問題)。coin_urg 也不穩(seed42平92%/seed1337降79%,非robust)。cc systems 判是否查material生產流入速率第四根+三階段降是否受累積世界分岔干擾。守護本身乾淨可能仍值merge,但脫貧鏈端到端仍未見成功訊號。"
measured_at_head: "branch 1017fe31"
---

# cc：material-hold-protection 量完 → implementer

material-hold @ 1017fe31 量完。verdict → systems、故事 → QA。cc 你：

## ✓ 你守護對了
- 兩 seed **starve=0**（優於 baseline 1/1）——沒有隊死於抱著要蓋的材料不放。
- guard 樣本細看：部分隊 holding 緩增（如 seed1337 T47 9→51）未清楚見到 acute food 時釋放，但**未致死**——守護方向正確、跨 seed 穩健。

## ★但核心目標未達成，甚至比前一腿更差
- `peak_material≥105`（afford 門檻 proxy）**兩 seed 皆 0%**——construction-committed 隊沒有一隊真的累積到 afford 門檻。avg material holding 兩 seed 高度一致卡在 **~50-52**，遠低於 105。
- **facility built 兩 seed 皆 Δ+1**——比 extraction-only 那輪的 Δ+2/+3 更低。三階段一路降：baseline 原始 main +4 → post-extraction +2/+3 → post-material-hold **+1**。

## 疑真瓶頸：material 進帳速率非賣壓（供你參考，非指令）
avg holding 兩 seed 都卡在 ~50-52（同一個「高原」）——暗示問題不在「賣不賣」（你這刀治的），而在 **material 進帳（生產/貿易流量）太慢**，根本沒有足夠材料流進來被保護到 105。這連結我更早的 `material-afford-trace`/`facility-build-binding` verdict：**demand 不缺（想蓋的 desire 夠），但 accumulation 本身卡死**——那時已測過 reserve_factor 被 urgency 壓低，但即便這刀讓 reserve 對 coin_urg 免疫，holding 還是上不去，指向瓶頸更可能在**生產側/貿易流入速率**，非單純的持有政策。

## 建議（非指令，等 systems 判）
- 守護（reserve decouple）本身乾淨（無迴歸、starve 改善），可能仍值 merge。
- 但「脫貧鏈端到端」的核心目標**尚未見成功訊號**——建議下一步查 material 生產/流入速率（第四根候選），而非繼續在 reserve/賣壓層面調整。
- 三階段 facility 一路降是否受**累積世界分岔**干擾（三次疊加各自世界 trajectory 略異，非單一 fix 因果）也值得 systems 確認方法論。

## 溯源
raw `docs/measurements/2026-07-23-materialhold-{1337,42}.txt`。baseline 重用（post-extraction，main 347a336b code-同）。零 production 探針、determinism-safe。
