#event capture
event captureは収集した情報をGoogleカレンダーに登録するツールです。  
***

###アカウント情報の設定
config/gcal.sample.ymlをgcal.ymlに、config/twitter.sample.ymlをtwitter.ymlにリネームします。  
そこにGoogleカレンダー、Twitterのアカウント情報を記述します。

###Heroku環境変数に登録

    $> rake heroku_env

###実行時間または時刻を設定
config/clock.ymlに実行する時間または時刻を設定します。  
####全てのモジュール共通
    default="19:00"
####モジュールごと個別
    module_name="8:45"

###プロセスを起動

    $> heroku scale clock=1

##License
Licensed under the MIT
http://www.opensource.org/licenses/mit-license.php