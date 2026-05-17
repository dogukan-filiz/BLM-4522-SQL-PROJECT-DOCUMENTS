# Proje 3 - Veritabanı Güvenliği ve Erişim Kontrolü

## 1. Projenin Amacı

Bu projenin amacı, SQL Server üzerinde kullanıcı yetkilendirme, rol yönetimi, hassas veri erişiminin sınırlandırılması, temel güvenlik önlemleri ve SQL injection riskine karşı güvenli sorgulama yaklaşımını uygulamalı olarak göstermektir.

Projede hem kullanıcı bazlı erişim kontrolü hem de veri güvenliği açısından örnek bir senaryo hazırlanmıştır. Ayrıca kullanıcı aktivitelerinin izlenmesine yönelik basit bir audit/log yaklaşımı da eklenmiştir.

## 2. Kullanılan Ortam

- Veritabanı Yönetim Sistemi: Microsoft SQL Server
- Yönetim Aracı: SQL Server Management Studio (SSMS)
- Veritabanı: SecurityProjectDB
- Kaynak Kontrol: GitHub

## 3. Veritabanı Tasarımı

Bu proje için `SecurityProjectDB` adında ayrı bir veritabanı kullanılmıştır. Güvenlik senaryolarını göstermek amacıyla aşağıdaki tablolar oluşturulmuştur:

- `Departments`
- `Employees`
- `Payroll`

### Tabloların Amacı

**Departments** tablosu, şirket içindeki bölüm bilgilerini tutmaktadır.

**Employees** tablosu, çalışanların temel bilgilerini içermektedir:
- ad
- soyad
- bağlı olduğu bölüm
- e-posta adresi

**Payroll** tablosu ise hassas verileri içermektedir:
- maaş
- bonus
- banka hesap bilgisi

Bu ayrım, güvenlik projesi açısından önemlidir. Çünkü çalışanların genel bilgileri ile hassas maaş/banka bilgilerinin aynı düzeyde erişime açık olmaması gerekir.

## 4. Örnek Veri Oluşturma Süreci

Tablolara test ve yetki denemeleri yapılabilecek ölçüde örnek veri eklenmiştir.

Eklenen örnek veriler şunlardır:

- 3 adet bölüm bilgisi
- 3 adet çalışan kaydı
- 3 adet maaş kaydı

Bu veriler, kullanıcıların hangi tabloya erişebildiğini ve hangi tabloya erişemediğini test etmek için kullanılmıştır.

## 5. Kullanıcılar ve Roller

Projede üç farklı güvenlik senaryosu oluşturulmuştur. Bunun için SQL Server login ve database user yapısı kullanılmıştır.

### 5.1 AdminUser

`AdminUser`, sistem yöneticisini temsil etmektedir. Bu kullanıcıya veritabanı üzerinde tam yetki verilmiştir.

Atanan rol:
- `db_owner`

Bu kullanıcı tüm tablolara erişebilir, veri ekleyebilir, değiştirebilir ve silebilir.

### 5.2 ReadOnlyUser

`ReadOnlyUser`, yalnızca verileri okuyabilen kullanıcıyı temsil etmektedir.

Atanan rol:
- `db_datareader`

Bu kullanıcı tüm tablolarda `SELECT` işlemi yapabilir; ancak veri değiştirme yetkisi yoktur.

### 5.3 HRUser

`HRUser`, sınırlı erişime sahip kullanıcı senaryosunu temsil etmektedir.

Bu kullanıcıya:
- `Departments` tablosunda `SELECT`
- `Employees` tablosunda `SELECT`

yetkisi verilmiştir.

Ancak:
- `Payroll` tablosunda `SELECT` yetkisi **özellikle engellenmiştir**.

Bu sayede maaş ve banka hesabı gibi hassas verilerin belirli kullanıcılardan gizlenmesi sağlanmıştır.

## 6. Yetki Testleri

Kullanıcı yetkilerinin gerçekten çalıştığını doğrulamak için `EXECUTE AS USER` komutuyla testler yapılmıştır.

### ReadOnlyUser Testi

`ReadOnlyUser` ile yapılan testlerde:
- `Departments` tablosu görüntülenmiştir
- `Employees` tablosu görüntülenmiştir
- `Payroll` tablosu görüntülenmiştir

Bu sonuç beklenen bir durumdur, çünkü `ReadOnlyUser` tüm tabloları okuma yetkisine sahiptir.

### HRUser Testi

`HRUser` ile yapılan testlerde:
- `Departments` tablosu görüntülenmiştir
- `Employees` tablosu görüntülenmiştir
- `Payroll` tablosu sorgulanmaya çalışıldığında izin hatası alınmıştır

Bu hata, sistemin doğru şekilde çalıştığını göstermektedir. Yani `HRUser` kullanıcısı hassas verilere erişememektedir.

## 7. View Kullanılarak Güvenli Veri Sunumu

Hassas veri erişimini doğrudan tablo bazında açmak yerine, kullanıcıya güvenli bir görünüm üzerinden veri sunulması daha doğru bir yöntemdir.

Bu amaçla projede `vw_EmployeePublicInfo` adında bir view oluşturulmuştur.

Bu view içinde şu alanlar yer almaktadır:
- EmployeeID
- FirstName
- LastName
- DepartmentName
- Email

Dikkat edilirse bu view içinde:
- maaş
- bonus
- banka hesap bilgisi

yer almamaktadır.

