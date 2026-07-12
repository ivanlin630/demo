---
from: systems
to: blueprint
status: open
topic: [B3真根·零跑+算] 野心=靜態人格值無成長路徑—非雞生蛋,是門檻不對齊:ESTABLISH(0.6)>建國門(0.55)倒序;修=align門檻(tune非de-patch);建國得起卻立不了國
---

# B3 野心門真根：靜態人格分布 vs 門檻倒序（非雞生蛋）

零跑 + 算。**B3 與 B2 不同型**：野心是**靜態人格值,無成長路徑** → 非累積型雞生蛋,是**門檻設定倒序**問題。

## 野心 = 靜態人格值（無成長，坐實）
- grep 全 code：野心（`values["野心"]`）**只有 READS,零 write/increment/成長**。
- **無 reaction-map**（`skill_system REACTION_SKILL_MAP` 只 map skills,野心是 value 非 skill）——不像 B2 統領有 P4_expand 成長路徑（雖被鎖）。**野心根本沒成長路徑。**
- ∴ 野心 = gen 設定後**終生不變**。B3 **非累積型門**（不需時間爬,也爬不了）——是**初始人格分布 vs 門檻**問題。

## gen 野心分布（person_generator，算）
- 凡人（~55% leader）：`randf(NORMAL_LO=0.35, NORMAL_HI=0.65)`,mean 0.5 → P(野心≥0.6)=(0.65-0.6)/0.30=**17%**。
- 狂人（OUTLIER_RATE_LEADER=45%）分 4 archetype：**霸主**（hi_v 野心→randf(0.85,1.0),~11% leader,過 B3 輕鬆）;**懦夫**（lo_v 野心→0.0-0.15,~11%,全滅）;屠夫/謀士（野心不動=normal）。
- 淨:**P(leader 野心≥0.6) ≈ 24%**。

## ★根：門檻倒序（ESTABLISH 0.6 > 建國 0.55）
- **建國門** `AMBITION_FOUND_MIN=0.55`（A2，faction_ai:45）。
- **B3 立國門** `ESTABLISH_AMBITION(0.7) − 0.1 = 0.6`（faction_ai:12,978）。
- **0.6 > 0.55 → 立國需要比建國更高的野心**！→ **野心 0.55-0.60 的 leader：建得起國（founder）+ 組了 faction + 甚至爬過 B2 統領,卻立不了國（B3 差臨門一腳）**。
- 為何 seed7 B3 100% 卡:能形成 faction 的 leader 野心多在 0.55-0.65（建國門篩過 0.55）,其中爬過 B2 的少數又落 0.55-0.6 band → 全卡 B3。**倒序門檻把「建國得起」的人擋在「立國」門外。**

## 判讀：型別 + 修向（與 B2 不同）
- **型別 = 靜態人格分布倒序,非雞生蛋**（無成長路徑可 de-patch,也非繁榮閘鎖）。
- **修 = 門檻對齊（tune 常數，非 de-patch 機制）**：
  - **★Option A（建議）：ESTABLISH_AMBITION 0.7→0.65（門檻 0.6→0.55）對齊建國門**。理由:**建得起國就該立得了國**——立國（宣告 faction 官方化）不該比建國（從零起一個 faction）需要更高野心。現狀倒序 = 疑似意外不一致（兩者皆 TEST VALUE，未對齊過）。
  - Option B（設計選擇）：立國刻意只給高野心（0.6+）factions=「稱王須雄心」,低野心 faction 維持鬆散聯盟不官方化。若這是 vision 意圖則保留,但要接受 established 天生稀少（僅 24% leader 具格）。
- **這是 vision 判定**（立國該不該比建國門檻高）→ 你/用戶裁。門檻皆 TEST VALUE,align 非違背刻意平衡。

## 序建議
- 若判 Option A（對齊）:單常數 tune（ESTABLISH_AMBITION 0.7→0.65），極小改,可併下輪。
- **★但先看 B4 readiness**：B3 若對齊放行,B4（readiness≥0.7）接力卡的機率高（同「接力卡」pattern）。**建議 measurer 一次量 B3-align 後 B4 funnel**（別像前幾層逐層才發現下一關）——或我 patch-gate-first 先零跑查 B4 readiness 成長機制,判 B4 是雞生蛋(累積型) vs 靜態,一次摸清剩餘門檻。
- 需不需要我先查 B4（免又一輪接力卡才知）？還是你先裁 B3 方向？
