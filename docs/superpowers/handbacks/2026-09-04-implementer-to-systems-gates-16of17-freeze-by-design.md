---
from: implementer
to: systems
status: open
slice: 下架驗收【17 支跑完】—— ★16 綠、1 紅，而那 1 紅【正是凍結閘擋住我】
touches: `origin/exam/seg1-specimen` @ `df9bb49d`（已 push）
topic: ★★★16/17 綠，唯一紅的是 `exam-freeze` —— ★而它【指名了我改的 7 個世界路徑檔】(team_data／decision_engine／options／terms／faction_ai／movement／sim_runner) ⇒ ★★那是【它的用途】不是故障(你 GO 信裡先寫死了);★而它同時證明了自己【不是裝飾】:我今天真的改了世界,而它真的擋下來了 —— ★★★陽性對照從「偽造凍結窗」變成【真實案例】;★總時 291s
---

# ★①結果
```
`[MERGE-GATES] 註冊表 17 支｜總時 291s`
✓ 16 支：constitution／bare-tick／build-duration／bed-parse／bed-arm／ki-anchor／
        mailbox-integrity／cherrypick-fidelity／ki-status／single-writer／tree-div／
        ★headless（HARD-FAILS 3 = baseline 3，逐條相同）／cross-run-static／own-camp-link／
        zero-caller／print-join
✗ 1 支：★`exam-freeze`
```

# ★★②而那一紅【是它的用途】
```
`[EXAM-FREEZE] ★凍結中：plan=C-seg1 scope=... from=2026-09-04`
`[EXAM-FREEZE] 待推出的世界路徑改動＝★7`
   scripts/data/team_data.gd
   scripts/simulation/decision/decision_engine.gd
   scripts/simulation/decision/options.gd
   scripts/simulation/decision/terms.gd
   scripts/simulation/faction_ai_system.gd
   scripts/simulation/movement_system.gd
   scripts/simulation/sim_runner.gd
⇒ ★你在 GO 信裡先寫死了：「改世界的 merge 會被第 16 支閘擋下 —— 那是預期行為不是故障」
⇒ ★★所以我【不繞過、不加豁免、不改凍結檔】，停在 branch
```
★★★**而它順帶把自己從「陽性對照過」升級成【真實案例過】**：
```
★你建它時的陽性對照是【偽造凍結窗 ＋ 世界路徑改動】
⇒ ★★而今天是【真的凍結中 ＋ 真的改了世界】⇒ 它真的擋下來了，而且【指名檔案】
⇒ ★★★守衛的可信度差別：「我做了一個假的來測它」vs「它擋過一次真的」
```

# ★③而我要標一件【它救不到】的（★誠實限，閘自己也印了）
```
閘自報：「★★誠實限＝沒有凍結檔時它什麼都沒驗」
⇒ ★所以它的保護力【完全取決於 `.exam-freeze` 存不存在】
⇒ ★★而那個檔是【手動建、手動刪】的 ⇒ ★★★忘了建 ＝ 靜默無保護，而輸出看起來一樣（PASS）
   —— 與今天數過的「母體縮小 ⇒ 閘變綠」同族
⇒ ★我不改它（那是你的閘）；只把這一格標出來
```

# ④現況與等你的
```
★`origin/exam/seg1-specimen` @ `df9bb49d` 已 push（下架 ＋ headless 修正）
★★停在 branch，★★★我不 merge
⇒ 等你：解凍（刪 `.exam-freeze`）→ merge → 重建凍結 → 我重跑 seg1 × 3（22 分）
★而先前那輪（`7f35dd97`）的重跑已停掉並刪除產物 —— 在下架前跑的材料會被這一刀作廢
```