Bu view üzerinde `HRUser` kullanıcısına `SELECT` yetkisi verilmiştir. Böylece HRUser kullanıcıları çalışan bilgilerini görebilirken, maaş bilgilerine doğrudan erişememektedir.

Bu yöntem, gerçek hayatta da sık kullanılan bir veri güvenliği yaklaşımıdır.

## 8. SQL Injection Riski ve Güvenli Sorgu Yaklaşımı

Projede güvenlik başlığının önemli bir parçası olarak SQL injection riski de gösterilmiştir.

İki farklı örnek hazırlanmıştır:

### 8.1 Güvensiz Dinamik SQL Örneği

İlk örnekte kullanıcıdan gelen veri doğrudan sorgu metnine eklenmiştir. Girdi olarak:

`' OR 1=1 --`

benzeri bir ifade kullanıldığında, sorgunun tüm çalışan kayıtlarını döndürebildiği gösterilmiştir.

Bu, SQL injection riskini temsil etmektedir. Çünkü kullanıcı girişi güvenli şekilde ele alınmamış, doğrudan sorguya yapıştırılmıştır.

### 8.2 Güvenli Parametreli Sorgu

İkinci örnekte aynı mantık `sp_executesql` ve parametreli sorgu kullanılarak yazılmıştır.

Bu yaklaşımda kullanıcıdan gelen veri sorgu metnine doğrudan eklenmemiştir. Bunun sonucu olarak aynı zararlı girdi bu kez sistemi kandıramamış, sorgu normal ve güvenli şekilde çalışmıştır.

Bu bölüm projenin en önemli güvenlik derslerinden birini göstermektedir:
- dinamik SQL dikkat gerektirir
- parametreli sorgu daha güvenlidir

## 9. Audit / Log Yaklaşımı

Tam SQL Server Audit yapılandırması yerine, öğrenci projesi seviyesinde anlaşılır ve uygulanabilir bir çözüm olarak `AccessAuditLog` adında bir log tablosu oluşturulmuştur.

Bu tablo aşağıdaki alanları içermektedir:
- `UserName`
- `ActionType`
- `TableName`
- `ActionTime`

Örnek kayıtlar üzerinden:
- `AdminUser` kullanıcısının `Payroll` tablosunu sorgulaması
- `ReadOnlyUser` kullanıcısının `Employees` tablosunu sorgulaması
- `HRUser` kullanıcısının `Payroll` tablosunda engellenen erişim denemesi

gösterilmiştir.

Bu yöntem tam kapsamlı bir güvenlik izleme sistemi değildir; ancak kullanıcı işlemlerini kayıt altına alma mantığını göstermek için uygun bir örnektir.

## 10. Kullanılan SQL Dosyaları

Projede kullanılan SQL dosyaları aşağıdaki gibidir:

- `01_create_database.sql`
- `02_create_tables_and_data.sql`
- `03_users_and_roles.sql`
- `04_permission_tests.sql`
- `05_secure_view.sql`
- `06_sql_injection_demo.sql`
- `07_audit_log_demo.sql`

Bu dosyalar veritabanı oluşturma, veri ekleme, kullanıcı ve rol tanımlama, yetki testleri, güvenli görünüm oluşturma, SQL injection gösterimi ve audit/log örneğini içermektedir.

## 11. Ekran Görüntüleri ve Kanıtlar

Proje boyunca şu tür ekran görüntüleri alınmıştır:

- tablo ve örnek veri oluşturma
- kullanıcı ve rol tanımlama
- yetki testleri
- güvenli view kullanımı
- SQL injection örneği
- audit log tablosu sonuçları

Bu ekran görüntüleri hem raporun destekleyici kanıtları olarak hem de GitHub deposundaki `screenshots` klasöründe kullanılmaktadır.

## 12. Karşılaşılan Hatalar ve Gözlemler

Bu projede büyük teknik hatalardan çok, güvenlik mantığını doğrulayan gözlemler öne çıkmıştır.

### 12.1 Yetki reddi

`HRUser` kullanıcısının `Payroll` tablosuna erişmeye çalışırken hata alması, sistemin beklenen şekilde çalıştığını göstermiştir. Bu durum hata gibi görünse de aslında güvenlik kuralının başarıyla uygulandığını kanıtlamaktadır.

### 12.2 SQL injection davranışı

Güvensiz dinamik SQL örneğinde kullanıcı girdisinin sorgu yapısını bozabildiği görülmüştür. Aynı senaryonun parametreli sürümünde ise bu davranışın ortadan kalktığı gözlemlenmiştir.

Bu iki örnek birlikte değerlendirildiğinde güvenli sorgu yazımının önemini açık biçimde göstermektedir.

## 13. Sonuç

Bu projede SQL Server üzerinde veritabanı güvenliği ve erişim kontrolü konusu uygulamalı olarak gösterilmiştir.

Kullanıcı ve rol yönetimi ile farklı yetki seviyeleri oluşturulmuş, hassas veri içeren `Payroll` tablosu belirli kullanıcılardan korunmuş, view kullanımıyla güvenli veri sunumu sağlanmış ve SQL injection riskine karşı güvenli sorgu yaklaşımı örneklenmiştir.

Ayrıca basit bir audit/log tablosu ile kullanıcı işlemlerinin kayıt altına alınması mantığı da gösterilmiştir.

Sonuç olarak, veritabanı güvenliğinde yalnızca kullanıcı oluşturmak yeterli değildir. Yetkilerin dikkatli tanımlanması, hassas verinin sınırlandırılması, güvenli sorgu yazımı ve erişim hareketlerinin izlenmesi birlikte ele alınmalıdır.