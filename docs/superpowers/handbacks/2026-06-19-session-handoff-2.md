# Session 交接（2026-06-19 #2，主SESSION02）

> 給重啟後新 session。承接 `2026-06-19-session-handoff.md`（#1）。main @ `bd95d4a`，全綠。
> 本 session **無 code 改動**，只做 backlog 盤點 + E-1 深挖 + 文件註記。

## 這串會話做了什麼

1. **讀 #1 交接 + known_issues + roadmap + trade-economy-review**，盤出完整 backlog。
2. **建 14 條 task**（task list 重啟即失，下方完整列出 = 真來源）。
3. **brainstorm #1（P6 遭遇戰收斂）E-1 深挖**，根因比原 known_issues 記的更深 → 已寫進 `known_issues.md` E-1 段（durable）+ 下方摘要。

## 待做 backlog（14 條，優先序）

> 用戶決策：trade 問4/5/6 一起做（offer-board 目標鏈）；先做 #1(P6) + #3(trade)，兩者皆 spec 級分開 brainstorm；**Bug2 不列**（複驗已實質關閉，roadmap 那條 stale）。

**🔴 高（卡可玩性）**
- **#1 P6 遭遇戰收斂（E-1/E-2/E-3）— spec**（in_progress，brainstorm 中，見下深挖）
- **#4 B-1 收留撞 pop_cap 守恆破**：`player_command_system:757/760/763` 先用意圖值算 cost/joined 再 merge，capacity<=0 時 transfer=0 但食物已扣（憑空蒸發）+ msg 謊報。修：cost/joined 改 merge 後量測 delta，或 merge 前驗 capacity 0 容量拒。**孤立 bug，直接修，無通用可言**。
- **#5 A-1 記名招募 TextUI 死路**：recruit 回 payload menu，但 `text_ui_main.gd` team-target handler(916-977) 不消費 → recruit_named 不可達（功能寫在停用的圖形 main.gd）。修：把 recruit menu 消費搬進 text_ui_main。**孤立 bug，直接修**。

**🟠 中**
- **#2 戰俘處置 — spec**（賣/屠/招降/釋放/勞役，接 P6）
- **#3 trade 問4/5/6 → offer-board 目標鏈**（用戶要一起做）：問4 商隊套利視野窄、問5 靜態 target 需求飽和(疑 W2 trade 量低最深根)、問6 coin 通縮+offer-board。樞紐：offer-board 是三者共同解（offer 指定付Y貨→解 barter；失衡湧現=需求訊號解問5；取代 _find_trade_target 解問4）。**未定決策：offer=線索 or 合約（傾向線索）**。詳 `docs/notes/trade-economy-review.md:43-92`。要 brainstorm→spec。
- **#6 W8 coin 產出鏈激活 — spec**（金銀礦從沒挖、鑄幣廠從沒用，休眠機制家族）
- **#7 玩家主動生存動作對稱(P4-3) — spec**（NPC 會乞討/投靠，玩家無 command）
- **#8 task 優先權仲裁(Spec A) — spec**（current_task 被 5+ 系統互蓋，優先表已設計）
- **#9 NPC 勒索活化(Bug5) — spec**（休眠，方向反，要翻成強勒弱）
- **#10 W4 層2 NPC train AI + 遊牧 leader 駐留建造**
- **#11 人口循環受窮困抑制 — tune/spec**（multi 90天 0 次長大）
- **#12 山村採礦換糧特化經濟 — spec（階段3+）**

**🟡 低/想法（notes）**
- **#13 分層評估頻率單一源**（`docs/notes/2026-06-08-tiered-evaluation-frequency.md`）
- **#14 戰鬥接觸深度（接 P6）**（`docs/notes/2026-06-10-combat-engagement-brainstorm.md`）

