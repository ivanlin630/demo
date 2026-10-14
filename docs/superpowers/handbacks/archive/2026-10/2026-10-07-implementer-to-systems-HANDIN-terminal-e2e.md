---
from: implementer
to: systems
status: consumed
slice: 終端 E2E 床（狀態驅動）＋架構改版（GDScript 床／共用送鍵／畫面不落後）
topic: ★**交件｜BATTERY_RC=0｜106 綠／0 紅**（run-id `48751-20261007-025124`，HEAD `7b73616a0`）｜branch **`feat/terminal-e2e-r2`** 遠端 tip **`1d99e9497`**（★舊的 `feat/terminal-e2e` 停在 WIP 6493fd484，不要 merge）｜fp **不變（量的）**｜第一次跑抓到 5 條＋4 條探路 ⇒ 回報清單 §五
---

# 一、改了什麼（4 個檔）

```
scripts/ui/player_repl.gd            press_on：推進中 await process_frame 直到 is_advancing()==false 才回（P10）
                                     ★_feed／stdin／tcp 三處呼叫改 await（play.py 落後一步同一支修好；play-selfcheck 綠）
scripts/simulation/player_command_system.gd   ACTION_SHAPE.effect：自家隊 10 個＋目標動作 9 個（你的 (甲) 裁定 58e41cfee）
                                     表上方逐支 handler file:line（重算過）；新值 "menu"（trade／recruit：只開子選單 ⇒ 紅二不適用、紅三適用）
scripts/debug/terminal_e2e_bed.gd    新床（@bed-kind invariant）
docs/process/merge-gates.tsv         新列 terminal-e2e（§七）
```

# 二、床怎麼走（照 spec＋架構改版）

```
世界：真的實例化 TextUI.tscn；送鍵＝PlayerRepl.press_on（REPL 同一支）；讀畫面＝_screen_label.text；狀態唯讀走 node._bridge
佈置：同格 NPC 7320＋強制事件 propose_alliance（照 forced_event_panel_bed 手法）⇒ 字母鍵空間與目標動作空間都走得到
解析：三個鍵位空間（自家隊數字／目標動作數字／強制事件字母）＋可互動目標＋「（未綁鍵）」
挑法：確定性（seed×31＋步×17）、沒按過的優先；N ＝ 畫面「自家隊動作（10 項）」× 2 ＝ 20
雙世界：每一步 A、B **各自**「建（同 seed）→佈置→重放前綴按鍵」，一次只活一份
  ★理由：GameSetup 叫 CrossRunReset（類級 static 歸零）⇒ 兩份交錯推進，建第二份那一刻就改了第一份
  ★啟動：一份 ~2.8s（實測）；整支床本機 ~8 分鐘（三輪走法＋P7）
  A ＝ [t,(tab),(目標鍵),動作鍵,(打聽：選第 1 題),esc…]
  B ＝ 同樣打開、不按動作鍵、esc 回主畫面、g N enter 補到 A 的終點 tick；B 超過 A ⇒ ABORT
  ★補齊量是「A 終點 − B 現在」，不是動作鍵那一下：交易子選單按 Esc ＝ 取消貿易，本身也是一道令（第一版 A t7／B t6 ABORT）
```

# 三、格與這一輪的數

```
P0  解析器自驗（含反向：空畫面三空間都 0）
P10 開場 x ⇒ 回來那一屏「第 1 天 01:00」＝ tick 60 ＝ 世界 60（等 1 幀）｜反向 Esc ⇒ 0 幀
    常駐：每一鍵回來 ⇒ 頂列 tick ＝ 世界 tick ＝ 狀態列 Tick，且推進已消化完｜1105 次按鍵、不等 1（已知：攻擊）
WALK 15／20 步（停在已知死路「攻擊」）｜自家隊 8／目標動作 6／字母 1
P1  畫面提供過 20 種／按過 12 種；沒按到：拒絕、紮營、狩獵、獵猛獸、放棄戰利品、收編敗者、收割戰利品、邀請定居、提議同盟
    （多數是「不可」）｜列出卻沒綁鍵（不判）：乞討、忽略、投降請和
P2 紅一 0｜P3 紅二 判 11 步、0（已知以外）｜P4 紅三 0
P5  同 seed 15 行逐字同｜換 seed 4242 必不同 ✓
P6  15 次分叉 fp 全同｜P7 不觀測重放 63 鍵 fp 同（61f66dbb13b8）
KNOWN 5 條每條都再現
```

# 四、陽性／負對照（各在獨立 worktree 擾動、跑整支床、刪掉）

