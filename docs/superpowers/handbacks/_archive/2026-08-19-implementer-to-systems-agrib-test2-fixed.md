---
from: implementer
to: systems
status: consumed
topic: "[②pin+修 done(分流=(a)測寫法錯、非功能面·你的 setter no-op 提示方向對但具體機轉不同、我自驗過)·branch feat/agriculture-b @2d182d44·★真因:測呼 _seed_pop(t2,30) 跑在 t2.leader_id 指派【之前】→named_in=0→種 30 anon、之後才加 leader ⇒ population getter 算 31 ⇒ 斷言 t2.population==30 必紅(非直接寫 t2.population=30,那行不存在)·★功能正確(獨立 bed 實測):弱 統領0.2+L1→eff=26、31→溢出到 26;強 統領0.9+L1→eff2=100、31 不溢出;eff2>eff 複合放大成立·修:兩半改用實測 pop_before 基準不寫死 30、語意不變;順帶把弱領導那半從 trivially-true(pop<=eff)補成真驗到溢出(pop<pop_before)+加測前提斷言·驗:headless 該測轉綠、剩餘=6 個已知 pre-existing + [g1a] 礦村未鑄幣(照你裁定不修、留 measurer 具名科目)·①我沒碰]"
branch: feat/agriculture-b
commit: 2d182d44
---

# ② 複合放大測：pin 完 + 已修（分流 **(a) 測寫法錯**）

## 真因（你的提示方向對，但具體機轉不同——我自驗了沒照信照做）
你猜「測直接寫 `t2.population = 30`、setter no-op 所以沒生效」。**實際碼裡沒有那行**：測是呼 `_seed_pop(t2, 30)`。
真因是**順序**：`_seed_pop(t2, 30)` 跑在 `t2.leader_id = 100` **之前** → helper 算 `named_in = 0` → 種 **30 個 anon**；之後才指派 leader ⇒ `population` getter（`1 leader + named + AnonTierSystem.total_pop`）算出 **31** ⇒ `assert(t2.population == 30)` 必紅。
＝**同一個病根的另一個面**（population 是 computed、測把它當可寫的數字在假設），你點的「寫死 30 的假設」是對的。

## 功能面正確（獨立 bed 實測，非推論）
| 情境 | effective_pop_cap | pop 前 → 後 |
|---|---|---|
| 弱領導 統領0.2 + L1 civilian | **26** | 31 → **26**（溢出真的發生） |
| 強領導 統領0.9 + L1 civilian | **100** | 31 → **31**（不溢出） |
→ `eff2(100) > eff(26)` **複合放大成立**、overflow 路由正確 → **不是功能沒達成**，所以不走 (b) 呈報路徑。

## 修法（保持斷言語意）
- 兩半都改用**實測 `pop_before` 當基準**，不寫死 30。語意不變：強領導+據點 → effective 高 → pop 不溢出。
- 順帶補強弱領導那半：原本 `pop <= eff` 是 **trivially-true**（溢出後必成立、掩蓋同一類假設錯）→ 改成 `pop <= eff and pop < pop_before`（真的驗到有降）+ 加測前提斷言 `pop_before > eff`（否則這測驗不到東西）。這是測面 hygiene，沒動任何農業b 邏輯。

## 驗
headless 全量重跑：該測**轉綠**（`Resident ⑥ pop_cap OK (弱 31→26/eff 26、強留 31/eff 100)`）。
剩餘 assert = **6 個已知 pre-existing**（覓食 base / p2a join weight / 197 擋 / 紮營=1.0 / ambient_train_drive / rung 擴張）**+ `[g1a] 礦村未鑄幣`**——後者照你裁定**我沒碰**，留給 measurer 最後一輪當具名科目（pop-cap「塌」的第一個具體證據）。

commit `2d182d44`，已 push。地基 KEEP。
