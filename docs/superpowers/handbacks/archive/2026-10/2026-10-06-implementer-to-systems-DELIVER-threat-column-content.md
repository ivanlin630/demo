---
from: implementer
to: systems
status: consumed
slice: 威脅欄印附身隊所知的最急一句（＋頂列無值主張預設）
topic: ★**交件｜BATTERY_RC=0｜103 綠／0 紅**（run-id `10989-20261006-192735`，HEAD `a857bfad8`）｜★branch **`feat/threat-column-content-r2`** 遠端 tip **`9139eb109`**｜★delta ＝ `60e4e2fd5..9139eb109`（rebase 在最新 origin/main 之上）｜④不做（狀態不存在，grep 在 §五）
---

# 一、delta（`60e4e2fd5..9139eb109`）

```
bc3e1f866  威脅欄寫入者／讀者 ＋ 頂列無值主張預設 ＋ 新床 threat_column_bed（P1–P8）
ff9b42c3e  註冊 threat-column ＋ 三個負對照先紅的原文：docs/measurements/2026-10-06-threat-column-negative-controls.txt
5d795b0d9  lookup-key 豁免「交戰中：野豬」（§八 A，你已收）
15b041eb5  text_ui_layout_bed `_func_body` 窄化回單一函式（§八 B，你已收）
f04c15aea  床那一行互指豁免＋窄化兩個負對照原文
a857bfad8  窄化對同檔另兩處用法：改前／改後窗口與命中行（逐行相同，非運氣綠）
9139eb109  scripted_exploration artifact 落這一輪（記的 sha ＝ a857bfad8）
```

# 二、H0／H0′ 怎麼落地

```
寫入者  PlayerApiMapper.map_threat_line(state) —— threat_line 的唯一產生者，永遠回字串
          成功出口：map_player_snapshot 加 out["threat_line"]
          失敗出口：player_query_api._always_keys(state)（＝ map_story_end ＋ threat_line）
          ★附身者沒有隊 ⇒「—」；判定無威脅 ⇒ 寫入者明示「（無）」
讀者    text_ui_main.build_regions：`_cached_snapshot.has("threat_line")` ⇒ 照印，否則「尚未提供」
          ★H0′：ct 為 {} ⇒ 家「—」、糧撐「—」（糧撐改 `ct.has("food_days")` 判）
          ★有隊時照舊：家 null（寫入者明示沒有家）⇒「（無）」；0 天糧 ⇒ 照印「糧撐 0.0 天」
P5 反向掃：寫 threat_line 鍵的地方 ＝ ["player_api_mapper.gd:850", "player_query_api.gd:91"]（2 處，都在組裝）
          map_threat_line 函式體內呼叫 best_estimate 的非註解行 ＝ 1
```

# 三、你要的數

```
·P1 四態（讀者直讀，畫面原文）
   鍵不存在 ⇒「尚未提供」｜寫入者明示 ⇒「（無）」｜一句 ⇒「Team7 敵對，最後所知 2 格」｜鍵在而空 ⇒「」
   ★第四態是我加的：它是 has() 與 == "" **唯一**分得開的輸入（寫入者今天不會這樣寫）
   負對照 N1（讀者改回 == ""）⇒ errors 1：**只紅**「鍵在而空 ⇒ 不得印尚未提供」
     ★誠實限：spec 寫「改回 == "" ⇒ 前兩種會同形」——在新寫入者之下前兩種**不會**同形
       （寫入者明示「（無）」≠ 空字串），所以真正會被 == "" 吃掉的只有第四態；我把它做成那一格
·P2 god-view 兩方向（同一佈置：真值 Team0 搬到附身隊旁 1 格、列入 player_hostile_teams）
   母體地板：真值距離 1 格｜N ＝ 2｜附身隊有它的 belief ＝ false
   不知道 ⇒「（無）」
   同佈置 record_claim 讓它知道 ⇒「Team0 敵對，最後所知 1 格」
·P3 只有③ ⇒「東南有野豬」｜②＋③ ⇒「Team0 敵對，最後所知 2 格」（野豬更近仍印②）
     ①＋② ⇒「交戰中：野豬」｜★反向：別人的戰（攻守都不是附身隊）⇒ 不印①
·P4 白天 tick 144 ⇒ N＝3｜夜晚 tick 1296 ⇒ N＝2（DayNightSystem.get_vision_mult 0.5）
     距離 3 格：白天 ⇒「Team0 敵對，最後所知 3 格」｜夜晚 ⇒「（無）」
·P6 最長句頂列 display width 119／COLS 120（威脅欄 clip）
·P7 失敗出口：ok=false code=no_player｜snapshot 鍵 ＝ [game_over, game_over_reason, threat_line]｜threat_line ＝「—」
·P8 無隊：第 1 天 00:00 ｜ —（人口 —） ｜ 家：— ｜ 糧撐 — ｜ 威脅：— ｜ 待執行 0 道
     有隊而 0 天糧（set_amt food 0）：第 1 天 00:00 ｜ Team15（人口 10） ｜ 家：（無） ｜ 糧撐 0.0 天 ｜ 威脅：（無） ｜ 待執行 0 道
   負對照 N2（糧撐 default 改回 0.0）⇒ 只紅 P8 兩格（無隊那屏出現「糧撐 0.0 天」）
     ★N2 第一次做無效：行內 `# NEG` 註解把行尾逗號註解掉 ⇒ 語法錯、紅在不相干的格；重做那次才算，兩次都記在證據檔
   負對照 N3（失敗出口不帶 threat_line）⇒ P7 兩格＋P8「威脅：—」紅
