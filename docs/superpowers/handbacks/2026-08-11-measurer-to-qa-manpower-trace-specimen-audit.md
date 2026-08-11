---
from: measurer
to: qa
status: open
topic: "[請QA故事稽核:指標團(Team0)人手池sharpened trace——3筆spinoff事件(t100/t700/t1000)全發生在非日邊界tick(100/700/1000,均非240倍數),code-read找到event_system.gd:55(Succession named-successor分支)可離峰直呼check_overflow_for_team的旁路,但我未能在本輪內確認t100那筆真正的觸發鏈(是否真的是某次領袖replace連鎖call、或有我沒找到的第三條路徑)——★★這是我報告裡唯一『不確定』的因果環節,其餘(anon→named晉升/famine/dispatch)都有明確Probe訊號佐證。★也請核:團4/團5其後merge回Team0(named非anon)是否真如log字面'完全合併'般乾淨(有無資源/anon桶遺失)。specimen已附team0(+spinoff團4/5/6動態納入)。"
---

# 請QA故事稽核：指標團人手池 sharpened trace 的不確定環節

sharpened ticket(`2026-08-11-systems-to-measurer-manpower-trace-sharpened.md`)已產表回 systems（並行送你）。這份是**附帶的 specimen 稽核請求**——依 §長跑必附 specimen hook（用戶定 2026-07-22），本表的 type/blind_check/guess 欄位屬 behavior-causal 歸因，鎖之前需要你讀 motive→action→outcome。

## 需要你核的兩點

### 1）★★t100/t700/t1000 三筆 spinoff 的真正觸發鏈（不確定，我誠實標了）
`check_overflow_for_team`（population_system.gd:24）正規只走日邊界（sim_runner.gd:231 `tick % TICKS_PER_DAY==0`，即 tick 0/240/480...）。但我這輪三筆 spinoff 都發生在 **tick 100 / 700 / 1000 —— 全部不是 240 的倍數**，不可能是正規日檢。

Code-read 找到唯一的離峰旁路：`event_system.gd:55`（Succession 系統，named-successor 分支）會在任何團的領袖被替換、且替補者是「有名字的既有成員」時，額外直呼 `PopulationSystem.new().check_overflow_for_team(state, team.team_id)` —— 不受日邊界限制。

**但我沒能在本輪內確認**：t100 那次是否真的踩到這條旁路（需要往前找 Team0 在 tick100 之前是否發生過領袖替換事件），還是有我沒 grep 到的第三條路徑。請你用 specimen 讀 Team0 tick 0-100 的完整 motive→action→outcome，核實這條因果鏈是否成立。

### 2）Team4/Team5 merge 回 Team0 的乾淨度
Log 字面顯示「[Merge] Team0 ← Team4 完全合併」發生兩次（day1、day3附近）+「[Merge] Team0 ← Team5 完全合併」一次（day4附近）——即部分 spinoff 團事後合併回 Team0（但作為 named member 非 anon，故我的 anon 專欄未顯示變化，這是設計上正確：問題問的是 anon 池，merge 增加的是 named 席位非 anon）。請核：這幾次合併有沒有資源/anon 桶在合併路徑上憑空消失（S9/S11 chokepoint 是否都走了）。

## 落地檔案
- `scripts/debug/scale_econ_manpower_trace_bed.gd`
- `docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed8181.json`（結構化表）
- `docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed8181-raw.txt`（完整 log）
- `docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed8181.specimen.jsonl`（374 entries，Team0 + 動態納入的 spinoff 團4/5/6）

其餘欄位（anon→named 晉升、famine、dispatch 事件）都有明確 Probe key 佐證，不需要你重新驗證因果——只有上面兩點是我報告裡的不確定環節。
