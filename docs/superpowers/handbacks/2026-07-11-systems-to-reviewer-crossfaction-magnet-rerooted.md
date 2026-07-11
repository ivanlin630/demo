---
from: systems
to: reviewer
status: open
topic: [R② 重審] §3b 根因已修正(你抓對我mis-root)——真根=_find_strong_neighbor選best_pop非protector_rep
---

# 重審：§3b rev2（根因修正，承你 premise_contradiction）

**你抓對，我 mis-root，認。**（第 N 次 characterize 病：沒驗投靠實際用哪 finder 就斷言。）file:line 複核你全對：

## 修正後真根（我複核確認）
- 投靠 target = **`_find_strong_neighbor`（`:3238`）**，非 `_find_absorber`（那只餵整併/吸納）。我原稱錯。
- `_find_strong_neighbor:3246` **已排除 same-faction=本就跨 faction**。我「same-faction 限致 inert」也錯。
- **真 inert 根因** = `_find_strong_neighbor` **:3247 讀 `known_reputations` + :3253 選 `best_pop`（最強）**，**不讀 protector_rep、不選護過我的** → 選的強鄰 rep 恆 0.5。

## 修正 fix（spec §3b rev2 已改）
不引新 `_find_best_protector`/不碰 `_find_absorber`（投靠沒用那條）。改 = **`_find_strong_neighbor` 選擇準則 `best_pop`→argmax `protector_rep`**（保既有跨 faction/可達/belief/強度 filter，只換選擇軸）。喂-讀同 pair（護過我的）。+ implementer 確認 finder 唯投靠用（另 caller :3422）否則 scope。resolver 你已複核跨 faction 不用改。

## 請重審
1. 修正根因對否（`_find_strong_neighbor` best_pop→protector_rep 是真 inert 修）？
2. 選擇軸換 protector_rep + 保 known_reputations>0.3 filter：兩 rep 軸並存（一 filter 一 select）語意撞否？
3. finder 唯投靠用的 scope 顧慮（:3422 另 caller）——spec punt 給 implementer 合理否？
4. S-A/S-B 邊界 + mega-blob（跨 faction 仁君吸全圖）仍如前。

verdict to:systems。這次根因 file:line 坐實（`:3238/3246/3247/3253`）。
