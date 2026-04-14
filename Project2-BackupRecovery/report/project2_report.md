# Proje 2 - Veritabanı Yedekleme ve Felaketten Kurtarma Planı

## Youtube link: [YouTube](https://youtu.be/63zP8es5KWc)

## 1. Projenin Amacı

Bu projenin amacı, SQL Server üzerinde çalışan bir veritabanı için yedekleme ve felaketten kurtarma sürecini uygulamalı olarak göstermektir. Çalışmada tam yedek (full backup), fark yedeği (differential backup), işlem günlüğü yedeği (transaction log backup) ve restore işlemleri uygulanmıştır.

Proje kapsamında Microsoft tarafından sağlanan örnek veritabanı olan `AdventureWorks2022` kullanılmıştır. Hazır veritabanı kullanılmış olsa da, uygulanan senaryo, seçilen tablolar, hata akışı ve kurtarma adımları projeye özel biçimde hazırlanmıştır.

## 2. Kullanılan Ortam

- Veritabanı Yönetim Sistemi: Microsoft SQL Server
- Yönetim Aracı: SQL Server Management Studio (SSMS)
- Veritabanı: AdventureWorks2022
- Kaynak Kontrol: GitHub

## 3. Veritabanı Bilgileri

Çalışmanın başında `AdventureWorks2022` veritabanının fiziksel dosya bilgileri incelenmiştir. Bu adımın amacı restore işlemi sırasında kullanılacak logical file name değerlerini doğru belirlemektir.

Tespit edilen logical file name değerleri şunlardır:

- `AdventureWorks2022`
- `AdventureWorks2022_log`

Bu bilgiler restore sırasında `WITH MOVE` ifadesi ile yeni bir test veritabanına geri yükleme yapmak için kullanılmıştır.

## 4. Full Backup İşlemi

İlk olarak veritabanının tam yedeği alınmıştır. Bu işlem felaketten kurtarma planının temel adımıdır. Full backup, veritabanının o andaki tam durumunu içeren ana yedek dosyasını oluşturur.

Bu aşamada aşağıdaki amaç gerçekleştirilmiştir:

- veritabanının başlangıç durumunu güvenli hale getirmek
- daha sonra yapılacak değişiklikler için temel geri dönüş noktası oluşturmak
- differential ve log backup senaryolarına temel hazırlamak

## 5. Differential Backup İşlemi

Full backup alındıktan sonra veritabanı üzerinde küçük bir veri değişikliği yapılmış ve ardından differential backup alınmıştır.

Differential backup, son full backup’tan sonra değişen veri sayfalarını içerir. Bu nedenle restore sürecinde hem zaman hem de işlem yükü açısından avantaj sağlar.

Bu aşamada differential backup’ın mantığı uygulamalı olarak gösterilmiştir.

## 6. Recovery Model ve Transaction Log Backup

Başlangıçta veritabanının recovery model değeri kontrol edilmiştir. İlk durumda recovery model `SIMPLE` olarak görülmüştür. Daha sonra bu değer `FULL` olarak değiştirilmiştir.

Bu değişikliğin amacı, transaction log backup alınabilmesini sağlamaktır. Ancak yalnızca recovery model’ı `FULL` yapmak yeterli değildir. Bu değişiklikten sonra yeni bir full backup alınması gerektiği görülmüş ve bu adım uygulanmıştır.

Ardından transaction log backup başarıyla alınmıştır.

Bu bölümde şu sonuç ortaya çıkmıştır:

- `SIMPLE` recovery model altında log backup alınamaz
- `FULL` recovery model’a geçildikten sonra yeni bir full backup alınmalıdır
- bundan sonra log backup zinciri başlatılabilir

## 7. İlk Felaket Senaryosu ve Karşılaşılan Sorun

İlk denemede felaket senaryosu için veritabanı içinde `DisasterRecoveryTest` adında özel bir test tablosu oluşturulmuştur. Bu tabloya örnek kayıtlar eklenmiş, daha sonra bazı kayıtlar silinmiştir. Ardından restore işlemi yapılarak bu kayıtların geri getirilmesi hedeflenmiştir.

Ancak restore sonrasında test tablosunun geri gelmediği görülmüştür. Bunun nedeni, restore işleminde kullanılan full backup dosyasının test tablosu oluşturulmadan önce alınmış olmasıdır.

Bu durum proje açısından önemli bir öğrenme sağlamıştır:

- restore işlemi teknik olarak başarılı olabilir
- fakat seçilen backup dosyası doğru zaman noktasına ait değilse istenen veri geri gelmeyebilir

Bu nedenle senaryo yeniden düzenlenmiştir.

## 8. Nihai Felaket Senaryosu

İlk senaryodaki zamanlama problemi nedeniyle daha kontrollü ve daha açık bir kurtarma örneği hazırlanmıştır. Bunun için `AdventureWorks2022` veritabanındaki mevcut bir tablo kullanılmıştır:

- `Person.PhoneNumberType`

Bu tabloda başlangıçta üç kayıt bulunduğu gözlemlenmiştir:

- Cell
- Home
- Work

Daha sonra veritabanının bu doğru hali için yeni bir full backup alınmıştır. Ardından `PhoneNumberTypeID = 1` olan satırdaki `Name` değeri bilinçli olarak yanlış biçimde güncellenmiştir:

