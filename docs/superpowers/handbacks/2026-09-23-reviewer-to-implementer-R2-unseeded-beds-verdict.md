---
from: reviewer
to: implementer
status: open
slice: 未加種子的閘床 — R②裁定
topic: verdict=issues(不擋方向,一條要驗證)｜①比對母體:你扣的[TickPerf]/[PhaseSpike]/[FaiPhase]三個標籤我查過production格式——它們同一行裡【也帶著teams=/factions=真實計數】,整行扣掉理論上會連內容差異一起扣掉;但這三支床的推進量都只有1-3tick(遠低於[TickPerf]觸發門檻TICKS_PER_DAY=1440、[PhaseSpike]/[FaiPhase]又需要phase_timing opt-in+spike門檻),實務上這三個標籤大機率根本不會出現在你的5跑輸出裡——請你grep一下原始5跑輸出檔確認這三個標籤真的有沒有出現過,若從未出現則扣法無害只是多餘,若真的出現過則改成只切掉數字部分保留teams=/factions=才安全｜②agent_verbs反向驗判讀:同意你的讀法,不是「穩定⇒過」是「種子對它沒作用」——我查過它呼叫的AnonTierSystem.add_anon是純函式零RNG,advance_ticks(7)雖跑真實tick但7遠小於cadence錯開的60-tick週期,新建team多半排不到due,你的措辭沒有過度宣稱｜③zhagen 5跑夠——這正是我先前核過CLEAN的兩層判準(靜態縮小/經驗兜底)裡明文定的樣本數,5跑STABLE照spec協議收手是對的,不用加碼
---

# 一、①比對母體——大機率無害，但請補一步驗證再定案

```
production 格式核過（scripts/simulation/sim_runner.gd:142/153/157）：
  [FaiPhase] tick=%d total=%d us | 母體=... | spike#=... | phases=%d | %s
  [PhaseSpike] tick=%d dt=%d us teams=%d | %s
  [TickPerf] day=%d avg=%d us max=%d us ticks=%d teams=%d factions=%d | ★>2s 幀數=...
⇒ ★這三行不是純時間噪音——它們同一行裡混著 teams=/factions= 這種【真實計數】。
  若比對用的是「整行 grep -v 那三個標籤」，理論上會把這些計數也一起扣掉，
  萬一世界內容真的因為某個原因分岔、而分岔剛好只反映在這三行裡，這個扣法會把它連著噪音一起沖走。
```

```
★但這三支床的推進量都很小：agent_verbs_c1_bed 推 3 tick、merchant_turnover_test／
phase_root_conservation_bed 各推 1 tick（本 session 稍早查過的既有數字）。
  [TickPerf] 只在 current_tick % TICKS_PER_DAY(=1440) == 0 才印 —— 1-3 tick 連零頭都到不了。
  [PhaseSpike]／[FaiPhase] 需要 phase_timing 開啟（opt-in，這三支床沒有理由開它）
    ＋ dt_us 撞 spike 門檻——1-3 tick 的迷你場景幾乎不可能撞到。
⇒ 這三個標籤大機率【根本沒出現】在你的 5 跑原始輸出裡，扣法即使理論上太寬，
  實務上大概率是扣了一個空集合，無害。
```

**請補一步（不是重跑，是回頭看你已經存下的東西）**：
`grep -c "\[TickPerf\]\|\[PhaseSpike\]\|\[FaiPhase\]"` 你那 5 跑的原始輸出檔案，
確認出現次數。
```
若三個標籤在三支床的輸出裡都是 0 次 ⇒ 你的扣法安全（雖然多餘，但無害），可以定案。
若有任何一次非 0 ⇒ 別再整行扣，改成只切掉數字（正則抓 us=\d+/avg=\d+/max=\d+ 之類，
  保留 teams=/factions=），否則這格會是本票唯一的兜底卻可能有盲點。
```

# 二、②agent_verbs 反向驗判讀——同意你的讀法

```
你寫「種子對它沒作用、今天保護它的是它自己不隨機」而不是「穩定⇒過」——
這是對的措辭，沒有過度宣稱。我查過它實際呼叫：
  AnonTierSystem.add_anon（本 session 稍早核過：5 行純函式，零 RNG）
  cmd.advance_ticks(st, runner, 7) —— ★這一步是真實跑 7 個 tick，不是純 API 呼叫
⇒ 7 tick 確實會經過 sim_runner 的正常迴圈，理論上不是「天生碰不到模擬 code」，
  但大多數會吃 RNG 的系統（faction_ai 評估等）走 CadenceStagger 錯開，週期是 60 tick，
  一個剛建立的 team 在 7 tick 內排到 due 的機率很低 ⇒ 「7 tick 太短、還沒輪到會吃 RNG
  的系統」是一個合理、可信的解釋，跟你的反向驗結果一致。
```

★這格我沒有找到反例（沒有發現一條它明明會吃 RNG、你的母體卻看不到的路徑），
但這是靜態推論不是窮盡證明——跟你自己的誠實限一致，我不比你更確定。

# 三、③zhagen_controlled_bed 停在 5 跑——夠，照協議走

```
spec（unseeded-gate-beds-HOW.md §2b，本 session 稍早我核過 CLEAN 的兩層判準）逐字：
  「經驗層（用來兜底）：凡是執行任何模擬 code 的床，都跑 5 次逐位元比對」
⇒ 5 是這個協議本身定義的樣本數，不是你自己抓的數字。zhagen 5 跑 STABLE，照協議
  歸「經驗層 STABLE」，不用再加碼跑更多次——加碼會是【超出協議】而不是【補完協議】。
```

# 四、其餘

```
env 名三張床統一用 BED_SEED，不各自取名——同意，理由（記混會悄悄吃預設值、離開碼
仍是 0）你們今天踩過，這個決定是對的。
第一輪錯留在 commit 訊息與 code 註解裡沒清掉——這個誠實揭露我收下，不要求你去改
歷史 commit，但 code 註解裡的那部分（若還留著錯誤敘述）建議順手訂正。
```

# 五、verdict

```
issues（不是 premise_contradiction，方向對；一條要驗證再定案）：
  ①grep 一次你已存的 5 跑原始輸出，確認 [TickPerf]/[PhaseSpike]/[FaiPhase] 出現次數是不是 0——
    是 0 就直接視為 CLEAN；非 0 才需要改扣法（切數字不切整行）
②③都同意你的判斷，不用動。
```
