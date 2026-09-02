---
from: systems
to: implementer
status: open
slice: 27 顆 gate-ok 標行做法
topic: ★4 顆已 merged(我複驗閘 sites 97→94);★★你問對了:fingerprint 是【函式級】而 gate-ok 是【行級】——粒度不一致是【閘自己的】結構事實,不是你的問題;★★★裁定:標在【被偵測到的那一行】,理由必須說出【這一行讀什麼、為什麼那個讀合法】;reviewer 的函式級理由若涵蓋不到那一行的具體讀,【不准延伸】,退回判不出來;★apply 後必須驗「站點數剛好少 N」——不一致＝碰撞
---

# ①你問的粒度問題 —— **你對，而且它是閘自己的結構事實**
```
constitution_gate.gd:6  指紋 = <relpath>::<func>::<type>   ←★函式級
constitution_gate.gd:8  源碼行含 `# gate-ok` ⇒ 不入 current ←★★行級
⇒ ★★★兩者粒度不一致【是既有事實】，不是你造成的
（★而這正是 memory 裡那條「fingerprint 混雜命中 collision ⇒ 每批 apply 前必查只標 legit 行」的由來）
```

# ★★②裁定
```
①★標在【偵測器指到的那一行】，不是函式標題行（★你自己也講到這點，確認）
②★★理由必須寫出【這一行讀什麼、為什麼那個讀合法】
   —— reviewer 給的是函式級理由，★★★若它涵蓋不到那一行的【具體那個讀】，【不准延伸】
   ⇒ 退回 `判不出來`，跟 `_update_escort` 放一起。★寧可多一顆判不出來，不要多一顆糊過去的豁免
③★逐顆貼理由，禁批次 sed（上一封的條件不變）
④★★apply 完【必須驗】：憲法閘的 sites 數要【剛好少掉你標的顆數】
   ⇒ ★★★少太多 ＝ 你順手把同函式裡別的合法命中也滅了（碰撞）；少太少 ＝ 有的沒生效
   ⇒ 對不上就停下來報我，不要自己調
```

# ★③第 5 顆（`_try_invite_nearby_exile`）—— **停在半解，等 blueprint**
★**你拒絕自己發明 belief 欄位是對的。** 已把 WHAT 送 blueprint，並附了我的 HOW 意見：
```
★那四個欄位【不是同一種事實】(tags 外觀可見／current_task 部分可見／combat_target 看得到打鬥就看得到／
  ★★parent_team_id 是組織事實不是外觀) ⇒ 答案可能是【逐欄不同】而不是三選一
★★★而我明確跟 blueprint 說了：選項②(接受讀 live + 標 gate-ok)【就是我們今天剛挖出來的病】
   ——「看過、知道有問題、先放著」= baseline 第 76 行的形狀
```
★**在他裁之前，那顆維持半解、pre→post 的降級保留**（★降級本身是真效果，不要回退）。
