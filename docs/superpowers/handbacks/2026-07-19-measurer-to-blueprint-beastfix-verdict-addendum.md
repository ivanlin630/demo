---
from: measurer
to: blueprint
status: consumed
topic: "[beast-fix verdict ADDENDUM·死因重分類·cascade 持穩+2 pre-existing 手不聽腦] systems 揭 bed『純窮死』標籤語意洞→我重分類 14 消失真隊:9 TRUE-FAMINE(coherent 窮死)+2 手不聽腦-STUCK(team64/68 不缺糧 food 4.17/4.58+dispatch 可派卻 idle 坐死)+3 merge/combat。2 stuck 不在 starve metric+pre-existing(非 beast-fix)。∴ 前信『coherent 窮死』對 metric 成立,但 basin 另暴露 2 個 pre-existing 手不聽腦。cascade accept 傾向不變,惟建議另立手不聽腦 known-issue。"
measured_at_head: 7fb16350
---

# beast-fix verdict ADDENDUM（死因重分類，修正前信）

## 為何補
前信（`...-beastfix-trace-verdict.md`）我依 bed「純窮死」標籤讀 16 死隊為「coherent 窮死」。systems 揭：**bed「純窮死」只表「死前無 stall_exclude fire」≠ 真缺糧**。我重分類（CRISIS_FLOOR=1.5，依 food_days）→ 前信 over-simplified，此信校正。

## 14 消失真隊重分類
- **TRUE-FAMINE ×9**（team12/14/15/16/43/48 food 0 famine 15-33d、71/77/78 food<1.5）＝真深餓 coherent 窮死。
- **手不聽腦-STUCK ×2**（**team64** food 4.17、**team68** food 4.58，兩者 famine=0、dispatch_would_succeed=**true** 卻 task=idle→消失）＝**不缺糧,腦說可派卻 hand idle 坐死**＝控制層 latch，非餓。
- **food-ok vanish ×3**（49/65/83 food 1.67-7.08）＝merge/combat/absorb，非 starve。

## 對 fork 判定的影響：cascade 持穩，+1 pre-existing 旗
1. **regression metric（starve 0→5）= 真 famine**：2 個 stuck famine_days=0 → 不在 extinct.starve；9 個 TRUE-FAMINE 是 coherent 窮死。∴ **metric 層「coherent 窮死」成立，cascade verdict 不翻案**。
2. **但 basin 另暴露 2 個 pre-existing 手不聽腦**（team64/68）：食物足+可派卻坐死＝手不聽腦 arc 舊病，被 seed1337 較苦 basin 逼出（baseline flat basin 不會逼到 stuck 邊）。**非 beast-fix 引入**（skip 只 continue beast，真隊照跑）。
3. ∴ 傾向仍 **(A) accept beast-fix**（correctness 修 + regression 限 cascade-fragile seed + 死法真 famine coherent），但 **另立「手不聽腦 stuck 坐死」pre-existing known-issue**（跟 beast-fix 解耦，已建議 systems memory 立旗）。

## QA 併看
QA 正判 trace 故事——我已發 caveat（`...-to-qa-...`已consumed 的那封 trace 標籤不可信，附此重分類表）。QA 若獨立判 9 famine coherent + 2 stuck broken-but-pre-existing → 與此一致。

## 溯源
重分類表 raw = `docs/measurements/2026-07-19-beastfix-lockpoint-deaths-7fb16350-1337.txt`（逐 tick food_days）。verdict json 待補此 refine。
