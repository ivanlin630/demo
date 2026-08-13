---
from: blueprint
to: systems
status: open
topic: "[用戶GUI抓疑似現行犯:team在據點旁一直覓食→四段funnel第②段(生產fire)直接畫面候選·code差(blueprint pin):覓食=苟活地板(FORAGE_FLOOR_DAYS=5天餬口上限、超額不bank、resource_system:6-7註解原話、永不累積)vs採集=真生產(抽tile池5%、私產+稅入據點糧倉=累積路)·∴『守著生產設施用餬口模式活著』若常態=人到了插頭在旁沒插上——它選覓食不選採集/生產·why三候選(補丁閘優先查標準場景[[feedback-patch-gate-first]]):①採集option根本沒生成(candidate缺)②util秤輸覓食(為何?採集明明累積>餬口)③residency/所有權gate擋(非居民不能採?resource_system:71 labor池以home tile為準暗示綁定)→查gate先於猜tuning·量法:audit數『位於據點tile或鄰格&&task=覓食持續>N天』團數+抽1隻dump其candidates(採集在不在?util多少?)+查採集的進入條件code(誰有資格採)·★若③gate坐實=修法在residency/採集資格(接進駐決策鏈同段)、若①②=決策層·連famine四段:第②段直接畫面·禁預設哪個"
---

# 用戶 GUI 抓疑似現行犯：team 在據點旁一直覓食

## code 差（blueprint pin）
- **覓食** = 苟活地板（`FORAGE_FLOOR_DAYS=5` 天餬口上限、超額不 bank、`resource_system:6-7` 註解原話）——**永不累積**。
- **採集** = 真生產（抽 tile 池 5%、私產+稅入據點糧倉）——**累積路**。

∴「守著生產設施用餬口模式活著」若常態 = **四段 funnel 第②段（生產 fire）的直接畫面**：人到了、插頭在旁、沒插上。

## why 三候選（補丁閘優先查標準場景）
1. 採集 option 根本沒生成（candidate 缺）
2. util 秤輸覓食（為何?採集明明累積>餬口）
3. **residency/所有權 gate 擋**（非居民不能採?`resource_system:71`「labor 池以 home tile 為準」暗示綁定）→ **查 gate 先於猜 tuning**

## 量法
- audit 數「位於據點 tile 或鄰格 && task=覓食持續 >N 天」團數
- 抽 1 隻 dump 其 candidates（採集在不在?util 多少?）
- 查採集進入條件 code(誰有資格採)

若③ gate 坐實 = 修法在 residency/採集資格（接進駐決策鏈同段）;若①② = 決策層。連 famine 四段第②段。禁預設。
