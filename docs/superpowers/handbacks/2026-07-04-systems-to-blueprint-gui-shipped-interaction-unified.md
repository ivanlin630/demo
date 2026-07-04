---
from: systems
to: blueprint
status: open
topic: ★觀測GUI三件全上(品質bar五條走完,截圖自驗過,用戶可開)+互動統一F-I2/I4/I5/I7收(C類退役不並存);屈服率上移待平衡pass;beast洩入訂單系統=known_issues新項
---

# GUI slice shipped + 互動統一 merged（兩軌並行收）

## ★觀測 GUI（品質 bar 逐條交代）

1. **範圍內完整**：三件全上未砍——ticker（中文成句+選中隊過濾+隱藏訂單雜訊預設開）/ 任意隊 inspect（pop 四分解/糧+日流/rung/勢力/task,與地圖點選同步）/ 速度四檔（暫停/1×/4×/MAX）+月日顯示。加碼:god-view 六角地圖（archetype 色+勢力環+據點標+鏡頭跟隨）。
2. **穩**：seed 1337+2674 各 6 月 MAX 跑滿不崩、0 SCRIPT ERROR;frame 時間預算攤 spike,>150ms 卡頓≈1 次/月偶發（far.total 殘餘,queue 照舊,不在本 slice 動 sim）。
3. **可讀**：逐 type 人話模板（「張忠隊(10) 收服 陳智隊(3)，納入勢力8」「錢明隊(20) 立國，號『勢力9』」）;probe 話（hitch 讀數）已藏 debug flag;訂單洗版已濾（可勾回看經濟流）。
4. **bar 場景**：兩 seed 狼弧 ticker+inspect 追得完整——raid→俘獲→逃亡→宣戰→擊潰→收服→立國 全鏈畫面可讀。
5. **自驗**：截圖 harness（本 slice 新建,repo 原本沒有）跑完我逐張看過才報你。assets `handbacks/assets/2026-07-04-observer-gui-slice/`。

**RNG 零擾證明**：seeded warring 逐點 diff=0（三 seed）。關鍵縫=觀測事件走新 `observer_messages` 獨立 channel——實測發現 `global_messages` 被訂單系統借當 id 空間,直 append 會真改訂單行為,已立 invariant 擋後人。

**用戶開法**（A:\GDS\demo 下）：
```
tools\godot\Godot_v4.2.2-stable_win64_console.exe res://scenes/ObserverMain.tscn
```
（勿用 godot.ps1 wrapper 開互動 GUI——360s timeout 會殺視窗。）

## 互動統一（矩陣互動格收斂）

- 屈服判斷三公式→1（`tribute_accept`,belief-gated;血仇不屈/恩義軟化入權重=RelationGraph 終於接線）;失真三引擎→1（DistortionEngine）+dormant 刪;戰意判斷轉 belief（無情報→保守不攻,欺敵誘殺鏈再閉一環）。舊路全退役,無並存。
- **行為影響（記錄,平衡 pass 收）**：屈服率整體上移（兵臨壓力入公式）→ 勒索/戰鬥/無事分佈會變;TRIBUTE_* 全 TEST VALUE。
- seeded finals 量級不崩（teams/factions/立國/pop 同量級,hash 變=統一本意）。

## 揭項（known_issues 已入,要你知道的兩條）

1. **beast 獸隊洩入人類系統**：ticker 揭獸隊會張貼收購武器訂單、對人宣戰——訂單/訊息入口沒濾獸隊。觀測揭露,sim 未動。修=小。排序你裁（荒謬感傷 believability,但無 crash）。
2. RelationGraph killed/protect 兩型 dormant（零 writer/writer-dead）——收徒/擊殺鏈機制 spec 時裁復活或刪。

## 下一步 queue（不變）

用戶親驗 GUI（真人玩測=互動 fidelity 唯一驗法）→ 回饋收 → 強制閘全立 ‖ 矩陣剩餘（人力 F-M/belief F-B）‖ envoy 結盟弧殘 ‖ cadence far.total。
