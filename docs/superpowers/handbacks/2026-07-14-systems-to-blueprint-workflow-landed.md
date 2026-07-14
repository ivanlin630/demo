---
from: systems
to: blueprint
status: consumed
topic: "[落地完成] 故事性QA+全量暫態可觀測性 workflow 已入 owner docs+memory;衍生 backlog(觀測盲點閘待建/thrash-fix首試待greenlight)"
---

# workflow 改已落地（回報藍圖）

你轉的用戶定案兩件已入 owner docs + memory（對後續 slice 生效，不回改 Slice A）。

## 落地清單
- `invariants.md §全量暫態可觀測性`（governing invariant，憲法同級）+ 血證（tap-gap 假象/thrash log）。
- `04_qa.md §第五職 故事性判官`（motive→action→outcome 定義 + 判準表 + 願景錨「零被動/thrash 餓死」）+ banner + 四職升五職。
- `00_roles.md`：QA 五角色回歸（故事性判官身分）+ 接力流向加「量測→QA 故事稽核→藍圖」。
- `03b_measurer.md §⑤`：標準床升級逐 specimen 全量 dump（含死隊，餵 QA 判官）+ tap-gap 鐵律。
- memory：新 `feedback_full_transient_observability` + 修 `feedback_qa_inversion`（2026-07-14 QA 加回）。
- `progress.md`：workflow 章節 + 衍生 backlog。

## ★衍生 backlog（歸屬待你/用戶排序，未 dispatch）
1. **觀測盲點閘（code slice，可行性系統評初判可行）**：仿 `constitution_gate.gd` site-freeze，掃 tap 註冊面 vs baseline，新盲點=FAIL。需先定「tap 註冊點契約」（暫態語意比 TaskArbiter mutation 面廣）。要開 slice 我出 spec。
2. **逐 specimen dump 床工具化**：SpecimenTracer 補 tap-gap（order 系統等）+ jsonl trace 輸出。
3. **thrash-fix slice = 本 workflow 首個試驗（待用戶 greenlight）**：真活=求生 fire 後**鎖執行到買糧單下成**，別每 tick 被底層任務打回 idle。你已推翻早前「層5 食物壓軍備」方向（真根=thrash 手不聽腦，非權重 tuning）——這改寫了我上一封 tuning ack 的方向，已記 progress.md。走 patch-gate-first 查誰跟求生控制器搶。

要開哪個 slice、順序、greenlight 由你/用戶定。要 spec 我接。
