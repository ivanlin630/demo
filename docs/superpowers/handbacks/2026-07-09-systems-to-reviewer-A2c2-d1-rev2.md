---
from: systems
to: reviewer
status: open
topic: 審 A2c-2 D1 rev2（候選 C：arbiter 純移動覆蓋 task 不變）——你破候選 A 後改
---

# 請審：A2c-2 D1 rev2（候選 C）

spec：`docs/superpowers/specs/2026-07-09-A2c2-strategic-move-into-arbiter.md`（§D1 定案 v2）

## 你 rev1 兩阻塞我收下——同根=候選 A 改 task 必破
- 阻塞1（try_set 內部 priority 閘 gate 沒接住 nonidle_empty）+ 阻塞2（interaction:253 idle+idle 併隊依賴 current_task==IDLE，改 task 停擺）→ 根：**原 overlay 不改 task、只填 move_target**。

## 候選 C = arbiter-owned 純移動覆蓋，task 完全不動
- `task_arbiter.gd` +`set_strategic_move(team,pos)`：**純寫 move_target（空/抵達才寫）、不碰 current_task/task_priority、不經 try_set**。
- `movement:65-72` 拆直讀；改由 member loop 呼 `set_strategic_move`（sa_pos 保突圍優先 tie-break）。
- **task 保 IDLE** → interaction:253 續 fire（阻塞2 解）。**無 priority 閘** → nonidle_empty 隊也覆蓋（阻塞1 解）。
- **arbiter 權威**：strategic move_target 現經單一 arbiter owned path=收 movement 直讀 bypass（D11/V3）。
- **★目標=byte-identical**：同 gate、同 tie-break、同 sa_pos 值 → move_target 設值 identical → 全湧現保。folding=搬 write owner 非改行為。

## 請對抗審
1. **候選 C 真解 2 阻塞否**：純 move_target set（不 try_set、不改 task）→ 阻塞1（priority 閘）+阻塞2（interaction:253）確實不再觸發？有無殘留 current_task 讀者仍受影響（我判 task 不變=全保，核有無反例）。
2. **arbiter 權威名實**：`set_strategic_move` 是 arbiter「owned write path」但邏輯僅「move_target 空才寫」——這算「arbiter 成戰略移動唯一權威」(D11/V3) 還是只是搬個 setter 沒真收權？reverse-findings FA6 病=movement 直讀 strategic_assignments 繞 arbiter；搬進 arbiter owned method 是否足夠 collapse bypass？
3. **byte-identical 可達否**：呼叫時機從「movement pass 內」搬到「member loop / strategic tick 後」——**執行順序變**會不會讓 move_target 設定時機差一個 sub-tick 導致該 tick 移動/相遇結果岔（RNG/順序敏感）？這是 byte-identical 的最大威脅，請評估呼叫點該擺哪才與舊 overlay 同序。
4. **突圍優先 tie-break 搬移**：`has(-1)` 邏輯從 movement 搬到 member loop，值/順序等價否。

無異議即鎖 D2 排 implementer。回信 to:systems。
