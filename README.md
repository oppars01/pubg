<a href="https://csgo-turkiye.com">![CS:GO Türkiye PUB-G](annen)</a>

# Description (Açıklama)

**[EN]** PUB-G Adaptation for CS:GO Game

It is an adaptation of PUB-G designed for use in jailbreak mods in the game "Counter-Strike: Global Offensive". The general purpose of the plugin is to allow the commanders or officials to play a PUB-G style game in one round.

--------------------
**[TR]** CS:GO Oyunu İçin PUB-G Uyarlaması

"Counter-Strike: Global Offensive" oyununda jailbreak modlarında kullanılmak için tasarlanmış bir PUB-G uyarlamasıdır. Eklentinin genel amacı komutçu veya yetkililerin bir roundda PUB-G tarzında bir oyun oynamalarını sağlamaktır.

# Setup (Kurulum)

**[EN]** Upload the given folders to the relevant fields on your CS:GO game server. After you have installed all the files completely, place the SQL setting below in the "csgo/addons/sourcemod/configs/databases.cfg" file. After the database connection is successful, it is enough to make the settings on the map where you will use the plugin.

**[TR]** Verilen klasörleri CS:GO oyun sunucunuza ilgili alanlara yükleyiniz. Tüm dosyaları eksiksiz yükledikten sonra aşağıda bulunan SQL ayarını "csgo/addons/sourcemod/configs/databases.cfg" dosyasına yerleştiriniz. Veritabanı bağlantısı başaralı olduktan sonra eklentiyi kullanacağınız haritada ayarları yapmanız yeterlidir.

```
"pubg"
{
	"driver"	"sqlite"
	"host"		"localhost"
	"database"	"pubg"
	"user"		"root"
	"pass"		""
	//"timeout"	"0"
	//"port"	"0"
}
```

# Settings (Ayarlar) [ cvar => csgo/cfg/CSGO_Turkiye/pubg.cfg ]

| cvar          | Default       | EN            | TR            |
| ------------- | ------------- | ------------- | ------------- |
| sm_pubg_tag | [PUB-G] | * Sets tags in messages.<br>* Maximum  Character Length: 64 | * Mesaj taglarını ayarlar.<br>* Maksimum Karakter Uzunluğu: 64 |
| sm_pubg_flags | b | * Authority flag.<br>* Set the commands with the **spacebar**.<br>* Root has automatic permission. You don't need to add.<br>* Maximum Character Length: 32 | * Yetki bayrağı.<br>* Komutları **boşluk** tuşuyla ayarlayın.<br>* Root'un otomatik izni vardır, eklemenize gerek yok.<br>* Maksimum Karakter Uzunluğu: 32 |
| sm_pubg_setting_commands | sm_pubgsetting sm_pubgayar | * Sets the commands for the setting menu.<br>* Set the commands with the **spacebar**.<br>* Maximum Total Character Length: 128<br>*  Max Command: 7<br>* Maximum Command Character Length: 20 | * Ayar menüsü için komutları ayarlar.<br>* Komutları **boşluk** ile ayarlayın.<br>* Maksimum Toplam Karakter Uzunluğu: 128<br>* Maksimum Komut: 7<br>* Maksimum Komut Karakter Uzunluğu: 20 |
| sm_pubg_main_commands | sm_pubg | * Sets the commands for the main menu.<br>* Set the commands with the **spacebar**.<br>* Maximum Total Character Length: 128<br>* Max Command: 7<br>* Maximum Command Character Length: 20 | * Ana menü için komutları ayarlar.<br>* Komutları **boşluk** ile ayarlayın.<br>* Maksimum Toplam Karakter Uzunluğu: 128<br>* Maksimum Komut: 7<br>* Maksimum Komut Karakter Uzunluğu: 20 |
| sm_pubg_team_commands | sm_pubgteam sm_pubgtakim | * Sets the commands for the team menu.<br>* Set the commands with the **spacebar**.<br>* Maximum Total Character Length: 128<br>* Max Command: 7<br>* Maximum Command Character Length: 20 | * Takım menü için komutları ayarlar.<br>* Komutları **boşluk** ile ayarlayın.<br>* Maksimum Toplam Karakter Uzunluğu: 128<br>* Maksimum Komut: 7<br>* Maksimum Komut Karakter Uzunluğu: 20 |
| sm_pubg_droptime | 15.0 | * Auto Drop Time. <br>* If the automatic drop status is active, it determines how many seconds the drop will drop from the start of the game. | * Otomatik Drop Zamanı.<br>* Otomatik Drop durumu aktif ise oyun başladıktan itibaren kaç saniyede bir drop düşeceğini belirler. |
|sm_pubg_team_waiting_time | 10 | * Team Waiting Time. <br>* The amount of time to wait to send a new team request after submitting a team request. | Takım Bekleme Süresi. <br>* Bir takım isteği gönderdikten sonra yeni bir ekip isteği göndermek için beklenecek süre. |

