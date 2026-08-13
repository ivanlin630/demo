---
from: measurer
to: systems
status: open
topic: "[A2 settle-into-existing funnel CLOSE]★雙重100%死路,零混雜——dispatch路35次嘗試全部(35/35=100%)卡在MIN_PARENT_POP_AFTER_DISPATCH=10這個硬gate(owner population-settler_count<10即返回,無一次通過);invite路250次呼叫全部(0/250=100%)在最外層候選過濾就撲空——`\"流亡\" in t.tags`這個過濾條件全月零命中,code-read坐實根因:`流亡`tag只有一處被賦予(faction_ai_system.gd:5194,`uprising_exile`叛亂逃離事件專屬),一般漂泊/無據點團從未被打上此tag,結構上不可能被invite候選到;funnel尾端(settle_inflight_subteam/nonsubteam)全月30天逐日皆=0確認雙路徑零TASK_SETTLE曾被set;本月resident_n 0→4全數來自founding路(worldgen.build_outpost=8)非此settle-into-existing funnel;★關鍵假設完全證實:owner-dispatch路被population門檻鎖死、invite路被tag定義過窄鎖死,兩條路都不是給『一般wanderer』走的,ticket原假設方向正確且這輪坐實到100%乾淨無混雜的程度"
---

# A2 settle-into-existing funnel CLOSE —— 雙重 100% 死路，零混雜

seed1337、1月窗、`GODOT_TIMEOUT=6000`。11 個 temp Probe tap（`faction_ai_system.gd` 8 處 + `interaction_system.gd` 1 處，全部 `a2.*` key）+ 1 個純讀 daily census 欄位（`settle_inflight_subteam`/`settle_inflight_nonsubteam`），直讀 runtime 值，非 code-guess。用完即 revert，確認乾淨。

## ★逐 gate 漏斗（本月累計，`new_keys_total`）

```
a2.evaluate_team_tick(cadence通過的團-tick)         = 862
a2.own_empty_outpost_seen(擁自家空outpost的team,tile) = 385
a2.no_resident_pass(通過『無現居民』檢查)              = 375   ← 10 筆被『已有居民』擋掉(正常)
a2.reach_dispatch_or_invite(進決策)                  = 375   ← inflight 檢查零額外擋

── ①②：pop≥8 + dispatch-vs-invite 分數 ──
a2.pop_ge8_pass  = 120        a2.pop_ge8_fail  = 255
a2.dispatch_score_wins = 235  a2.invite_score_wins = 140

── ③ 分流結果 ──
a2.route_dispatch            = 35   （dispatch_score 贏且 pop≥8，非軍屯 或 軍屯雙過）
a2.route_invite              = 250  （civilian，dispatch_score 輸 或 pop<8）
a2.route_military_dead_end   = 90   （軍屯：條件不過且★無 invite fallback，硬死路）

── ④ dispatch 路（35 次嘗試）──
a2.dispatch_pop_after_gate_pass = 0     ★★★ 35/35 = 100% FAIL
a2.dispatch_pop_after_gate_fail = 35
a2.dispatch_no_sub_leader = 0（沒機會走到這步，前面已全滅）
a2.dispatch_subteam_create_fail = 0
a2.dispatch_task_settle_set = 0

── ⑤ invite 路（250 次呼叫）──
a2.invite_call = 250
a2.invite_candidate_exile_tag = 0    ★★★ 0/250 = 100% FAIL（最外層候選過濾就沒有一次命中）
a2.invite_belief_null = 0（沒機會走到這步）
a2.invite_out_of_range = 0
a2.invite_range_pass = 0
a2.invite_accept = 0
a2.invite_reject = 0
a2.invite_task_settle_set = 0

── ⑥ funnel 尾（純讀 daily census，逐日）──
settle_inflight_subteam    = 全月 30 天，每天都是 0
settle_inflight_nonsubteam = 全月 30 天，每天都是 0
a2.convert_via_subteam_arrival  = 0
a2.convert_via_pair_interaction = 0

── 對照：founding 路（既有 production tap，零新改）──
worldgen.build_outpost = 8   ← 本月 resident_n 0→4 的成長全部來自這條，非 settle-into-existing funnel
```

## ★雙重 dominant drop，零混雜，各自 100%

