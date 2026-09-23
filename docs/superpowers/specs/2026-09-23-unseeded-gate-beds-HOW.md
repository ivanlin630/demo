# HOW spec：註冊表上【沒播種】的床 —— 先量，再逐支處置

owner: systems ｜ 2026-09-23 ｜ player_reachable: no
起點：`ui-flow` 被實測為 **9 跑紅 4（~44%）**，根因＝**Godot 每個行程開機時全域 RNG 是隨機的**
（implementer 實測：四個未 seed 行程 `randf` ＝ 0.336／0.970／0.761／0.207）。

---

## ★§1 範圍（★我量出來的，不是估的）

```
scripts/debug/ 共 475 支｜有 seed( 的 251｜★沒有的 224
而【註冊表 merge-gates.tsv 引用到的】床 45 支，其中沒有 seed( 且會建世界或推進 tick ＝ 12 支：
  agent_verbs_c1_bed.gd            建世界1 推進3
  ui_flow_test.gd                  建世界1 推進6   ★已在修（fix/ui-flow-determinism）
  merchant_turnover_test.gd        建世界0 推進1
  phase_root_conservation_bed.gd   建世界0 推進1
  bed_arm_gate.gd                  建世界3 推進0
  crisis_override_test.gd          建世界3 推進0
  team_ui_test.gd                  建世界2 推進0
  grudge_ledger_bed.gd／material_buy_test.gd／plan_speed_move_cost_test.gd
  ／ui_logic_test.gd／unified_commerce_test.gd     建世界1 推進0
★判準是 grep：`seed(` 有無 ＋ `WorldState.new|GameSetup.setup|TextUI.tscn|ObserverMain.tscn`
  ＋ `advance_tick|request_advance|tick_step|advance_ticks`
★★誠實限：grep 抓不到【經由 helper 間接建世界】的；⇒ §5 的量測會抓到它們（跑出來會變）
```

## ★★★§2 第一步是【量】，不是【補 seed】

```
★不要一口氣把 12 支都加上 seed —— 兩個理由：
  ①有些床【推進 0】，它的斷言可能只看建構後的靜態性質 ⇒ RNG 碰不到它 ⇒ 補了是裝飾
  ②★★更重要：有些床【本來就應該跨多個世界驗】，把它釘死在一顆種子上＝【縮小它的涵蓋率】
    ⇒ ★★★那會把「它其實只驗過一個世界」這件事藏起來，而卷面照樣全綠
```

**量法（每一支都一樣，★可平行）**：

```
同一棵樹、同一個 config，連跑 5 次，比對【完整 stdout 逐位元】
  5 次逐位元相同 ⇒ 標 STABLE（★不代表它決定性，只代表這 5 次沒抓到 —— 見 §4）
  出現任何差異   ⇒ 標 VARIES，並把【第一處差異的那一行】記下來
```

## §3 逐支處置（★量完才決定，先寫死規則免得看到數字再想）

```
VARIES ＋ 它的斷言【依賴那個變動的東西】 ⇒ ★補 seed（形狀抄 warring_harness.gd:120）
VARIES ＋ 斷言【不依賴】它（只是 log 在變）   ⇒ ★★不補 seed，改把那段 log 移出比對範圍
                                              （★補 seed 會讓它從此只驗一個世界）
STABLE                                      ⇒ ★★★【不動】，而在該床檔頭寫一行
                                              「本床未播種：5 跑逐位元相同（2026-09-23）」
                                              ⇒ 下一個人看到的是【量過的事實】，不是沉默
```

## ★§4 這張票【不宣稱】的（寫在前面，免得後人把它讀太大）

```
★「5 跑相同」不是「決定性」的證明 —— ui-flow 的紅率是 44%，而它仍然可能有 1% 的床
⇒ ★★所以 STABLE 只代表【這 5 跑沒抓到】，那一行檔頭要照這個措辭寫，不得寫成「它是決定性的」
⇒ ★★★而真正能斷言決定性的只有【同種子兩次逐字相同 ＋ 未播種兩行程 randf 不同】那一對格，
  那是 ui-flow 那張票在做的事，本票不重做
```

## §5 驗收

```
P1 12 支各有一份 5 跑的原始輸出，落地在 docs/measurements/（★exact path 進 handback）
P2 每一支都有處置標籤（VARIES-補seed／VARIES-移出比對／STABLE-檔頭記一行）
P3 補了 seed 的那幾支：★各自附【陽性對照】—— 把 seed 換成 randomize() ⇒ 該床必須變 VARIES
   ⇒ ★★沒有這一格，「補了 seed」與「它本來就穩定」在卷面上長得一樣
P4 全電池綠（★本票只動 scripts/debug/，零 production）
```

## ★§6 不在本票

```
✘ ui_flow_test（它有自己的分支 fix/ui-flow-determinism）
✘ 那 224 支【不在註冊表上】的床 —— ★它們沒有人在看，補了也沒有消費者
  ⇒ ★★真要處理它們，門票是「它被註冊進電池的那一天」，不是現在
✘ 幫 Godot 的隨機播種行為加任何全域設定（★那會改變所有床的既有行為，代價不明）
```