**通用 vs 逐修判斷**（用戶問過）：真共根值得想架構 = #3 trade offer-board、#8 task 仲裁。孤立 bug 直接修 = #4 #5。休眠家族(#6/#9/#10) 有共根但**別現在做通用**（防戰略引擎無底洞，守不追 NPC 完美化）。

## #1 P6 brainstorm 進度（深挖，未定案）

**E-1 兩個獨立病灶疊加**（比原 known_issues 深，已寫入 known_issues E-1）：
1. **結構免疫**：encounter 只 spawn 上場 units = `named + mini(pop×armed_anon_ratio, ANON_UNIT_CAP)`（encounter:247-248）；死亡 kill_random 只記上場陣亡(:1186-1194) → 未上場 anon mass 永不在 kill 池。
2. **繼承分叉（違單一真值源）**：`event_system.on_leader_death:47` named 不足→從 anon 晉升（符合設計、用戶記得的行為）；但 faction_ai 偵測點(:502) gate `not named_members.is_empty()` + `_promote_successor`(:1066) 只從現存 named 拔、無 anon fallback → 遭遇戰打到 named 全滅 = 永久 leaderless anon blob（玩測觀察到 named 不再生）。generate_for_team 只被 npc_combat:456 + subteam:161 呼。

**關鍵推論**：單修繼承會回「named 工廠」死循環，仍不收斂。**必須 繼承統一 + 敗方 pop 損耗(模型 A) 兩件一起** → anon 漸減→0→無人晉升→on_leader_death 回 false→團崩潰滅團(event:54) = 真「打到死」。

**收斂模型（待用戶定）**：A底(敗方pop損耗,force_occupy:1424 已有 20% 損耗先例可複用)+B層(subjugate/驅散,接戰俘#2)。C 武裝率下限否決。+ 繼承統一(faction_ai 偵測併到 on_leader_death 同一條,拿掉 gate)。leaderless+anon blob 走向待定:(a)再生 leader (b)崩潰/吸併。

**spec 前還沒挖**（next step）：
1. **npc_combat vs encounter 分叉（最重要）**：NPC-vs-NPC 可能走 npc_combat（已自帶 on_leader_death+可能 pop 損耗）→ 也許 NPC 世界自己收斂、只玩家介入的不收斂 → **可能大幅縮 E-1 範圍**。下一步先挖這個。
2. encounter 觸發/spawn 端（只讀了結算端）：誰發起、為何反覆刷弱隊、spawn 時未上場 pop 怎記。
3. `ANON_UNIT_CAP` 值。
4. retreat/draw 是否常態結局（接 E-2，則連現有 pop 損耗都不觸發）。

**E-2** AI 死戰：`RETREAT_TEAM_RATIO=0.7`(encounter:43) 隊級殘廢比，1-unit 小隊只在該 unit 殘到 0.7 才退。需絕對 HP/敵我懸殊判定。
**E-3** 玩家走戰場邊無逃離：`has_exited`(encounter:636) 機制在，玩家輸入 wire 待查 encounter_view。

## 起手（新 session）
1. 接 #1：先挖 npc_combat vs encounter 分叉（定 E-1 範圍）→ 續 brainstorm → spec。
2. 或先清孤立 bug #4/#5（快、卡可玩性、無 brainstorm 需求）。
3. #3 trade offer-board 另開 brainstorm。

## 未提交
- `known_issues.md` E-1 深挖註記（本 session 改，**待 commit**）。
- 本交接 doc。
- `scripts/debug/qa_probe.gd` 仍 untracked（QA 暫時工具）。

## 工作流提醒（記憶已存）
- L1/L2 spec/plan→子 session；L3 主 session 可直改。禁東修西補，維持單一真值源。
- 確定性回歸閘：headless + coin_eq（非 multi drift）。
- 別問技術微決策；ctx ~90% 才提醒交接。用戶戳破假設就停止理論化（本 session 我先把繼承講成「刷新得太好」，用戶說「沒看到 named 刷新」→ 修正為繼承路徑壞了）。
