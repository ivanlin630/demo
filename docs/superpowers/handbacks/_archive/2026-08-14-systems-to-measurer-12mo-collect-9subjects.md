---
from: systems
to: measurer
status: consumed
topic: "[12月長局收割:9期末考科目 aggregate(既有 json 平行收割、byte-identical 免等 specimen re-run)+specimen re-run pid28020 過夜跑中(QA二輪料)·★systems 疏漏誠實:第一輪我 launch 忘設 SPECIMEN_SAMPLE_N→tracer disabled→specimen 沒 dump(非 own_granary crash、那是分開 known-issue);已 re-launch pid28020 帶 SPECIMEN_SAMPLE_N=8(strided [0,6,12,18,24,30,36,42] observer-neutral、byte-identical 同世界)→末端 dump specimen·★aggregate 收割(既有 11MB json docs/measurements/2026-08-12-phase3-story-audit-seed1337-12mo.json、與 re-run 之 aggregate byte-identical 故現在收=同值免等):對照 2mo baseline 9 科目:①佔據率曲線(短窗11.02%隨窗放大否/settle-into-existing 量隨窗)②pop/starve(-32.6%/2mo改善否、famine 主死因否)③碎裂vs合併(spawn:merge 25:1棘輪解否、期末teams線索)④factions 8→3(兼併/滅亡過程=興衰真發生?)⑤established立國⑥combat死亡(零戰死改否)⑦糧帳P/C+跑道+糧倉世界帳⑧團規模分布(有大有小max/median)⑨vitals全套·★own_granary Nil error 污染查:json 守恆用 _pool_census(逐tile直讀、不經 own_granary_tile)→理論不污染、你驗證守恆項數值合理·★specimen re-run 完(pid28020 末端寫 seed1337-12mo.specimen.jsonl)→QA story-audit 二輪(motive→action→outcome、修後世界故事講得通否、對照第一輪六symptom)·序:aggregate 你現收→specimen re-run 完 QA二輪→systems consolidate→blueprint 帶用戶·地基KEEP"
---

# 12 月長局收割 — 9 期末考科目 aggregate + specimen re-run（QA 二輪料）

## ★systems 疏漏誠實
第一輪我 launch **忘設 `SPECIMEN_SAMPLE_N`** → tracer disabled → specimen 沒 dump（**非 own_granary crash**、那是分開 known-issue、非致命 sim 完成）。已 **re-launch pid 28020** 帶 `SPECIMEN_SAMPLE_N=8`（strided [0,6,12,18,24,30,36,42] observer-neutral、byte-identical 同世界）→ 末端 dump specimen。

## ★aggregate 收割（既有 11MB json、平行免等 specimen）
既有 json 與 re-run aggregate **byte-identical**（同 seed 同 code）→ 現在收 = 同值免等。對照 2mo baseline 9 科目：
1. 佔據率曲線（短窗 11.02% 隨窗放大否 / settle-into-existing 量隨窗）。
2. pop/starve（−32.6%/2mo 改善否、famine 主死因否）。
3. 碎裂 vs 合併（spawn:merge 25:1 棘輪解否、期末 teams 線索）。
4. factions 8→3（兼併/滅亡過程 = 興衰真發生?）。
5. established 立國。
6. combat 死亡（零戰死改否）。
7. 糧帳 P/C + 跑道 + 糧倉（世界帳）。
8. 團規模分布（有大有小? max/median）。
9. vitals 全套。

## ★own_granary Nil error 污染查
json 守恆用 `_pool_census`（逐 tile 直讀、**不經 own_granary_tile**）→ 理論不污染、你驗證守恆項數值合理即可。

## ★specimen re-run → QA 二輪
pid 28020 末端寫 `seed1337-12mo.specimen.jsonl` → **QA story-audit 二輪**（motive→action→outcome、修後世界故事講得通否、對照第一輪六 symptom [[feedback_qa_inversion]]）。

序：aggregate 你現收 → specimen re-run 完 QA 二輪 → systems consolidate → blueprint 帶用戶。地基 KEEP。
