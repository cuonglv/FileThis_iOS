FUTURE TODOs
Hook up Passcode UI
Only update connections from ConnectionView controller


- login requests (institutions), connections, (destinations), and current destination, but doesn't block.
  don't check connections, or current destination at login

1. Queue transactions in AppleStoreObserver.
   store to disk... continue posting to filethis.com until complete.
2. redo login
   lazy fetch connections, institutions, current destination, destinations...
3. save institutions and destinations across restarts.



TODO:
get Q&A working...
Hook up Passcode UI
Logos
Destination - 
Handle timeout.
Display order of destinations using ordinal field.
- Forgot Password link

Handle server response:
Once in DestError state, everything should popup dialog.
"Destination Needs Attention" state

Destination UI

Status: "Ready to receive documents" | "Needs your attention"
Connected as xxx@xx

Connected as First Last (e.g. Box)
Google provides photos



PERSONAL - company doesn't disclose username.


 public static const STATE_NONE:String = "none";
 public static const STATE_READY:String = "redy";
 public static const STATE_WAIT_USER_AUTHORIZE:String = "auth";
 public static const STATE_ERROR:String = "erro";

 public static const ERROR_NONE:String = "none";
 public static const ERROR_AUTH_INVALID:String = 'ainv';
 public static const ERROR_AUTH_EXPIRED:String = 'aexp';
 public static const ERROR_NOT_PERMITTED:String = 'nper';
 public static const ERROR_QUOTA_EXCEEDED:String = 'qexc';
 public static const ERROR_UNEXPECTED:String = 'unex';





3/12/2013 Discussion with Brian
Startup screen should fade to login
  - with FileThis Fetch logo
  
Change Connection Status to UILabel.

Overhaul Destination UI
   display account name
   display status


- display institution's name as proxy
add name and use smaller icon for institution proxy
fade in image when loaded




weblogin
destinationlist
institutionlist
connlist
dstconnlist


op=dstconnlist
https://filethis.com/ftapi/ftapi?op=dstconnlist&flex=true&json=true&compact=true&ticket=VxVRN4W7GJ72n5BxBWhxq2Yn34m




op=connecttodestination

Connect to Destination after creating new account...

https://staging.filethis.com/ftapi/ftapi?op=connecttodestination&flex=true&json=true&compact=true&id=4&browseable=false&ticket=eLVoEBtNJ6Gh9eB1YuOIP05bJep

op	connecttodestination
flex	true
json	true
compact	true
id	4
browseable	false
ticket	eLVoEBtNJ6Gh9eB1YuOIP05bJep


returnValue	String	https://www.dropbox.com:443/1/oauth/authorize?oauth_token=54dxhm9bskvv1wb&oauth_callback=https%3A%2F%2Fstaging.filethis.com%2Fftapi%2Fftapi%3Fop%3Ddropbox%26aid%3D407%26ticket%3DeLVoEBtNJ6Gh9eB1YuOIP05bJep&locale=en


Destination List
https://staging.filethis.com/ftapi/ftapi?op=destinationlist&flex=true&json=true&compact=true&ticket=eLVoEBtNJ6Gh9eB1YuOIP05bJep


{"destinations":[{"id":2,"type":"locl","state":"live","name":"FileThis DeskTop","provider":"this","url":"http:\/\/filethis.com\/","logoPath":"logos\/Logo_FileThisDesktop.png"},{"id":3,"type":"conn","state":"live","name":"Evernote","provider":"ever","url":"https:\/\/www.evernote.com\/Home.action","logoPath":"logos\/Logo_Evernote.png"},{"id":4,"type":"conn","state":"live","name":"Dropbox","provider":"drop","url":"http:\/\/www.dropbox.com\/","logoPath":"logos\/Logo_Dropbox.png"},{"id":6,"type":"conn","state":"live","name":"Box","provider":"box ","url":"http:\/\/box.com\/","logoPath":"logos\/Logo_Box.png"},{"id":7,"type":"conn","state":"live","name":"Fake","provider":"fake","url":"http:\/\/filethis.com\/","logoPath":"logos\/Logo_FakeBox.png"},{"id":8,"type":"conn","state":"live","name":"Google Drive","provider":"gdrv","url":"https:\/\/drive.google.com\/start#home","logoPath":"logos\/Logo_GoogleDrive.png"},{"id":11,"type":"conn","state":"live","name":"Personal","provider":"pers","url":"https:\/\/personal.com","logoPath":"logos\/Logo_Personal.png"}]}


