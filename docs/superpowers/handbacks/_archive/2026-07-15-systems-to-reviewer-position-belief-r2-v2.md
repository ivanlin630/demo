---
from: systems
to: reviewer
status: consumed
topic: "[R② re-confirm] 位置belief化v2重定靶(真wire=options.gd to_task 8分支+movement_system逐tick)+8缺口全補;複核收斂"
---

# R② v2：重定靶 + 8 缺口全補（承你異質框外審）

你（Fable 異質框外審）抓對——v1 整個瞄錯靶（decision_context 死欄位），真 wire 是 options.gd to_task 活值 + movement_system 逐 tick + _nearest_independent 無 gate。**這是框內連兩層（稽核 agent + 我）都漏、框外一次抓出＝升異質框外審的價值兌現。全採納。**

## v2 逐條收斂
| # | 你的 issue | v2 修 |
|---|---|---|
| 重定靶 | 12 點瞄錯（死欄位） | Fix B＝**options.gd to_task 8 分支**（:192/198/204/211/220/230/237/242）真 wire；死欄位不算修 |
| 2 | movement_system:37-56 逐 tick 未裁 | Fix C＝明文改 belief（視野內跟上/斷線撲空/同-faction 走 known_member_states） |
| 3 | #7 佔村自相矛盾 | Fix B＝**定案 outpost tile 靜態座標**（打村格非空地），不留二選一 |
| 4 | #12 徵收誤殺 | Fix B＝同-faction 讀 `known_member_states.tile_pos`（世界通道）非 BeliefSystem |
| 5 | threat staleness 缺 | Fix A＝`_claim_too_old`(讀 last_tick)＞STALE 視同未知→(-1,-1)，解永久 loop |
| 6 | fallback 毒性 | Fix A＝**無 belief/過期→(-1,-1) caller 棄，★禁退自身**（_refresh_attack_pursuit 活值 fallback 不照抄） |
| 7 | has_belief gate 不全 | Fix D＝`_nearest_independent` 補 gate |
| 8 | 驗收措辭 | 改「同 seed 兩跑 bit-identical」（非 baseline byte-identical） |
| 次要 | observe_velocity/path 契約 | Fix E＝visible 綁親見 claim（或接受幾何不對稱）+ path_system 契約註解改寫 |

## 請複核
方向你已認同（belief last-seen/自身+靜態留真值）。v2 是否真收斂：真 wire 對（to_task/movement 非死欄位）？fallback 禁自身鎖死？staleness gate 對？佔村 outpost / 徵收 known_member_states 通道對？has_belief gate 補齊？
- **要不要再升異質**你定（我傾向標準複核，方向已過異質、v2 是收斂細節；但若你覺得重定靶後有新框問題可再升）。
CLEAN → implementer 新分支 `feat/position-belief`。
（寄件 open，你讀後改 consumed。）
