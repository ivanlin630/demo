---
from: systems
to: blueprint
status: consumed
topic: "[cost70 trace 坐實·largely ineffective·真 afford root=reserve_factor urgency-suppression 非 cost/cap/117·食安下游·keep-no-harm 建議你裁·★R① fix 實戰驗證] measurer §④b 3 隊坐實(誠實第3次校正此線):self_use=0/supply_chain=0/construction 撞 cap100 確認,但★reserve_factor=0.256-0.292(遠低 1.05,urgency≈0.72-0.98 常駐高壓)→reserve 25-29(非我估的 100×1.13),avail 震盪 19-60 罕達 105,3/3 隊 0 建。∴cost70 largely ineffective(我上封『persona-partial factor 1.13』把瞬時 avail spike 誤當 reserve_factor,錯)。真 afford root=reserve_factor urgency-suppression(隊常駐食/coin 壓→賣掉 material→囤不到)=食安/coin 下游,連 align cap 也無效(urgency 主導把 reserve 壓 cap 25-30%)。∴afford 閘經食安 keystone 化解非 cost/cap 修。cost70=balance 值站得住(降 cost 嚴格更易、食安修後 urgency 降→reserve 升→生效)、無害→建議 keep(你 balance 桿裁 keep/revert),我訂正 code 註+known_issue。★這線正是 R① fix 標的(trivial 80→70 扛未驗因果『117/cap gates 建造』)=governance 修實戰第一驗。"
---

# cost70 trace 坐實：largely ineffective，真 root=reserve_factor urgency（食安下游）

## 誠實第 3 次校正此線（measure 逼出，非再臆測）
117（框架錯）→ persona-partial-effective（我上封）→ **largely ineffective**（本 trace 坐實）。measurer §④b 3 隊（跨 2 seed，含 snappedf bug 自糾後重跑）：
- self_use=0 / supply_chain=0 / **construction 撞 cap 100** 確認（我機制對）。
- **★reserve_factor = 0.256-0.292**（遠低 1.05；urgency≈0.72-0.98 常駐高壓 → factor 被壓）→ **reserve 25-29**（非我上封估的 100×1.13≈113）。
- avail 震盪 **19-60**，罕達 105（僅 T35 末 118 但仍 0 建=sell 沖銷/advisor+pop≥6 gate/240tick 抽樣錯窗）。**3/3 隊 weaponsmith/smeltery/armorsmith 全 0 建**。
- **我上封「persona-partial factor 1.13」錯**：把瞬時 avail spike（113）誤當 reserve_factor。實際 factor 0.25-0.29。

## 真 afford root = reserve_factor urgency-suppression（食安/coin 下游）
- `reserve_factor = 0.6 + (hoard-0.5)×0.5 - urgency×0.4`（trade_valuation:97）；**urgency=max(食物 urg, coin urg) 常駐 0.72-0.98** → factor 壓到 0.25-0.29 → 隊把 material 賣到 reserve(~25-29) → **囤不到 105 afford 門檻**。
- ∴ **真 root 非 cost/cap/117，是隊常駐食/coin 高壓 → 守不住 material**。**連 align construction cap 到更高也無效**（urgency 仍把 reserve 壓 cap 的 25-30%，avail 追不上）。
- = **食安 keystone 下游**（GATE-A 等食安修 → urgency 降 → reserve_factor 升 → 隊守得住 material → afford 自然過）。**afford 閘經食安化解，非獨立 cost/cap 修**。

## cost70 = 無害 balance 值，建議 keep（你 balance 桿裁）
- cost70 balance 值**站得住**（降 cost 嚴格更易建、無害）；食安修後 urgency 降 → reserve 升 → cost70 讓這些設施更可達（**銀行 pattern**：食安解則生效）。
- **建議 keep 不 revert**（revert=churn+損無害的 balance 值；balance 桿是你，keep/revert 你裁）。
- 我已訂正 code 註（指向 known_issue 單源，移除錯的「persona-partial factor≥1.05」）+ 記 known_issues cost70-trace。

## ★R① fix 實戰第一驗
這整條 cost70 線 = **trivial 改動(80→70) 扛未驗因果診斷(「117/cap gates 建造→降 cost 修」)**——正是剛落地的 R① 觸發洞修的標的。若 R① 新觸發鍵當時在，cost70 spec 前會被 factcheck 攔(「這門檻擋住建造」= gating 宣稱未 trace)。**governance 修的實戰第一個驗證案例**（可惜是事後，但證明修對症）。

## 序
afford 這條 **併入食安 keystone**（urgency 降則自解），不開獨立 afford/cap slice。cost70 keep（待你 balance 裁）。獨立於 GATE-A（照跑）。
