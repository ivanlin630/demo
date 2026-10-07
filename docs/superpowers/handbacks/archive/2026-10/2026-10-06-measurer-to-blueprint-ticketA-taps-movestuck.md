---
from: measurer
to: blueprint
status: consumed
slice: Q-raid窗／施工counter／wall.reject／village.build_fired／move_target卡住普查
topic: ★回應 systems 派工（tap對準merge 79774bbe9 後那一批）：四件機械量測＋一件決定性結論（move_target卡住全是正常移動成本,0件真無理由,不需要移動層開票）。★Q-raid窗可能對錯了世界，請核對。副本：systems（SendMessage 已敲）。
---

# 一、★Q-raid（Team11, tick 13350-13400）—— 窗內 0 筆，疑似世界不對

```
Probe.sample_window 對準 team=11/tick 13350-13400，跑在「玩家活著的30天」那個世界：
窗內收到 0 筆（594 筆被窗濾掉，證明窗真的在過濾，不是沒接電）。

★★★疑點：我自己先前那份「玩家死後7天」specimen（seed同1337，但 tick 4320 殺了玩家）裡，
Team11 的掠奪連續承諾正好是 tick 13357→14400——跟這個窗(13350-13400)幾乎重疊。
兩個世界從 tick 4320（殺不殺玩家）就分岔，tick 13350 時兩邊的 Team11 行為不保證一樣。
這個窗的來源看起來是從「死後」那個世界讀出來的，但這次派工說的是「30天那個世界」（活玩家）。
★請核對：這個窗口原本是要對準哪一個世界？若是死後那個，我可以換那個世界重跑；
若真的是活玩家 30 天世界，那麼 Team11 在這個窗裡本來就沒有掠奪，0 筆是正確答案。
```

# 二、施工 construct.start / construct.stall

```
construct.start=1（team4, tick=11097, tile=(4,6), action=upgrade_facility）
construct.stall=134（8 筆樣本，cap預設8，可能漏掉更多——若要更完整需要另設窗）
樣本全部是：ct_id=4，ct_task=逃跑，從 (4,6) 移到 (3,7)
★★★結論：這次施工卡死不是「沒人去蓋」，是施工隊自己因為某個理由逃跑了，
人跑了當然蓋不下去。「task=逃跑」本身的誘因（威脅？絕境？）本床沒追，交你/QA判。
★★systems 提的 team0(2,13)／team3(11,5) 完全沒出現在這 8 筆樣本裡——可能是被 cap=8
擋掉（134次只抽前8），不是沒發生；若要那兩隊的樣本需要對它們單獨設窗。
```

# 三、wall.reject_*

```
全 30 天僅 1 次：wall.reject_terrain.day.002（team18，地形不合）。
★這個數字很小，若 A1 的故事需要「牆閂常被撞」這個現象，這份數字不支持。
```

# 四、village.build_fired

```
全域=1（跟 construct.start 的 1 次一致）。
★全程(30天)曾宣稱「建設」或「紮根」的隊＝[0,1,2,3,7,10,11,12,13,14,26]（11 支），
但只有 1 次真的 build_fired——這個全域數【不能】直接歸給某一隊，要讀的人自己對這張名單。
11 支宣稱、1 次真建 ⇒ 跟我之前 Q-material 普查的結論（11 隊宣稱、4 隊有 material 進出、
4 隊建物欄變化）同一個方向：宣稱遠多於真正生效。
```

# 五、★★★move_target 相鄰卻不動——決定性結論：0 件真無理由，不需要移動層開票

```
全世界普查，≥60 tick(1小時)零位移的連續段，共 218 段。逐段複查三條已知阻擋條件
（複製自 movement_system.gd:process() 的真實 continue 邏輯，不是推論）：
  ①resident_lock（TAG_PRODUCE+_is_resident_team）
  ①combat_block（combat_target != -1）
  ①insufficient_time_budget（move_tick_acc < 重算的 move_cost_pure，含日夜速度倍率）
  ①flee_special（current_task==FLEE，邏輯特殊但仍是「有理由」）

分類統計：
  只有 insufficient_time_budget            197 段
  + resident_lock                            4 段
  + flee_special + resident_lock             1 段
  + flee_special                             13 段
  + combat_block                              3 段
                                          合計 218 段

★★★純②（整段從頭到尾三條都沒成立過）＝0 段。
⇒ 你開票判準「有 move_target 且相鄰、連續≥1小時零位移、而移動層無理由的隊·次 > 0」
  這個數在本次 30 天世界裡＝0——★不需要開移動層票。
  implementer 找到的 Team7 (2,7)→(3,7) 那 663 tick 案例也在這 218 段裡
  （tick=19617-20279 和 tick=28630-29339 兩段），理由都是 insufficient_time_budget
  （該地形/時段的移動成本相對單次 tick 預算偏高，正常機制，不是卡死）。

★誠實限（寫在判準本身上，不是補充）：三條複製自我讀到的 process() continue 分支。
判準刻意保守：只要三條有一條成立就算①，不算②——若 process() 還有我沒讀到的分支，
本床會把那類段誤歸進②（高估②的風險方向，不會把真缺陷藏進①）。目前 0 段屬於②，
所以這個誠實限在本次結果上沒有改變結論，但下次若出現非 0 的②，要先查是不是我漏了
一個 continue 分支，不要直接當真缺陷。
```

# 六、落地

```
commit：1ca01ffa8（已 push）
床：scripts/debug/ticketA_taps_and_movestuck.gd
產物：docs/measurements/ticketA-taps-and-movestuck.jsonl（Q-raid 樣本 + 全部 218 段）
跑法：GODOT_TIMEOUT=1800 .\tools\godot.ps1 --headless --script scripts/debug/ticketA_taps_and_movestuck.gd
```
