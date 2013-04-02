## Step for connect Fat Free CRM and VoIP
Can be used with FeeSWITCH (mod\_cidlookup) or Asterisk FreePBX module ( CallerID Lookup ).
Provides the definition of the name or business name on a search by phone number in the database [Fat Free CRM](http://www.fatfreecrm.com/) (ffcrm).

### Attention! Requires patch ffsrm code too. Will be soon on github.

### installation
On PBX server. Install RVM, ruby 1.9.x.

```bash
gem install bundle
bundle install
shotgun config.ru
```
### Configure PBX

#### FreeSWITCH 
See [Mod cidlookup](http://wiki.freeswitch.org/wiki/Mod_cidlookup) for instructions.
Edit 'autoload_configs/cidlookup.conf.xml' with:
```bash
<param name="url" value="http://127.0.0.1:9393/?number=${caller_id_number}"/>
```
Make changes in dialplan for cidlookup. See [Mod cidlookup](http://wiki.freeswitch.org/wiki/Mod_cidlookup). 
And testing with fs_cli:
```bash
cidlookup status|number
```
#### Asterisk
Install moduleCallerID Lookup. 
Select FreePBX --> Admin --> Caller ID Lookup source. Add source "ffcrm" with:

* Source type --> HTML
* Host --> 127.0.0.1
* Port 9393
* Query --> number=[NUMBER] 

#### app.rb

Set own data for connect to ffcrm DB. See db_*

### Testing
Install console browser on server. Lynx for example.
Request like this can help test without PBX.
```bash
lynx "127.0.0.1:9393/?number=7968866XXXXXX"
```
Where 7968866XXXXXX -- phone number in ffcrm DB.

### Additional
See code in app.rb

* remove leading 0 -- before searching
* remove local country code -- before searching
* search phone in order: accounts, clients, leds and users
* output name and etc in translit -- work for russian and latvian languages, becauce most phones don't work with utf-8
