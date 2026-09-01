---
from: systems
to: measurer
status: consumed
slice: S6-after
tier: measure
topic: ★S6 已 merge ⇒ 跑 after 腿,跟你四月前存的 before 腿比(commit 1af956fa,同一把尺);★★這一輪是【intended-change 的驗證】不是找 bug:工期全面變慢 4~8×,★所以「變慢了」是成功不是回歸;★★★而要你特別看的是【決策端有沒有跟上】——S6 之前 NPC 讀的是另一張表,那正是這一票修的東西
---

# ★①要什麼
```
after commit : 現行 main（含 S6 phase1+phase2）
before       : docs/process/verdicts/S6-baseline-before.measure.json（commit 1af956fa）
床/種子/天數 : ★完全照 before 腿（qty_tap_bed / seed 1337 / 30d / 兩床 / per-team-day）
```
★**不要加新 tap** —— ★★**before 腿的價值就是「同一把尺」，這一輪加 tap 會把它作廢。**

# ★★②這輪的判讀方向跟平常【相反】
```
★S6 是 intended-change：工期全面變慢 4~8×（錨 720 person_hours，blueprint 正式簽署）
⇒ ★★「建設變少、變慢」是【成功】,不是回歸
⇒ ★★★而【失敗】長這樣：世界的工期變慢了，但建設決策的【數量/節奏】完全沒變
   —— 那代表決策端還在用舊估算下單
```

# ★★★③要你特別看的那一格
```
S6 之前：decision_context:392 ／ goal_resolver:913 ／ faction_ai:4133 讀的是【另一張表】
        ⇒ 錨推不動它們 ⇒ 世界慢了而 NPC 不知道（★★「手不聽腦」的鏡像：腦不知手）
S6 之後：三處都改讀唯一入口
⇒ ★★★所以這一輪的核心問題是：【決策端的行為有沒有跟著變】
   （例：預期工期變長 ⇒ 該不該建的判斷改變 ⇒ 建設嘗試數/取消數/完成率的形狀）
```
★**照實報形狀，不要歸類成好壞** —— ★★**「該不該建」的判斷是 blueprint 的，不是我們的。**

# ★④誠實限
```
★工期 ×4~8 ⇒ 30 天窗內【完成數】會大幅下降,而那可能讓某些量的母體變太小
   ⇒ ★★母體小就說母體小,不要用小母體算比率（★★★今天已經有人吃過這個虧）
★timeout 也改了（相對錨定 + pop 動工當下凍結）⇒ 工地取消的形狀會變,一併報
```

# ★⑤交付
`docs/process/verdicts/S6-after.measure.json`（★明標 after commit hash）
