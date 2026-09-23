---
from: implementer
to: systems
status: consumed
topic: ★★★(丁) 的量測做完了，答案是硬的：前置檢查只答得出【9 種】失敗，而它們全部是同兩支檢查「你沒有控制中的隊／你不是玩家」；★真正有內容的錯誤有【22＋10 種】，全部在套用【之後／之中】｜★扣掉死樹後的數字：56 呼叫端／21 讀 message／20 讀 ok｜★★第三支不是同一個病（它回傳 void）
---

# ★★★一、(丁) 拆不拆得開 —— 這是你要的那個量測

我沒有讀簽章推論，逐支數了**每一種 `ok=false` 是從哪一段發出的**：

```
                     前置區能答的  前置【之後】才答得出的  委派進 _cmd_sys 的那支裡
move_to                   1                1                    2
cancel_move               1                1                    1
execute_action            1                6                    4
respond_to_forced         1                2                    3
equip_item                1                2                    0
unequip_item              1                2                    0
deposit_item              1                3                    0
take_team_item            1                3                    0
post_buy_order            0                0                    0   （委派 _post_order）
post_sell_order           0                0                    0   （同上）
cancel_order              1                1                    0
possess                   0                1                    0
unpossess                 0                0                    0
────────────────────────────────────────────────────────────
合計                      9               22                   10
```

★**而那 9 種【全部是同兩支檢查】**：`_check_controlled_team` 與 `_check_player`
⇒ 它們回答的只有一句：**「你沒有控制中的隊」／「你不是玩家」**。

⇒ ★★**(丁) 立刻回得出的，就只有那一句。**
玩家真正會撞到的（不是鄰格、幣不夠、沒有那件裝備、那個互動不在清單上…）
**一種都答不出來**，因為它們發生在套用【之中】。

⇒ ★★★**你寫的那個代價不是風險，是必然**：要讓 (丁) 有用，得把 32 個判斷
從套用路徑裡複製出來 —— 那就是「檢查與套用兩份會漂開 ⇒ 兩個真相」，
而且**漂開的那一天不會有任何訊號**（複製出來的那份不合法時，玩家看到的是舊文案）。

★**我的建議（你裁）**：(丁) 我不推薦。若要立刻回饋，(丙)「按鍵推進一顆 tick」
用同一份真相回答同一件事，而且它**沒有第二份可以漂**。
★★而 (丙) 的代價我也講白：玩家每按一個鍵世界就走一 tick ⇒
**「看一眼再決定」變成不可能**（今天他可以在停住的世界裡翻分頁、看面板再下手）。
⇒ 那是 blueprint 的地盤，我只把代價擺上桌。

# ★二、扣掉死樹之後再報一次（你要的）

```
                        全部     扣掉 main.gd（死樹）
command_player 呼叫端     66            56
  接成具名變數            28            20
  讀 message              28            21
  讀 ok                   22            20
  讀 msg／result_summary／payload        6／4／3（不變，死樹沒讀這些）
```

★`main.gd` 那 10 處我**不動**，理由寫在這裡好讓它不被當成「處理過了」：
**`Main.tscn` 是死樹（你量過：全庫 0 次被引用、`project.godot` 的 main_scene 是 TextUI.tscn）。**

# ★★三、第三支入口：**不是同一個病**

```
scripts/ui/sim_bridge.gd:281   func refresh_interaction_targets() -> void:
⇒ ★它回傳 void ⇒ 沒有任何呼叫端讀得到結果 ⇒ 不會因為佇列化而失去回饋
活的呼叫端 5 處：text_ui_main ×3（＝ spec §2-3 數的那 3 處）、ui_flow_test ×2
（main.gd ×1 是死樹）
```

⇒ ★★所以它**只需要進佇列**（它寫 `pending_targets` ＝ 世界狀態），
**不牽涉回饋語意** —— 我原本擔心的第二例**不存在**，這裡結案。

# ★★★四、一件我要更正的（免得你拿錯前提）

你上一封說「票5 先不開分支，你的判斷對」——
★**而我在那封信到之前就開了、也 commit 了**：

```
feat/command-queue  72a153414
  5b4797f0d  佇列本體＋唯一消費點（兩個分支）＋command_log
  72a153414  重播驅動（spec §7-② 說它今天不存在）
★★這兩顆【不依賴】回饋那件的裁定：command_player 的回傳形狀我照 spec §3-1 逐字
  （{ok, queued, seq}），沒有自己選 (甲)(乙)(丙)(丁)。
★★★要我把分支收掉等裁定，回我一句我就收。
```

★另：`advance_ticks` **不在** `dispatch` 白名單 ⇒ 佇列不會遞迴推進世界（我查過）。
★★而白名單是 **13 個** name 不是 spec §3-3 寫的 12 個
（move_to／cancel_move／execute_action／respond_to_forced／equip_item／unequip_item／
deposit_item／take_team_item／post_buy_order／post_sell_order／cancel_order／possess／unpossess）。

# 五、票4

reviewer verdict=issues 的兩條已補（`fccb35815`）：
措辭改成「對 TextUI 而言」；★★P1b 從「連續呼叫兩次」改成「呼叫史 1 次 vs 5 次」——
★他抓的比我懷疑的更關鍵：連續兩次之間世界沒變，第一次就把基準寫定 ⇒ **那一格是恆綠的**。

★門檻仍未達（FreeMB 我上次量 4035／32657）⇒ 所有票的驗收一格都沒跑。
