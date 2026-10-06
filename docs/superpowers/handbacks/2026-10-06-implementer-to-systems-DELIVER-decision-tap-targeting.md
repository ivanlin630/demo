---
from: implementer
to: systems
status: consumed
slice: 決策 tap 能對準某一隊、某一段時間
topic: ★**交件｜BATTERY_RC=0｜103 綠／0 紅**（run-id `11736-20261006-204156`，HEAD `ac1c705d8`，rebase 在最新 origin/main 之上）｜branch `feat/decision-tap-targeting` 遠端 tip **`9d81ec21a`**｜P1–P4 全綠＋反向對照｜★設窗後 Team11 tick 13357 那一筆真的取到了（補領袖 merge 之後的世界裡它照樣在）
---

# 一、改了什麼（兩處，都只在 Probe.enabled 時有作用）

```
①decision_engine.gd `_cmp` 補 "team"／"tick"（緊接 `_cmp["opt"] = opt`）
   state／team 是可選參數 ⇒ null 寫 -1，照記不跳過
②probe_stats.gd，形狀照同檔 `sample_mute`：
   static var sample_window: Dictionary = {}          # event → {team(-1＝不篩), tick_min, tick_max}
   static var sample_window_dropped: Dictionary = {}  # event → 被窗擋掉的筆數
   bump_sample：設了窗的 event 只收窗內；樣本沒有 team／tick 鍵 ⇒ 視為窗外
   reset()：清 sample_window_dropped（資料）、**不清** sample_window（設定，同 sample_mute 的理由）
   summary()：逐窗印「sample_window <event> ＝ <窗>｜收 N 筆｜窗外擋掉 M 筆」
   ★不讀 state、不呼 rand、不動計數器 ⇒ 決定性不受影響（P1 量的就是這件）
```

# 二、驗收的數（床 `scripts/debug/decision_tap_window_bed.gd`，acceptance、不進註冊表——三輪 × 13400 tick 太重）

```
世界：照 player_death_7day_specimen 的 _run_pass，★但建世界走 MeasureBedHelper.arm_and_setup（先 arm 後 setup；default.json、seed 1337、暖身 3 天、照
      story_end_not_physics_bed 殺玩家），推到 tick 13400
P1  A（Probe 關）／B（開、不設窗）／C（開、設窗）
      decision_hash ＝ 4cdce6286272691e…（三輪相同）｜fp ＝ 0924915271cef4ec6886fd54811a60d7（三輪相同）
P2  窗 {team 11, tick 13350–13400}
      ★母體地板：Team11 在窗內 51 個 tick 的 current_option 去重 ＝ ["駐守", "掠奪"]
      C 的 raid.composition：1 筆，窗外 0 筆
      那一筆 ＝ { drive 0, weight 1, after_weight 0.003, coeff 0.35, after_coeff 0.001, fail_mult 1, after_fail 0.001,
                  final 0.001, terms [loot_drive:d=0.003 w=1.000, intent_fit:d=0.000 w=1.000], opt 掠奪, team 11, tick 13357 }
      ★反向：B（不設窗）的 raid.composition 150 筆、**150 筆全在窗外**（first-N 被早期佔滿，正是量測員報的病）
P3  C：窗外擋掉 153 筆（summary 那一行逐字：sample_window raid.composition ＝ {…}｜收 1 筆｜窗外擋掉 153 筆）
P4  attack.composition B 150＝C 150 逐筆相同｜recon.composition 150＝150 逐筆相同｜shelter.composition 0＝0
原文：docs/measurements/2026-10-06-decision-tap-window.txt
```

# 三、給量測員／QA 的兩句（我量到的，判斷是你們的）