```
紅一 鍵表錯位一格（TextUiView.action_for_key 回 key+1 那個 id）
     ⇒ P2 紅 3：按「貿易」結果句說「提議同盟」、按「招募匿名」說「邀請定居」…
紅二 _action_promote_anon 只回 ok:true 不改狀態
     ⇒ P3 紅 5：「拔擢匿名→記名」說成功而 roster_self 在 A−B 沒變
紅三 結果行不寫（_set_feedback 對含「拔擢」的訊息直接 return）
     ⇒ P4 紅 4＋P2 紅 4：世界變了（roster_self）而結果句還是上一道令的
     ★為什麼擾動放在 UI 而不在 handler：畫面上的「已排入：行動：X」是 UI 入列當下印的回音，
       handler 不寫結果句的話回音照樣在 ⇒ 玩家看到的「結果句」只能在 UI 那一層被拿掉
P10 press_on 改回舊版（不等推進）
     ⇒ 開場 x 紅（畫面 tick 0）＋常駐紅 1240／1240
     ★第一版常駐**沒有鑑別力**：只比「畫面 tick ＝ 世界 tick」⇒ 舊版回來時兩邊都在推進前 ⇒ 1240 次 0 次不等、照綠
       ⇒ 加「回來那一刻推進必須已消化完」之後才紅（commit 44ddf143a）
```

# 五、★回報清單（spec §6：列、不修；床把前 5 條釘成 KNOWN，每條必須再現，修好那天它會紅要你回來拿掉）

```
K1 P2|招募    step 08｜鍵 t tab 1 4｜按目標動作「招募」⇒ 開 `── 招募 Team7320 ──` 子選單
              而結果行仍是上一道令的回音「已排入：行動：拔擢匿名→記名」；同時鍵列印的是**主畫面**那一份
K2 P3|打聽情報 step 12｜鍵 t tab 1 5 1｜選題 ask_food_source ⇒ 畫面只有「已排入：行動：確認打聽」、belief 不變
              handler：ok:true、`_exchange_intel` 寫入 0（log「mode=honest 寫入=0 結果筆數=1」）
              ⇒ 它回的是「他說了些事情（記下 0 筆…）」或「他也不知道」—— 而那句完成句**不上畫面**
K3 P3|確認打聽 step 13／14｜同上（自家隊動作區的「確認打聽」重送上一次的選題）
K4 P10|攻擊   step 15｜按「攻擊」回來那一屏頂列 35、世界 36（慢 1 tick）
K5 STUCK|攻擊 step 15｜攻擊之後（交戰中）互動面板 Esc 關不掉：連按 6 次仍在面板、世界還被推了 1 tick
              ★順帶：攻擊的對象是**剛結盟的**同勢力隊，而「攻擊」是可做的
P11（床印、不判）沒被拒、而畫面只有「已排入」回音、沒有完成句：建立勢力、貿易、拔擢匿名→記名、招募、確認打聽
              ⇒ 真因（讀 code）：成功句「行動：X：<msg>」進了 `_events`（type cmd），而事件區只印 `_feed_rows`
              ⇒ 不只建立勢力（原 P11），是**所有成功的令**都沒有完成句；K2／K3 是它的直接後果
探路已見、床沒走到的：
E1 互動面板寫「[T/Esc]關閉」，而按 T 印「現在沒有要回應的事件」、面板不關（同時畫面掛著 [A]接受 [B]拒絕）
E2 兩支都沒勢力（faction_id −1）的隊：「提議同盟（不可：對方已經和你同一個勢力）」⇒ −1 == −1 被當同勢力
E3 extort／invite_settle／beg 被拒時回 ok:true（「對方拒絕勒索」「拒絕邀請」「不予施捨」）⇒ 紅二候選（這輪勒索被接受、沒走到拒絕那支）
E4 強制事件字母鍵的標籤前面多一個字元（「[A]  接受」解析後是「 接受」，事件句也寫「回應了「 接受」」）—— 我沒查是什麼字元
```

# 六、fp

```
本信那一輪 world-fp ✓ ⇒ 基準 8c9b2d72… 不動（量的）
為何沒變：改的是 UI 送鍵的等待＋一張資料表的新欄（effect 只有床讀）；sim 路徑零改動
```

# 七、新列（四欄；expect 從輸出逐字抄）

```
id      terminal-e2e
cmd     GODOT_TIMEOUT=1800 powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/terminal_e2e_bed.gd
expect  === terminal_e2e DONE === errors: 0
★第一輪電池這一格 no-verdict：我原本寫「…｜★到場點名：10／10（缺：[]）」，而 runner 是 grep -E 整串比一行 ⇒ 永不命中
  （床本身 errors: 0）⇒ 改成只比 DONE 行（errors 0 已含到場點名那一格）⇒ 重跑整輪
```

# 八、分支

```
feat/terminal-e2e-r2 tip 1d99e9497（rebase 在 origin/main e4ad6cb65 之上）
★舊 feat/terminal-e2e（6493fd484 WIP）不要 merge —— rebase 後 force push 被權限擋，照慣例推新名
輕路（§5）的 docs/process/ 改動照原派工由你在 merge 那一顆寫
```
