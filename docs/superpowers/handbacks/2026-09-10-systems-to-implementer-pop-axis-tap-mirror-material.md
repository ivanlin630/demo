---
from: systems
to: implementer
status: open
slice: 人口軸 tap（鏡射材料軸）｜★小刀，量測員被它卡住
topic: ★做什麼：`faction_ai_system.gd:4741-4746` 的 pop 閘**只有聚合 counter**，而同一支函式上面的材料軸（`:4722-4727`）**有 `bump_sample` 逐筆 detail** ⇒ 照同款式補一支｜★★這是【全量暫態可觀測性】那條不變量的直球案例：**一個決策閘沒有逐筆 tap ＝ 量測盲點**｜★★★而 `pop*2` 那個門檻本身是 `TEST VALUE`（`:4741` 註解自己寫的）—— **本票不動它**，只是記下來
---

# ① 現況（★file:line，我讀過）

```gdscript
# 材料軸 :4722-4727 —— ★有逐筆
Probe.bump_sample("dispatch_fail.material_detail", {"team":…, "resource":…, "need":…,
    "margin":…, "avail":…, "vault":…, "private":…, "home_mfg_level":…, "tick":…}, 30)

# 人口軸 :4741-4746 —— ★★只有聚合
var pop: int = maxi(6, level * 4)   # TEST VALUE — 建造隊最小 6 人；pop*2 門檻=12(lv1)
if leader_team.population < pop * 2:
    _log_dispatch_fail(…, "pop 不足: %d < %d" % [leader_team.population, pop * 2], cost)
    if Probe.enabled: Probe.bump("funnel.build_gate.pop")
```

# ② 做什麼

```
補一支 `Probe.bump_sample("dispatch_fail.pop_detail", {...}, 30)`，★**款式照材料軸那支**
（同樣的 `Probe.enabled` 包裹、同樣的 cap 30、同樣放在 `_log_dispatch_fail` 之前）：
   team ／ have(=leader_team.population) ／ need(=pop*2) ／ ★**gap(=need−have)** ／
   level ／ tick
⇒ ★★**gap 是這一票的重點**：用戶看到的是「10 < 12」＝差 2 人，
  而「差 2 人也派」是【合法試探】還是【盲派】，要靠 gap 的分布 ＋ 逐隊重撞次數才分得出來。
```

# ③ 驗收

```
①★母體地板：跑一窗 ⇒ `dispatch_fail.pop_detail` 的樣本數 **> 0**
  ⇒ ★★若是 0，**不可判**（不是「沒問題」）—— 換窗或換 config，不要交一支乾淨的 0
②★★★與既有聚合對得上：`dispatch_fail.pop不足`（`:4649`，★它 fire 在 de-dup 之前 ⇒ 是真實觸發次數）
  的計數 **≥** 逐筆樣本數（樣本有 cap 30）⇒ ★兩者的關係要在交件裡寫出來，
  否則下一個人會把「樣本 30」讀成「只發生 30 次」
③fp 不變（★純觀測，依界限第十八條附一格行為證據）
④★零 RNG（觀測路徑禁耗 global RNG —— 既有不變量）
```

# ④ 不做

```
①★不改 `pop*2` 這個門檻（它是 TEST VALUE，改它＝改世界，要 blueprint 裁）
②不改 `_log_dispatch_fail` 的 de-dup 行為（見給量測員那封的理由）
③不動材料軸那支
```
