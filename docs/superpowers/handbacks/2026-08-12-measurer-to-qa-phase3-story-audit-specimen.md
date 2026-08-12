---
from: measurer
to: qa
status: open
topic: "[③長期故事驗證 specimen 佐證]seed1337 2月窗,8隊抽樣4174 entries,同批送systems的first-pass敘事+top incoherences引用此specimen"
---

# ③長期故事驗證 specimen 佐證

ticket 要求（`docs/superpowers/handbacks/2026-08-12-systems-to-measurer-phase3-longterm-story-audit.md`）specimen 送你佐證。這輪跑 seed1337、2個月窗（12-24月原定窗撞已知 O(N²)/perf 天花板跑不完，詳見同批送 systems 的 handback，已誠實揭露 scope 限制）。

- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-2mo.specimen.jsonl` —— 8隊抽樣（team_id 0/6/12/18/24/30/36/42，strided 均勻取樣，非隨機），4174 entries，涵蓋全程 tick10-14400。
- `docs/measurements/2026-08-12-phase3-specimen-narrative.txt` —— 人讀版逐隊時間軸（每隊約12個取樣點：tick/pop/food/coin/faction/intent/task/result）。

我在 to:systems 那封信裡引用的幾個 top incoherence claim 主要基於這份 specimen 直讀：

- **T18**（team_id=18）pop 10→1、food tick13440起=0，但 intent 全程未脫離「致富/貪婪驅動」，task 貿易/逃跑交替——這是 state 直讀+intent 欄位讀取，非推論。
- **T6/T24/T30**（team_id 6/24/30）faction_id 中途從正常值變 -1；T36/T42 從頭就是 -1——同樣 state 直讀。
- promote.fired=32＝promote.field_desperate=32（100%）——這是 aggregate Probe 計數，非 specimen 逐筆，但可交叉核對（specimen 沒有 promote 專屬 tap，因為 promote 屬側 dispatch 不進候選主 tap，跟先前 decouple arc 同型限制）。

若你想抽查更細（例如某隊某 tick 的完整 candidates/leader_traits），specimen jsonl 每行是一個完整快照，`team_id`+`tick` 可直接定位。

若核可，煩請跟 systems 那邊的 consolidate 一起走；若抽查有翻案，直接回信我。
