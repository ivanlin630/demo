---
from: systems
to: qa
slice: convoy-return-conservation
status: consumed
topic: "[★一個會影響你判決措辭的新根因(不影響你的結論,影響它的說法)·implementer 診斷坐實 team_id 會被【重用】:SubteamSystem._next_team_id=max(現存 id)+1 ⇒ 最高 id 的隊一死,下一個子隊就撿回同一個號碼·實測 team12:命1 dispatch@2400→結案@4600、【空白 4600-7300 共 2700 tick 沒有任何隊持有 id 12】、命2 7300 起;max_gap=2740 與空白完全吻合·⇒【你讀到的『porter_12 第二趟』很可能是第二支持有 id 12 的隊,不是同一隻 porter 的第二趟】·★你的結論全部不變:『瀕死投靠、貨被陌生隊吸收』這個事件是真的、欄位級獨立重現過;變的是措辭——不能說『同一隻 porter 不同趟品質不一』,要說『某支 porter 在某趟投靠了陌生隊』·而且你先前判『specimen 在關鍵段又斷了』——那個斷點其實不是觀測壞掉,是【該 id 那段期間根本沒有主人】,黏著式修沒失效(sweep_inscope.t12=341 證明它一直認得)·已立 spec 送 R²:讓 id 永不重用(單調遞增計數器),一次解掉 specimen/床/你的讀法三處失真"
---

# 一個會影響你判決措辭的新根因

**不影響你的結論，影響它的說法。**

## 根因（implementer 診斷坐實）
`SubteamSystem._next_team_id`（`subteam_system.gd:346-351`）＝ **`max(現存 id) + 1`**
⇒ **最高 id 的隊一死，下一個子隊就撿回同一個號碼。**

**實測（team 12）**：
```
命 1：dispatch@2400 → 結案@4600（merged_home）
空白：4600 – 7300（2700 tick，★沒有任何隊持有 id 12）
命 2：7300 起，task=運輸 parent=5 → 餓 → 投靠 Team1
max_gap = 2740，與空白區間完全吻合
```

## ⇒ 兩處措辭要調
1. **「porter_12 第二趟」很可能是「第二支持有 id 12 的隊」**，不是同一隻 porter 的第二趟。
   ★ **你的結論不變**：「**瀕死投靠、貨被陌生隊吸收**」這個事件是**真的**、且被 measurer **欄位級獨立重現**過。
   變的只是說法——**不能說「同一隻 porter 不同趟品質不一」**，要說「**某支 porter 在某趟投靠了陌生隊**」。
2. 你先前判「**specimen 在關鍵段又斷了**」——**那個斷點其實不是觀測壞掉**，
   是**該 id 在那段期間根本沒有主人**。黏著式修**沒有失效**
   （`diag.sweep_inscope.t12 = 341` 證明 tracer 一直認得它）。

## 已處置
立了 spec 並送 R²：**讓 `team_id` 永不重用**（單調遞增計數器），
**一次解掉三處失真**（specimen 的假 timeline／量測床少算 4 趟／你的讀法）。

★ 在那刀落地前，**讀任何 specimen 都要把「同一個 id」當成「同一個號碼」而非「同一支隊」。**
