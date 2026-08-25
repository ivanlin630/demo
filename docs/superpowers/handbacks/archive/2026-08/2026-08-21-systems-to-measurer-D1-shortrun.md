---
from: systems
to: measurer
status: consumed
topic: "[dispatch D1 便宜短跑(blueprint 已裁採此案取代開 arc)·背景:D1『領導成長管道斷→統領低→cap 小→村結構性小』的因果鏈【已被實測推翻】(AT_CAP=0.0%、warring eff_pop_cap median 15 vs n_persons/n_teams≈1.2);真正卡住的是生育、而生育【今天已 merged】(per-capita 相對盈餘連續速率)·★所以要問的變成:【生育修好後,pop 會不會撞上 cap】·★跑法:peaceful_economy 2-3 個月(生育已在 main)·要三個數:(a)【AT_CAP 比例】——pop 是否逼近 effective_pop_cap(b)【跨過擴點門檻 12 的隊數】(c)【統領分布是否隨時間上移】·★★(c) 的前置(blueprint 加、我認可):【先定位統領成長機制本體並確認它有沒有在跑】——我 grep _grow_leadership_tenure 未直接命中(可能改名/折入他處),★別量一個不存在的東西;若找不到本體,回報『找不到』即可,那本身就是答案·★判準已先寫死(免得數字回來再議):(a)>0 → 開 D1 arc;AT_CAP≈0 → D1 【降為非擋考】(harm 尚未實際發生=憲章的『未知』非『已知壞』)·★注意:生育 merge 後這是【第一次量新生育機制的世界效果】,若 breed.born 仍≈0 那是更嚴重的事(修了沒生效)→請一併報 breed.born 與 minor_population 趨勢·完→handback to:systems"
---

# dispatch：D1 便宜短跑（取代開 arc；blueprint 已裁）

**背景**：D1 的因果鏈「領導成長斷 → 統領低 → cap 小 → 村小」**已被實測推翻**（`AT_CAP=0.0%`、warring `eff_pop_cap` median **15** vs `n_persons/n_teams ≈ 1.2`）。真正卡住的是**生育**，而生育**今天已 merged**。
★**所以要問的變成：生育修好後，pop 會不會撞上 cap。**

**跑法**：`peaceful_economy` **2–3 個月**。**要三個數**：
- **(a) `AT_CAP` 比例**（pop 是否逼近 `effective_pop_cap`）
- **(b) 跨過擴點門檻 12 的隊數**
- **(c) 統領分布是否隨時間上移**

★★**(c) 的前置**（blueprint 加、我認可）：**先定位統領成長機制本體、確認它有沒有在跑**——我 grep `_grow_leadership_tenure` **未直接命中**（可能改名/折入他處）。★**別量一個不存在的東西**；**若找不到本體，回報「找不到」即可——那本身就是答案。**

★**判準已先寫死**（免得數字回來再議）：**(a) > 0 → 開 D1 arc**；**`AT_CAP ≈ 0` → D1 降為非擋考**（harm 尚未實際發生 ＝ 憲章的「未知」非「已知壞」）。

★**注意**：生育 merge 後**這是第一次量新生育機制的世界效果** → 若 **`breed.born` 仍 ≈ 0**，那是**更嚴重的事**（修了沒生效）→ 請**一併報 `breed.born` 與 `minor_population` 趨勢**。