# Commands (Komutlar)

-  Setting Menu (Ayar Menüsü)

**[EN]** CVAR can be used with the command specified by sm_pubg_setting_commands. Only root users can use it. In order for the PUB-G game to work, the settings must be made on the current map. This command cannot be used while dead. You can add and delete new commands via this menu. With the options that are in the deletion process, you can easily delete only a specific location on the map or locations on a map that is not open.

**[TR]** CVAR sm_pubg_setting_commands tarafından belirlenen komut ile kullanılabilir. Sadece Root yetkisine sahip kullanıcılar kullanabilir. PUB-G oyunu çalışabilmesi için ayarların mevcut haritada yapılmış olması şarttır. Bu komut ölüyken kullanılamaz. Bu menü aracılığı ile yeni komunlar ekliyebilirsiniz ve silebilirsiniz. Silme işleminde olan seçenekler ile haritada sadece belirli bir konumu veya açık olmayan bir haritadaki konumları rahatlıkla silebilirsiniz.

- Main Game Menu (Ana Oyun Menüsü)

**[EN]** CVAR can be used with the command specified by sm_ pubg_main_commands. Only commanders and users with the authorization flag set with CVAR sm_pubg_flags can use it. With the weapon category divided into groups, the weapons that will be released from the safes can be adjusted. Teams can be turned off or allowed in the team option. Intra-team treason can be unlocked. When the game starts, this team can be exchanged if desired. Objects can be placed at some points to automatically kill players when the game starts via the automatic obstacle. These objects are created at a certain rate at drop locations. Even if it is open, luckily there may be no obstacles at all. With automatic drop, the safe is sent by drone at predetermined intervals. Those who have access to the menu can place the obstacle as a drop point or directly dorp when the game is active. PUB-G countdown is set to 30 seconds. After activation, it can be extended with +10 additional time. Also, amnesty can be given during this time. The forgiven player is automatically included in the game. The game can be ended or directly finished by specifying a certain time and gathering area for the game to end.

**[TR]** CVAR sm_pubg_main_commands tarafından belirlenen komut ile kullanılabilir. Sadece komutcular ve CVAR sm_pubg_flags ile ayarlanan yetki bayrağına sahip kullanıcılar kullanabilir. Gruplara ayrılmış silah kategorisi ile kasalardan çıkacak silahlar ayarlanabilir. Takım seçeneğinden takım olmalaları kapatılabilir veya izin verilebilir. Takım içi ihanet açılabilir. Oyun başladığında ise istenirse bu takım bozdurulur. Otomatik engel aracılığı ile oyun başladığında bazı noktalara otomatik oyuncu öldürmek için nesneler konulabilir. Bu nesneler drop konumlarında belirli bir oranda oluşturulur. Açık olsa bile şans eseri hiç engel olmayabilir. Otomatik drop ile daha önceden belirlenmiş aralıklarda drone ile kasa gönderililir. Menüye erişimi olanlar oyun aktif olduğunda engeli drop noktası  veya direk olarak dorp yerleştirebilir.  PUB-G geri sayımı 30 saniyeye ayarlıdır. Aktif edildikten sonra +10 ek zaman ile süresi uzatılabilir. Ayrıca bu süre içinde af verilebilir. Af verilen oyuncu otomatikmen oyuna dahil edilir. Oyunun bitmesi için belirli süre ve toplanma alanı belirterek oyun sonlandırılabilir veya direk olarak bitirilebilir.

- Team Menu (Takım Menüsü)

**[EN]** If the team is open in the PUB-G preparation screen, players in the T team can send team requests to their command teammates specified with CVAR sm_ pubg_team_commands. Once a request has been sent, it cannot send new requests for a predetermined period of time. If his request is approved, both players start the game in the same position.

**[TR]** PUB-G hazırlık ekranında takım açık ise T takımındaki oyuncular CVAR sm_pubg_team_commands ile belirtilmiş komut takım arkadaşlarına takım isteği gönderebilir. Bir kez istek gönderildikten sonra daha önceden belirlenen süre boyunca yeni istek gönderemez. İsteği onaylanır ise iki oyuncu da aynı konumda oyuna başlar.

# Planned Updates (Planlanan Güncellemeler)

- [ ] Air Strike (Hava Saldırısı)


> [CS:GO Türkiye | Türkiye'nin CS:GO Rehberi](https://csgo-turkiye.com/)
