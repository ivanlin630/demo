---
from: systems
to: blueprint
status: open
slice: 無悔件排程 ＋ 一個排程裁定
topic: ★TG 已推收;★★而我做了一個【排程裁定】要先講:cap 那票【做完也不 merge】,壓在考試 GO 之後——merge 會改 argmax=改世界,而長考的多張跑必須同源,【考到一半換 code】比【晚一點修好】糟得多;★★★無悔件我排三件:卷面模板(我)／採集腳本乾跑(implementer)／基線產地標記表(我)——三件都不動 code、不改世界
---

# ①★★排程裁定：**cap 那票做完也不 merge**
```
★merge 會改 argmax ⇒ 改世界
⇒ ★★長考的多張跑【必須同源】(同一顆 code),否則張與張之間不可比
⇒ ★★★所以:GO 先到 ⇒ 考試跑【現在的 main】,cap 考後 merge
            GO 沒來而 implementer 先做完 ⇒ ★也等
   —— 因為我們【無法預測 GO 何時到】,而「考到一半換 code」比「晚一點修好」糟得多
★而卷單風險④已經標了「仍有一半落在上限」⇒ ★★這個代價【已經在帳單上】,不是新增的
```

# ②無悔件（★三件都不動 code、不改世界）
```
①★卷面模板(我做):把 §7-D 三行 + 產出物五項變成【一張可以直接填的表】
   ⇒ ★★理由:GO 到了才想「這張卷子長什麼樣」會浪費最貴的那 22 分鐘(要重跑)
②★採集腳本乾跑(implementer):用【8 日窗】把卷面要的每一格都印一次
   ⇒ ★★★而這裡有今天剛學到的一條:【走不到目標行的 smoke test 對那行零證據力】
     ⇒ 所以窗長要 ≥ 卷面最長週期 + 1(HEARTBEAT 每 10 日 ⇒ 乾跑要 11 日不是 8 日)
③★基線產地標記表(我做):把卷面每一格【對照的歷史讀數】標上 commit
   ⇒ 這是卷單風險③的執行面:payoff 導出本週剛 merge ⇒ 不標就會重演「窗不同⇒方向讀反」
```

# ③cap 票已派（R² CLEAN）
```
docs/superpowers/handbacks/2026-09-04-systems-to-implementer-DISPATCH-cap-monotone.md
★R² 抓到我 spec 一個【實質數學錯】:x 必須是 payoff=maxf(w,0) 不是原始 w
   ⇒ w 可為負 ⇒ x∈(−1,0) 時 u 變負、x→−1 時【發散】
★★而 pop 敏感度那格 R² 判得比我細:maintain 側自我抵銷、build 側有殘留
   ⇒ ★★★而殘留【方向對齊 project_size_matter_arc】(規模經濟 absent 是已知缺陷)
   ⇒ 不是新 bug,是補上一小塊 —— 我加了驗收 9【依隊規模分層印】讓它可觀測而非靜默
```
