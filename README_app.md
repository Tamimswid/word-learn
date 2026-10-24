Harika bir fikir! Bu 4 modülün mimari detaylarını, veritabanı etkileşimlerini, ekran işlevlerini ve aralarındaki entegrasyonu en ince ayrıntısına kadar açalım:

---

### 1. `word_management/` (Kelime Yönetimi & AI Ön Üretim Sistemi)

Bu modül, uygulamanın "veri girdisi" ve "akıllı içerik zenginleştirme" merkezidir.

* **Detaylı Akış:**
1. **Kullanıcı Girdisi (`AddWordScreen`):** Kullanıcı sadece öğrenmek istediği İngilizce kelimeyi (örn. *"Resilient"*) yazar ve kaydet tuşuna basar.
2. **AI Pre-generation (Ön Üretim) - `WordRepository` & `Network`:** Kelime veritabanına ham olarak kaydedilmeden önce, arka plandaki AI istemcisi (Dio üzerinden) tetiklenir. Yapay zeka anında şu verileri üretir:
* *2-6 kelimelik kısa ve net örnek cümle*
* *Anlamı/Çevirisi*
* *3 adet akıllı çeldirici (distractor - yanlış seçenek)*


3. **Veritabanı Kaydı (`WordModel`):** Üretilen tüm bu paket, sıfır gecikme (zero-latency) prensibiyle SQLite veritabanına tam ve hazır bir şekilde kaydedilir. Kullanıcı daha sonra çalışırken AI'ı beklemek zorunda kalmaz, veriler anında yüklenir.



---

### 2. `deck_session/` (10'luk Deste & Akıllı Swipe Mekaniği)

Kullanıcının ezber ve pekiştirme seanslarını yürüttüğü, uygulamanın kalbi olan ekran modülüdür.

* **Detaylı Akış:**
1. **SQL View Optimizasyonu (`v_card_deck`):** Karmaşık algoritmaları Dart tarafında yazıp işlemciyi yormak yerine, SQLite içinde oluşturulan `v_card_deck` view'i sorgulanır. Bu view, **50/30/20 kuralını** doğrudan veritabanı seviyesinde uygular:
* *%50:* Yeni veya tekrarı gecikmiş kritik kelimeler.
* *%30:* Öğrenme aşamasındaki pekiştirme kelimeleri.
* *%20:* Sağlamlaştırılmış (mastered) kelimelerden rastgele karışım.


2. **Swipe Arayüzü (`DeckScreen` & `SwipeCardWidget`):** Kelimeler deste halinde (10'arlı paketler) kartlar şeklinde sunulur.
* *Sağa kaydırma:* "Biliyorum / Başarılı" -> Kelimenin skorunu artırır, sonraki aşamaya taşır.
* *Sola kaydırma:* "Bilmiyorum / Tekrar" -> Kelimenin tekrar havuza dönmesini sağlar.


3. **State Yönetimi (`DeckCubit`):** Kart hareketlerini anlık olarak yakalar, `DeckRepository` aracılığıyla SQLite veritabanındaki kelime durumunu günceller ve destenin sonuna gelindiğinde tebrik/özet ekranını tetikler.



---

### 3. `micro_exercise/` (Mikro Alıştırmalar & Hızlı Pekiştirme)

Kullanıcının gün içinde uzun vakit ayıramadığı anlarda (örneğin yolda yürürken veya kısa bir molada) bildirimler veya hızlı 1 dakikalık seanslarla kelime kalıcılığını artıran modüldür.

* **Detaylı Akış:**
1. **Hızlı Tetiklenme:** Ana ekrandan veya bildirim aracılığıyla tetiklenir.
2. **Repository Sorgusu (`ExerciseRepository`):** Kullanıcının geçmişte zorlandığı veya pekiştirmesi gereken kelimeler arasından anlık 3-4 soruluk mini bir test verisi çeker.
3. **Etkileşimli Arayüz (`ExerciseDialog` / `Screen`):** Boşluk doldurma veya doğru/yanlış formatında hızlı interaktif kartlar sunar. Kullanıcı anında geri bildirim (yeşil/kırmızı) alır ve veritabanı başarı oranını günceller.



---

### 4. `home_dashboard/` (Ana Sayfa, 7 Günlük Chart ve Streak Takibi)

Kullanıcının uygulamaya girdiği ilk karşılaştığı ekran olup, motivasyonunu ve günlük ilerlemesini görselleştiren komuta merkezidir.

* **Detaylı Akış:**
1. **SQL View İstatistikleri (`v_weekly_chart`):** `HomeRepository`, son 7 günün çalışma verilerini (çözülen kart sayısı, doğru oranları vb.) `v_weekly_chart` view'i üzerinden tek ve optimize edilmiş bir SQL sorgusuyla çeker.
2. **Görselleştirme (`WeeklyBarChartWidget`):** Çekilen verileri modern, minimalist ve karanlık mod uyumlu bir çubuk grafikle ekrana yansıtır.
3. **Streak (Seri) Kontrolü:** Kullanıcının üst üste kaç gündür aktif olarak kelime çalıştığını hesaplar, ana ekranda ateş/seri ikonlarıyla göstererek habit-forming (alışkanlık kazandırma) psikolojisini tetikler.