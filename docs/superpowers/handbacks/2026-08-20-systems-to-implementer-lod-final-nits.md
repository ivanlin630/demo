---
from: systems
to: implementer
status: open
topic: "[LOD 修驗收=行為面我判過(四個補償逐行讀完全對、判準也寫進 code 註解=好)·收尾兩件小的,做完我 merge:①★過時註解:evaluate_all 函式頭仍寫『只有 breed 用得到（唯一 randf 處）』——addendum 後 trials 餵四條路(morale w_eff/技能 XP/comply loyalty/unrest),這句現在會誤導下一個讀的人;改成講清楚【trials 補償的是每次呼叫累積的量,判準不是有沒有 RNG】(你 _apply_reaction 頭上那段註解寫得正好,搬個對應版本上來即可)·②perf 重量一輪(你問的):要,但便宜就好——同一組 10 天窗 main↔branch(跟上輪同法、同 seed/config),因為 addendum 對 far pass 加了 skill on_reaction ×trials 的短迴圈,雖然那正是 near 端本來就在做的事、理論上不該多花,但【理論上不該】不是數字;上輪 +2.3%,這輪報個新數就好,不用長窗(長窗成本本來就交大考量)·★你自己抓到擴充 gate 的 vacuous pass(第一版 morale/unrest 兩側都 0 變化=那些反應根本沒 fire、改成 TAG_PRODUCE+morale 起點 0.5+高壓 rioter 才是真證據)=這是本輪最值得記的一手:【兩側相等】在『兩側都沒發生』時是假通過,跟你上一輪抓到的『兩側都撞 cap』同型;我會把這條寫進量測紀律·地基KEEP"
---

# LOD 修驗收：行為面我判過了，收尾兩件小的

四個補償我逐行讀完**全對**（`w_eff=1-(1-0.1)^trials` 對固定 target 的重複 lerp 精確等價、技能跑滿 `trials` 次保 `MAX_SKILL` 夾頂語意、comply/unrest ×trials），**判準也寫進 code 註解**＝好，那段以後會救人。

1. **★過時註解**：`evaluate_all` 函式頭仍寫「只有 breed 用得到（唯一 randf 處）」——addendum 後 `trials` 餵**四條路**，這句現在會誤導下一個讀的人（**今天才剛因為 stale 標籤害 QA 誤讀 `intent`**）。改成講清楚：**trials 補償的是「每次呼叫累積的量」，判準不是「有沒有 RNG」**（你 `_apply_reaction` 頭上那段寫得正好，搬對應版本上來即可）。
2. **perf 重量一輪**（你問的）：**要，但便宜就好**——同一組 **10 天窗 main↔branch**（跟上輪同法、同 seed/config）。addendum 對 far pass 加了 `skill on_reaction × trials` 的短迴圈；雖然那正是 near 端本來就在做的事、理論上不該多花，但**「理論上不該」不是數字**。上輪 +2.3%，這輪報個新數即可，長窗成本本來就交大考量。

★**你自己抓到擴充 gate 的 vacuous pass**（第一版 morale/unrest 兩側都 0 變化＝那些反應根本沒 fire → 改成 `TAG_PRODUCE` + morale 起點 0.5 + 高壓 rioter 才是真證據）——**這是本輪最值得記的一手**：「兩側相等」在「兩側都沒發生」時是**假通過**，跟你上一輪抓到的「兩側都撞 cap」**同型**。我會把這條寫進量測紀律。

地基 KEEP。
