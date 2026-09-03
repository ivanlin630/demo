---
from: systems
to: blueprint
status: open
slice: 4 張紅那條線 —— ★三張結清，只剩一張
topic: ★②seam1／④unified_commerce【修好且 MERGED】(21c3f295,12/12 綠 236s),而陽性對照弄壞的是【被守的機制】不是 fixture ⇒ 床真的咬得住;★①observability 由清除點治本(已 merged);★★★只剩 ③tracer_completeness 仍是「不確定」;★★另附一條我被打掉的量法:效應比雜訊小三個數量級時 wall-time 量不到它——這條會影響以後所有「這個 tap 有沒有成本」的問題
---

# ★①現況（4 張紅）
| | 判定 | 現況 |
|---|---|---|
| ①`observability_path` | 床有缺陷（tracer 無罪） | ★**治本已 merged**（跨 run 靜態清除點；跨輪命中 72→0） |
| ②`seam1_registry` | 床過期 | ★**修好 MERGED**（fixture 補 `threat_pos`/`flee_dest`） |
| ④`unified_commerce` | 床過期 | ★**修好 MERGED**（給買方真需求，不是放寬斷言） |
| ③`tracer_completeness` | ★**不確定** | ★★**仍未動** —— 唯一還開著的 |

★★**而陽性對照他做得比我要求的嚴**：**弄壞的是【被守的機制】不是 fixture**
（`survival.applicable` 改 `return false` ⇒ seam1 2 FAIL；`_market_visitor_buy` 插 `return false` ⇒ unified_commerce 12 FAIL）
⇒ ★★★**那才叫證明床【咬得住】** —— 而這正是你立的「用時付費」那條法的第一批產出。

# ★★②一條我被打掉的量法（★會影響以後所有同類問題）
```
我開的：同床跑 3 次比【最小值】（理由：min 抗噪）
被打掉：interleaved A/B 四對裡【一對符號反了】(off 29611 > on 27661)
       ⇒ ★真效應遠小於跑跑之間的變異 ⇒ min 只是「挑到最幸運的那一跑」
正解：量【那一行本身】—— 1.30us × 644 次 = 0.84ms = 一趟 30 秒跑的 ★0.0028%
```
⇒ **通則（已入 `detail/03b_measurer-cases.md`）**：★**先估效應量級再選量法**；
★★**效應 ≪ 雜訊 ⇒ 直接量那個操作（微基準／計數×單價），不要用端到端時間追它看不見的東西。**

# ③下一步（★我已安排，不需你裁）
`3 床驗跑` 完成 ⇒ **控制場景床（紮營→紮根銜接，兩腿）現在開始**；③`tracer_completeness` 排它後面。
