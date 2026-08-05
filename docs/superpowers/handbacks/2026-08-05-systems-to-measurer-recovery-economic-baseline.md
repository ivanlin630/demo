---
from: systems
to: measurer
status: open
topic: "[recovery-path arc ★開場 §3 經濟底查(measure-first、spec 鎖前 grounding、用戶拍 A;同 cohesion exit-attribution 先例定主力動詞)·核心問:pop2 入不敷出(relief 均攤 1.4<消耗 1.6/天)是『地不好』(terrain 產出撐不起)還是『人太少』(pop2 below 最小可活規模、哪塊地都活不了)?→答案定主力動詞:人太少→③移民主力(領主派人補村)/地不好→①②遷村主力(遷到好地)·量(純觀測/算、無 code 改):①各地型×村規模產耗打平點:各 terrain(平原/森林/山地/etc REGEN_RATE)×pop 的 per-capita 產出(tile 產出×harvest_factor)vs 消耗(FOOD_PER_PERSON_PER_DAY 0.8)——哪個 pop 起產≥耗(self-sufficient)?②pop2 特定村 distress 拆:同 pop2 放好地(平原)vs 爛地(山地)產耗差=隔離地 vs 人變因(controlled:固定 pop 變 terrain、固定 terrain 變 pop)③最小可活村規模 per terrain(產≥耗的最小 pop)④各 tile 型產出曲線(pop scaling:規模經濟有無、大村 per-capita 較高否)⑤relief+投資成本 vs 回收(relief 花糧+facility 投資 vs 村站起來後產出、回本否)·★答案 grounds §2 主力動詞(移民 vs 遷村 vs facility 投資哪個 cost-effective)·純觀測 dump 真值(產耗表、打平 pop、controlled 地 vs 人)→回 systems 定 spec·避 warring perf·地基 KEEP"
---

# recovery-path ★開場 §3 經濟底查（measure-first、定主力動詞）

用戶拍 A（recovery-path arc）。**spec 鎖前必先 measure-first grounding**（同 cohesion exit-attribution 先例、定主力動詞）。

## 核心問
pop2 入不敷出（relief 均攤 1.4 < 消耗 1.6/天）是**「地不好」**（terrain 產出撐不起）還是**「人太少」**（pop2 below 最小可活規模、哪塊地都活不了）？→ **答案定主力動詞**：人太少→③**移民**主力（領主派人補村）/ 地不好→①②**遷村**主力（遷到好地）。

## 量（純觀測/算、無 code 改）
1. **各地型×村規模產耗打平點**：各 terrain（平原/森林/山地… `REGEN_RATE`）× pop 的 per-capita 產出（tile 產出×harvest_factor）vs 消耗（`FOOD_PER_PERSON_PER_DAY` 0.8）——哪個 pop 起產≥耗（self-sufficient）？
2. **★pop2 特定村 distress 拆（controlled）**：同 pop2 放**好地**（平原）vs **爛地**（山地）產耗差 = **隔離地 vs 人變因**（固定 pop 變 terrain / 固定 terrain 變 pop）。
3. **最小可活村規模 per terrain**（產≥耗的最小 pop）。
4. **各 tile 型產出曲線**（pop scaling：規模經濟有無、大村 per-capita 較高否）。
5. **relief+投資成本 vs 回收**（relief 花糧+facility 投資 vs 村站起來後產出、回本否）。

## 序
★答案 grounds §2 主力動詞（移民 vs 遷村 vs facility 投資哪個 cost-effective）。純觀測 dump 真值（產耗表、打平 pop、controlled 地 vs 人）→ 回 systems 定 spec（+ blueprint R① 平行）→ 鎖 → HOW → build。避 warring perf。落地 `docs/measurements/`。地基 KEEP。
