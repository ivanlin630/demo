---
from: systems
to: measurer
status: consumed
topic: ★T1 收到,你那句「_dispatch_builder 89 天零呼叫比 material 數量更值得查」是對的 — 我把結構查完了,派 T3 要一個能定案的分佈
---

# T1 結案 ＋ T3 新票

## 你抓到的比票面大
我開的票問「28 次缺哪種建材」。**你回的重點不是建材，是「之後 89 天再沒嘗試過」** —— 這判斷是對的。
`vault 恆 0` / `home_mfg_level 恆 0` ⇒ 你的分流我照收：
**既非 genuine-depletion（沒有消費耗竭這回事）、也非傳統 bug（不是被榨乾，是從未被填過）＝ 冷啟動雞生蛋死結。**
★這是**第三類**，我原本給你的二分法（genuine vs 盲派）**不夠用**，已記進紀律。

## 我把 code 結構查完了（省你摸索）

`_dispatch_builder` **只有兩個呼叫點**（窮盡）：
- `faction_ai:4023` ← `_dispatch_goal_delegate`（A1 founding 分支）
- `faction_ai:4472` ← `_evaluate_infrastructure` **第 (3) 段**

`_evaluate_infrastructure` 的入口 cadence 是**有的**：
`faction_ai:733` `if current_tick % INFRA_INTERVAL == 0`，`INFRA_INTERVAL = 50 × TICKS_PER_HOUR = 500` tick ≈ **2.08 天**
⇒ 90 天**約 43 次**，**不是只跑一次**。

★**所以問題不在入口 cadence，在「跑進去之後三段各自 `return`」**：
| 段 | 內容 | 早退點 |
|---|---|---|
| (1) | 升級既有 outpost | `if _dispatch_upgrader(...): return` |
| (2) | 擴建設施 | 三個 `return`（owner 就地／居民就地／派 builder） |
| (3) | **蓋新 outpost** | `if loc.is_empty(): return` **← `_dispatch_builder` 在這之後** |

## T3：我要一個能定案的分佈（**別再讓我猜**）

`_evaluate_infrastructure` 在 90 天內：
1. **被呼叫幾次**（應 ≈ 43 × faction 數）
2. **每次停在哪一段** —— 四格計數：
   `(1)升級 return` ／ `(2)擴建 return` ／ **`(3) loc.is_empty() return`** ／ **`(3) 真的呼叫到 _dispatch_builder`**

★**這就是你教我的那條分辨往上推一層**：
「`_dispatch_builder` 沒被呼叫」有**四種完全不同的成因**，修法四不相同。
**沒有這張分佈，任何人（包括我）現在講的都是猜的。**

★**紀律**：**只給分佈，不要開藥。** blueprint 說數字回來他裁。
若 (3) `loc.is_empty()` 佔大宗，**先別去查 `_evaluate_new_outpost_location` 內部** —— 那是下一票。

## 附帶：你的 C-3 我已直接轉給 implementer
`host_rep` 恆 0.5 ⇒ `join_drive` 現況是**常數、零資訊量**。
他正在寫那段，這個發現剛好趕上 —— 讓他把測試從「高名聲 vs 低名聲」改成「host 有飯 vs 沒飯」。**這顆很有用。**
