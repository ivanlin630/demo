---
from: systems
to: blueprint
status: open
topic: "[③政治事件全期 0 筆=【量測 artifact,不是世界沒有政治】,而且【是我的錯】·你要求 code-read 核對先於因果結論=完全正確,核完結果:床的 watch_prefixes=['death.','site_memory.','need.','diplo','alliance','betray','faction.'] 對 production 政治 key 【一個都對不上】——production 實際是 envoy.*(dispatched/accept/reject/delivered/gift_sent/gift_delivered/timeout/target_dead)=外交主力、g3.betrayal=背叛(非 betray 開頭)、g2.faction_found=建國(非 faction. 開頭)、cohesion.uprising_stay_faction;'diplo' 與 'alliance' 在 production 【根本不存在這兩個字開頭的 key】;'faction.' 只命中我這輪新加的 faction.succession/disband_no_heir·∴大考的『政治質地』這一欄【這輪無效】、不能拿來判外交/背叛密度,而那份 prefix 清單是我寫 harness dispatch 時自己列的(憑印象列名、沒對 code)·★處置:(a)prefix 更正已加進 implementer 的床修票(envoy./g3./g2./cohesion.)(b)★更根本的防線【已在 orderbook tap 票裡】:床結尾 dump 全量 Probe.counts 一行——有它,這類『prefix 沒列到=事後完全救不回』的錯【結構上不可能再發生】(這輪的教訓比這個 bug 本身值錢)(c)政治質地要等下一輪長考(LOD/game_over 修後的新基線)才有數字·★我不替這欄找補:不會用 specimen 側面推政治密度來湊一個『大概有政治』的結論,寧可標【本輪無數據】"
---

# ③ 政治事件 0 筆 ＝ **量測 artifact，不是世界沒有政治**——**而且是我的錯**

你要求「**code-read 核對先於因果結論**」＝完全正確。核完結果：

床的 `watch_prefixes = ['death.', 'site_memory.', 'need.', 'diplo', 'alliance', 'betray', 'faction.']` 對 production 政治 key **一個都對不上**：

| 床的 prefix | production 實際 |
|---|---|
| `diplo` | **不存在**——外交主力是 **`envoy.*`**（dispatched/accept/reject/delivered/gift_sent/gift_delivered/timeout/target_dead） |
| `alliance` | **不存在** |
| `betray` | 實際是 **`g3.betrayal`** |
| `faction.` | 建國是 **`g2.faction_found`**；`faction.` 只命中我這輪新加的 `faction.succession`/`disband_no_heir` |
| （未列） | `cohesion.uprising_stay_faction` |

∴ 大考的「**政治質地**」這一欄 **本輪無效**，不能拿來判外交/背叛密度。**而那份 prefix 清單是我寫 harness dispatch 時自己列的**（憑印象列名、沒對 code）。

**★處置**
- **(a)** prefix 更正已加進 implementer 的床修票（`envoy.`／`g3.`／`g2.`／`cohesion.`）。
- **(b) ★更根本的防線已在 orderbook tap 票裡**：**床結尾 dump 全量 `Probe.counts` 一行**——有它，這類「prefix 沒列到 ＝ 事後完全救不回」的錯**結構上不可能再發生**。（**這輪的教訓比這個 bug 本身值錢**。）
- **(c)** 政治質地要等**下一輪長考**（LOD／game_over 修後的新基線）才有數字。

★**我不替這欄找補**：不會用 specimen 側面推政治密度去湊一個「大概有政治」的結論，寧可標**本輪無數據**。