```

# 四、感知鐵律（我寫的時候核的）

```
·位置只讀 best_estimate 的 tile_pos；自己的 tile_pos 是自我知識
·①只用 encounter_active ＋ 攻守 id（不讀 encounter_log）
·敵對 ＝ state.player_hostile_teams（自己的清單）
·★誠實限：野獸種類讀 state.teams[tgt].beast_kind（spec §2 指定的判準，身分不是位置）；
   目標已不在 state.teams ⇒ 當作非野獸、**不跳過**（跳過的話「它死了」會從真值漏進來）
·★誠實限：方位「r 增加 ＝ 南」是照地圖逐列由上往下印的慣例，沒有另一份權威可對
·★誠實限：②只看距離不看 belief 年齡（spec 沒定；最後所知 30 天前的敵隊也會印）
```

# 五、④勢力交戰 ＝ 不做（照 spec §2）

```
git grep -nE "at_war|war_with" -- scripts/simulation scripts/data            ⇒ 0 命中
git grep -nE 'relations *(\[[^]]+\] *=|=[^=]|\.merge|\.erase|\.clear)' -- scripts/simulation scripts/data scripts/ui
                                                                               ⇒ 1 命中：npc_ai_system.gd:153（**人物**的 relations）
⇒ FactionData.relations（註解寫 neutral／ally／enemy）全站零寫入者 ⇒ 「自己勢力在交戰」這個狀態不存在 ⇒ 不發明
```

# 六、新列（四欄；expect 從輸出逐字抄）

```
id      threat-column
cmd     powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/threat_column_bed.gd
expect  === threat_column DONE === errors: 0
```

# 七、其他

```
·★分支名：原 `feat/threat-column-content`（遠端停在 ca345f27c，rebase 前的舊底）推回去要 force ⇒ 推新分支 -r2；舊的請不要 merge
·main 在我 rebase（60e4e2fd5）之後只多動了 scripts/debug/player_death_7day_specimen.gd（量測員的床，不在註冊表、本票沒碰）＋ docs ⇒ 沒重跑
·舊遠端分支 feat/game-over-story-end（45d718b34）與上面那支：刪遠端分支是不可逆的外部動作，我沒刪；留給你／用戶決定
·★這張曾被「補領袖」那張插隊：停點 111522a4b → 你收了 A／B → 我回來 rebase 到 60e4e2fd5（補領袖已 merge）後才跑本信那一輪電池；註冊表表尾兩列衝突，兩列都留

# 八、你已收的兩件（摘要，原文在證據檔）

A｜lookup-key 豁免「交戰中：野豬」：床 P3 的期望字面；產線是 "交戰中：%s" ＋ BEAST_LABEL 組出來的 ⇒ 整句只該在床裡出現一次；
   打錯會讓 P3 當場紅、不會靜默；精確名、兩邊互指；刻意不引用產生者常數（同源比較恆真）
B｜text_ui_layout_bed `_func_body` 只認 `
func ` 截止 ⇒ 遇到全 `static func` 的 mapper 一路吃到檔尾（tick_clock 675 行）
   ⇒ 截止改「下一個 func／static func 的較早者」＋新格「窗口內不得再有其他簽名」（現 9 行）
   負對照：NA 舊截止點 ⇒ 窗口格紅（675）｜NB tick_clock 塞 60 ⇒ 原守衛照紅
   同檔另兩處：_refresh 74 行（命中 :792）、_render_screen 10 行（命中 :893），改前改後逐行相同
```
