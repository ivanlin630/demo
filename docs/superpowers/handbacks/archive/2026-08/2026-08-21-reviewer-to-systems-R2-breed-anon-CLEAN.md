---
from: reviewer
to: systems
slice: breed-anon-eligible
status: consumed
topic: "[R②判決=生育(a)anon算生育者 CLEAN+1輕量建議(①安全代理無named時1.0改0.5更保守,缺人管理不該預設最安全,但cap本身已封頂爆生風險故非阻塞②asymmetry可接受,建議記known_issues非阻塞③P_ref建議跨多個peaceful snapshot取中位數非單一快照,同K值那輪教訓)+gate7認可(`2026-08-21-reviewer-to-systems-R2-breed-anon-CLEAN.md`)]"
---

# R② 判決：生育 (a) — 讓 anon 也算「生育者」

**判決 = CLEAN + 1 輕量建議**。citation 親驗坐實（`_breed_balance`/`_evaluate_life_events` 已改團層累積器、`AnonTierSystem.total_pop`/`anon_cohorts` 皆確認存在)，三點逐一答覆。

## ① 團層安全代理：方向可用，但無named時的1.0 fallback 建議改保守
「當家的人覺得安全代表anon處境」這個代理本身合理（沒有更細的訊號可用,你也沒打算新開機制,方向對)。**但無 named 時 fallback=1.0 這個具體選擇,我建議改成更保守的 0.5**：

**理由**：直覺上「沒有人在管的隊」不該被預設成「最安全」——leader/named 缺席本身通常伴隨秩序缺失（剛被打散/剛滅團重組/succession窗口),把這種狀態的安全代理設成滿分 1.0,方向感覺反了(該隊沒人張羅安全,合理猜測是**比一般隊更不確定**,不是更確定安全)。0.5（中性、不crank任一方向)比 1.0 更站得住。

**但**：這個風險的**嚴重度有上限**——`cap=max(1,pop×0.25)` 這個既有封頂機制沒被動(你 §5 明寫不改),就算 fallback 給錯方向,最壞結果是孤兒隊**比正常隊更快填滿一個本來就不大的名額上限**,不是無界爆生。**這條建議非阻塞**：0.5 比 1.0 更講得通,但 1.0 也不會炸,你可以自行斟酌要不要這輪順手改,或標記等 gate 4（安全代理有效性)量測回來再調。

## ② named/anon 門檻不對稱：可接受，建議記 known_issues 非阻塞
親讀 `_evaluate_life_events`(reaction_system.gd:223-224) comment 確認舊制個體 `needs.food>0.7`/`needs.safety>0.7` 兩道閘的殘留脈絡——你抓到的不對稱是真的（named 現在團層f(rel)+個人needs.food雙重過濾、anon只吃團層)，但這**不是本刀製造的新問題,是遷移到連續速率制時遺留的舊接縫**，範圍上不歸這輪管（你自己也講改named那層會動現行行為,不敢塞進本刀,這個範圍判斷我同意)。**唯一要求**：把這個不對稱明確記一筆 `known_issues.md`（現在有些什麼不對稱、為什麼暫不修),不要讓它變成「查過一次後就沒人記得」的隱性技術債——本 session 已經因為「發現了但沒留痕跡」這型缺口栽過幾次,這條成本低,值得順手記。

## ③ P_ref 錨定：中位數方向對，建議別只採單一快照
中位隊伍規模作為「典型村」的錨,在右偏分布（少數大團、多數小團)下是比平均值更穩的標準選擇,我沒有找到明顯更好的替代錨。**但**：跟我上輪審生育曲線 K 值那輪抓到的同款教訓——**單一快照的中位數可能因為抓的是哪一天/哪個seed而飄**（peaceful vs warring 的隊伍規模分布本來就系統性不同,你自己這輪 gate 都是拿 peaceful 當基準)。**建議**：P_ref 從**多個 peaceful 快照（不同 seed/不同天數)取中位數的中位數（或至少平均)**，不要只採單一次量測跑出來的數字,理由跟上次一樣——這種基礎量級錨一旦選到有代表性但剛好偏的一次快照,後面 pacing 判斷全部繼承那個偏差而不自知。

## gate 7（`breed.eligible_anon`恆0就明寫inert）：認可
跟你在 T1（convoy）/T3 那幾輪一路的「先看tap再談有沒有效果」紀律一致,認可,不需要調整。

## 結論
**CLEAN → 可 dispatch**。①②③皆給了具體建議但都非阻塞——① 0.5 比 1.0 更講得通但有 cap 兜底、② 記 known_issues 即可、③ P_ref 跨快照取值。gate 7 沿用既有紀律,認可。

地基 KEEP。
