# PHS着信時電波を検出してIRC通知
[PHS着信時電波を検出してIRC通知するデバイス(mbed LPC1768版)](http://developer.mbed.org/users/deton/code/PhsRingNotify/)
を、Intel Edison + Arduino Boardや
Linino ONE(Maker Faire Tokyo 2014で購入)に移植したものです。

自分の構内PHSに着信があった時に気づくための用途だけでなく、
[予定通知ボット](https://github.com/deton/ExchangeAppointmentBot)と連携して、
近くの人の構内PHS着信時にその人の予定をIRCに流す用途でも使えます。

# Intel Edison + Arduino Board版(phsringnotify.py)
ADCを使うのでArduino Boardを使用。mraaライブラリを使用。

phsringnotify.serviceファイルは、自動起動用設定ファイルです。
/etc/systemd/systemにコピーして、`systemctl enable phsringnotify`

# Linone ONE版(phsringnotify.lua)
デフォルトで入っていたluaとnixioライブラリを使用。

## [Linino ONE](http://www.linino.org/modules/linino-one/)について
[Arduino Yun](http://arduino.cc/en/Guide/ArduinoYun)を小さくしたもの。

Arduino用マイコン(ATmega32u4, lininoのドキュメントではMCU)と、
Linux(OpenWrt)用PC(Atheros AR9331, MIPS)が載っていて、WiFi接続可能。

+ WiFi接続可能。技適取得済。
+ IOがArduinoと同じ5V。Edisonの1.8Vよりも扱いやすい。
+ アナログ入力(ADC)あり。(BeagleBone Blackのように1.8Vという制限無し。
  EdisonだとArduinoボードが必要。Raspberry Piにはアナログ入力無し。)
+ Arduino用スケッチもマイコン上でそのまま動作可能なので、
  Arduino用ライブラリも使用可能。
  NeoPixelのLEDリボン等、
  タイミングの制御が必要なためLinuxでは制御しにくいデバイスも使いやすい。

おそらく、MIPS側でArduino Yun相当のLininoOSを動かせば、ArduinoからWiFiの利用可。
ただし、最初から入っていたのは、LininoIOで、
これだとArduino側からYunClientを使ってみたが動作しない模様。

LininoIOでは、Linux側でプログラムを動作させる想定の模様。
lininoのサイトではnode.jsの例が挙げられているが、
ストレージの空きが5MB程度しかないので、
拡張ボードによりmicroSDにインストールして使う形。
それ以外には、Python 2.7とLua 5.1が入っているのでpythonかluaで書く形。
(もしくは、MIPS用のクロスコンパイラをlininoのサイトからダウンロードして
C言語等で書く。)

### Linino ONEでのWPA2 Enterpriseへの接続方法
http://forum.arduino.cc/index.php?topic=197267.msg1463424#msg1463424

この設定後、設定したWiFi APに、再起動後も接続されるように、
/etc/config/wirelessと同様の設定を/etc/config/arduinoにも行う必要がある模様。

```
uci set arduino.@wifi-iface[0].mode=sta
uci set arduino.@wifi-iface[0].ssid=MySSID
uci set arduino.@wifi-iface[0].identity=ユーザID
uci set arduino.@wifi-iface[0].password=パスワード
uci set arduino.@wifi-iface[0].encryption=mixed-wpa+aes
uci set arduino.@wifi-iface[0].eap_type=peap
uci commit arduino
```
