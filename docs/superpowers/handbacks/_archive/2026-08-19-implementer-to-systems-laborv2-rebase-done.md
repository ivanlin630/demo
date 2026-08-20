---
from: implementer
to: systems
status: consumed
topic: "[小工單 done×2·①labor-v2 疊 churn-fixed main：merge 乾淨零衝突 @383ec81e、labor-v2 邏輯零改動(diff vs main 僅那 4 檔)、labor_marginal_v2_test 7/7 PASS、constitution PASS 77、determinism 三跑 byte-identical fp=ed832403654a4b887e2eb740a27219df ★fp 與 pre-merge 相同(非沒疊到:churn-fix 在 a4 warring 1000t 窗內 JOIN arrival-fail 不觸發=dormant、我在 churn-fix branch 已量過 branch fp==base fp)·headless 又被環境 reap(5650 行止、只見已知 pre-existing ①②)→0-new 交 measurer·②wrapper timeout-kill race 已修 push main d18ff8fc(WaitForExit 有界 grace+FileShare::ReadWrite 讀+retry backoff+byte[] 不 unroll)、人工 timeout 驗 221 行 stdout 完整存活、正常路徑不回歸、對外行為未改(免 R² 條件成立)]"
branch: feat/labor-marginal-food-v2
commit: 383ec81e
---

# 小工單 done ×2

## ① labor-v2 疊 churn-fixed main（純 base 更新）

- `git merge origin/main` → **乾淨、零衝突**（如你預期：churn-fix 只碰 `faction_ai_system.gd`）。merge commit `383ec81e`，已 push。
- **labor-v2 邏輯零改動**：`git diff origin/main --stat -- scripts/simulation` 只剩那 4 檔（`food_flow` +7/-2、`labor_system` +41/-6、`marginal_economy` +12/-2、`resource_system` +4/-1）＝labor-v2 本體，無其他漂移。

| gate | 結果 |
|---|---|
| `labor_marginal_v2_test` | **7/7 PASS**（核心 ③ 仍 L1 2.00 < L2 4.00 < L3 6.00；對照舊 fill 式 L1==L3） |
| constitution | **PASS (sites=77, removed=0)** |
| determinism | **三跑 byte-identical**：`fp=ed832403654a4b887e2eb740a27219df` |
| headless | ⚠ 環境 reap（5650 行處中斷），可見範圍**只有已知 pre-existing**：`Team23 task=建設 order=-1`②×2、`弱目標未加入攻擊 goal`① → **0-new 請 measurer 正式判** |

### ★fp 說明（與你「新 fp 會變」的預期不同，先講清楚）
combined fp **等於 pre-merge labor-v2 fp**（`ed832403…`）。**不是沒疊到 churn-fix**——我在 churn-fix branch 交付時就量過：churn-fix branch fp **==** base main fp（同樣 `86c2fe82`），因為 a4 warring **1000 tick ≈ 4 天**內 JOIN commit 稀少、`join.timeout`/`join.abort_ghost` 兩條出路**未觸發**＝churn-fix 在該窗 **dormant**。所以 combined fp 不變是**一致且可預期**的，churn-fix 的行為差異只會在 churn-rich 長局現形（＝measurer 那輪 combined re-measure 才看得到）。
供 measurer 對照三個 fp：base main `86c2fe82`、churn-fix branch `86c2fe82`、labor-v2 combined `ed832403`（labor-v2 自己的行為變化）。

## ② wrapper timeout-kill race（已修，push main `d18ff8fc`）

三向全做：
1. `Kill()` 後 **`WaitForExit(5000)` 有界 grace**（不用無界，免 wrapper 自己掛住）。
2. 讀檔改 `Read-BytesTolerant`：`FileStream` + **`FileShare::ReadWrite`**（handle 還活著也讀得到）+ **5 次 × 300ms backoff retry**，全失敗才回空陣列。
3. 回傳 **comma-wrap + `[byte[]]` 轉型**——這是修的過程中撞到的第二個坑：PowerShell 會把陣列 unroll，**0-byte 檔（常見的空 stderr）會變成 `$null`** → `Encoding.GetString(null)` 直接爆，等於換一種方式吃掉輸出。

**驗**：
- 人工 timeout（`GODOT_TIMEOUT=8` 跑 `headless_test`）→ **被殺前的 221 行 stdout 完整落到 caller** + 尾端 `[GODOT TIMEOUT 8s - process killed]` 標記仍在。
- 正常路徑不回歸（constitution gate 照常 PASS、輸出完整）。
- **對外行為未改**（輸出格式／timeout 語意／exit code 全未動）→ 你的免 R² 條件成立，無需回頭走 R²。
- ASCII-only 維持（PS 5.1 無 BOM 讀檔限制）。

★順帶記帳（infra，給 measurer/後續輪）：`godot-detach.ps1` **只轉發白名單 env**（`WARRING_*`/`LADDER_*`/`SPECIMEN_*`/`LW_*`/`PERF_*`/`GODOT_TIMEOUT`…），且會把 `--` user-args 一併加引號 → **`--` 之後的 script 參數到不了 Godot**。新床要傳參請沿用白名單 env 名（我 churn 床就是這樣接 `LW_CONFIG`/`LW_MONTHS`/`PERF_SEED`）。要不要把這條也修成通用（白名單擴充或 args 直通）＝有對外行為面，等你裁再動。

地基 KEEP。
