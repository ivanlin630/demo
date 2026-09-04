# HOW spec — 「備戰」下架（★blueprint 裁 2026-09-04：它不該是持續 task）

**裁定來源**：備戰的真身是**軍民混編 arc 的【動員】軸**（動員抽勞力 → 產出掉；threat 消 → 解甲回田）
⇒ **它是【狀態調升】不是【佔位 task】**；現 `TASK_PREPARE` ＝ **無執行體的空殼**。

## §1 為什麼「接上豁免」不是修法（★已由 systems 查證）
```
★faction_ai:454 要【威脅消失才釋放】⇒ 若真的 dispatch,隊會被【鎖在一個什麼都不做的 task 裡】
⇒ ★★而威脅在 warring 世界可能很久都不消失 ⇒ 那把【幻影贏】換成【真空轉】,更糟
```

## §2 範圍（★下架 ＋ 五處殘件）
```
①★options.gd:427-435「備戰」entry ⇒ 【從候選池移除】
②★team_data.gd:20 TASK_PREPARE const ⇒ 移除
   ★★★（訂正 2026-09-04：我原本寫「前提：全庫零引用」—— **那個前提不成立**：
   debug 端還有 6 處引用，const 一移除就【編不過】。
   ⇒ ★而我手上【本來就有那個數字】：我自己的窮盡搜索是「13 處，production 六處」⇒ 剩下七處在 debug，
      ★★我卻把前提寫成「零引用」—— ★★★前提要寫成【可驗的檢查】(「移除前先驗零引用，含 debug」)
      而不是【斷言】(「零引用」)，否則它會變成下游的絆索。）
③faction_ai:454 的 task 清單成員 ⇒ 移除
④movement_system.gd:73 ／ sim_runner.gd:414 的「不移動」清單成員 ⇒ 移除
⑤faction_ai:754 那句【錯的】註解（「TeamData 無此 task」）⇒ 一併修掉

### ★★★（訂正 2026-09-04，R² ① 抓到我的負斷言翻車）：**字面字串 `"備戰"` 另有五處**
```
★我用 const `TASK_PREPARE` 搜索 ⇒ 13 處乾淨 —— ★★而【字面字串天生躲得過 const 搜索】
⇒ 補上(全部 production,不 head):
   terms.gd:27-29        PREP_A / PREP_B / PREP_K 三常數（★備戰 util 的係數）
   terms.gd:333          `if opt != "備戰": return 0.0` ★★prepare_drive 的 gate
   options.gd:533        `if opt in ["備戰", "迎戰", "求和"]`
   faction_ai:3022       `if Probe.enabled and opt in [...]` ★Probe tap
   decision_engine:681/689  ★純儀器 tap（prep.*）
⇒ ★★★不清這些 ⇒ 它們變成【孤兒死碼】,而 terms.gd 的三個常數會讓下一個人以為備戰還在
★而存檔路徑:R² 查過 —— ★本 codebase【沒有 game-save/load 機制】⇒ 該風險不存在
```
```

## §3 ★★★兩個必須寫死的坑
```
★①`prep.*` 那組 Probe tap（decision_engine:676-695）【必須一起移除】
   ⇒ ★★否則它們會【永遠印 0】—— 而那正是今天記過的【幽靈 counter】形狀:
      「這條沒發生」與「這條不存在」長得一模一樣
   ⇒ ★★★留著 0 比刪掉更糟:它會讓下一個人以為備戰還在候選池裡而只是沒贏
★②【殘留狀態】檢查:若有隊 current_task 已經是 "備戰",移除釋放路徑(:454)會把它們卡住
   ⇒ ★而本 bug 本身保證了這件事不會發生:它【從未成功 dispatch】⇒ 沒有任何隊處在該 task
   ⇒ ★★但仍要【機械驗證】:跑後印 `current_task == "備戰"` 的隊數 ＝ 0（★不是論證,是量）
```

## §4 驗收
| # | 判準 |
|---|---|
| 1 | 「備戰」**不在候選池**：`optpool` 裡不再出現該 option（★母體仍要印，證明表沒壞） |
| 2 | ★`prep.*` tap **全部消失**（★★不是變成 0） |
| 3 | ★★`current_task == "備戰"` 的隊數 ＝ **0**（機械斷言，不是論證） |
| 4 | determinism：同 seed 三跑一致（★`fp` 會變 —— 候選池變了） |
| 5 | 憲法閘 PASS ＋ 17 支 merge-gate 全綠 |
| 6 | ★★★**流向讀數**：原本輸給備戰的那些 option，現在**贏了什麼** ——★照原樣報，**不解讀**（blueprint：讓引擎自然重分配） |

## §5 不在範圍
```
★①動員軸本體（軍民混編 Slice B：mobilizable 分數）—— 條目已標【已知未實裝｜觸發＝Slice B】
★★②threat 相關的其他 option（迎戰／求和）不動
★★★③不補任何「替代的備戰」—— 下架就是下架,不要順手塞一個佔位
```
