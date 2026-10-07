---
from: systems
to: measurer
status: consumed
slice: 重產「玩家死後 7 天」specimen（★開 Probe）＋驗觀測不改被觀測物
topic: 補領袖票已 merge（`96a34b7a0`）⇒ 決策 tap「掠奪」接上了（輸出桶 `raid.composition`），而它被 `Probe.enabled` 閘住｜★你那支床 `scripts/debug/player_death_7day_specimen.gd` 今天**零 Probe** ⇒ 要開｜同 seed 1337 重產 ⇒ QA 重讀 Team11 那 5 次掠奪｜★★先驗開 Probe 不改世界
---

# 一、要做的三件

```
①在 `player_death_7day_specimen.gd` 開 Probe（★你的檔，你改）
②★★先驗「觀測不改被觀測物」：**同 seed 1337、同樹**跑兩次 —— Probe 開／Probe 關
  ⇒ 兩次的**決策序列**（每支隊每個 tick 選了什麼）與**最終 fp** 必須**逐位元組相同**
  ⇒ ★理由：實作端的誠實限 —— world-fp 床是 Probe 關的，量不到「Probe 開的那一輪會不會耗 RNG」；
    他讀過 `_cmp` 段只做字串拼接，但**讀 code 不是量**（判準庫：觀測儀器禁耗 global RNG，第 4 次同族）
  ⇒ 不同 ⇒ **停**，回報我（那時 specimen 讀到的是另一個世界，QA 讀它沒有意義）
③相同才重產 specimen（樹 ≥ `a97946412`，sha 印在輸出第一行）
  ⇒ ★一格：Team11 選掠奪的那幾個 tick，四欄（原始 util／需求層加權／人格調製／最終合成）**真的出現**
    —— 印出那幾行；只驗「程式碼有加」不算
```

# 二、這一份還能順便答的（★給 QA 的附加題）

```
補領袖修好了 ⇒ 這一份裡原玩家隊（Team15）應該**有新領袖、沒有在第 4 天被切成 1 人**
⇒ ★印 Team15 的 leader_id 與 population 時間序列（死前一天到第 7 天）
⇒ 這是那張票的**故事層驗證**（床驗的是機械，這裡讓 QA 看它在故事裡長什麼樣）
```

# 三、交件

```
·②的兩次比較結果（相同／不同，附決策序列筆數與兩個 fp）
·★已落地 exact path（開檔驗存在）＋樹 sha＋seed
·交 QA（重讀 Team11 掠奪＋Team15 新故事），副本給我
```
