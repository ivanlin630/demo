# Team Reference 契約（通用化 team_id 引用解析）— Design

> 來源：2026-06-18。reference integrity 完成（`erase_team` chokepoint + `_check_no_dangling_team_id` audit → 無懸空 team_id 為真不變量）後，使用者指出消費端 204 個 `teams.get()` 各自 inline 判「ref 有效嗎」、慣例不一致（-1 哨兵與 dangling 存在檢查時而分開時而纏死），無通用化。趨勢要多做系統 → 趁不變量剛立、依賴它的 code 還少時通用化，避免複利成本。
> 目標：立「team ref 只有 -1 或 live」鐵律 + 強制它的存取函式，使消費端統一、自我說明、槓桿不變量，dangling 處理結構上無處可寫。

## 問題

`team_id` 是裸 int + `-1` 哨兵。每個消費點 inline 判有效性，把兩個語意不同的事混在一起：
- `tid == -1`：**語意上的「無」**（合法，永遠要處理）
- `not teams.has(tid)`：**dangling**（erase_team 後已不可能）

慣例不一致 → 兩形態：
- **形態 A**（少）：先擋 -1、再檢存在 → 存在檢查純 dangling → 可清。
- **形態 B**（多）：`if eid == -1 or not teams.has(eid)` 揉一起 + dangling 時自癒（設 -1）→ 纏死，不可乾淨拆。

無統一「解析 team ref」路徑 → 新系統照抄不一致慣例，debt 繁殖。

## 設計：鐵律 + 強制存取函式 + 納管範圍

### 鐵律
team 之間的引用只准兩種狀態：`-1`（無）或指向**保證存在**的 team。「指向已 erase 的 team」結構上不可能（`erase_team` 不變量 + `_check_no_dangling_team_id` audit 擔保）。

### 強制存取函式（WorldState）
```gdscript
# 解析「保證活」的 team ref。tid 必須非 -1（caller 先處理「無」）。
# 不存在 = 不變量被破（erase 漏清）→ assert 立刻喊（debug 崩抓 bug；release 中 assert 被剝離 → 不崩，保 1000-tick 韌性）。
func require_team(tid: int) -> TeamData:
	assert(teams.has(tid), "require_team: Team%d 不存在（team-ref 不變量被破）" % tid)
	return teams[tid]
```

消費端統一形狀：
```gdscript
if tid == -1:
	# ...語意上的「無」分支...
else:
	var t: TeamData = require_team(tid)   # 保證活，不檢 null
	# ...用 t...
```
→ team-ref 解析路徑**無 null**。「無」是顯式 `tid == -1` 分支（自我說明）。dangling 無處可寫（require_team 不回 null，只 assert）。

### 納管範圍（哪些 ref 走契約）
`erase_team` 會清乾淨的 team-to-team 引用 → 納管（保證 -1 或 live）：
- `TeamData.combat_target` / `order_target_id`（int）
- `TeamData.parent_team_id`（int）
- `TeamData.subteam_ids`（Array：每個元素必活）
- `FactionData.member_team_ids`（Array：每個元素必活）/ `FactionData.leader_team_id`（int）
- `WorldState.team_discovered[obs]` / `team_known[obs]`（Array：每個元素必活）

**不納管**（本就可能空、非 team-to-team 不變量 ref）→ 照舊 `teams.get()` + 處理：
- 玩家輸入來的 tid（UI/command，可能無效）
- 建立中／快照迭代期間可能已移除（`teams.keys()` 快照 + 中途 erase）
- 非 team 的 lookup（persons/tiles/factions dict）—— 與本契約無關

> 判準：ref 來源是「erase_team 維護的欄位/結構」→ 納管走 require_team；ref 來源是外部/瞬時/非管控 → 不納管。spec 附上述明確清單，plan 逐站按清單分類。

### 不變量守門
現成 `InvariantAudit._check_no_dangling_team_id` 已守納管結構（combat_target/order_target_id/known_reputations/strategic_assignments/team_discovered）。契約落地後此 audit 恆 0 = 鐵律成立的證明。

## 推行（中間版：立契約 + 新 code 強制 + 舊 code 批次清）

1. **立基**：`require_team` 加進 WorldState；`invariants.md` 寫「team ref 契約」節（鐵律 + 納管清單 + 統一形狀 + 不納管例外）。
2. **新 code 強制**：此後所有納管 team-ref 解析走 `require_team`（PR/review 規範；process 文件提示）。
3. **舊 code 批次轉**：
   - **批次 1（形態 A，低風險）**：已先擋 -1 的純 dangling 站 → `target == null` 自癒分支改 `require_team`（dangling 不可能 → 移除自癒）。
   - **批次 2（形態 B，逐站判讀）**：`-1 or not has` 纏死站 → 拆成 `if tid == -1: <無> else: require_team`，移除 dangling 自癒半。
   - 其餘非納管站不動。
   - 每批：headless 綠 + multi `_check_no_dangling_team_id` 維持 0。

> 批次邊界以「ref 類型」或「檔案」切，每批 ≤ 一個可審 plan。不需一次 204。

## 連動 / 風險

- **誤判納管 vs 非納管** = 最大風險：把「可能合法為空」的 lookup 改 require_team → 該情境 assert 崩。緩解：spec 的納管清單明確、plan 逐站對照清單分類、批次小、audit + headless 每批驗。
- **release assert 剝離**：assert 在 export release 被移除 → 不變量真被破時 release 不 assert，會走到 `return teams[tid]`（GDScript dict 缺鍵回 null）→ 下游可能 null deref。但這只在「不變量已被破」時發生（=已有 erase 漏清 bug），audit 在 debug/CI 早抓 → release 不該帶著破不變量出貨。可接受（debug 抓、prod 不為已修的不變量付韌性代價）。
- **GDScript assert**：`assert(cond, msg)` debug 有效、release 剝離 → 正好符合「debug 抓 bug、prod 不崩」。

## 測試標準

- `require_team` 單元測試：存在回 team；（debug）不存在觸發 assert（測試以 `teams.has` 前置判，不直接觸 assert crash headless）。
- 每批轉換：headless `=== DONE ===`、`_check_no_dangling_team_id` multi 維持 0、無行為差異（納管站語意等價：-1 分支不變、dangling 分支本就不可達）。
- 端到端：滅團/合併後納管 ref 解析不崩、無懸空。

## 範圍註

本 spec = 契約 + 基建 + 批次策略。各批次轉換各自 plan（writing-plans 拆）。批次 1（立基 + require_team + invariants.md + 形態 A）為第一個 plan；批次 2+ 後續。