destinations	Array	
[0]	Object	
id	Integer	2
type	String	locl
state	String	live
name	String	FileThis DeskTop
provider	String	this
url	String	http://filethis.com/
logoPath	String	logos/Logo_FileThisDesktop.png
[1]	Object	
id	Integer	3
type	String	conn
state	String	live
name	String	Evernote
provider	String	ever
url	String	https://www.evernote.com/Home.action
logoPath	String	logos/Logo_Evernote.png
[2]	Object	
id	Integer	4
type	String	conn
state	String	live
name	String	Dropbox
provider	String	drop
url	String	http://www.dropbox.com/
logoPath	String	logos/Logo_Dropbox.png
[3]	Object	
[4]	Object	
[5]	Object	
[6]	Object	




op=connlist

/ftapi/ftapi?op=connlist&flex=true&json=true&compact=true&ticket=eLVoEBtNJ6Gh9eB1YuOIP05bJep

connections	Array	
[0]	Object	
id	Integer	1
destinationId	Integer	4
name	String	Dropbox
type	String	conn
state	String	auth
error	String	none
browseable	Boolean	false

{"connections":[{"id":1,"destinationId":4,"name":"Dropbox","type":"conn","state":"auth","error":"none","browseable":false}]}


op	connecttodestination
flex	true
json	true
compact	true
id	4
browseable	false
ticket	eLVoEBtNJ6Gh9eB1YuOIP05bJep




op	profilelist
{"accountId":54,"profiles":[{"id":2256,"name":"American Express Platinum Card -61000","templateId":17,"connectionId":"2035","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":2259,"name":"American Express Costco TrueEarnings Card -11008","templateId":17,"connectionId":"2035","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":2262,"name":"AT&T Wireless 287247021045","templateId":18,"connectionId":"","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Utility\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Utility\"\n\t\t}\n\t}\n}\n"},{"id":2906,"name":"Bank of America Alaska Airlines Signature Visa - 5154","templateId":17,"connectionId":"","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":2909,"name":"Bank of America Alaska Airlines Business Visa - 2572","templateId":17,"connectionId":"","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3227,"name":"Amazon Orders","templateId":17,"connectionId":"1981","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3227,"name":"Amazon Orders","templateId":17,"connectionId":"1987","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3227,"name":"Amazon Orders","templateId":17,"connectionId":"1990","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3227,"name":"Amazon Orders","templateId":17,"connectionId":"1993","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3227,"name":"Amazon Orders","templateId":17,"connectionId":"2032","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3227,"name":"Amazon Orders","templateId":17,"connectionId":"2050","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3227,"name":"Amazon Orders","templateId":17,"connectionId":"2053","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3658,"name":"Wells Fargo CHECKING XXXXXX7492","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3661,"name":"Wells Fargo Ellas Checking XXXXXX1190","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3664,"name":"Wells Fargo ZACH CHK XXXXXX6688","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3667,"name":"Wells Fargo Sitka XXXXXX1332","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3670,"name":"Wells Fargo WebFlow XXXXXX2744","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3673,"name":"Wells Fargo Ella Saving XXXXXX5056","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3676,"name":"Wells Fargo Our Savings XXXXXX5469","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3679,"name":"Wells Fargo Zack's Savings XXXXXX0755","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3682,"name":"Wells Fargo Zach Minor XXXXXX8937","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3685,"name":"Wells Fargo Tahvo's XXXXXX8952","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3688,"name":"Wells Fargo Esme's XXXXXX8960","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3691,"name":"Wells Fargo VISA XXXX-XXXX-XXXX-0443","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3694,"name":"Wells Fargo WF HOME EQUITY ACCT XXX-XXX6777-1998","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3697,"name":"Wells Fargo FIXED RATE ADV XXX-XXX6777-1001","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3700,"name":"Wells Fargo MORTGAGE XXXXXX0486","templateId":17,"connectionId":"2179","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3703,"name":"Charles Schwab Gaby's Roth IRA 1273-1672","templateId":17,"connectionId":"","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3706,"name":"Charles Schwab Main 2216-6077","templateId":17,"connectionId":"","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3709,"name":"Charles Schwab Drew's Roth IRA 6541-5601","templateId":17,"connectionId":"","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3712,"name":"Charles Schwab Rollover IRA 9407-6110","templateId":17,"connectionId":"","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3715,"name":"Charles Schwab Old Original 9453-5722","templateId":17,"connectionId":"","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":3718,"name":"Charles Schwab Custodial 9478-0355","templateId":17,"connectionId":"","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"},{"id":4297,"name":"New York Times 892181397","templateId":18,"connectionId":"","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Utility\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Utility\"\n\t\t}\n\t}\n}\n"},{"id":4306,"name":"ING Direct 118428091-eStatements","templateId":17,"connectionId":"","data":"{\n\t\"instanceData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"value\":\"\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t},\n\t\"version\":1,\n\t\"templateData\":\n\t{\n\t\t\"items\":\n\t\t{\n\t\t\t\"item\":\n\t\t\t[\n\t\t\t\t{\n\t\t\t\t\t\"id\":\"1\",\n\t\t\t\t\t\"type\":\"accountId\",\n\t\t\t\t\t\"label\":\"Account Number:\",\n\t\t\t\t\t\"prompt\":\"0000000000\"\n\t\t\t\t}\n\t\t\t]\n\t\t},\n\t\t\"classifyTags\":\n\t\t{\n\t\t\t\"classifyTag\":\"Financial\"\n\t\t}\n\t}\n}\n"}]}


