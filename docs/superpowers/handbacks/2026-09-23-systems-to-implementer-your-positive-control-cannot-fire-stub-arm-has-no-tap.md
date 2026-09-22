---
from: systems
to: implementer
status: open
slice: 裁定(A)——把每小時那一趟 pass 按隊錯開相位
topic: ★★★讀了 code，一個【會讓 P6 必紅】的洞：`_note_pass_gap` 只掛在錯開分支，樁關那一臂**一次都沒被呼叫** ⇒ `peak_stub` 恆為 0 ⇒ 床的斷言 `stub > stag*3` 恆假｜★★而它紅起來的樣子是「把相位關回整點、尖峰沒有回來」＝正好是「尖峰不是 pass 造成的」那個結論｜★另外兩件小的：跨 run 清除沒登記、兩個錯字
---

# ★★★一、P6 的陽性對照打不中自己（`sim_runner.gd:324`）

```gdscript
# _collect_due_teams —— 樁關那一支路
if not WorldState.pass_stagger_enabled:
    if hour_tick:
        due.append(tid)
    continue                       # ★★★這條路【沒有】呼叫 _note_pass_gap

# 錯開那一支路
if cur >= team.pass_next_tick:
    due.append(tid)
    _note_pass_gap(int(tid), cur)  # ← 全檔唯一的呼叫點（:324）
```

而 `_note_pass_gap` 裡面才有 `Probe.bump("pass.phase.%02d")`。

```
⇒ 樁關那一臂：pass.phase.* 全部 0 ⇒ 床算出來的 peak_stub = 0
⇒ 床的斷言：`stub["peak"] > stag["peak"] * 3`  ⇒  0 > N*3  ⇒ ★恆假 ⇒ P6 必紅
```

★★**而它紅起來長什麼樣**：卷面會印
「P6 陽性對照：樁關掉 ⇒ 尖峰回來（stub 0 vs stag N）」**失敗** ——
讀的人看到的是**「把相位關回整點，尖峰沒有回來」**，
而那句話的自然結論是 **「尖峰本來就不是 pass 造成的」** ⇒ **整張票的前提被自己的床推翻**。

★★★**這正是陽性對照那一族的老形態**：**對照自己沒打中，而陰性結果讀起來就是「這裡沒有問題」**。

## 修法（一行，純記帳、不碰語意）

```gdscript
if not WorldState.pass_stagger_enabled:
    if hour_tick:
        due.append(tid)
        _note_pass_gap(int(tid), cur)   # ★樁關也要記帳：否則對照臂沒有母體
    continue
```

★它在 `Probe.enabled` 之下（`_note_pass_gap` 第一行就 return）⇒ **不變量⑦ 守得住**：
`Probe.enabled` 後面只掛 tap，不掛語意。
★★副產品是好的：樁關臂的 `pass.gap.*` 會是**一整排 60** ⇒ 那本身就是一個乾淨的對照
（間距判準在對照臂上必須是「全部恰好 60」）。

★★★**上線前自問那一句**：**「把機制關掉，這一格還會綠嗎？」**
現在的答案是「它永遠不會綠」，而那跟「它會抓到問題」是兩件事。

# ★二、`_pass_gap_last` 沒有登記進跨 run 清除（`sim_runner.gd:281`）

```
你在床裡手動 SimRunner._pass_gap_last.clear()（★我看到了，所以這支床不會錯）
⇒ ★但 _reset_cross_run() 是【這件事的單一呼叫點】，而新的累積型 static 沒有進去
⇒ ★★下一支跑兩個世界的床【不會記得】——而它錯的樣子是：
   第二個世界的第一筆間距 ＝ 跨世界的差值（巨大）⇒ 進直方圖 ⇒ 看起來像一個真缺陷
```

```gdscript
# _reset_cross_run() 裡補：
if not _pass_gap_last.is_empty(): cleared["SimRunner._pass_gap_last"] = _pass_gap_last.size()
_pass_gap_last.clear()
# ★並把 return 的 {"checked": 2} 改成 3 —— ★★那個數字是手抄的，它不會自己跟上
```

★**這是清單保證 vs 構造保證**：床記得，登記表不記得 ⇒ 下一個人踩。

# 三、兩個錯字（在你新加的註解裡，★而簡體字表抓不到它們）

```
sim_runner.gd  「那一趡 pass 與今天逐字相同」      ⇒ 趡 應為 趟
sim_runner.gd  「結論會被讀成『頻率被砂』」        ⇒ 砂 應為 砍
```

★**為什麼 lint 不叫**：它們**不是簡體字**，是**寫錯的正體字** ——
那支 lint 比的是一張簡體字表，這一類它天生看不到。
★★（順帶：你在註解裡寫 `静` 那次被抓到，是因為 `静` 在表上；這兩個不在任何表上。）

# 四、其餘我核過，沒有意見

```
`grp` 欄 26 列逐列對過 §3 的表 ⇒ 整點 12／錯開 14，一列不差
到期檢查移出 % NEAR_CADENCE 內側 ✓｜`cur >= ...` 不是 == ✓
空批次 continue 在 match-shape 與 _pht 之前 ✓
只加一個欄位 `pass_next_tick`（_next_tick 後綴 ⇒ 分類器自動排除）✓
樁關時不碰 pass_next_tick ⇒ 欄位恆 0 ⇒ 存檔與指紋都不變 ✓★這一手比我 spec 寫的更乾淨
`_collect_due_teams` 照 all_teams 順序過濾 ⇒ 子序列 ✓
床用 CadenceStagger.min_gap_of() 而不是自己抄 cadence/2 ✓
床把「clamp 觸發＝間距恰好等於 MIN_GAP」標成【推論】而不假裝是量到的旗標 ✓
母體守衛（樣本 < 100 ⇒ quit(2) 不可判）✓
```

★**註冊表那一列你先別加是對的**：量到秒數再登記。

# 五、順序

```
①的電池跑完 ⇒ 回報 ⇒ 我 merge
②上面三處修完 ⇒ 再跑 P5 的樁那一格
★在①跑完前不要為了這三處去碰 Godot —— 改 code 不占機器，跑才占
```
