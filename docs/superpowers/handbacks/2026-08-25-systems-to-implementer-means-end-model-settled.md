---
from: systems
to: implementer
status: open
slice: means-end-brick
topic: ★手段模型定案(delta R² CLEAN)——四條裁決:①stock 不進價值比較只報形狀+tap ②形狀表准留但配機械 falsifier ③falsifier 要按【出處】分類非【字面】④比值那題留給量測不推理
---

# 手段模型**定案**，你可以往下做了

**delta R² ＝ CLEAN**（reviewer 親驗 + 一條自我訂正 + 一條對我的訂正，都收下）。

## ★四條裁決

### ①★**`stock` 資源本票【不進價值比較】**
**理由**：reviewer 自推 PV 證明 —— ★**stock 用 flow 尺 ＝ 系統性高估，且不對稱（只會高估或打平，不會低估）。**
⇒ **本票只做三件**：**回報「有此手段」＋「形狀＝`stock`」＋ 發 tap**。**價值比較留下一票。**
> ★★**寧可缺一個數字，不要一個錯的數字 —— 錯的數字會被下游當真，缺的不會。**

### ②★**形狀分類表【准留】，但必須配機械 falsifier**
**我不再要求「從結構導出」**（`capped-regen`/`loot` 確實沒有 registry 可導）。
**改判準**：
> ★★**「這張表變錯的時候，誰會發現？」——有機械答案才准留表。**

**falsifier 形狀**：**跑一輪開 `driver_ledger` 的 bed → 掃所有 `delta > 0` 的 `(資源, reason)` 對 → 出現任何【未分類】的組合 ＝ 紅。**
★**這比「新 resource 未分類＝紅」多抓一種：舊 resource 長出新增加路徑**（例：某天有人給 `gem` 加了 regen）。

### ③★★★**falsifier 必須按【出處】分類，不能按【字面】**
★**我自己差點埋雷**：`record_driver` 的 `field` 欄位**是混雜的** ——
`tags` / `readiness` / `solo_intent` / `loyalty` / `unrest_turns` / `outpost_owner` / `coin` **跟真資源名同欄**。
⇒ **直接掃 `field` 會把 `tags` 當資源**（＝ `constitution_gate` fingerprint 踩過的**混雜命中 collision**）。

**修法**：★**`WorldState.record_driver` 多帶 `kind`，由【bank 自己填死】，不是呼叫端填。**
（`resource_bank`/`tile_bank` 的 `res` 參數天生就是資源 ⇒ **來源即分類**。）
> ★★**用【出處】分類，不用【字面】分類 —— 字面會碰撞，出處不會。**

★**`driver_ledger` 的三個限制記住**：**預設關**（`world_state.gd:122`）、**ring-buffer `cap=4096` 標 `TEST VALUE`**（`:123`）、**冷啟動記不到**
⇒ ★**它是【離線稽核】工具，不准接進 runtime 決策路徑。**

### ④★**「哪個資源誤差最糟」——不推理，留給量測**
**需要真實 `gain_daily`（採集率）**。**reviewer 明說「我沒有也不編」，我同意。**
★**判準是比值 `gain_daily × H / S`，不是絕對量體** —— **絕對量體在這題沒有判別力。**

## ⇒ 交付閘（含前一封那三條，這裡是完整版）
1. **TDD：★缺設施 vs 缺原料分得開**（解法完全不同，分不開等於沒做）
2. **遞迴深度上限 ＋ 環偵測**（`ore_steel` 同時在 `out`/`in` 兩側，鏈深 ≥ 3）
3. ★**`horses` 在 `tile.public_storage` 不在 `tile.resources`** —— 只查後者會永遠回「無手段」
4. ★**「無手段終止」不得靜默：發 tap，帶資源名**（已進 `invariants.md`）
5. **估工時禁手抄 `rate`**（`rate_const` 是字串名，從 `ManufacturingSystem` 讀）
6. **`estimator-lineage-scan.sh` 綠**
7. ★**驗收判準優先【集合型】**：「無手段可取得桶 ＝ 空集合」；**別寫「2089 降到多少」**（事件數，分母會墊高）
8. **交接標【已落地 exact path】**
