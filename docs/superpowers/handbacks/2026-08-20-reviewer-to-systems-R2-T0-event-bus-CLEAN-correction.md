---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=T0事件匯流排CLEAN+1必查項(★事件盤點漏一個真實函式chokepoint:_execute_betrayal零emit_message、不在任何三類清單裡,受害方ally_team不會瞬醒)+5問全答覆(`2026-08-20-reviewer-to-systems-R2-T0-event-bus-CLEAN-correction.md`)]"
---

# R② 判決：T0 事件匯流排（效能 arc slice A）

**判決 = CLEAN + 1 必查項**。你點名要我獨立掃一遍事件源,掃到一個真漏洞——`_execute_betrayal` 不在任何一類清單裡。

## citation 親驗
- 17 個 `emit_message` type 親 grep 全站取出實際字串,逐一核對你列的清單（`combat_start`/`combat_end`/`famine_warning`/`faction_defect`/`faction_establish`/`diplomacy`/`extortion`/`subjugate`/`tribute`/`aid_given`/`aid_refused`/`trade_done`/`order_*`/`order_delivered`/`outpost_built`/`split`/`replace`）——**數字與內容全對得上**,無遺漏無多算。
- `start_combat`/`on_leader_death`/`erase_teams` 三個函式 chokepoint：`on_leader_death`(event_system.gd:31-66) 跟 `erase_teams`(world_state.gd:286-357) 我在別輪（succession-lite/observer-never-freeze）已逐行讀過,坐實存在。`_on_team_extinct` 未逐字重驗但跟前科同一族,信任。
- `_detect_survival_stall`(faction_ai_system.gd:4957+) 親讀確認**不是**你講的「跨餓線」偵測——它偵測的是「已承諾的求生選項有沒有 stall」,跟「food_days 第一次跌破安全線」是不同概念,**你 §2「狀態跨線型目前連偵測點都不存在」的判斷屬實,不是漏找**。

## ★必查項：`_execute_betrayal` 是真實存在、零覆蓋的第五個函式 chokepoint
親 grep `diplomatic_ai_system.gd` 全檔 `emit_message`——**零命中**。`_execute_betrayal`(我在繼承-lite那輪讀過這段:`state.clear_team_faction(self_team)` + `ally_team.update_reputation(self_team.team_id,-0.5)` + 寫 memory)**不經 emit_message、也不在你列的四個函式 chokepoint 裡（`start_combat`/`on_leader_death`/`_on_team_extinct`/`erase_teams`)**——這是一個真實存在、你三類清單都沒接住的事件源。

**後果**：背叛發生時,**被背叛的一方**（`ally_team`,聲望被砍、被劃出plans之外)不會被 T0 瞬醒——牠要等自己的下個 cadence 才會重新評估（是否該防禦/報復/調整信任),這正是你 §5 自己點名的風險（「該想的時候沒想,比慢更糟」)的一個具體活案例,不是假設。

**必查項**：`_execute_betrayal` 補進函式 chokepoint 清單（第五個),對 `ally_team`（受害方)標 `pending_rethink`。這條不需要重送 R②,dispatch 信裡帶給 implementer 即可。

## 五問逐條答覆
**① A1/A2 拆分值不值得多一輪**：值得,而且我想不到單輪內分離量測的辦法——兩者一個加計算一個減計算,要獨立歸因只能有「只做 A1 那半」跟「A1+A2 都做」兩個可比對版本,這本質上就是兩輪(不管你怎麼包裝量測方式,對照組跟實驗組的差異天生就要求兩套設定)。多一輪 dispatch 的代價換到「淨值可歸因」,划算,支持你拆。

**② 全量事件盤點**：見上,漏了 `_execute_betrayal` 一個。其餘我想過的候選（威脅感知上升/天災天候/繼承後續)——威脅感知合理歸進你「關鍵情報抵達」那條(belief 更新);天災天候你自己在時間 spec §3b 已經框成「未來 T0 型事件,現在還沒建」,本 spec 掃現況不用管;繼承(succession-lite 那輪我審過的 `succeed_or_disband_faction`)還沒落地,等它 merge 後才需要考慮要不要也掛 T0（那時候的事,非這輪責任)。**只有 betrayal 這一個是現在就該補的**。

**③ 對帳守衛擋不擋得住白名單挑食**：**只保護第一類（`emit_message`)**,對第二類（函式 chokepoint)跟第三類（狀態跨線)**完全沒有結構性保護**——這正是我剛好抓到 betrayal 漏洞的原因（它連你清單都沒列到,守衛自然也管不到)。你自己在③的問句裡已經預見「不經 emit_message 的新事件源」這個繞過口,**這個繞過是真的、不是杞人憂天**。**建議**：第二/三類至少上一個弱一點但有牙的機制——例如統一約定 chokepoint 函式頂端加 `# T0-CHOKEPOINT: <event>` 這種可 grep 的標記註解,另開一支輕量 debug 腳本掃全 `scripts/simulation/*.gd` 找「看起來像重大狀態轉換但沒有這個標記」的可疑函式（可以先用簡單啟發式,例如函式名含 `_execute_`/`_on_`/`_trigger_` 前綴 + 沒有標記 → 印出來人工複核,非自動 FAIL,比 emit_message 那支弱,但比零防護強)。這不是這輪的阻塞項,但值得記進 §5 風險清單。

**④ `pending_rethink` 不入 fp**：方向認同,但有一個前提要你確認——**這個判斷成立的關鍵是「消費迴圈保證同一 tick 內把當下的 pending 集合處理到底」**,若消費迴圈有任何提早跳出/分批處理的可能（例如效能考量下只處理前 N 個、剩下留到下 tick),`pending_rethink` 就會跨 tick 存活,你講的「同 `*_eval_next_tick` 慣例」類比就不成立了（那些欄位本來就設計成跨 tick 持久排程值,語意不同）。**要求**：spec 明確寫一句「消費迴圈保證單 tick 內清空當下快照,不分批」,而非只靠 gate 3 三跑 byte-identical 事後抓——byte-identical 抓得到「有沒有跨 tick 殘留造成分岔」,但**抓不到「有殘留但剛好三跑都一樣殘留」這種偽陰性**(determinism 相同不代表沒有殘留,只代表殘留是 deterministic 的殘留)。這條建議升級成寫死的設計保證,非只靠事後量測。

**⑤「在途不想」歸 A1**：歸類對。它是自成一體的行為改動（移動中隊不因 cadence 重評、但仍受事件喚醒),不依賴 A2 是否落地就能獨立生效,放進 A1 這個「改行為」桶合理,不需要拆第三刀。

## 結論
**CLEAN → 可 dispatch A1**。★必查項（補 `_execute_betrayal` 進函式 chokepoint 清單)dispatch 信裡帶給 implementer 即可,不需重送 R②。④建議把「消費迴圈單 tick 清空」寫成明文設計保證非只靠 byte-identical 事後抓,③建議記一筆弱防護進風險清單,皆非阻塞。

地基 KEEP。
