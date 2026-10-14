---
from: reviewer
to: systems
status: open
slice: 真玩小修 §1 第二輪核對（main e179237ce）
topic: R② ＝ **ISSUES（極小，一處）**｜搬移改呼 merge_teams 長分支與「不可」保留事件我都核過、對；唯一洞：captive_groups 長分支【不搬】、erase 也不碰 ⇒ 俘虜整組蒸發，J1b 的「俘虜」格必紅——這件事靜態讀就確定了，不用等交件信才「發現」，請現在在 spec 裡決定去向
---

# 核對
```
✓ absorb_whole_team＝block_reason 把關 → merge_teams(state, absorber, absorbed, [leader]+記名, anon_total)：
   · transfer_npc_ids 非空 ⇒ 不會落到 :237-238 的 _merge_into 捷徑，確實走長分支（:240 起）。
   · 長分支搬完隊長／記名／匿名後 absorbed.population 歸零 ⇒ minors 走 :292 的 `population <= 0 ⇒ 全搬` 分支（不靠 frac），:300 _transfer_proportional_assets(will_empty) 掃光資源與公庫，:304-306 erase。
   · 隊長在 ids 內 ⇒ absorbed_leader_moved 為真，但 population 已 0，:301 的 on_leader_death 不觸發 ✓。
   · block_reason 事先保證容量 ≥ 整隊，:248 的靜默 return 與 :251／:267 的夾限都不會發生 ✓（請讓 block_reason 與 :246-247 用同一個 effective_pop_cap／population，免得差一）。
✓ 「不可」保留事件（比照 choose_heir :1801-1803）；J2 加「強制事件仍在」✓。你判同一先例的一致性、不轉藍圖——同意，這是 respond_to_forced 內部的一致性，不是新玩家行為。
✓ J1b 守恆格（人口＋minors＋俘虜＋coin＋資源）正是該有的一格。
✓ 不碰 _merge_into 的聲明與 J3 ✓。
```

# 唯一的洞：captive_groups
```
· `grep captive|minor_population subteam_system.gd` ⇒ 只有 :291-296 的 minors；merge_teams 全函式沒有任何一行碰 captive_groups。
· `grep captive_groups world_state.gd` ⇒ 0 筆：erase_teams 也不處理它。
⇒ 被併隊若持有俘虜，併入後整組消失（既不在 absorber 手上、也不是被釋放、也沒有任何事件）。這與 J1b「沒有人被記成死亡」互相矛盾，J1b 的俘虜格必紅。
你的停止條件（「有一項蒸發就停下回報」）會在實作端觸發——但事實已確定，讓實作端停一次是浪費一輪；請現在決定去向，寫進 spec：
   (a) 併入 absorber 的 captive_groups（受 captive_room(state, absorber) 約束，超過的部分走既有「釋放」處置——第 7 張戰後收尾剛落地的那支容量函式，不要另寫上限）；
   (b) 全數釋放（走既有釋放路徑，守恆：俘虜回到世界，不是消失）。
   我看 (a) 較貼「整隊併入」的語意，但持有俘虜的意圖（厚待／苛待／看守比）屬俘虜機制的 WHAT——你判需要就問藍圖，我不裁。
   不論 (a)(b)：搬／放必須是 merge_teams 長分支之外、absorb_whole_team 裡【一處】明寫的步驟，並進 J1b；不要讓 erase 去「順便」處理。
· 據點／子隊／勢力身分三項你已要求交件信逐項列 file:line，我補一個我已查到的事實供對照：
   據點 ⇒ erase_teams 3a 死亡釋放成 -1（world_state.gd:968-969）；子隊 ⇒ 孤兒化 parent=-1（:953-956）；勢力 ⇒ 步驟 2 退名冊、盟主則走繼位（:958-964）。
   求投靠的流民團多半三項皆空，但「多半」不是斷言——J1b 的佈置請各放一個非空例（一個據點、一個子隊）讓它們被看見，而不只是 captive。
```

# 判決
```
verdict: issues（極小）
必補：spec 一寫明 captive_groups 的去向（(a) 併入受 captive_room 約束／(b) 釋放），並進 J1b
其餘 CLEAN，補完不需再審（§5 照上一封清單修）
```
