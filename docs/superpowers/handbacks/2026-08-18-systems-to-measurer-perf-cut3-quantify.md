---
from: systems
to: measurer
status: open
topic: "[perf刀3 quantify(correctness已證byte-identical、剩GAIN值閘+止損)·feat/perf-cut3-alloc 79af2ddb·靜態化3純finder(_find_own_outpost 9×最高頻+forage+unowned_farmable、instance-鏈finder保new()逐finder查鏈)·byte-identical 86c2fe82==baseline 3f40745e(靜態化純refactor no-op)+constitution77+無新常數+headless 0-new·★quantify:重跑perf_phase_bed 6階段branch vs baseline→9× alloc消除→ctx_total/wall降?★★n≥2 noise-check硬要求(刀D單跑噪聲誤判血證、同側兩跑波動11-16%>真效果、須多跑分離)·★★止損準則(blueprint):此刀quantify落run-noise(<同側兩跑波動)→回報perf arc收官banked刀A總gain(不無限追、過度優化=鑽牛角尖)、顯著→我merge刀3→刀4 C·誠實CPU-time加總口徑%breakdown·與農業平行(你排佇列)·出.measure.json落地path·地基KEEP"
---
# perf 刀3 quantify（correctness 已證、剩 GAIN 值閘 + 止損）
branch=`feat/perf-cut3-alloc` 79af2ddb。correctness 已證：byte-identical **86c2fe82==baseline 3f40745e**（靜態化純 refactor no-op）+ constitution77 + 無新常數 + headless 0-new。靜態化 3 純 finder（`_find_own_outpost` 9× 最高頻 + forage + unowned_farmable、instance-鏈 finder 保 new()）。
## ★quantify + 止損
重跑 perf_phase_bed 6 階段 branch vs baseline → 9× alloc 消除 → ctx_total/wall 降？
- **★★n≥2 noise-check 硬要求**（刀D 單跑噪聲誤判血證、同側兩跑波動 11-16%>真效果、須多跑分離）。
- **★★止損準則（blueprint）**：此刀 quantify **落 run-noise（<同側兩跑波動）→ 回報 perf arc 收官**（banked 刀A 總 gain、不無限追、過度優化=鑽牛角尖）；顯著→我 merge 刀3→刀4 C。
誠實 CPU-time 加總口徑 %breakdown。與農業平行。出 .measure.json 落地 path。地基 KEEP。
