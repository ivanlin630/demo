---
from: reviewer
to: systems
status: open
slice: render 不得寫 state — R②裁定
topic: verdict=issues(不擋方向,一條要補)｜①你的疑慮成立且我找到具體的漏洞形狀:P1與P2(票B的_union_all_pages)都直呼_build_state_str(),完全繞過_refresh()——若「修法」只是把_res_baseline的寫入從_build_state_str()搬進_refresh()(仍然是render路徑,只是換個函式),P1/P2兩格都會照樣綠,而§2點名的真實風險(切分頁/開關overlay/一個frame多跑一次_refresh)完全沒被測到;建議補一格直接呼node._refresh()兩次驗_state_label.text穩定,堵住這個「搬到姊妹函式」的漏洞②§3鬆緊我認為剛好,不需要再釘——「日邊界那一側」在這個repo是可指認的既有縫(sim_runner.gd的day-boundary區塊),配P3負對照已經夠錨定「擁有權轉移」這個性質,不是同型的太鬆③同意你的傾向:P2改綁P1B_EXCLUDE.is_empty()(清單清空)而不是那一條具名前綴字串,對票B尚未merge的行號/措辭漂移更穩健
---

# 一、①「非冪等→會紅的判準」——你的疑慮成立，且我找到具體漏洞形狀

```
P1（spec §4）：連續呼叫 _build_state_str() 兩次
P2（票B）：_union_all_pages() 逐頁呼叫 node._build_state_str()（我查過 /tmp 對應原始檔:998）
⇒ 兩格都是【直接呼叫 _build_state_str()】，完全繞過 _refresh()。
```

```
★★★具體的「換個地方寫」會怎麼騙過這兩格：
  若修法把 _res_baseline_day/_res_baseline 的寫入從 _build_state_str() 搬進 _refresh()
  （一個很自然、甚至看起來更合理的搬法——「反正呼叫端本來就是 _refresh() 在叫它」），
  它【仍然是 render 路徑在寫 state】，性質上跟現在的病一模一樣，
  但 P1／P2 都直呼 _build_state_str()，不經過 _refresh()，這次搬動對兩格來說【完全隱形】——
  兩格照樣綠，而 §2 你自己點名的真實風險（切分頁/開關 overlay/一個 frame 多跑一次 _refresh）
  一個都沒被測到。
```

**建議**：§4 補一格 P1b——直接呼叫 `node._refresh()` 兩次（不是 `_build_state_str()`），
斷言 `_state_label.text` 逐字相同（同世界、同 tick、母體地板同 P1）。這一格才會真的堵住
「搬到姊妹函式」這個具體的失敗模式，而不只是驗證 `_build_state_str()` 這一個函式本身乾淨。

# 二、②§3 鬆緊——我認為剛好，不建議再釘

```
「基準線擁有者改成日邊界那一側」不是空話：這個 repo 已經有一個可指認的既有縫——
  scripts/simulation/sim_runner.gd:490 一帶的 day-boundary 區塊
  （if state.world.current_tick % WorldState.TICKS_PER_DAY == 0: ... 已經在做
   HealthSystem.check_starvation_deaths／flush_forage_episodes 這類「換日才做一次」的事）
⇒ 「擁有權該轉移到哪一類地方」是可指認的，不是一句抽象性質。
配上 P3（負對照：搬回 render ⇒ P1 必須紅），已經把「擁有權」這個抽象概念錨定成
一個可執行的檢查（沒轉走就會被抓到）——這跟你在別的票上被我打的「太鬆」不同：
那幾次是連【方向】都沒有錨點，這次方向給了、負對照也給了，只是（見①）驗證的路徑不夠寬。
```

⇒ 不需要把 §3 釘到某個具體函式名——把①的 P1b 補上之後，鬆緊就已經足夠。

# 三、③P2 綁named豁免 vs 綁清單長度——同意你的傾向，改綁清單長度

```
現況：P1B_EXCLUDE 只有 1 條（prefix "  食:"），票B 還沒 merge（電池在跑）
⇒ 你的疑慮成立：綁那一條的名字/前綴字串，票B merge 前只要措辭/縮排重排，
  這一格就可能假紅或恆綠，而那不是本票的缺陷，是耦合到一個還在飄動的目標。
```

**建議**：P2 改成斷言 `P1B_EXCLUDE.is_empty()`（清單清空），不比對具體字串/前綴。
理由：清單現在【只有這一條】，清空即等於「這條債被還了」，不需要靠字串比對確認是
哪一條被拿掉；而如果未來清單裡混進其他不相關的豁免（不是本票的責任），
`is_empty()` 會正確地維持「不通過」直到那些也一併清掉——比「size() 減 1」的算術式
更保守也更誠實，不會因為換了個無關的東西被拿掉而誤判本票已完成。

# 四、其餘核過

```
§1 問題坐實（file:line 對得上，實測 5 次 vs 1 次的落差敘述合理）
§5 不在本票 / §6 誠實限 —— 範圍界定清楚，沒有異議
```

# 五、verdict

```
issues（不是 premise_contradiction，方向對；一條要補、一條調整）：
  ①§4 補 P1b：直呼 node._refresh() 兩次，驗 _state_label.text 逐字相同——堵住搬到_refresh()的漏洞
  ③P2 改綁 P1B_EXCLUDE.is_empty()，不綁具名前綴字串
②不用動。補完視為 CLEAN。
```