op	dstconnlist
{"connections":
    [
        {"id":1,"destinationId":3,"name":"Evernote","type":"conn",
        "state":"redy","error":"none","browseable":false,"userName":"drewmwilson"}]}




My Connections -
Row indicators

Delete
- r.h.s. indicator in normal model: either refresh or fix-it buton
in edit mode:
- display institution logo
- Settings
 - all right-aligned or all left-aligned?
 - read-only settings left-aligned and writeable right-aligned

"Click here to Add New Connection"
  bold italic
  big green plus icon
  - swipe left to Add New Connection
  - swipe left to reveal Settings
  
My Connections
   make rows light blue

My Connections and Add Connection
   Background dark blue, foreground light blue

Add Connection popup
   wider, to display NOTE:
   e.g. T Row Price Retirement
   iPhone UI: display note in alert
   
   Clicking Cancel should stay on Add Connection page.

Ing Direct
  customer id: 118428091
  pin: 123457
  city born in: Johannesburg
  city that i met my spouse: San Rafael
  anniversary: 0984
  spouse's father's first name: Zohar
  first job: Motorola
  my oldest sibling's birthday: November 1958

Application Settings
- Remove Powered by InAppSettingsKit
- Member Since: don't include time

Settings UI
- light blue on dark blue background.

Destinations
- don't show FileThis for Mac desktop


##TODO
- select Destination, wizards
- clicking "Done" should act as Done in toolbar.
   1. in Q&A's keyboard
    see QuestionPanel's textFieldShouldReturn.
    Also - don't active Done until text fields are filled.
   2. in login page
- implement connection view's activity indicator as accessory view
   to avoid problems with incorrect horiz positioning.
- popup Q&A alert automatically, don't wait for accessory click.
- upgrades
- add destination setting to main app
- adopt http://cocoapods.org
- adopt https://github.com/afnetworking
- cleanup accessory icon view in connections list
- debug BofA registration, compare with flash
- handle "info" attribute - timeout (see BA timeout)
    /ftapi/ftapi?op=connlist&flex=true&json=true&compact=true&ticket=6f50eG7FBTGCt6yxdZ9SYtWIIsj
    {"connections":[{"id":2143,"state":"waiting","name":"Bank of America","institutionId":4,"username":"drewmwilson","attempt":1355516735,"checked":1354867200,"success":1354912264,"documentCount":1,"fetchAll":false,"info":"One or more of your documents may not have been fetched because Bank of America is temporarily unable to process the request.","retries":0,"enabled":true,"period":"1w"}]}
- help screen?
- automate build version bumping
 (ref http://stuff.bondo.net/post/7769890357/using-build-and-version-numbers-and-the-art-of)


##BUGS
- why are images served from https:// instead of http (test with Charles)

##DONE
- debug documents count
- renable Login button after getting error upon connect (e.g. no internet)
- resize institutions table when keyboard shows/hides.
- BUG: crash when deleting last connection
- implement new user registration
- fix size of Q&A window (need to move popover impelementation into ConnectionViewController and simplify QuestionsController)
- turn on network activity indicator per request
- purge institution icons after receiving low-memory warning
- fetch institution icons after receiving list of institutions
- cache institution list (using IF-LAST-MODIFIED)
- request responses to be compressed for less network traffic
- cache logos on disk and load from disk
- don't delete connection until we get back a 200 response
- display connection's institution logo in QuestionPanel.
- request questions after connections
- click on ? icon should start Q&A immediately, not request questions


 in-app shared secret
 
 c090b73a77774b87b0a46f1a9c009bed
 