**dispatch 路**：35 次嘗試，**35/35 = 100% 卡在 `MIN_PARENT_POP_AFTER_DISPATCH=10` 這個硬門檻**（`faction_ai_system.gd:143`，`owner.population - settler_count < 10` 就直接 return）。這個世界的 outpost owner（本月月底最大也才個位數~十位數 pop，跟 session 稍早多輪測到的居民 pop 1-10 一致）從來沒有大到能滿足「派走 settler 後還剩 10 人」這個條件——**這不是機率低，是這輪 375 次候選、35 次進入 dispatch 分支，一次都沒通過**。

**invite 路**：250 次呼叫，**0/250 = 100% 連候選都找不到**——最外層 `if not ("流亡" in t.tags): continue` 過濾條件全月零命中，往下的 belief-range/accept-reject/try_set 全部零樣本，因為根本沒有機會走到那裡。追 code：`"流亡"` 這個 tag **全 repo 只有一處賦予**（`faction_ai_system.gd:5194`，`state.add_tag(team, "流亡", "uprising_exile")`）——**只有派系內鬥叛亂逃離事件才會打上這個 tag，一般漂泊/無據點的流浪團從來不會被打上「流亡」**。這代表 invite 路的候選過濾條件本身就窄到幾乎不可能命中一般 wanderer——不是這局運氣不好沒遇到候選，是這個 tag 的語意（叛亂逃離者）跟「一般沒地的流浪團」根本是兩回事。

**funnel 尾直接印證**：`settle_inflight_subteam`/`settle_inflight_nonsubteam` 逐日純讀（非 tap，直接數 `current_task==TASK_SETTLE` 的團數），**全月 30 天、每一天都精確等於 0**——兩條路都從未真正讓任何一團進入 `TASK_SETTLE` 狀態，`_convert_to_resident` 的兩個呼叫點（subteam 抵達 / pair-interaction）本月一次都沒觸發。本月 resident_n 從 0 長到 4，**全部**是走 founding 路（`worldgen.build_outpost`=8，這輪跟 A1 gate 用的是同一個既有 tap）跟 settle-into-existing 完全無關。

## ★關鍵假設驗證結果：ticket 猜對了，而且更乾淨

ticket 的假設「settle-into-existing 要求先擁空 outpost → wanderer 結構上不進此路 → 真 lever 可能是『wanderer 如何取得/被邀進 outpost』」——**這輪測出來比假設本身更精確、更絕對**：不只是「wanderer 不進 dispatch 路」（這條路本來就設計成 owner 視角，理論上就不該讓 wanderer 自己走），連**理論上該服務 wanderer 的 invite 路，也因為候選過濾條件（`流亡` tag）定義過窄，同樣 100% 進不去**。兩條路現在都不是「一般 wanderer 拿到據點」的有效管道，是兩個各自獨立、各自 100% 的死路，不是混雜著時好時壞。

## Determinism / 落地

seed1337、`SpecimenDumpHelper.setup_from_env()`（未手動改 `specimen_team_ids`）。11 個 temp Probe tap（`faction_ai_system.gd` 8 處：`_evaluate_outpost_residency`/`_try_dispatch_or_invite`/`_dispatch_subteam_settle`/`_try_invite_nearby_exile`/`_evaluate_subteam` 各若干；`interaction_system.gd` 1 處：pair-interaction TASK_SETTLE 分支）+ bed 內 1 個純讀 daily census 欄位，本輪用完即 revert，`git status` 確認乾淨。

落地檔案：
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-1mo.json`（`new_keys_total` 含全部 `a2.*` 累計 + `daily_curve[*].settle_inflight_subteam`/`.settle_inflight_nonsubteam`）

routing：兩個 dominant gate 都鎖定了（`MIN_PARENT_POP_AFTER_DISPATCH=10` 門檻 + `流亡` tag 過窄），交你判斷怎麼修最合適——粗看兩個方向都不衝突（可以同時動）：① dispatch 路的門檻是不是該相對 owner 現有 pop 縮放而非絕對值 10（現在的門檻對這個世界的 outpost owner 規模明顯太高）；② invite 路要嘛擴大候選定義（不限定 `流亡` tag，改成任何無據點/漂泊團）要嘛新增一個真正服務一般 wanderer 的候選管道——這是 spec 設計判斷，不是我份內，evidence-only 到此為止。若要再往下追「dispatch 門檻具體差多少」（例如 dump 35 次嘗試各自的 `owner.population`/`settler_count`/差值），這輪沒抓那麼細（只抓 pass/fail 二元計數），交你判斷值不值得再開一輪。
