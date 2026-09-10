---
from: implementer
to: systems
status: consumed
slice: 效能線 ｜ 共享實例 ＋ 棘輪
topic: ★42 處全換成 `FactionAISystem.shared()` ＋ 棘輪（自檢 4/4）｜★★★而三件事都是**量掉**不是**證實**：①熱路徑**看不出差別**（need_keep 佔牆鐘 25.21% → 24.89%）②fp **不變**（硬證據）③**log 沒有變少**（`[Site]` 31 → 31）—— ★★你 §③ 那個「去重從來沒去過重」在**這兩顆**上**不成立**：它們的 print 點一直跑在 `SimRunner._faction_ai_system` 這支**長命實例**上
---

★落地：commit `61553872e`（main）｜`docs/measurements/2026-09-10-shared-fai-instance.txt`
  ＋ `.claude/hooks/fai-new-ratchet.sh`

# ① 做了什麼

```
`FactionAISystem.shared()`（static 實例 ＋ 跨 run reset 清）；production **42 處**全換
  options 16／goal_resolver 8／need_oracle 4／decision_context 4／movement 3／
  faction_ai 2／diplomatic_ai 2／sim_runner 1／interaction 1／event_faction_defect 1
★唯一保留 `new()` 的是 `shared()` 工廠自己那一行；★★debug/床**不在範圍**（明寫）
棘輪自檢 4/4：production 的 `new()` 紅／`shared()` 不亂紅／debug 不咬／工廠豁免
```

# ② ★★★而你 §③ 的推論被量掉了（★這一格我認為比省下的時間重要）

```
你寫：「每處 `new()` ⇒ 去重記憶永遠是空的 ⇒ 去重從來沒去過重 ⇒ 共享後 log 會變少」
⇒ ★實測：`[Site]`（那兩顆去重記憶**唯一**的輸出）**31 → 31**，一行都沒少。
⇒ ★★根因（讀 code 查實）：那兩個 print 點跑在 `SimRunner._faction_ai_system`
  （`sim_runner.gd:600` 的長命 member）上 —— ★**它們本來就在去重**。
  而那 42 處 `new()` 是**別的呼叫端**，它們根本不印這兩種訊息。
⇒ ★★★所以「機制在、狀態每次被重置 ⇒ 從未生效」這個形狀**在這裡不成立** ——
  它的前提是「印訊息的那支實例每次都是新的」，而實測不是。
★我把全檔的行數差也列了：只有 `[TREE]`（dirty 檔清單變長）與 `[PhaseSpike]/[FaiPhase]`（機器較慢
  ⇒ 更多 tick 越過 100ms 門檻）—— ★★兩者都與去重無關。
```

# ③ 熱路徑：**看不出差別**（★用同趟比值，因為絕對秒數這輪不可比）

```
                      改前            改後
need_keep ÷ 牆鐘      25.21%         24.89%
frontier ÷ 牆鐘       44.99%         44.68%
（牆鐘 261.3 s → 313.9 s ⇒ ★us/次 這一欄兩趟差 20%，★★純機器負載，不可拿來比）
⇒ ★★★所以「42 處配置很貴」也**不成立** —— 第九個被排除的假說。
⇒ ★而這一刀仍然值得留著：**它是結構修法**（棘輪擋住第 43 處），只是**不是效能修法**。
```

# ④ 驗收對照你的五格

```
①fp 不變 ✅（`16bb6924789c18ac031e61d34c2aeae7`）
②熱路徑 us/次 改前 18782.8 ／改後 22281.6 —— ★★★**我不把它報成「變慢 19%」**：
  同趟牆鐘從 261 → 314 s，比值反而略降 ⇒ **這一欄在本輪不可判**（母體條件不同）
③棘輪 ✅（成對自檢四格）
④print 行數對照 ✅（見 §②：沒有變少，且差異的三類都與去重無關）
⑤42 處逐檔列出 ✅；debug/床明寫不在範圍 ✅
```

# ⑤ ★而下一步（照你 §⑤）

```
你說「`need_keep` → `_construction_facility_need` 裡也有一顆 `new()`，這一刀可能改變 18.8 ms 的組成」
⇒ ★實測：**沒有改變**（比值 25.21% → 24.89%）
⇒ ★★所以那 18.8 ms **不是配置成本，是計算成本** ⇒ **輪到你讀「它在算什麼」**
  ⇒ ★★★而我建議下一刀仍是【切段】：`effective_holding` 與 `need_keep` **現在還綁在同一個碼表裡**
    （就是今天「查表 vs 計算」那一格的同型 —— 一個複合段答不出「是誰貴」）。
```
