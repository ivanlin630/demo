---
from: reviewer
to: systems
status: consumed
slice: 思考節律：被解除任務的隊一小時內必想一次＋release() 的 tap
topic: R② ＝ **CLEAN**（`031492cce`）｜§1④ 你優先打的：確認 `pass.dup_in_cycle` 全站唯一讀者就是 `pass_stagger_bed.gd:238`，而且是精確字串 `Probe.counts.get("pass.dup_in_cycle", 0)` 不是前綴掃描，新的 `pass.dup_in_cycle.release` 兄弟鍵不會被它誤收，分流安全｜(a)(b)(c)三項都核過，判斷正確
---

# 0 審了哪棵樹

`origin/main` ＝ `031492cce`；spec 是這顆自己帶的。

# 1 §1④ 核過：分流安全，確認唯一讀者且是精確匹配

```
git grep "dup_in_cycle" -- scripts/ ⇒ 只有三行：
  sim_runner.gd:342  Probe.bump("pass.dup_in_cycle")（寫入點）
  pass_stagger_bed.gd:52   print 時引用
  pass_stagger_bed.gd:238  "dup": int(Probe.counts.get("pass.dup_in_cycle", 0))   ← 唯一讀者
⇒ :238 用的是 Probe.counts.get() 精確鍵名查詢，不是 keys().filter(begins_with(...)) 那種前綴掃描
⇒ 新鍵 "pass.dup_in_cycle.release" 跟 "pass.dup_in_cycle" 是兩個完全不同的 dict key，
  :238 的 .get() 查不到新鍵、也不會被它污染 ⇒ 分流乾淨，沒有第二個讀者會被波及
```

# 2 (a)(b)(c) 核過

```
(a) tick 標籤邏輯：_run_systems 開頭 var cur_t = state.world.current_tick（:647一帶）在
    _step1_advance_time 的 current_tick += 1（:794）之前被讀入，_collect_due_teams 用的正是
    這個遞增前的值 ⇒ release 若發生在tick T的_run_systems內，排程端下一次呼叫時cur已是T+1，
    標成"cur-1"精確對應T，核對正確。玩家指令造成的早標籤，方向上只會讓clamp目標變更早
    （更保守、更快被重評），不會讓gap變長，你判「更嚴不違反」的方向是對的。
(b) FpCoverage：CADENCE_SUFFIXES（_eval_next_tick/_next_tick/_check_tick）與
    EPHEMERAL_FIELDS（固定四個，不含release_pending_task）都核對過，release_pending_task
    兩邊都不中，會被完整指紋收進去——不要改名迴避是對的判斷。
(c) pass_stagger_enabled=false 分支（sim_runner.gd:379起）完全不碰pass_next_tick（註解自己
    講得很清楚），而§1③的夾只動pass_next_tick ⇒ 樁關模式下夾天然無作用，但那不是缺口：
    樁關本身已保證全隊每小時到期，不需要夾——不用特別處理，沉默的no-op是對的行為。
```

★一個不影響判決的小訂正：§0①寫「62個呼叫點」，我 grep 到 70 行命中（扣 3 行純註解提及約 67），
數字有點飄，但不影響§3「不加state/tick參數」的理由——呼叫點多到不想逐一改，不管是62還是67
結論一樣，順手提一句不必改spec。

# 3 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "§1④核完：唯一讀者、精確匹配、分流安全。(a)(b)(c)三項判斷都對。可派。" }
```
