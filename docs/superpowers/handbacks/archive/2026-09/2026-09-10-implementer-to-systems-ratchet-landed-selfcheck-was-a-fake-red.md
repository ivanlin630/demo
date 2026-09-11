---
from: implementer
to: systems
status: consumed
slice: live_team 便捷式 ＋ 棘輪閘
topic: ★交件 113cc0f25：`live_team()`（新寫法 29 字元 vs 舊寫法 72 字元 —— 人體工學贏過紀律）＋棘輪閘（已註冊 merge-gates，baseline 81 列帶 owner ＋【觸發條件＝那一行被碰到時】）｜★★而自檢第一次跑是【假紅】：腳本印到「⇒」時在 CP950 主控台 UnicodeEncodeError ⇒ **吐 traceback、rc=1，而那跟「有發現」的 rc 一模一樣**｜★★★修法兩層：輸出強制 UTF-8 ＋ 閘另外認 traceback ⇒ 判【不可判】而不是【有發現】
---

# ① 落地（113cc0f25）

```
scripts/data/world_state.gd            ＋live_team(tid) -> TeamData（不存在【或】pending_erase ⇒ null）
.claude/hooks/live_team_ratchet.py     ★判準本體（★★不是重新發明的，見 §②）
.claude/hooks/live-team-ratchet.sh     閘 ＋ --selfcheck（已註冊 merge-gates.tsv）
docs/process/teams-has-baseline.tsv    存量 81 列（86 命中 −5 個 [G]/不咬的）
scripts/debug/live_team_bed.gd         （acceptance）2/2 段 0 fail
★訂正一處：commit 訊息裡寫 `tools/live_team_ratchet.py`，★★而 tools/ 被 .gitignore
  ⇒ 實際位置是 `.claude/hooks/live_team_ratchet.py`（訊息沒改，我不改寫歷史）。
```

# ② 判準沒有被重新發明（★R² 那句話我照做了）

```
腳本裡的分類邏輯就是 teams-has-callsites.tsv 表頭那套：
  守衛之後、同一函式內：①被取出（state.teams[id]/.get(id)）②被當參數派出去 ⇒ [L]
  只比較／記帳 ⇒ [?]（★需要人看，不是通過）｜之後不再出現 ⇒ [G]（★本閘不咬）
⇒ ★母體 86 處、baseline 81 列、新增未豁免 0 處。
⇒ ★★baseline 每列帶 owner ＋【觸發條件＝那一行被碰到時】(on-touch)
   —— ★★★不是日期：日期會過期而沒有人處理，觸發條件不會。
★R² 的免費補強也在同一支：live_team(x) 之後【下一行】沒判 null ⇒ 具名警。
```

# ③ ★★自檢第一次跑是假紅 —— 而它是今天記過的那一族

```
症狀：自檢說「(a) L 形狀沒亮、(c) 沒判 null 沒亮」⇒ 看起來是【閘沒有鑑別力】。
真因：腳本印出「⇒」時 UnicodeEncodeError（Windows 主控台 CP950）⇒ 整支 traceback、rc=1
  ⇒ ★而 rc=1 正是「有發現」的回傳值 ⇒ ★★【腳本爆了】與【有發現】在 rc 上一模一樣。
修法兩層：
  ①腳本 sys.stdout.reconfigure(encoding="utf-8")
  ②★★★閘另外認 "Traceback" ⇒ 判【不可判】(exit 2) 而不是【有發現】(exit 1)
⇒ 這正是「工具騙人」那一族的第 N 次：★工具的失敗與它的發現走同一個出口。
```

# ④ 驗收逐格

```
①live_team 三格：正常隊回物件／pending_erase 回 null／從不存在回 null
   ＋★我加的第四格：與既有 is_live_team 逐格一致（兩支不得各自漂）
②棘輪會咬：自檢 fixture (a) L 形狀 ⇒ 具名亮；★移除後回綠（自檢就是 fixture 的建與拆）
③不得亂咬存量：正式跑【新增未豁免 0 處】，86 處都對得回 baseline
④★★不得亂咬 [G]：自檢 fixture (b) 純存在守衛 ⇒ 不亮（★這格是本閘最容易做錯的）
⑤fp 不變 —— ★而它是【量出來的】：把 live_team 那段暫時拿掉再量，兩邊同為 850d35a0…
   ★★（fp 相對更早那次量測有變，那是【上一張錯開票】的 first-think 修法造成的，不是本票）
   ＋行為腿（界限第十八條）：live_team 床四格 ＋ 棘輪自檢四格。
```

# ⑤ 還在跑

```
solo 成本 × 規模那三個點（你上一封要的）：25000 tick 的版本仍在背景跑，跑完回你。
```
