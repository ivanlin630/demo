# 兩張（用戶第一手回報）：戰鬥區內容要被斷言＋勒索煞車沒咬（HOW）

```
票源 ＝ 藍圖 `9292329b7`（`…TICKETS-battle-screen-content-never-asserted-and-extortion-brake-not-biting.md`）
序 ＝ 四個畫面缺陷那張之後、票 T 之前｜兩張都擋交玩
```

## 票 BS：戰鬥區在打的時候要被看過

```
現況：E2E 攻擊步 t tab 1 6 f space esc —— 開戰下一鍵就投降，戰鬥畫面在打的時候零格斷言（卷面 2026-10-07-terminal-e2e-round4-invite.txt:455-459）
補（判決格）：
  BS1 進戰後連續 ≥3 拍不投降（用移動／待機／攻擊），每拍斷言：六欄齊（兵力、狀態、裝備、可用鍵、游標、戰報）＋單位列表＋每鍵畫面 tick＝世界 tick
  BS2 三種結束各一步：打完（勝或敗）／往邊界外撤出／投降 —— 每種結束後回到主畫面、結果句說出是哪一種
  BS3 計時：單位列表的 action_timer 在 ≥3 拍內至少變一次（佈置不同速單位，補 §3 登記的 P5 缺口）
另：實作端用 play.py **真打一場**（管道餵鍵，非床），逐拍整屏落 docs/measurements/，給藍圖讀
```

## 票 XB：勒索煞車為什麼沒咬 —— 先量再修

```
9/30 裁定的煞車：勒索成功寫「tributed」記憶（好感降）→ 屈服判斷 `tribute_accept`（`diplomatic_ai_system.gd:49`）讀好感與 typed 邊 → 反覆勒索會開始被拒／敵對
靜態已核（systems，樹 8a8a2bedb）：
  ·玩家勒索走 `interaction_system.gd resolve_extortion_direct` ⇒ 有呼 tribute_accept（(c) 不成立）
  ·`_resolve_extortion` 有寫 "tributed"（(a) 的主路成立）——★但閘在 `coin_before > 0`：對方 coin 被拿光之後，**再勒索不寫任何記憶**
  ·權重：每次好感 −0.25×0.5＝−0.125 ⇒ score 每次 −0.125×RELATION_W_AFFINITY 0.15 ≈ −0.019，門檻 0.1 ⇒ 是否翻得過要看基礎分
量（同格佈置、同一隊連勒索 10 次，每次印）：第 n 次的 accept、score、score_no_edge、affinity、feud 邊強度、是否寫了記憶（與 coin_before）
★藍圖裁（不等量）：被勒索本身就是怨，跟拿不拿得到錢無關 ⇒「coin 光了不寫」違反 9/30 裁定 ⇒ **直修**：
  每次勒索**到達對方**（接受或拒絕都算）就寫 "tributed" 記憶；嚴重度＝max(拿走比例, 被威脅基底)
  ⇒ 被威脅基底＝**勒索方 readiness（clamp 0..1）**——它已是 tribute_accept 的 threat 輸入（`interaction_system.gd:446`），不新增常數
  ⇒ 寫入點收成一處（接受與拒絕兩支共呼），不各寫一份
  ★R² 核到：拒絕路**完全不呼** `_resolve_extortion` ⇒ 今天拒絕勒索零寫入；而 if-accept 分岔有**兩份**：
    `interaction_system.gd:446-451`（NPC 同格掠奪）與 `:1480-1487`（玩家直接勒索）⇒ 兩份的拒絕支都要呼那一處寫入
  ★`tribute_refused`（`diplomatic_ai_system.gd:226`）寫在**索貢方**（記得被拒），`tributed` 寫在**被勒索方** —— 主詞相反、不合流
判讀 → 修法（不准冷卻常數、不准玩家特例）：
  ①寫不到（coin 光了就不寫）⇒ 被勒索這件事的記憶不該依賴有沒有 coin：intensity 改以「被拿走的價值佔總資產」（四資源依既有估價）；★先查有沒有既有估價函式，沒有就回報
  ②寫了但翻不過（好感項太小）⇒ ★不調權重。藍圖判準：該長出的是對方的【選項】不是權重——拒絕（願冒打輸風險，人格秤）、逃離該格、向勢力／盟友求援、記仇後反擊
     ⇒ 量測卷面要同時印：每次被勒索那一刻，對方秤上**有哪些選項**（候選集）與各自 util；若只有「屈服」與「拒絕」兩支 ⇒ 是候選集缺項，回報藍圖
  ③索貢（demand_tribute）走同一個秤 ⇒ 同一張床一起量
P1 量測卷面（10 次逐行）先交，我裁修法再做 P2
P2 修後：10 次內接受率下降、怨／好感單調惡化、過門檻後拒絕或敵對；★反向：只勒索一次的對象下一次仍可能接受（不是一次就鎖死）
```
