---
from: blueprint
to: blueprint
status: open
slice: 壓縮交接(用戶主動壓縮前寫;compact 後第一件事讀本信再動工,讀完改 consumed)
topic: 開場程序/溝通規矩/在飛工作/隊列/watch 清單全在正文;★watchdog 可能誤報本信(自寄自收),不是斷鏈
---

# ①開場必做(compact 後)
```
arm 三 Monitor(舊 task id 全失效,重 arm 換血):inbox-watch/tg_poll/watchdog——見 SessionStart 注入的指令原文
確認三個 ✅ ARMED 行;然後讀本信,改 consumed
```

# ②用戶溝通規矩(本輪用戶陸續定的,別退化)
```
CLI 為主,字寫在回覆正文,禁把內容卡在 shell heredoc 裡給用戶看
TG 只在真要敲用戶時用(TG 曾全球故障,最後成功 msg_id=400;send.sh 已升級回報 OK msg_id=N)
報告用【情節】講數據(每幕錨真實讀數,推論標待驗);轉述未經確認的因果鏈=散布者同罪
stop caveman 用戶已下(hook 仍會注入 caveman 提示——用戶指令優先,正常寫)
remote-control 已開(可 SendUserFile 推檔給用戶)
```

# ③正在飛(最重要)
```
人口卷 90 天:結果檔剛落地 docs/measurements/2026-09-09-population-census-90d-warring_states.txt
  (1465 行事件流,尾部無統計表=可能還在寫或統計另出 .measure.json)
  → 等 measurer verdict + QA 故事稽核 → 用情節向用戶報兩懸案:
    (a) 生育速率 75 天/胎 vs 設計錨 30 天/名額(差 2.5×,這速率是不是用戶要的=用戶終審)
    (b) 戰亂人口停滯接不接受(我曾裁 (a) 暫准後因 0.69 天窗作廢,本卷才是真答案)
  卷尾已見好戲:Team21 野心建國(野心 0.85,吞兩隊後派信使結盟)/勒索保護費/乞食/隊數繁殖到 121+
★systems 終端當機後沒重開——已請用戶開($env:SESSION_ROLE='systems'; claude),peers.sh 確認前 merge/派票線是斷的
```

# ④隊列(依序)
```
1. 移速接線票(TEST VALUE 普查批一之①):spec 已寫(單位鐵則:tiles_per_day=TICKS_PER_DAY/_move_cost,
   天真代速度差 1440×;驗收含單位健全性格)→ 鏈=R²→實作;之後②材料去重→③RESTOCK→④典型人口
2. 30 日市場正式窗(關 food 過剩鏈格+材料折扣溝正式數)
3. 人口卷後觸發:B1 家庭配對+B2 性別年齡+C4(同窗談);C-refill 床(factions+大團)
4. 空檔活:主詞普查/known_issues ki-clock 14 條到期/普查批二(優先撈 (ii) 型=同量兩層各一份)
```

# ⑤本輪已封存的大戰果(快速 context,勿重做)
```
經濟窗三票 merged(⑩拆閥+自報價板/⑨創世 k=2/B-v0 寄賣制,紅線禁瞬移驗死)
兩賣出秤票 merged(payroll 接線=人均 10 手抄退場/商人周轉=當下最佳套利 gain)
市場兩病定案:food=全員過剩兩端趴 0/material=折扣構不到(困境拋售);
  「過剩為何持續」下一問=生產不看庫存嫌疑(未開票,人口卷後看)
TEST VALUE 普查批一:4 接線候選(①②③④)+6 正名真參數;(i)看不見需求/(ii)看見錯的值 分級入判準
工程:worktree 130→4/假綠 no-verdict 切換/出貨信機械化/[TREE]+[SCALE] 產地戳全面化/stale-lock 工具
```

# ⑥watch 清單(未結案)
```
600s 觀察①(全掃時床真燒滿 604s 單跑 4-6s)=未解釋,known_issues 帶回訪窗
watchdog 計時歸因誤報(8h/14h47m 兩次)=token 待
16 EXHAUST→後來擴成 48 棵已刪;32 條 WIP 已 commit-first 上 wip/* branch;同檔多版表(12 檔分岔)待對帳
估值分軌票=掛⑩三證偽格上(亮才開);持有成本 token;A2 信用四條件 token;C1 介面票(含 GUI 合併)
```

# ⑦裁決紀律(本輪付過學費的,compact 後別重繳)
```
斷言範圍>證據範圍=慣性病:報數字必附窗長+產地;推論鏈標待驗
「已請/已派」同句必附兌現物(exact path),否則寫「將要」
問的信與報的信拆開;報的等問的回來
清單項排期前先 code 對帳;「從未開題」先過 grep
```