- `Cell` → `WRONG_VALUE`

Bu adım felaket senaryosunda “yanlış veri güncellemesi” durumunu temsil etmektedir.

## 9. Restore İşlemi

Yanlış güncellemeden sonra veritabanı doğrudan değiştirilmemiş, bunun yerine test amaçlı ayrı bir veritabanına geri yükleme yapılmıştır:

- `AdventureWorks2022_RestoreTest`

Restore işlemi sırasında aşağıdaki yaklaşım izlenmiştir:

- varsa eski restore test veritabanı silinmiştir
- full backup dosyası kullanılmıştır
- `WITH MOVE` ile veri ve log dosyaları yeni isimlerle uygun dizine yerleştirilmiştir
- restore tamamlandıktan sonra test veritabanı içinde `Person.PhoneNumberType` tablosu tekrar sorgulanmıştır

İlk restore denemesinde dosya yolu nedeniyle hata alınmıştır. Bunun nedeni restore hedef yolunun yanlış seçilmesidir. Daha sonra sistemde kullanılan gerçek veri dizini `D:` sürücüsünde olduğu için restore komutu bu yola göre düzeltilmiştir ve işlem başarılı şekilde tamamlanmıştır.

## 10. Restore Sonrası Doğrulama

Restore işlemi sonrası `AdventureWorks2022_RestoreTest` veritabanında `Person.PhoneNumberType` tablosu sorgulanmıştır. Sonuçta başlangıçtaki doğru değerlerin geri geldiği görülmüştür:

- `Cell`
- `Home`
- `Work`

Bu sonuç, hatalı güncellemenin restore edilen veritabanında ortadan kalktığını göstermektedir.

Böylece şu durum açık biçimde kanıtlanmıştır:

- canlı veritabanında veri bozulmuş olabilir
- backup kullanılarak ayrı bir test veritabanına geri yükleme yapılabilir
- bozulmadan önceki doğru veri durumu geri getirilebilir

## 11. Uygulanan SQL Dosyaları

Projede kullanılan temel SQL dosyaları şunlardır:

- `01_database_info.sql`
- `02_full_backup.sql`
- `03_differential_backup.sql`
- `04_recovery_model_and_log_backup.sql`
- `05_create_test_table.sql`
- `06_disaster_scenario.sql`
- `07_restore_validation.sql`

Bu dosyalar sırasıyla veritabanı bilgilerini inceleme, backup alma, recovery model değiştirme, felaket senaryosu oluşturma ve restore sonrası doğrulama işlemlerini içermektedir.

## 12. Ekran Görüntüleri ve Kanıtlar

Proje boyunca aşağıdaki türde ekran görüntüleri alınmıştır:

- veritabanı dosya bilgileri
- full backup başarı mesajı
- differential backup başarı mesajı
- recovery model değişimi
- log backup başarı mesajı
- test verisinin ilk hali
- hatalı güncelleme sonrası durum
- restore file list kontrolü
- restore başarı mesajı
- restore sonrası doğrulama sonucu

Bu ekran görüntüleri hem GitHub deposunda hem de raporun destekleyici unsurları olarak kullanılmaktadır.

## 13. Karşılaşılan Hatalar ve Çözümler

Çalışma sırasında aşağıdaki problemlerle karşılaşılmıştır:

### 13.1 Differential backup hatası
Differential backup alınmaya çalışıldığında sistem, mevcut bir full backup bulunmadığını bildirmiştir. Bu problem, önce full backup alınarak çözülmüştür.

### 13.2 Log backup hatası
Recovery model `FULL` yapılmadan log backup alınmaya çalışıldığında hata oluşmuştur. Ayrıca recovery model değiştirildikten sonra yeni bir full backup alınması gerektiği görülmüştür.

### 13.3 Restore dosya yolu hatası
İlk restore denemesinde hedef veri dosyası yolu hatalı olduğu için restore işlemi başarısız olmuştur. Sistem üzerindeki gerçek SQL Server data dizini belirlenmiş ve restore komutu buna göre düzeltilmiştir.

### 13.4 Yanlış backup zaman noktası
İlk test tablosu senaryosunda restore başarılı olsa da beklenen tablo geri gelmemiştir. Bunun nedeni backup dosyasının test tablosu oluşturulmadan önce alınmış olmasıdır. Bu problem, yeni ve daha kontrollü bir senaryo tasarlanarak çözülmüştür.

## 14. Sonuç

Bu projede SQL Server üzerinde veritabanı yedekleme ve felaketten kurtarma süreci uygulamalı olarak gerçekleştirilmiştir. Full backup, differential backup, recovery model değişikliği, transaction log backup ve restore adımları test edilmiştir.

Çalışma sırasında yalnızca başarılı sonuçlar değil, hatalı senaryo ve çözüm süreçleri de incelenmiştir. Bu durum projenin uygulama değerini artırmıştır.

Özellikle `Person.PhoneNumberType` tablosu üzerinde gerçekleştirilen yanlış veri güncellemesi ve sonrasında restore test veritabanında doğru verinin geri getirilmesi, felaketten kurtarma planının pratikte çalıştığını göstermiştir.

Sonuç olarak, veritabanı yönetiminde yalnızca yedek almak değil, yedeklerin doğru sırayla alınması, uygun recovery model seçimi ve restore sürecinin test edilmesi de kritik öneme sahiptir.
