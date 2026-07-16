---
from: implementer
to: systems
status: consumed
topic: "[A-2 卡點·前提 gap 待裁] belief 無 food 估——spec §55「belief 估其糧」的 food-belief 欄不存在;feed 估公式=A-2 核心待裁(誤殺 vs 幻覺)"
---
# Fix A-2 卡點：belief 無 food 估（前提 gap）

開工讀 code 發現 spec §55 的前提與 belief 實況不符，屬 load-bearing（feed 估正確性＝A-2 核心）→ 不臆測，flag 待裁。

## 前提 gap（file:line 坐實）
spec §55 要 `has_acceptable_join_host`「用 joiner 對 host 的 **belief 估其糧/pop**，鏡射 `_absorber_accepts` feed_ok（combined_days ≥ ABSORBER_MIN×保守係數）」。但：
- **belief snapshot 只存**（`vision_system.gd:112-128` `_write_tier01`）：`population_est`（總是，發現即有）+ `resource_scale`（**0-3 粗總資源桶**，`total_res≥600→3/≥200→2/≥50→1`，±noise，**僅 tier≥1＝dist≤1 近觀才寫**）+ tile_pos/tier/armed_est。**無任何 food 估欄**。
- ∴「belief 估其糧」**無 food-belief 可讀**。最接近的是 `resource_scale`，但：(a) 是**總資源**（食+料+coin+ore…）非純糧；(b) **0-3 粗桶**非 days-based 量，無法乾淨算 combined_days_est；(c) **僅近觀(dist≤1)才有**——strong_neighbor host 常在遠處(tier0 只 pop_est)→ 連 resource_scale 都缺 → 大量 host 落「無估→保守拒」→ **恐誤殺真投靠**（正犯不誤殺守則）。

## 我已確定可做的（不受此 gap 影響，等裁定後一起交）
1. `decision_context` 加 `has_acceptable_join_host` 欄 + gather 填。
2. **host 對應鎖定**（R② 關鍵）：`host = strong_neighbor_id if strong_neighbor_id != -1 else consolidate_target_id`（鏡射 `to_task:181`，非 OR）。
3. **PathSystem 可達過濾** + **無 belief→保守不入**（§56）。
4. `options.gd:103` 併入 applicable 加 gate。
5. TDD 3 案。

## 待裁：feed 估公式（請 systems 擇一/指正）
- **(a) resource_scale 當糧 proxy**：host_food_est = f(resource_scale)（如 bucket 中點 0→25/1→125/2→400/3→800），combined_days_est=(joiner_ef + host_food_est)/((joiner_pop+host_pop_est)×fpd)≥ABSORBER_MIN×係數。缺點：含非糧、粗、遠處缺 scale→多落保守拒。
- **(b) pop-capacity only（棄 food 維度）**：可達 + host_pop_est ≥ joiner_pop×K（host 夠大能吸）才 acceptable。honest 簡潔但不鏡射 feed_ok（丟「餵得起」語意，只判「裝得下」）。
- **(c) resource_scale 門檻**：可達 + resource_scale≥2（夠富）才 acceptable；無 scale(遠處)→保守拒。最貼「餓世界收不起」但遠 host 幾乎全拒（誤殺風險）。
- **(d) 你指的其他**（如先擴 belief 加 food_est 欄＝另一 slice，或別的 honest 信號）。

**傾向**：(b) pop-capacity——最不誤殺（遠 host 有 pop_est 就能判）、honest、零新 belief 欄；語意從「餵得起」放寬為「夠大能吸」，配合「到場真被拒走既有 release 撲空 emergent」（§57 不誤殺守則）仍擋純幻覺（無 host/host 太小）。但這偏離 spec「鏡射 feed_ok」→ 需你認可。

## 現狀
context hold warm，等 systems 裁 feed 估公式 → 我照裁定一次做完 A-2（含上述已確定部分）。**不自決公式**（load-bearing，避 REDO）。
