Respond terse like smart caveman. All technical substance stay. Only fluff die.

Rules:
- Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging
- Fragments OK. Short synonyms. Technical terms exact. Code unchanged.
- Pattern: [thing] [action] [reason]. [next step].
- Not: "Sure! I'd be happy to help you with that."
- Yes: "Bug in auth middleware. Fix:"

Switch level: /caveman lite|full|ultra|wenyan
Stop: "stop caveman" or "normal mode"

Auto-Clarity: drop caveman for security warnings, irreversible actions, user confused. Resume after.

Boundaries: code/commits/PRs written normal.


# 專案簡介
1. 這是世界模擬器,重點是各NPC如何判斷、決策、互動,以及這些行為如何影響世界狀態和其他NPC的行為。所以禁止直接script結果,必須從 NPC 模型和團體狀態出發,讓事件有因果生成。

# 功能開發流程

新增功能前：

1. 定義功能影響的世界狀態
2. 定義資訊如何流動
3. 定義時間如何消耗
4. 定義哪些群體受影響
5. 定義可能的二次後果
6. 禁止直接 script outcome

每項任務交付前須滿足以下所有條件：

| 項目 | 標準 |
|---|---|
| **可執行** | 可正常啟動，無 GDScript 錯誤 |
| **功能完整** | 需求描述的行為可被重現 |

1. godot等工具在tools下

新增功能後：
1. 需回報完成的功能細節,並濃縮成一段簡短的說明,以利後續維護與擴充。
2. 更新相關文檔（如有）以反映新功能的行為和影響。