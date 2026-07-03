---
from: blueprint
to: systems
status: open
topic: 三軌裁定——裁1雙引擎複利+★佔村option(弱村=最小據點,measure狼為何43連raid不佔);裁2誘因結盟准;裁3★馬經濟提前build(最小slice=產馬點+入交易網,消費端全在)+default組成/健康measure照舊
---

# 三軌裁定：雙引擎+佔村 / 誘因結盟 / 馬提前

回 `longwindow2-results`。三軌一次看清記一功（warring 修好/seed7 戰略 capture 首 fire/default 荒=誠實）。三裁：

## 裁 1：糧複利非目標——雙引擎複利 + ★「佔村」選項
- **「搶窮村只夠餬口」= 正解非 bug**（loot 不 inflate）。複利=兩引擎咬合：
  ```
  人力引擎:raid→俘→同化→壯兵        （seed7 已證 by_attack 3+同化 3）
  糧引擎:  據點+生產→盈餘            （T32 已證和平生產 flow 正）
  弧:raid 活命抓人→同化壯兵→奪據點→據點產糧養兵→打更大→立國
  ```
- **★用戶戳破缺口：弱村=最小據點,狼為何搶了就走？** T36 月 raid 43 次從不佔村=荒謬（月月搶同片村不搬進去）。capture 機制在（`OutpostSystem.capture` 決勝/潰逐觸發）但狼的 raid 弧走不到。
- **修：「佔村」= means-end option 與「搶了就走」並列**：
  ```
  搶了就走 = 守不住（離家遠/強敵環伺/人少分不出駐軍）
  佔住不走 = 守得住+要根據地（奪據點+村民=受控人力+糧產出歸你）
  = 雙引擎一口咬合。按情境秤,零新判斷器。
  ```
- **先 measure**：狼 43 連 raid 不佔=機制斷（raid 路徑不觸發 capture-hold）還是權重斷（選項在但永輸）→ 修那個。
- 複利驗收改盯：by_attack→同化→pop/force 長→**佔村/奪據點**→盈餘→更大目標。loot 量級 sanity 順量。

## 裁 2：誘因結盟——准
提案帶誘因（糧禮先行）：資源轉移（既有）+ diplomacy score 讀禮值一項。**掏誘因=戰略選擇**（越急掏越多）。驗收:帶誘因成功率>0、白嘴仍難。門檻 TEST VALUE 同步微校。聯姻槽順鋪（維度5未來直插）。

## 裁 3：★馬經濟提前 build（用戶裁）+ default measure 照舊
- **馬消費端全建好**（movement 騎乘模型/mounts 資源/速度加成/大團懲罰），**只缺來源**（世界 mounts=0 全 dormant）。
- **最小 slice**：①產馬點（牧場地形 or stable 產出,你選 HOW——地形特化+1=產馬區則順鋪馬貿易戰略不對稱）②馬入交易網（貿易品,馬貴=高值商品）。
- **醒來的**：信使 3×（default 地圖尺度/envoy timeout 直接解）、隊伍機動、馬貿易 stakes、E-2 騎兵地基。
- **default 組成/健康 measure 照舊**（馬解不了這兩個）：FORCE 獨立狼=0（生成分佈?世界太小?）+ **和平隊自己餓崩**（知足隊 13→1/絕境隊月2死=default 健康問題）。量完回報,我裁 default 生成參數（WHAT:自然世界該多密/多少狼）。
- GateWait 指標修你直做 ✓。

## 燒序
佔村 measure→修 ‖ 誘因結盟 ‖ 馬最小 slice → default 組成/健康 measure → 裁生成參數 → **軌3 二考**（馬+誘因+佔村上車後,自然世界再考沙盒 bar）。
