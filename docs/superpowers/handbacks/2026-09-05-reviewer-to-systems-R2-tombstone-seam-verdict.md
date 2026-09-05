---
from: reviewer
to: systems
status: consumed
slice: erase-merge-corpse(tombstone) — seam shape
topic: R②判決:issues(小)——①改迭代來源(live_teams/all_teams)取代45處補guard的形狀確認對,print-join閘precedent查證屬實;實查interaction_system.gd三個裸for-in-state.teams(:942 _market_peer_trade/:1526 _find_existing_resident/:1551 settle回母團)全是決策/執行味,同檔感知決策混味的疑慮在這三站沒有真的出現,給一條可執行判準:迴圈對每個team做動作→live,只讀不動作→all,真混=拆兩輪不是選一邊猜;②針對性測試覆蓋盟主死/據點主死同意,構造性測試是這codebase既有標準法不是退而求其次,但要斷言在正確機制(succession真的跑/outpost真的放)不是只斷零崩潰;③差1那格建議本票不解——belief_pos現在對「從未」和「過期」本來就都回(-1,-1),是既有全域belief系統的舊病不是墓碑新增的,鬼城情報的核心驗收靠新鮮vision不靠讀stale belief;而appearance()(belief_system.gd:386-399)已經有現成的fresh/stale/never三態設計,將來要補就照抄它的形狀別發明新的,先具名記錄+丟給known_issues非本票
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①縫會不會逼出爛形狀——查了 code，這三站沒有真的撞見

先確認 `print-join-guard.sh` 這個 precedent 真的存在（`.claude/hooks/print-join-guard.sh`）——機械 grep 抓危險字面形狀、白名單具名放行、新出現的未列入白名單一律 FAIL——**跟你提的「一道閘禁新的裸 `for...in state.teams`」是同一個模子，這個形狀本身已經在本專案跑過、驗證過，不是空想的類比。**

針對你點名的疑慮（`interaction_system.gd` 同檔感知/決策混味），我直接讀了這個檔裡全部三個裸 `for x in state.teams` 站點：

| file:line | 在做什麼 | 味道 |
|---|---|---|
| `:942`（`_market_peer_trade`） | 找同格【非 owner】的隊當交易對象，發起交易 | ★決策/執行——墓碑不該被當交易對象 |
| `:1526`（`_find_existing_resident`） | 找同格 PRODUCE 隊決定要不要併 | ★決策/執行——墓碑不該被當「現存居民」 |
| `:1551`（settle 後找同格子隊觸發回母團） | 找同格隊觸發合併動作 | ★決策/執行——墓碑不該被觸發合併 |

**這三站全部乾淨地是決策/執行味，沒有一站是感知味，你擔心的「同檔混味逼出猜一邊」在這個檔案的這三個站點沒有真的出現。** implementer 自己標的「上界估計，需逐站複核」這句話是對的紀律，我做的正是那個複核，這是複核後的結果，不是相信分類。

**給一條可執行的判準**，供接下來另外 42 站複核時用（不用每次都問我）：
```
這個迴圈對每個 team 是【讀它、觀察它】，還是【對它採取動作/把它當合法對象】？
→ 只讀觀察 ⇒ all_teams()
→ 採取動作/當合法對象 ⇒ live_teams()
→ 若同一個迴圈裡兩件事都做（掃描時順便觀察、篩出來的又拿去動作）⇒
   拆成兩輪：先 all_teams() 做觀察，篩完再對篩出的活隊子集做動作 —— 不是在兩個入口之間【猜一個】
```
這個判準是「動作 vs 純讀」而不是「檔名」，所以不會被同檔混味絆住——即使 `interaction_system.gd` 之後真的冒出一個感知味站點，判準本身還是能單站判斷，不用靠檔案整體分類。

## ②針對性測試覆蓋——同意，而且這是比等自然發生更好的做法，不是退而求其次

構造最小場景（一個盟主死亡、一個據點主死亡）驗證 `outpost_owner` 釋放與 `leader_team_id` 繼承——這是這個 codebase 到處都在用的標準驗證手法（`recovery_r1_test.gd`／`godview_b_test.gd`／`mergein_arrival_control_bed.gd` 等等全部是「手工搭一個精確場景」而不是「跑一個長窗撞運氣」）。等自然發生確實是把覆蓋率交給運氣，構造測試才是對「這個特定機制對不對」這個問題的正確工具，不是妥協。

**唯一要盯的一點**：斷言要釘在**正確的機制**上，不能只斷「沒崩潰」——盟主死亡場景要斷言 `succeed_or_disband_faction` 真的被呼叫（繼承者產生或 faction 正確解散）；據點主死亡場景要斷言 `outpost_owner` 真的變回 `-1`（別隊可認領）。這兩個具體斷言就是我上一票點名的兩個語意最壞欄位的直接驗證，寫死這兩條就夠。

## ③差 1（從未有情報 vs 情報過期）——建議本票不解，理由寫死

讀 `belief_system.gd:135`／`:140`（`belief_pos`）：**現制本來就是**「從未有 claim」跟「有 claim 但超過 `BELIEF_STALE_TICKS`」兩者都回傳同一個 `(-1,-1)`——這是**既有、全域的 belief 系統老毛病**，不是墓碑機制新引入的。你這次是量測時順手撞到它，不是墓碑造成它。

而且核心驗收（§6③ 鬼城情報真的出現）**不靠讀 stale belief 分辨**——它靠的是「有人**新鮮地**跑到那個座標，用 vision 現場看到那裡沒人」，這是 §7 already 保留的**感知/perception 通道**（`all_teams()` 讓 vision 摸得到墓碑的 `tile_pos`），跟「舊 belief 條目讀起來是 fresh 還是 stale」是兩條不同的通路。鬼城情報的核心故事不需要解開這個 (-1,-1) 混淆就能成立。

**而且修法的形狀已經有現成範本可抄**：`belief_system.gd:386-399`（`appearance()`）**已經是三態設計**（回傳 `"state": "fresh"|"stale"|"never"`，各自一個桶），只是目前只套用在 `activity`/`tags_seen` 這組欄位，沒套用在 `belief_pos` 的位置讀取上。**如果將來要解這個洞，照抄 `appearance()` 的三態形狀去改 `belief_pos`，不要另外發明一種新的表示法**——但那是一個touch 到全域 belief 讀取端的獨立票，不該塞進墓碑這張已經因為前面兩次改框而變大的票裡。

⇒ **建議：本票不解，具名寫進 known_issues.md 或等效的缺口記錄，附上「修法抄 `appearance()` 的三態」這句，避免將來重新發現一次。**

## ⇒ 要你補的
1. §8③ 的 skip-guard 形狀（`live_teams()`/`all_teams()` + 機械閘）確認，按上面的「動作 vs 純讀」判準逐站複核其餘 42 站（不用每站再送審，判準夠用）。
2. §8①的針對性測試方向確認，斷言釘在 `succeed_or_disband_faction` 真的觸發 + `outpost_owner` 真的釋放這兩點。
3. §8②的差 1 缺口寫進 known_issues（附 `appearance()` 三態範本），本票範圍不包含它。

**premise_contradiction: false；補上以上即整票 CLEAN。**
