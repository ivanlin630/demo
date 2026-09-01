---
status: R² CLEAN(2026-09-01 issues→定案第 4 案;★R² 訂正了我沿用的舊描述)
owner: systems
slice: tracer-observe-purity
law: ★用戶立法「觀測不得改變被觀測物」（`observer_no_global_rng`）—— 本例是它的第 5/6 例，且是【直接寫 state】
---

# ★①現症
```
specimen_tracer.gd:107 → to_task → gather → ★寫 state
~~gather 三項副作用：EWMA 推進 ／ cache 寫 ／ cadence 重排~~
★★★**R² 訂正（2026-09-01）**：**EWMA 推進【已經修過】**（`advance` 旗標預設 false）
⇒ ★**真正還活著的副作用只剩一處：`idle_employ` 快取寫**
⇒ ★★而我沿用的「三項」來自 `known_issues:653` 的舊描述 —— **我照抄記錄當現況，傳了好幾封信**
★而 tracer 是【QA 讀 motive→action→outcome 故事】用的工具 ⇒ 觀測正在改世界
```
★★**且它有一層保護而擋不住**：`:87 _begin_observe` 自述 suppress RNG ＋ suppress Probe，**沒有** suppress state 寫入
⇒ ★★★`known_issues:653`「抑制清單＝易漏的黑名單」的**第一個實證，而漏的就是最重要的那一項**。

# ★★★②修法：**不要用另一個黑名單去修黑名單**
```
✗ 反面教材：「把 gather 會改的那三樣 save + restore」
   ⇒ ★那還是黑名單 —— 它只還原【我們今天知道的三樣】
   ⇒ ★★而今天這個病的成因，就是有人列了一張只有兩項的清單
```
## ★三個候選（★選擇依據 ＝ **tracer 到底需要 `to_task` 的什麼**）
```
A★【不呼叫】：tracer 要的是「動機」,而 to_task 是【決策執行】
   ⇒ 若動機能從既有欄位/Probe 讀出 ⇒ ★★最乾淨:沒有寫入,就不需要抑制
B★【read-only 投影】：抽一個 pure 版本供觀測呼叫
   ⇒ ★★而它的風險是【下一個副作用被加回 pure 版】—— 需要一個守衛盯它
C★【整體 snapshot/restore】：★★白名單安全（連未知寫入都還原）
   ⇒ ★★★但代價是深拷貝 WorldState,且【restore 本身可能有洞】(引用型欄位)
```
## ★★★定案：**第 4 案 —— 在源頭擋那一個寫點**（R² 提出並查證）
```
★R² 查證：29 個 to_task handler【沒有一個真的讀 idle_employ_value】
   ⇒ ★★所以那顆快取寫【對觀測路徑毫無用處】—— 擋掉它不損失任何東西
★★★而它不是黑名單：★因為那是【唯一還活著的寫點】(EWMA 那項已修)
   —— 而「唯一」這個負斷言【由驗收①自己證明】：若還有別的寫入，三跑 byte-identical 會失敗
```
★**A/B/C 全部作廢**：A 不必（不用避開 to_task）、B 太重、C 代價最高而現在沒必要。
★★**而 R² 幫我查了我原本要交棒的那件事**（「tracer 需要 to_task 的什麼」）——
★★★**答案是：不是全查 29 個，是查 7 個，而 7 個都不需要那顆髒欄位。**

# ★★③驗收（★blueprint 定，既有法的驗收式）
```
①★★★開 tracer vs 關 tracer，★三跑 byte-identical（state_fingerprint）
   ★失敗長相＝任一跑不同 ⇒ 還有寫入沒擋住
②★陽性對照：把修法拿掉 ⇒ 必須【不同】
   ★★★而 R² 指出我的疑慮是真的 ⇒ **走【構造】，不要靠隨機跑撞到窄觸發**
   （★`idle_employ` 快取寫的觸發條件窄 ⇒ 隨機跑可能整輪都沒踩到 ⇒ ★★那時「相同」是【沒觸發】不是【沒影響】）
③★★若選 B：需一顆守衛盯「pure 版有沒有長出副作用」
   ⇒ 而它必須掛在【一定會走】的路上（★★★今天剛立的 invariant）
```

# ★★★④修完接一支量測（blueprint ②）
```
★量【過往 QA 判決的擾動量級】：帶/不帶 tracer 的差分
   大 ⇒ 列【重驗名單】／小 ⇒ 記帳免重驗
★★而【不預設作廢】—— ★★★「可能被污染」與「已經錯了」是兩件事
```

# ★⑤併入讀寫分離票（blueprint ③）
```
★known_issues:653 改【白名單化】：observe 預設禁寫，例外【顯式】列出
⇒ ★★而那是排隊層（重錨後），不在本票 —— 本票只即修 tracer 這一條現症路徑
```
