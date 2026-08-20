# 08_machine_workflow_v2.md — 機器軌操作（**現行**；設計背景看 07）

> **用戶親自討論鎖定**的 workflow（真實工作模式：只跟 00 談、00 當 gate、重工 off-他-context、輕基建）。
> **★軌的定位（`CLAUDE.md:72`）：少用**——只在「**手上一批獨立 specced slice 想一次平行**」時才上；**1–2 條走 mailbox 軌**。
> **實作權威 ＝ `tools/orchestrator/`**（`run.py` / `real_nodes.py` / `graph.py` / `test_graph.py`）：節點鏈、`--from-impl` lane、完整性 gate **以 code 為準**（doc 不重述；2026-08-21 瘦身，歷史全文見 git log）。

## ★兩軌 QA 模型（2026-07-09 用戶定案；**最易誤解、故留全文**）
**QA 砍與否綁「模式」，不綁「軌」**：
| 軌 | 模式 | QA |
|---|---|---|
| mailbox／單 slice（用戶盯） | **in-loop** | 砍 QA release-gate，**藍圖持 pass 權**（沒問題就過、有問題升用戶） |
| **LG 下游平行**（fire N 條走開） | **autonomous** | **`rn_qa` 保留硬閘**（獨立判決）——autonomous lane 正是該有 QA 的時候 |
∴ **LG 下游 `rn_qa` 不搬藍圖 pass、保留自動硬閘**；`rn_measure` 用**標準 full_probe 床**（全維度一次抓齊、治 bounce），`rn_qa` 判在完整數據上。
**平行多條 ＝ fire N 個 `run.py --from-impl`**（各自 thread/worktree），**非改 graph**。

## ★成本控制（上不上這條軌的主要判準）
- **cost ≈ $27/slice** → **值得的時機 ＝ 一批獨立 slice 一次平行**；否則走 mailbox。
- **判斷節點用 haiku**（02①/02②/QA/量測判讀）；**opus 只給 01-spec / 03-實作**。
- **scope 限讀**：節點讀 `touch_files` + 工作所需，**別盲掃全庫**（A1a $12 ＝ systems 讀太多）；**02② 可讀廣一點**（抓跨系統）。
- 退化偵測 ＝ **量測員跑全 sim（行為）**，非誰讀全 code。

## 記憶（節點 CTX）
節點 ＝ `claude -p` 子行程、**0-CTX**，靠 git 產物（spec/plan/handback/verdict）接力。
**session-resume 優化**：同角色重複（01-spec→01-plan）用 `--resume <session-id>` 免重讀；★**跨角色故意斷**（保 02 對抗獨立）。

## 三裁定（已內建於 code）
1. **退回不 silent 重試** → halt 通知 00。
2. **刪 GATE** → QA 後**強制中斷**，00 + 用戶判（真 bug vs godot 噪音）。
3. **API 限流/超時** → **原地定格，不自動重試**。
