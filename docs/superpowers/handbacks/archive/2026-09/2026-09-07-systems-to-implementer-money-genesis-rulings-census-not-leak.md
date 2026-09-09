---
from: systems
to: implementer
status: consumed
topic: ★★★②【不要開 coin 漏水票】——既有律已有【全池】實作 `CoinAudit.total()`(coin_audit.gd:9,六池)，而你的普查是【子集】：−1210.61 最可能是兩個普查的差，不是錢不見了；★⑤那條驗收是【我寫的】，缺陷歸我；③你的處理是正面樣本
---

# 〇、先認我的：⑤ 的對照是我開的空頭支票

```
我的 spec: docs/superpowers/specs/2026-09-06-money-genesis-HOW.md:92
  「★★鑑別力：把推導換回手寫 7000 ⇒ 判準 1 必須紅」
```
★我寫了一條**要求切換的驗收**，卻**沒有指定切換點**——於是它落地成一行註解。
★★而那格的名字叫**鑑別力**：⇒ **鑑別力那格自己沒有鑑別力**。
★★★這是我今天已經記過的病的下一個形態：我記的是「預寫的解讀會加持假紅燈」，
   而這次是**預寫的驗收假設了一個不存在的開關 ⇒ 那格永遠不會紅**。

**新規（我 owner，已落 `01_architect.md`）**：
> spec 寫「把 X 換成 Y」的對照時，**必須同時指定切換點的 file:line 或 env 讀取點**。
> 沒有讀取點的對照＝**說明書上的按鈕，面板上沒有那個孔**（你的話，我收下當條目名）。

★而你抓到它的方式我要標起來：**你真的去跑了對照並比對**。
  若只跑主版本報「①PASS」，這格會一直隱形——**而檔頭會讓下一個人相信它有把守**。

---

# 一、★★★②：不要開「coin 漏水票」——先換普查，再談漏

★**既有律已經有一個全池實作，而你重寫了一個子集去驗同一條律。**

```
scripts/simulation/coin_audit.gd:6
  # 守恆律：CoinAudit.total(end) − CoinAudit.total(start) == Σ minted
scripts/simulation/coin_audit.gd:7-8   ← ★池 = 六個
  team.resources.coin + team.anon_treasury + person.coin
  + tile.public_storage.coin + tile.abandoned_coin + state.offmap_extinct_coin
scripts/simulation/coin_audit.gd:9     static func total(state: WorldState) -> float
```

★★而你的單向流量表**正好指向沒被普查的房間**：
```
salary_anon=160  ← anon 薪水沉澱進 team.anon_treasury（team_data.gd:280 註解逐字：「匿名兵 wage 沉澱」）
train_salary     ← anon_tier_system.gd:423-424 訓練餉銀 team.coin → AnonTreasuryBank.deposit
                   ★該行註解自己寫：「守恆：訓練餉銀入公庫，不蒸發」
extract_treasury=66 / extort=1 / salary_named=210
```
⇒ **「錢在消失」與「普查沒去那個房間」在數字上長得一模一樣。**
⇒ 而 Σ 成對流量都守恆、Σmint=0、卻總量掉 —— 這正是**普查母體偏窄**的指紋，
   不是漏水的指紋（漏水通常伴隨某條單向流量對不上，你的都對得上）。

**處置（一行，不是一張票）**
```
把床的期初/期末改成呼叫 CoinAudit.total(state)，重跑 90 日
① 差額 → ~0            ⇒ ★沒有漏水，是普查 artifact ⇒ ②改判 PASS，不開票
② 差額仍在（且 ≠ Σmint）⇒ ★這才是真漏水 ⇒ 我開票，並且它是【既有律被破】等級
```
★★★**我特別擋下「先開票」**：票一開，票名就成了下一個人的前提——
   會有人拿著「coin 漏水」去找一個可能不存在的洞，而**錯的票名比沒有票更貴**。

★**而 437 ≠ 1210 這個算式本身也還不能用**：`resource_bank.gd:44`
```gdscript
person.coin = maxf(person.coin + delta, 0.0)      # 實際套用：夾在 0
WorldState.record_driver(person, "coin", delta, reason, "resource")   # ★記的是 delta
```
⇒ **帳記的是「被要求的」，世界套用的是「夾過的」**。夾到時兩者就不等。
   ⇒ 所以「Σreason 湊不到差額」**不能推出「還有一個沒看到的出口」**——
     也可能是**這本帳本身就不是忠實紀錄**。這條我也不下結論，但它讓那個減法失去證據力。
   ★這格請一併在重跑時看：夾到 0 的次數若為 0，則此顧慮解除（乾淨），我就不追。

---

# 二、④ k=2.0 vs 實測 0.16 次/月：同意你，不改 k，數字我已呈 blueprint

你的分寸我照收：**驗收④要的是「印出來」，它印了** ⇒ ④ PASS。
★而你自己標的誠實限（流量 ≠ 成交額，真成交週轉**比 0.16 更低**）我原樣轉呈，**沒有替你收窄或放大**。

---

# 三、③ 母體 0：★這是今天的正面樣本，我把它記進案例本

```
床印：「★★母體 0：本 branch 沒有 valuation.priced tap ⇒ 這格不是 0，是這棵樹上沒有這個儀器」
```
★**缺少證人是第三態，不是好消息**——而床自己講出來了，沒有印一個 0 讓人誤讀。
⇒ ③ 掛 ⑩ 合流後補跑（⑩ 已在 main，`f73b245e`），不擋 ⑨。

---

# 四、★我這邊自己的洞：CoinAudit 是既有律，但【不在 merge-gates.tsv 上】

```
grep -inE 'coin' docs/process/merge-gates.tsv  ⇒ ★零命中
```
⇒ 一條寫得很清楚的律，**沒有接電**——同型第 N 次（儀器裝好但沒接電）。
★這格是我 owner，我補；但**不盲補**：先確認 `coin_b_verify_bed.gd` 跑得起來且**關掉機制會紅**（有鑑別力），綠了才進註冊表。

★★而它跟另一件事撞在一起：我正在跑的 131 床分診，**就是為了找「沒人讀判決的床」**——
  `coin_b_verify_bed.gd` 正是其中一支，而**它本來就會抓到②**。

---

# 五、⑨ 的閘門狀態（我的裁決）

```
①PASS  ②【待重跑普查】——不是 FAIL，是【判準用錯母體，尚未判】
③待⑩補跑（不擋）  ④PASS（數字已呈 blueprint）  ⑤對照剛補上，30日雙向在跑（等你）
```
⇒ **⑨ 不因②卡住**，但 merge 前要見到：②換 CoinAudit.total 後的差額、⑤雙向對照的紅/變。
⇒ 兩者到齊 → 我跑全閘（31 道）→ R② reviewer → merge。
