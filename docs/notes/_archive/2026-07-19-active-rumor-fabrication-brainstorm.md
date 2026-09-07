# 主動造謠（憑空捏造）brainstorm — 未來 arc 停車筆記

> 藍圖×用戶 brainstorm 2026-07-19。**未來討論，非現在派工**——主藍圖專注 god-view 殲滅 + stall-gap。此筆記存 `notes/`（不碰 game-design.md canonical、不發 handback），待造謠 arc 真開時提為正式 spec 輸入。
> altitude＝WHAT/願景方向，非機制 spec。observe-gated（framework 綠 → full-HD live 觀察後才設計得準）。

## 定位：謊言目前只能扭曲真相，不能製造真相

遊戲命題＝「資訊不透明」。現況欺敵已有兩半（**被動/反應式**）：
- **中繼失真**（`message_system` `malicious` mode，計謀驅動）：轉述時竄改已發生事件的 origin/位置/描述。
- **親見欺敵**（`DistortionEngine.apply_observation_deception`）：被觀察時偽裝平民/虛張聲勢/謊稱勢力。
- **G3 資訊戰 arc**（已建）：credibility/trust、multi-claim 儲存、skill-detection、決策不確定 gate。

**缺口（命題最後一半）＝主動造謠**：`emit_message` 只有 event 呼叫（unrest_replace/split），**沒有決策路徑讓 NPC 憑空捏造一件沒發生的事、注入傳播網當武器**。
- 差別：中繼失真＝竄改**已發生**事；親見欺敵＝**被看時**裝；主動造謠＝**憑空捏造**（「X 屠了村」實際沒有）達成目的。
- ＝`emit_message` 的一個**戰略決策 caller**，現不存在。

## 用戶裁定＝A+B（命題走 A，落地走 B）

**A. 造謠是 first-class 戰略動詞**——跟開戰/貿易同級的決策 option。具體戲：
- **借刀殺人**：放「A 屠 B 村」→ B 信 → B 打 A，造謠者坐收。
- **假警報**：放「大軍壓境」→ 目標恐慌逃散/備戰空耗。
- **抹黑正統**：散「頭人失天命/通敵」→ 侵蝕合法性（接維度4 正統）。
- **掩弱**：弱隊放「背後有大勢力」→ 遠距、廣域嚇阻（比親見虛張更遠）。

**B. 節奏＝罕見、自壓、性格戲**：
- 決策 option（`散布假消息`）走引擎 argmax，非腳本。人格 gate：**計謀高提案、義氣高避開**。
- **反噬走「可信度崩」自然壓 spam（非設頻率上限補丁）**：被識破 → 來源可信度崩（G3 credibility）→ 往後說啥沒人信 → 引擎極少選。奸雄用多變「狼來了」＝性格的自然代價。**合憲法：引擎秤、不設補丁閘。**
- ∴ 訊息量增幅小、有界。

## 載重分析（用戶問，已澄清＝小且有界）

1. **假消息 struct ＝真消息一模一樣**（同 `MessageData`、同傳播 event-driven 同格、同衰減 HOP 0.15＋TIME 0.005、同 id 去重）→ 造謠＝`emit_message` 多一 caller，零新傳播成本。
2. **量增被 argmax 掐死**（人格×情境×反噬 gate，不每 tick 噴）+ 既有衰減/belief 安全閥兜著。
3. **★belief-store 已扛 90%**：一條造謠＝掛在 entity 的 belief claim，正是 belief-store point 6（世界特徵 belief）+ point 7（message→belief 橋）+ G3 multi-claim/credibility。衝突 claim 怎麼存、來源可信度怎麼秤——地基本就在建。

## 這波（belief-store 在建）唯一時效約束＝不 preclude（非 build）

造謠決策 option ＝ observe-gated 後續 arc，**這波不建**。只要 belief-store 的 claim 結構保住兩性質，後續造謠＝「加一 option」非「重構 belief」：

1. **來源可歸屬**：每 claim 記得「誰跟我說的（carrier）」可溯 + 該來源可信度可秤 → 捏造 claim 經 message→belief 橋進來時，跟誠實/失真 claim **同一種可秤 claim**，非特例。（G3 已建大半，別在統一 claim 結構裡弄丟。）
2. **provenance 可分級（誠實／失真／捏造 三態）**：現 `is_distorted` 二元（真被竄改）；捏造＝憑空非竄改，語意不同。**不要求這波做三態欄位，只要求統一 claim 結構別焊死成二元、留得下第三態**（enum or 擴充位，HOW=systems）。

**★resurface 時機**：belief-store design review 時，藍圖主動提這兩性質給 systems 確認沒被焊死。**不 fire-and-forget handback 干擾 systems 當前 god-view 專注。**

## Guardrails（守憲法/鐵律）
- **感知鐵律**：造謠讀寫全走 belief，不碰 god-view（虛張/示弱要有效＝因對方只有 belief，承 threat-severity 裁定）。
- **憲法**：造謠＝引擎 argmax 輸出（人格秤），非腳本 event → 未來落地＝DecisionEngine option，**非重觸舊 scripted-event**（同 ③內政 de-patch 精神）。
- **反噬＝可信度崩**，非頻率上限補丁。

## monotonic-id 雙重服務（強化既有硬前置）
造謠「X 屠村」要 X 的 id 穩定，否則死 id 回收 → 冒名 → 謗到錯的隊。monotonic-id（belief-store point 4 已硬前置）**同時是造謠正確性前提**——多一理由先做，非新工。

## 序（backlog）
1. framework 綠（god-view 殲滅 + 零殘留閘）。
2. full-HD live 觀察（謠言在真傳播網怎麼擴散）。
3. 造謠 arc 才 spec（此筆記＝輸入）。
- belief-store review 時 resurface「不 preclude 兩性質」（唯一時效項）。
