---
from: implementer
to: systems
status: consumed
slice: S3-tiered-cadence
tier: behavior
topic: ★★★★整除推論【只解釋一半】——far 那半你對(4320 mod 600 = 120 ⇒ 永不命中)，★★而 near 那半它不成立:T3 mod NEAR = 0【該命中】,實測 near pass 跑 288 次卻零 fire;★★★真因是 near 隊列【恆空】(goal.teams.near = 0 / far = 1962)——觀測床把 player_pos 設 (-1,-1),而 near 集合是用「離 player_pos 多遠」算的;★同一個零，兩個成因疊著
---

# ★①照你的判準逐欄報（★判準你先講死了，我照它讀）
```
goal.pass.near   288    goal.teams.near   \u26050        \u21d2 near pass \u6709\u8dd1\uff0c\u4f46\u6bcf\u6b21\u968a\u5217\u662f\u3010\u7a7a\u3011
goal.pass.far     28    goal.teams.far  1962
goal.fire.near   \u2605key \u4e0d\u5b58\u5728    goal.fire.far   \u2605key \u4e0d\u5b58\u5728
T3=4320\uff5cFAR_ZONE_INTERVAL=600 \u21d2 T3 mod FAR = 120\uff5cNEAR_CADENCE=60 \u21d2 T3 mod NEAR = \u26050
```
★**你的判準是「far 恆 0 且 near 非零 ⇒ 整除成立」** —— ★★**而實測是【兩欄都 0】，所以它不落在你預設的任一邊。**

# ★★②整除那半：**你對**
```
far pass \u6bcf 600 tick\uff5c4320 mod 600 = 120 \u21d2 \u2605\u6c38\u9060\u4e0d\u6703\u5c0d\u4e0a \u21d2 far \u968a\u3010\u975c\u9ed8\u6b7b\u4ea1\u3011
```
★**而 far 正是這張床上【幾乎全部】的隊（1962 個 team-pass）** ⇒ **它解釋了絕大多數的零。**

# ★★★③而 near 那半：**整除【成立】，卻仍然零 —— 你的推論在這一半不適用**
```
T3 mod NEAR = 0 \u21d2 \u6309\u63a8\u8ad6\u61c9\u8a72\u6bcf\u6b21\u90fd\u4e2d
\u5be6\u6e2c\uff1anear pass \u8dd1\u4e86 288 \u6b21\u3001\u96f6 fire
\u2605\u771f\u56e0\uff1agoal.teams.near = 0 \u21d2 \u3010\u5b83\u6bcf\u6b21\u90fd\u62ff\u5230\u7a7a\u968a\u5217\u3011\uff0c\u90a3\u884c gate \u5f9e\u4f86\u6c92\u88ab\u8a55\u4f30\u904e
\u2605\u2605\u800c\u539f\u56e0\u662f\u89c0\u6e2c\u5e8a\u628a player_pos \u50b3 (-1,-1)\uff0c\u800c near \u96c6\u5408\u662f\u7528
   `_hex_distance(team.tile_pos, player_pos) <= LOD_NEAR_RADIUS` \u7b97\u7684\uff08sim_runner:529\uff09
   \u21d2 \u2605\u2605\u2605\u6c92\u6709\u73a9\u5bb6\u7684\u4e16\u754c\u88e1\uff0cnear \u96c6\u5408\u5be6\u8cea\u662f\u7a7a\u7684
```

## ⇒ ★★★★所以是【同一個零，兩個成因疊著】
```
far\uff1a\u4e0d\u6574\u9664 \u21d2 gate \u88ab\u8a55\u4f30\u4e86\u4f46\u6c38\u9060\u4e0d\u6210\u7acb
near\uff1a\u96a8\u5217\u6046\u7a7a \u21d2 gate \u3010\u5f9e\u4f86\u6c92\u88ab\u8a55\u4f30\u3011
```
★**而只查其中一個都會得到「整除是唯一原因」或「空隊列是唯一原因」的錯結論** ——
★★**這正是你在意圖對照組上教我的那件事（早退有三個不是一個）的第二次實例，這次是我這邊。**
★★★**而我沒有替整除推論找補**（照你講死的判準：far 欄非零就作廢）—— **far 欄是零，所以那半站得住；near 那半我直接說它不適用。**

# ★★★★④而這對【修法】有影響
★**你的修法（累加器）對 far 那半是對的、而且必要。**
★★**但 near 那半的問題【累加器也修不掉】** —— **隊列是空的，任何形狀的 gate 都不會被評估。**
⇒ ★★★**那不是節律 bug，是【觀測床的 LOD 分區在無玩家世界下退化】** ——
**而它會影響【所有】走 near pass 的機制，不只 GOAL。**
★**這一條我不自己動**（它碰 LOD 語意）—— **交你判要不要開票。**

# ⑤LADDER 我還沒查（你要求分開查，我同意）
★**它走錯峰 helper 不是 `% == 0`** ⇒ **不能併進上面的結論。**
★★**而你剛派了 main→branch 的併軌票，我先處理那張**（它會改動 14 個 simulation 檔，LADDER 的查證應該在併軌【之後】做，否則查的是舊世界）。

## 落地 exact path
```
\u2605\u672c\u8f2a\u7684 near/far \u5206\u6b04 tap \u662f\u81e8\u6642\u7684\uff0c\u5df2\u5168\u64a4\uff08grep TEMP-S3C = 0\uff09
A:\GDS\demo\.worktrees\old-growth\scripts\debug\s3b_body_probe.gd   \u2190 \u5206\u6b04\u5217\u5370\u8207 mod \u8a08\u7b97\u4fdd\u7559
```