```
·窗內只有 **1 筆**（tick 13357）；而窗內 51 個 tick 的 current_option 是「駐守」／「掠奪」
  ⇒ 其餘 tick 的掠奪那一列**沒有被記**——**為什麼我沒查**（可能那些 tick 沒進評估、或掠奪當時不 applicable）
  ⇒ 若 QA 要的是「持守期間每一刻」，先確認是哪一個，這支 tap 只在掠奪被評估的那一刻記
·那一筆的 final ＝ 0.001（after_weight 0.003 × coeff 0.35）——「掠奪 util 很低卻被選」在這一刻的數字長這樣；
  為什麼被選我沒判（藍圖逐字：在 QA 重讀之前不下「決策壞了」的結論）
```

# 四、bed-arm 那一段

```
第一版床照抄 specimen 床「setup 之後才 Probe.arm」⇒ bed-arm 閘紅（同格紅的還有 main 上的 specimen 床，量測員已修 c4884e5b4）
⇒ 改走 MeasureBedHelper.arm_and_setup(cfg, false)（保留玩家，因為要殺的就是玩家）
★誠實限（寫在床裡）：A 輪也是先 arm 後 setup、再關 Probe ⇒ 三輪的 setup 期 Probe 都是開的，P1 比的是**模擬期**
重跑：數字與改前逐位相同（hash 4cdce628…、fp 09249152…、1 筆 team 11 tick 13357、擋掉 153、不設窗 150 筆全窗外）
```

# 五、交件前追加：隊伍鍵可選（team_key，預設 "team"）—— 你的追加③（spec a99cc14a6）

```
probe_stats.gd：sample_window[event] 可帶 "team_key"（預設 "team"），bump_sample 用它讀隊伍
  例：Probe.sample_window["construct.stall"] = {"team": 0, "team_key": "ct_id", "tick_min": a, "tick_max": b}
  ★沒改任何 bump_sample 的鍵名（construct.start 仍是 "team"、construct.stall 仍是 "ct_id"）
床 P5a（合成，直接餵 bump_sample）：
  team_key ct_id、team 3：收 [{tick 5, ct_id 3}]｜擋掉 2（ct_id 4 那筆、只帶 team 3 那筆）
  ★反向：不給 team_key：收 [{tick 5, team 3}]｜擋掉 2（兩筆只帶 ct_id 的）
床 P5b（真世界）：B（不設窗）construct.stall 8 筆，ct_id 全是 4 ⇒ C 對 team 4、team_key ct_id、tick 從 11521 起設窗
  ⇒ 收 8 筆、全是 ct_id 4｜擋掉 8 筆
  ★★我第一版這格**沒有鑑別力**：窗從 tick 0 起 ⇒ C 收的 8 筆＝B 的 8 筆、擋掉 0 ⇒ 窗什麼都沒做也綠
    ⇒ 改從 B 最後一筆之後起＋加「擋掉 > 0」地板
  ★★★誠實限：這一輪看到的停滯**全是 team 4** ⇒ 擋掉的 8 筆是被 **tick** 篩掉的，不是被隊伍篩掉
    ⇒ 「篩掉別隊」在真世界沒被展示（由 P5a 證）；P5b 真正證的是**鍵讀對了**
      （construct.stall 樣本沒有 "team" 鍵 ⇒ 不給 team_key 會一筆都收不到；它收到 8 筆）
⇒ 給量測員：要讀 team0／team3 的 construct.stall ⇒ {"team": 0 或 3, "team_key": "ct_id", …}；construct.start 不用給 team_key
```

# 六、分支與 main 的差

```
branch feat/decision-tap-targeting tip 9d81ec21a（最後一顆 ＝ artifact 落 ac1c705d8 那一輪）
★main 在我 rebase 之後多了：scripts/debug/team7_combat_trace.gd、scripts/debug/window_timing_ticketA_ratios.gd（量測員的）
  ＋ docs/mechanism-intents.md ⇒ 本票沒碰；但兩支新床會進**掃描型閘**的母體（bed-arm／bed-kind…）⇒ merge 時請照你說的重跑全部掃描型閘
```

