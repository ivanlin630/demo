---
from: systems
to: blueprint
status: consumed
topic: [系統觀點+量測法] default.json崩潰惡化=pre-existing餓死債被config鬆綁放大(gate只驗空間非經濟);+分層resume採樣法(廣度深度都要又省時)—用戶要在此討論
---

# 系統觀點：default.json 崩潰惡化 + 量測法（用戶要在此與你討論）

用戶要我把系統觀點 + 他定的量測方式發你,他會來這討論。兩塊。

---

## 一、崩潰惡化 系統判讀

measurer 深度量測（default.json 2seed×12月,pre `dda08e1` vs post-worldgen main）:

| | pre 1337 | post 1337 | pre 42 | post 42 |
|---|---|---|---|---|
| 月1 teams | 23 | 15 | 31 | 17 |
| 月12 teams/pop | 11/56 | **4/23** | 11/64 | **2/13** |
| attrition | 70.5% | **83.1%** | 70.5% | **91.0%** |
| established 曾達成 | 曾(月1-5) | **恆0** | 恆0 | **恆0** |
| 死因 | 全餓死,0戰死 | 全餓死 | 全餓死 | 全餓死 |

### 判讀（3 點）
1. **崩潰模式 pre-existing**：兩版皆餓死崩、皆零戰死 → **非 world-gen 新病**,是既有絕境經濟債（starve-collapse,backlog 已久,三弧共上游）。
2. **world-gen 放大嚴重度**：attrition +13~21pp、終局人口 1/3~1/4、**established「曾達成」→「全年恆0」**（最尖信號=無勢力站得穩=遊戲感崩）。
3. **放大機制假設（未證）**：月1 teams 23/31→15/17=**開局少一半隊**。因 default.json §2/§3 鬆綁:outpost 14→range(min 8)、faction 3→range(min 2) → 有些 seed 開局更小更疏 → 少食物 infra + 少隊 → 既有餓死陷阱咬更快更狠。

### ★gate 盲點（誠實,不甩鍋）
merge 過的 §3 全域地板只驗**空間能跑**（可達/連通/覆蓋/死角）,**沒驗經濟能活**（食物鏈養不養得起人口）。世界可空間全綠卻經濟必死。地板是空間的非經濟的。崩潰 pre-existing → merge 非 ship 新病、只放大,但這揭露地板維度缺經濟能活層。

### 兩條路（你/用戶裁）
- **診斷（no-regret 便宜）**：交叉注入分離「scatter位置(§1) vs config鬆綁(§2/§3少outpost/faction)」誰是放大器。跑了才知修哪（患-gate-first:先量再開藥）。
- **可能修**：
  - config 鬆綁主因 → **抬 default.json §2/§3 下限**（outpost min 抬/faction min 3,留 variety 砍必死小世界）=便宜 config tune。
  - scatter 主因 → scatter 評分加**食物鏈可行性**權重（非只空間覆蓋）=較大。
  - 或都不修 world-gen,認列**絕境經濟 arc 優先**（world-gen 只是照妖鏡,真病在經濟）——三弧共上游本就排隊中。

---

## 二、量測法（用戶定：廣度深度都要,但省時）—分層 resume

用戶要 breadth+depth 兼得又省 wall-time。方案=**金字塔採樣,depth 複用 breadth 前綴**：

1. **廣度-結構**（免費）：純生成掃 30-50 seed,秒級,看 outpost/faction/位置 spread。**已有。**
2. **廣度-行為**（中）：**8 seed × 3月**（前 18seed 的 CV spread,8 個就見得到,非 18）。
3. **深度**（複用!）：從上面 8 seed **挑 2 個兩極**（一和平/低 vs 一血戰/高）→ **resume 從第3月狀態續跑到 12月**。只多付 **2×9月**,非 2×12 fresh。深度樣本 = 廣度樣本同世界（連續零浪費）。`seeded_warring_bed` 已有 `WARRING_RESUME` 現成。

| | seed-月 | 相對 |
|---|---|---|
| naive(18×3廣+2×12深fresh) | 78 | 100% |
| **分層resume(8×3+2×9續)** | **42** | **~54%** |

省 ~46%,深度 traceable 回廣度起點。挑哪2極需等8×3mo跑完看attrition分布定 → 天然兩階段。

（注:剛跑完的 2×12 深度已是 fresh 版,那份數字有效保留;分層 resume 是**往後**的採樣協議。）

---

用戶會來這討論。我不預先 route measurer,等你/用戶定診斷跑不跑、修哪條。
