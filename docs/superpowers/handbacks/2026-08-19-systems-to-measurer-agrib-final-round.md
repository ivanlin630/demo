---
from: systems
to: measurer
status: consumed
topic: "[★農業b 最後一輪 re-measure(churn-fix+labor-v2 都已在 main)·branch feat/agriculture-b @ee618dcc(疊新 main 乾淨零衝突、9/9+constitution 77、★新 fp=24cffe3b=農業b 行為在 a4 窗真現形)·baseline=現 main(含 churn-fix 7877310a+labor-v2 eb20531d)·★★具名科目①(新證據、優先):headless 全量比對顯 branch 打破既有 arc fixture——[g1a]礦村未鑄幣(mint_level=0 coin_delta=0;main 同測 PASS mint=1/coin=200)=疑 pop-cap『塌』的具體後果(弱領導村 effective cap 崩→村發展不到蓋/運鑄幣廠)→請在 organic 世界驗:弱領導/小村是否因 effective_pop_cap 過低而無法發展設施(mint/farming level/倉)=結構性發展封頂;若 organic 也顯→floor 需要(我出校準 ruling);若只 fixture artifact(該測 leader skill 設定極端)→訂正 fixture·★★②pop-cap 爆/塌 re-measure(churn 修完的乾淨世界、前輪 churn 污染已除):effective_pop_cap 分布(min/p10/p50/p90/max、cap<5 佔比、前輪 5.3%)+pop 爆(前輪 0 runaway=⑥ 驗證通過、複核)+overflow 事件率(前輪 pop-cap 自身僅 3×)·★★③churn 缺口高壓覆蓋(blueprint 認可由此輪帶、churn-fix gate 缺的就是這個):team 不暴增否(原 49→242)/per-tick perf 回正否(原 793ms avg、20.2s peak、40-70×)/同對隊 SurvivalMergeIn 反覆數(原 698)——★此床正是原始 churn 現形的那個高壓場景(warring_states 3mo popcap 床)、是唯一能覆蓋 churn-fix 高壓效果的機會·④determinism 24cffe3b 驗+headless(★branch 有 2 known red:①g1a 上述具名科目、②農業b 自加的複合放大測=branch-WIP、implementer 正在 pin 測 vs 功能;除這 2 外應 0-new)·★wrapper 已修=長跑 stdout 不再失憶·跑法 godot --path .worktrees/agriculture-b·出 .measure.json 落地 path·綠(或校準後綠)→我 merge→§4·地基KEEP"
---

# ★農業b 最後一輪 re-measure（churn-fix + labor-v2 都已在 main）

branch=`feat/agriculture-b` @ee618dcc（疊新 main 乾淨零衝突、9/9 + constitution 77、**★新 fp=24cffe3b**=農業b 行為在 a4 窗真現形）。**baseline=現 main**（含 churn-fix `7877310a` + labor-v2 `eb20531d`）。

## ★★具名科目①（新證據、優先）
headless 全量比對顯 **branch 打破既有 arc fixture**：**[g1a] 礦村未鑄幣**（mint_level=0 / coin_delta=0；main 同測 PASS mint=1 / coin=200）=疑 **pop-cap「塌」的具體後果**（弱領導村 effective cap 崩→村發展不到蓋/運鑄幣廠）。
→ 請在 **organic 世界**驗：**弱領導/小村是否因 `effective_pop_cap` 過低而無法發展設施**（mint / farming level / 倉）=**結構性發展封頂**。
- organic 也顯 → **floor 需要**（我出校準 ruling）；只 fixture artifact（該測 leader skill 設定極端）→ 訂正 fixture。

## ★★②pop-cap 爆/塌 re-measure（churn 修完的乾淨世界、前輪 churn 污染已除）
`effective_pop_cap` 分布（min/p10/p50/p90/max、**cap<5 佔比**、前輪 5.3%）+ pop 爆（前輪 0 runaway=⑥ 驗證通過、複核）+ overflow 事件率（前輪 pop-cap 自身僅 3×）。

## ★★③churn 缺口高壓覆蓋（blueprint 認可由此輪帶、churn-fix gate 缺的正是這個）
team 不暴增否（原 **49→242**）/ per-tick perf 回正否（原 **793ms avg / 20.2s peak / 40-70×**）/ 同對隊 `SurvivalMergeIn` 反覆數（原 **698**）。
★**此床正是原始 churn 現形的那個高壓場景**（warring_states 3mo popcap 床）=**唯一能覆蓋 churn-fix 高壓效果的機會**。

## ④其餘
determinism `24cffe3b` 驗 + headless（★branch 有 **2 known red**：①g1a 上述具名科目、②農業b 自加的複合放大測=branch-WIP、implementer 正在 pin 測 vs 功能；**除這 2 外應 0-new**）。★wrapper 已修=長跑 stdout 不再失憶。

跑法 `godot --path .worktrees/agriculture-b`。出 `.measure.json` 落地 path。綠（或校準後綠）→ 我 merge → §4。地基 KEEP。
