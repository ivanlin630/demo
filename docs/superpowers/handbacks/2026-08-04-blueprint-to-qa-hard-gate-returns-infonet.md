---
from: blueprint
to: qa
status: consumed
topic: "[QA硬閘回歸(用戶點名:8/1後QA零單+premature victory滑過=你該抓的型)·依7/9但書『轉自動交付則QA硬閘回歸』——現遠端Telegram+長鏈自動跑=條件成立·新常態:大arc量完→先你對抗式判決→綠→我才對用戶驗收·首單=資訊網whole一次量(systems build中,spec=2026-08-03-information-network-core-design.md):量落地後你獨立審故事非數字——①商業真活?(trade.deal/convoy/fulfilled>0是真流通還是數字搬家/單床偽陽)②饑荒真解?(領主經belief賑濟+居民relocate找糧,故事完整:求援→信使走→belief→convoy送達)③人格真分化?(傲撐/務實早求可觀測,非齊一常數偽裝)④fog保住?(遠/敵stale非god-view)⑤escaped_defects回顧:『後勤flow修好』premature victory這型你往後專盯(窄床accepted≠general)·你留main dir讀diff+measurements判、不checkout·背景:§5揭執行層塌陷+一root三症收斂資訊網,詳spec+handbacks 2026-08-03/04"
---

# QA 硬閘回歸 — 首單:資訊網 whole 一次量

用戶點名:8/1 後你零單,且「後勤 flow 修好」premature victory 滑過(正是你該抓的型)。依 7/9 但書「**轉自動交付則 QA 硬閘回歸**」——現遠端 Telegram + 長鏈自動跑 = 條件成立。

## 新常態
**大 arc 量完 → 先你對抗式判決 → 綠 → 我才對用戶驗收。**(小 doc/infra 活不必。)

## ★首單(立即、回溯):三個因果結論的故事稽核
用戶點破:`longrun-qa-gate.sh`(7/22)早寫死「長跑 sim → 必送 QA 故事稽核才可下因果結論/鎖 spec」——**這波違規了**(hook 只提醒不硬擋,角色照走、blueprint 也沒攔)。資訊網 spec 鎖在三個未經你稽核的因果結論上 → **build 落地前回溯驗最便宜**:
1. **§5 三層 root**(`jia-distribute-zero-diagnostic.json`):distribute=0 真是 received_buy_orders 不達?非決策層的排除穩嗎?
2. **饑荒-flee 收斂**(`famine-flee-diagnostic.json`):居民 relocate「會生成只是沒 target」= 純資訊餓,故事(motive→action→outcome)撐得住?
3. **anomaly 因果**(「選建設=留守→採集穩」):這個 causal claim 有 trace 還是推論?
→ 你判:CONFIRM(spec 前提穩)/ REFUTE(我 halt build 修 spec)。**specimen trace 若缺,照 hook 標準點名**(光聚合不履職)。

## 次單:資訊網 whole 一次量(systems build 中)
spec = `docs/superpowers/specs/2026-08-03-information-network-core-design.md`。量落地後你**獨立審故事、非數字**:
1. **商業真活?** `trade.deal/convoy.dispatch/order_fulfilled >0` 是**真流通**還是數字搬家/單床偽陽(多床、量級)。
2. **饑荒真解?** 故事完整鏈:求援→信使物理走→領主 belief→賑濟→convoy 送達→居民真得糧;居民 relocate 找糧真 fire。
3. **人格真分化?** 傲撐/務實早求**可觀測差異**,非齊一常數偽裝人格。
4. **fog 保住?** 遠/敵 stale、無 god-view 瞬傳。
5. **escaped_defects 回顧**:「後勤 flow 修好」premature victory 這型(**窄床 accepted ≠ general**)你往後專盯。

你留 main dir 讀 diff + `docs/measurements/` 判、不 checkout。背景:§5 揭執行層塌陷 + 一 root 三症收斂資訊網(詳 2026-08-03/04 handbacks)。量落地 systems 會通知你。
