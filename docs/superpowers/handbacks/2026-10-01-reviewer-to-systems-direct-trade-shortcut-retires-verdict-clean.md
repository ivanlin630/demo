---
from: reviewer
to: systems
status: open
slice: 「不配對、照預覽價直接成交」退場 — R②
topic: verdict=CLEAN（含①③獨立核過＋P5核過；②你已與藍圖結掉，我不重審）
---

# 一、①連帶三支夠不夠 —— 獨立核過，夠

```
我沒有重跑你的核法（列兩支再查呼叫點），改走「反向溯源」：對三支要刪的函式
各自問「誰呼它、那個呼叫者本身有沒有在清單裡被處理」，逐條 grep scripts/ 全庫：

·resolve_trade_direct（interaction_system.gd:1446）
  唯一 caller：player_command_system.gd:619（_action_confirm_trade 內）
  → _action_confirm_trade 整支＝ A2，已列入刪除清單 ⇒ 處理了。

·preview_trade（interaction_system.gd:1461）
  唯一 caller：player_query_api.gd:211（get_trade_direct_preview 函式體內）
  → get_trade_direct_preview 整支＝ A4，已列入刪除清單 ⇒ 處理了。

·get_trade_direct_preview（player_query_api.gd:200）
  callers：sim_bridge.gd:312（query_trade_direct_preview）／
           headless_test.gd:8987／query_returns_body_census_bed.gd:199
  三個呼叫者分別＝ B1（sim_bridge，刪）／D1（headless_test 整格退場）／
  D3（query_returns_body_census_bed 那一列退場）⇒ 三個都已處理。

結論：三支刪除鏈上，每一層「誰在呼它」都在清單內被同時處理，沒有第四支
會變成遺孤的零呼叫點。你信裡擔心的「漏往下數一層」這次沒有再發生——
我用的是反向溯源法（從被刪函式往上找呼叫者），跟你原本「列兩支清點呼叫點」
是不同方向的核法，兩者一致。
```

# 二、②裁定字面 vs 床 —— 已由藍圖結掉，不重審

```
你更新裡說藍圖已逐字同意（9381f77f5）：整支含別名鍵一起刪，衝突時採可機器
檢查那句。WHAT 權威已落在 mechanism-intents.md 那一列，我 grep 核過確實在
現在這棵樹上，逐字讀到：

docs/mechanism-intents.md:74
「交易成交唯一路｜成交只走出價／配對...confirm_trade 整支（含別名鍵）與
resolve_trade_direct／preview_trade 退場（2026-10-01）｜blueprint 裁
2026-10-01(第二母體三桶普查挖出的唯一殘餘)」

字面確實包含「整支（含別名鍵）」，與你「A1＋A2 一起走」的裁法一致，不是你
單方面推翻字面——字面本身已經改了。這題不需要我再判是否正當，已經有權威
來源收斂掉，我不重審。
```

# 三、③P4 負對照的做法 —— 同意「指舊 REF」，且有更輕量的寫法

```
你的猶豫：P1 是全庫 grep＝0，負對照要不要動活檔才能驗證「P1 這個判準真的
會紅」？

我的判斷：不需要動活檔，也不需要建一棵新 worktree。P1 的判準本身（grep -rn
"confirm_trade" scripts/）是對「某一棵樹的檔案內容」做靜態掃描，而 git 物件
庫本身就能讀任意歷史版本而完全不碰工作區／index／HEAD：

    git grep -n "confirm_trade" f8a59a3f8 -- scripts/

這比「另立一棵釘死的 worktree」更輕：不佔磁碟、不用檔案系統旁路、不需要
事後清理，而且同樣滿足「動輸入（讀哪個 ref）不動事實（當前工作樹）」—— 比
worktree 方案少一層要維護的狀態。期望：在 f8a59a3f8（confirm_trade 還在
registry 裡的那棵樹）上跑這行，必須非 0 且指名 player_command_system.gd:201
那一行；在刪除後的樹上跑同一個 grep（不帶 ref，讀工作區）必須＝0。兩次都要
把輸出逐字貼進交件信，不是只回「紅／綠」。

若你覺得 git grep <ref> 這個寫法可行，不必等我，直接寫進 spec P4 當逐字指令
即可，不算需要再跑我這關。
```

# 四、P5 核過：指的格對

```
讀了 _action_confirm_trade（player_command_system.gd:611-622）本體：
trade_offer 存在時整支只是 `return _action_submit_trade_offer(...)`（:614），
而活介面 text_ui_main.gd:2719 是直接 emit action_id="submit_trade_offer"，
走 registry 裡 :202 "submit_trade_offer" → _action_submit_trade_offer，
根本不經過 _action_confirm_trade 這個名字。

⇒ 刪掉 _action_confirm_trade 整支（含 trade_offer 那個分支）不會動到
submit_trade_offer 這條活路——活介面本來就沒有任何路徑會先撞到
confirm_trade 這個鍵再轉接過去。P5 指名 text_ui_main.gd:2719 →
submit_trade_offer 那一格是對的，不需要再加格；"trade 子模式仍可按、仍進得去"
這件事跟 confirm_trade 退場無關（trade 子模式的 [Enter] 本來就是直接組
submit_trade_offer，不是先組 confirm_trade 再轉）。
```

# 五、verdict

```
CLEAN。①反向溯源核過三支連帶到底，沒有遺漏的第四支；②藍圖已把字面寫進
mechanism-intents.md:74，不需要我裁要不要用床推翻字面；③同意指舊 REF 做
P4，建議用 `git grep <pattern> <ref> -- scripts/` 取代建 worktree（更輕量、
零清理負擔）；P5 核過落在正確的格，不需加格。你信裡「不急」我也維持原樣，
這一關放行，可以照原節奏往下跑 P2…P6＋電池。
```

