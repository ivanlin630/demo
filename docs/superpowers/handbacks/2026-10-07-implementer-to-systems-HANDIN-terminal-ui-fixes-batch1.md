---
from: implementer
to: systems
status: open
slice: 終端介面修正（票 U）第一批：U0＋U1（含 E3 被拒）＋U4＋K5(乙)
topic: ★**交件｜已知紅 7**（E2／提議同盟、E4／記號、P10／攻擊、P2／招募、P3／打聽情報、P3／確認打聽、STUCK／攻擊）｜BATTERY_RC=0｜107 綠／0 紅（run-id `31949-20261007-041014`，HEAD `71dafd3bf`）｜branch `feat/terminal-ui-fixes` 遠端 tip **`c57f186f6`**｜fp 不變（量的）｜第二批（U2／U3-K4／U5／S1）接著做
---

# 一、這一批做了什麼

```
U1 結果句上畫面（text_ui_main.gd 指令結果排空那一段）：同時寫進 _feed_rows（source「指令」、時間＝結果自己的 tick），成功失敗同一處
   ★E3：handler 契約不改（ok＝有執行、accepted＝對方答應）；accepted 透傳：
     _action_extort 原本把 resolve_extortion_direct 的 accepted 丟掉 ⇒ 照傳；_action_beg 被拒那支補 accepted:false；
     execute_action 把 accepted 放進 payload（map_command_result 只留 ok/code/message/payload）
     sim_runner：ok 且 accepted:false ⇒「<動作>：對方拒絕（<msg>）」
   ★拒絕字樣**唯一一份**：PlayerApiMapper.REFUSED_WORD「被拒絕」／DECLINED_WORD「對方拒絕」／REFUSAL_WORDS
     ⇒ sim_runner 組字與 E2E 紅二分類器讀同一份
U4 互動面板頁腳「[T/Esc]關閉」→「[Esc]關閉」（改頁腳不改行為：互動模式字母鍵歸強制回應獨佔，讓 T 關面板＝同一字母兩個意思）
K5(乙) text_ui_main._input 交戰中（encounter_view 可見）：不再靜默 return，結果行印 ENCOUNTER_NO_TERMINAL_MSG
   「交戰中：終端尚無戰鬥畫面（按鍵交給戰鬥畫面，這裡收不到）」；K4／K5 KNOWN 照你裁的留著
U0 E2E 床：
   ①DONE 行 ＝「errors: N｜已知紅排除: K（清單）」（清單裡的 | 換成 ／：runner 用 grep -E，ASCII | 是「或」）；expect 從輸出逐字抄
   ②P11 升判決格（已知以外缺一個就紅）③新格：FOOTER（畫面頁腳寫的每個鍵各開一次面板按一次，要真的關）／E2／E4；K5 死路要有那一句
   ④紅二分類：✗ 或含 REFUSAL_WORDS 任一 ⇒ 被拒
已知問題清單：完成句、T/Esc、勒索/邀請/乞討三列標已修；打聽那列標「回答那句已修、記不記得待查」（你改的遭遇戰那列保留）
```

# 二、這一輪 E2E（seed 1337）

```
P11：成功的令只有回音的 ＝ []（修前：建立勢力、貿易、拔擢匿名→記名、招募、確認打聽）
FOOTER：頁腳「── [Esc]關閉 ──」⇒ 按 Esc 面板 開→關
K5：死路那時結果行 ＝ 交戰中：終端尚無戰鬥畫面…
已知紅 7（每條都再現）：E2／提議同盟、E4／記號、P10／攻擊、P2／招募、P3／打聽情報、P3／確認打聽、STUCK／攻擊
★新的副作用（不判，給你看）：U1 之後每按一次 [T] 進互動（重掃同格對象＝一道令）都會在事件區留一句「重掃同格對象：已重掃同格對象」
  ⇒ 事件區 8 條裡常有兩三條是它；要不要讓那一道 silent 是呈現決定，我沒動
```

# 三、負對照（獨立 worktree 擾動、跑整支床）

```
f1 頁腳改回「[T/Esc]關閉」⇒ FOOTER 紅（按 T：面板 開→開）
f2 拿掉 U1 那段 _feed_rows.append ⇒ P11 紅（已知以外缺 5：建立勢力、貿易、拔擢匿名→記名、招募、確認打聽）
```

# 四、U0⑤：註冊表裡有「已知／豁免」機制的床（掃 scripts/debug 下被註冊表跑的 74 支）

```
掃法：常數名含 KNOWN／EXEMPT／WHITELIST／ALLOW，及「已知紅／缺陷／洞／問題」「已登記」字樣；UNKNOWN 等字面命中逐支開檔排除
| 床（註冊 id）                 | 機制                                   | 性質                         | 判決行印了排除數？ |
| terminal-e2e                  | KNOWN（7 條缺陷登成已知，必須再現）     | ★已知紅                      | ✅ 本票加 |
| bed-arm                       | bed-arm-whitelist.txt（295 行）＋SELF_EXEMPT | 遷移債（未納管存量）         | ✅ 已印「白名單 %d 張…未納管存量」 |
| colocation-gate               | SPEC_EARLY_RETURN_EXEMPT ["ignore"]，上限 1 | 結構豁免（走不到閘），棘輪  | 印「例外的上限」 —— 不是缺陷 |
| available-actions             | SPEC_SHAPE_EXEMPT 3 個                  | 結構豁免（不在 registry 的動詞）| 不是缺陷 |
| leader-chokepoint             | SPEC_NAMED_EXEMPT 1（subteam）          | spec 具名不改                | 不是缺陷 |
| forced-event-panel            | SPEC_UNKNOWN_OK []（空）                | 曾是已知紅，已清空             | — |
| scripted-exploration          | ID_WHITELIST（每個附理由）               | 設計白名單（玩家面合法英文）     | 不是缺陷 |
| terminal-selfcheck            | EN_WHITELIST 8 個                       | 設計白名單                    | 不是缺陷 |
⇒ 「把紅格登成已知」的床只有 terminal-e2e 一支；bed-arm 的白名單是同族（存量債），已在印
★誠實限：只掃了 GDScript 床；註冊表另有 33 列是 hook／python（其中 ratchet／baseline 類：live-team-ratchet、registry-axis-ratchet、
  fai-new-ratchet、bare-tick triage、single-writer…）—— 它們的「基線」是不是已知紅、有沒有印，這一輪沒逐支判
```

# 五、fp

```
本輪 world-fp ✓、world-fp-ctrl ✓ ⇒ 基準不動｜sim 側只改結果句文字（command_results 的 text 不進 fp，只有筆數進）與 accepted 透傳
```

# 六、第二批（照序接著做）

```
U2 招募結果行（K1）｜U3-K4 攻擊那一鍵畫面慢 1 tick｜U5 強制回應標籤的 ✓／✗（查到了：forced_label 自己加的，player_api_mapper.gd diplomacy 那支）｜S1（52 行同族表）
```
