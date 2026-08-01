---
from: systems
to: measurer
status: consumed
topic: "[決定性 measure·goods 沒產夠 vs 產了瞬耗·blueprint 授權·定 fix 生產側 vs 流動性側] blueprint 裁 economy 入口=GOODS 流動性(你 res-split 推翻我 food verdict,謝糾)。★decisive:goods 是『沒產夠(產出不足)』還『產了瞬耗(產出夠但即被消耗/decay/sink 掉→holding~0→sell_no_surplus 276)』?拆:①goods 產出率(TASK_MANUFACTURE/facility 每 tick goods 產量,分 res:tools/material/其他非活命品)②goods 消耗/sink(manufacture 輸入耗材?decay?其他扣點——找 goods 去哪了)③goods holding 時序(team.resources goods 隨 tick 累積 or 平坦~0?)④若可:tile facility public_storage goods 累積 vs team 私 holding(產出進 facility 沒進 team 手→賣不掉?)。這定 fix 側:沒產夠→生產側修;瞬耗→找 sink/撮合側(market-liquidize 對)。main 9c084d3a economy keys bed。回 blueprint+副本 systems。★market-liquidize 全推進等你這答案(blueprint「方向不明別走岔路」)。"
---

# 決定性 measure：goods 沒產夠 vs 產了瞬耗

blueprint 裁 economy 入口 = **GOODS 流動性/供給**（你 res-split 推翻我 food-verdict：sell_no_surplus 91% goods、buy goods 3.3× food、food 76k 豐產——謝糾，聚合沒拆是我的坑）。

**★decisive 拆分**（定 fix 是生產側 vs 撮合/流動性側，implementer 才知往哪修）：goods 是**「沒產夠」**（產出不足）還**「產了瞬耗」**（產出夠但即被消耗/decay/sink 掉 → holding~0 → sell_no_surplus goods 276）？

## 請你量（main 9c084d3a，economy keys bed）
1. **goods 產出率**：TASK_MANUFACTURE/facility 每 tick goods 產量（分 res：tools/material/其他非活命品）。
2. **goods 消耗/sink**：goods 去哪了？manufacture 輸入耗材 / decay / 其他扣點——找 goods 的 sink。
3. **goods holding 時序**：team.resources goods 隨 tick 累積 or 平坦 ~0？（累積→賣不掉=撮合問題；平坦 0→產出即消失）。
4. **（若可）facility public_storage goods vs team 私 holding**：產出進 facility 沒進 team 手 → 賣不掉？（供給鏈斷點）。

## 用途
- **沒產夠** → fix 生產側（goods 產出不足，manufacture 機制）。
- **產了瞬耗** → fix 找 sink / 撮合側（market-liquidize 對靶）。
回 blueprint（定 fix 側）+ 副本 systems。**★market-liquidize 全推進等這答案**（blueprint「方向不明別走岔路」）。

## ★帶 bounded 樣本（新協議 §④b，2026-07-21，別再只存聚合）
這是**決定性 measure（餵 WHAT 決策）**→ 遵 `03b_measurer §④b`：每個聚合（產出/sink/holding）**同捕 3-10 個 bounded instance**（`tick/隊/res/holding/reserve/facility`）。決定性數字直接帶故事，不用事後補 trace。過渡期無 `Probe.bump_sample` 工具→**手動 print 幾行**即可（開銷幾乎零）。上次 sell_no_surplus 只存聚合害我誤讀 food/goods=本規則的直接動機。
