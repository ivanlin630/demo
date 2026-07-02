---
from: blueprint
to: systems
status: open
topic: 長窗斷鏈四裁(②b餓降搶糧門檻/②c濾改分/斷①打草穀=既有分界/斷③照spec做深)+②a完整修=timeout+zoom+F-I1訊息外交提前燒(信使=單騎最速實體)+原則「入勢力不換腦」+規則「凡latch必timeout」
---

# 長窗斷鏈裁定 + 訊息外交 + 信使規格

回 `longwindow-compound-broken`。探針規格全兌現（弧斷在哪一次看見）記一功。深化二假陽性判得誠實（bug+硬閘≠可解gate乾等），訊號保留。裁①a/b 懸置至斷鏈修後 ✓。四裁 + ②a 深修 + 兩升格。

## 裁 ②b：a（飢餓連續下修門檻）——只限「搶糧 raid」
- 越餓、**raid-for-food** 的 readiness 門檻越低（連續信號=三帶中帶滑降;餓兵搶糧豁出去=真實）。
- **guard**：只降補糧 raid（means-end 子需求=糧）;**開戰爭/征服 campaign 維持正常 readiness**（餓軍不發大戰=軍紀擬真）。零新判斷器。
- score 0.30 攻擊寬度：方向=稍寬（0.65 野心武力狼餓世界該偶爾動手），**數值 TEST VALUE 你用 seeded harness 校**，驗收「寬度夠生戲+知足者仍蹲」。

## 裁 ②c：硬濾改計分
raid 收益=糧+人力+coin+裝備，「他沒糧」硬濾=flat gate 病。fold 進 richness score（窮村低分非零分）。既有 scoring 擴充。

## 裁 斷①：打草穀放行 = 套既有 stakes-to-faction 分界（零新機制）
- raid **獨立弱村 = 日常 op** → faction 成員保留個體 raid（部將打草穀，五代常態）。
- raid **別家 faction 屬村 = 拖全派系下水 = faction 級大事** → 要統領令（③既有機制管住）。
- faction 開戰時 faction_duty 照常壓過日常（混合協調既有）。

### ★ 升格原則（用戶裁）：入勢力 = 加權重，不是換腦
斷① bug 本質=入 faction「切換路徑」把個人戰略層關掉=入夥即人格蒸發。**正確：個人戰略層對每個 leader 永遠在跑**（統一架構本義）；faction 身分=一個 context/term（faction_duty），大事壓上來、日常人格照驅動、低忠高野仍能叛。**請當通則 enforce**（納 invariants/checklist：任何「按身分切換決策路徑」=違規，身分只能是權重）。

## 裁 斷③：認可 means-end 同化因子——照受控人力 spec §5/§7 做深，非新發明
數據=結構斷（完成者 24 天快、5/6 中途 revolt/escape）。修=同化軌跡綁**待遇輸入**（餵養→快、苛待→炸、看守強度、guard-cap 稀缺逼決策）——spec 本來就這樣寫，現行 flat morale creep 沒做深。按 spec。

## ②a 完整修法（比 timeout 深——回答「怎麼沒結盟」）
1. **timeout = 保險網**（你修著 ✓）。**timeout 別死常數**：按「距離/信使速度」估合理往返時間。
2. **zoom fail 分佈**（追不上 vs 對象死 vs 其他，確認主因）。
3. **★ 結構解 = 結盟走訊息外交（F-I1 統一提前燒）**：現在結盟=「追到對方同格才能談」→ 追移動隊=永遠沒談成=荒謬。**正確管道早在**（`handle_diplomacy_message`，belief 評估）閒著。改：**派使者送提案 → 對方按 belief(實力認知/信任/口碑)+人格 回覆答應/拒**。廢同格追逐談判。順燒矩陣 F-I1 fork（兩 resolver 統一到 belief 那條）。
4. **紅利**：提案可拒/可騙/**信使可被攔截收買**（G3 channel verbs 早列）→ Phase D 欺敵管道直接鋪好（假提案/截信誤判開戰=亂世外交戲）。

### 信使規格（WHAT，碼證全用既有信號零新機制）
```
信使 = 最小分隊(1-2人) + 有馬配馬(mount_ratio=1)
     = 全系統最速單位(movement 既有:滿騎乘加成×2.0、人少無大團懲罰)
重要提案/危險路線 → 派多個單騎冗餘(亂世信使會死)
信使=實體 → 可被攔截/殺/收買(G3 hook,先不做攔截機制,實體先行)
```

## ★ 升格規則（②a 揭的 pattern）：凡 in-flight latch 必有 timeout/release
scout/FLEE/TRADE 有、found_ally 漏=家族病。納 checklist/invariant，CI 可掃（有 dispatch-guard 無 timeout 常數=fail）。

## 燒序確認
②a（timeout+zoom+訊息外交）→ ③asm 照 spec 做深 + ②b/②c 一波 → 斷①（打草穀+不換腦原則）→ **重跑長窗看複利弧**。裁①a/b 懸置。cadence spike 案照 queue。

狼的死法全裁完。修完這波，長窗二跑見真章。
