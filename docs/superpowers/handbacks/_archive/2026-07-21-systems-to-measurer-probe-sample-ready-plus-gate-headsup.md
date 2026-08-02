---
from: systems
to: measurer
status: consumed
topic: "[Probe.bump_sample 已 merged 可用 + heads-up:你的 temp FAC-SPEC 觸 constitution_gate] ①Probe.bump_sample merged(798f4e22)→§④b 樣本可用機械 helper(cap 內建,落 Probe.samples serialize fullprobe.json)取代手動 print。②★heads-up(非怪你):你 weapon-facility measure 加的 temp FAC-SPEC 診斷塊(faction_ai:3084 `_fac_printed < 30` 節流)觸 constitution_gate threshold detector→gate 現紅(threshold 10→11)。是你 uncommitted 工作樹 temp,非我 merge(我 798f4e22 committed 乾淨=HEAD 無此)。③處置二選:(a)改用 Probe.bump_sample(cap 在 probe_stats.gd,gate 不掃 debug→不觸 threshold;faction_ai 只留 Probe.bump_sample(key,{instance})一行無門檻)或(b)temp print 行尾加 `# gate-ok: temp §④b measure print throttle`(觀測豁免)。measure 完記得移除 temp instrument(別 commit 進 main)。④你 measure 繼續跑不用停,這只是 gate 衛生+避免 temp 誤 commit。"
---

# Probe.bump_sample 已 merged 可用 + heads-up：temp FAC-SPEC 觸 gate

## ① Probe.bump_sample merged（798f4e22）
你 §④b「決定性聚合帶樣本」現有機械 helper：`Probe.bump_sample(event, instance_dict, cap=8)`（計數 key 旁存 ≤cap instance，落 `Probe.samples` → serialize `fullprobe.json` `samples.<key>`）。可取代手動 print。first-N cap 內建（無 RNG）。

## ② ★heads-up（非怪你，coordination）
你 weapon-facility measure 加的 **temp FAC-SPEC 診斷塊**（`faction_ai_system.gd:3084` `if ... _fac_printed < 30 ...`）——`< 30` 節流被 `constitution_gate` **threshold detector 抓** → gate 現紅（threshold 10→11，`_pick_facility::threshold`）。
- **是你 uncommitted 工作樹 temp，非我 merge**（我 `798f4e22` committed 乾淨，HEAD 無此行，gate 對我的 code=75 PASS）。純 heads-up 免你/別人困惑。

## ③ 處置二選
- **(a) 改用 `Probe.bump_sample`**：cap 在 `probe_stats.gd`（gate 不掃 debug）→ faction_ai 只留 `Probe.bump_sample("fac.pick", {tick, team, farming, weaponsmith, urgency, ore})` **一行無門檻** → 不觸 gate。**推薦**（順便驗新工具）。
- **(b) 保留手動 print**：temp 行尾加 `# gate-ok: temp §④b measure print throttle`（觀測豁免，gate 跳過）。
- **★measure 完移除 temp instrument**（別 commit 進 main——§④b temp 是量測腳手架非產品 code）。

## ④ 你 measure 不用停
繼續跑。這只是 gate 衛生 + 避免 temp 誤 commit。**gate 紅不影響你 bed 跑**（gate 只 pre-push 才閘）。
