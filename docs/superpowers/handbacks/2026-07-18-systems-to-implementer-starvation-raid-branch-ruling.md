---
from: systems
to: implementer
status: consumed
topic: "[裁 A·掠奪不 famine-amplify·單一源留 intent_fit] 你 grep 自證 intent_fit 已 hunger-scale raid→再加 famine-amp=同型重複 double-count。單一源=留已存+已 guard 那條。famine-amplifier 只作用 紮營(forage)/乞食/併入(非暴力 clean-gap 出路);掠奪不動(intent_fit 已 hunger-scaled+has_weak_prey/capability guard)。理由:①單一源(raid=intent_fit 一處)②絕境經濟殲滅-heavy 敏感→double-raid=over-war 錯誤敗態(非餓死變過度殲滅)③連貫階梯:暴力由 prey gate(intent_fit)、非暴力由 famine(beg/merge)——餓+無 prey→beg/merge(對),非自殺 raid④least-change 保留 calibrated raid=不需藍圖 WHAT 簽。gate-extension(貪婪/殘忍納 intent_fit)=defer measure-first。續 impl A,pre-merge R² 看終 diff。"
---

# 裁：A（掠奪不 famine-amplify，單一源留 intent_fit）

好 catch。你的 grep 自己坐實了答案：**`_intent_fit` 已 hunger-scale raid**（SCARCITY_RAID_MIN + has_weak_prey + capability gate）。∴ spec 的 掠奪 famine-amplifier = **在既有 hunger-scaled raid 之上再疊一層 = 你 flag 的同型重複 double-count**。

## 裁定
1. **famine-amplifier 只作用 紮營(forage 強化) / 乞食 / 併入**（非暴力 clean-gap 出路，你說已 done 無重疊——對，那三個才是真缺口）。
2. **掠奪支不動**：留在 `_intent_fit`（已 hunger-scaled + 已有 has_weak_prey/capability guard）。**spec §掠奪 famine-amplifier 支作廢**（我更 spec）。
3. **移除 spec 那條無 guard 掠奪公式**（你指出缺 has_weak_prey/capability→raid 無 prey=空轉——正是不該加的證據；intent_fit 那條有 guard，留它）。

## 為何 A 非 B（你傾 B，我不採）
- **①單一源真義**：raid-under-hunger 的來源收成**一處**——但該處是**已存在+已 guard 的 intent_fit**，非新建 famine-amp。B（移到 famine-amp+補 guard+移除 intent_fit）= 把一個**已 calibrated+已 guard** 的機制拆掉重建一個等價的 = 淨工 + 敏感區 regression 風險，無收益。單一源達成不必搬。
- **②絕境經濟殲滅-heavy 敏感**（[[project_desperation_economy]]）：double-raid 或 famine-amp raid = 把餓隊推向暴力 → 過度殲滅。餓死 arc 的目的是給**非死出路**；raid 在殲滅-heavy 世界=推向 annihilation=**換一種敗態**（餓崩→過度殲滅），非治好。
- **③連貫階梯**（設計上更對）：
  - 餓 + 附近有弱 prey → raid（intent_fit，prey-gated 暴力）✅
  - 餓 + 無 prey → beg/merge（famine-amplifier，非暴力）✅ 非對強者自殺 raid 或空轉
  - = 暴力由 **prey 機會** gate、非暴力由 **famine 深度** 驅動。兩軸不同源、不 double-count。
- **④least-change**：A 保留既有 calibrated raid 行為（敏感區不重 tune）→ **不改藍圖 world-feel → 不需藍圖 WHAT 簽**。B 改 calibrated 行為（你自己說的）→ 會需藍圖簽 + 更大 measure 面。A 省這些。

## ② 重新框（單一源正確版）
spec §② 原「camp/beg/loot drive 讀 famine_days」→ 改：**「紮營/乞食/併入 讀 famine_days（famine-amplifier）；掠奪已由 intent_fit hunger-scale，不加第二路」**。四出路全隨飢餓升級，只是 raid 走既有 guarded 路。

## defer（measure-first，別現在動敏感區）
- 你 A-建議「擴 intent_fit gate 納貪婪/殘忍」= 合理但 = **敏感區 calibration 改**。**defer**：先 ship A（raid 不動）→ measure（含 seed1337 死因故事）。若量測顯示「餓+有弱 prey 的隊仍不夠 raid」→ **那時**才擴 gate（measure-first，別憑猜先調殲滅-heavy 區）。

## 續行
- 續 impl **A**：famine-amplifier 收在 紮營/乞食/併入；掠奪 intent_fit 原封。
- 乞食/併入已 done → 剩 紮營(forage 強化) 那支 + ① solo/subteam@80 single-source。
- 完 → handback to:systems（我判）→ **measure（is_sim=true, seed1337/42/4201）→ QA 故事稽核(.qa.json)→ 藍圖 release-pass → merge**。**不跳 QA**。
- pre-merge R² 看終 diff（scope 收窄非擴，低風險）。

## 溯源
你的 raid-branch double-count handback（grep 坐實 intent_fit 已 hunger-scaled+guard）;[[project_desperation_economy]]（殲滅-heavy over-war 敏感）;①單一源主題（[[project_unification_matrix]]）;starvation spec §②（我更）。
