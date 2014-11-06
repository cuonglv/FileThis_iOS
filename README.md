# FileThis iOS ReadMe

## Release Notes

### 1.0(38) FileThis Fetch
Shipping version.

### v1.2(8)
- "Add Connection" is now implemented on iPhone.
- Implement Connection settings.
- "Add New Connection" is last row in table.
- only show 4 columns across in Add Connections window on iPad.
- add cancel to Add popover
- change "Back" to Cancel
- clean up accessory icons.
- search - new & popular filter
- Edit Connection


### TODO
- BUG: connection list doesn't update after editting name
- Forgot Password button
- Display progress spinner when logging in.
- Move Logout into Settings
- Help/Contact Us
- Add Terms of Use / EULA to Settings
- Add Privacy Policy to Settings
- Add Share our App to Settings
- Settings: move version into footer at bottom (ala Manilla)

Connections disabled badge
Institutions disabled bad


###Startup
A session object (FTSession) is created at startup.
A ticket is stored in this session object when the user successfully logs in. This ticket is sent along with all the requests (except for images).

After the session object is created, the server requests are made to fetch institutions, connections, and questions.

When the questions list is returned, the connection objects are updated, and the connections table refreshed.




##How version numbers are set

- Version numbers are determined by the CFBundleShortVersionString and CFBundleVersion keys in the Info.plist.

- If the CFBundleShortVersionString exists, we use it as the main version number with CFBundleVersion as the build. For example, if CFBundleShortVersionString = 1.0.0 and CFBundleVersion is 223 the version will appear as 1.0.0 (223).

- If the CFBundleShortVersionString does not exist, we use the CFBundleVersion as the main version number.

- Should you upload an IPA with a version that already exists, we append the #x to create a unique version number.



## PROGRAM FLOW
1. Boot -
a. passcode?
b. Login?
c. 
   entery
   4.




## Apple Store Purchases

- Test in-app purchases using a test user account.
- Create test users at https://itunesconnect.apple.com.
- password is Filethis with a capital initial letter and l33t digits for vowels.


Test accounts
FileThis users
filethisfetchdrew@ymail.com
filethisdrew@ymail.com
drew@filethis.com


iTunes Connect test users

"filethisfetchdrew@ymail.com@integration.filethis.com" =     {
    password = 123456a;
    username = "filethisfetchdrew@ymail.com";
};
loginName = "filethisfetchdrew@ymail.com@integration.filethis.com";
ticket = ScuWDB90I9iSLeoXCVY9y8yGlfu;
}


## Custom build steps

We have a post-action in our Archive step.




## Misc Notes

URL	https://staging.filethis.com/ftapi/ftapi?jsonp=jQuery1620411283269058913_1352846335218&first=Drew&last=Wilson&email=drewmwilson%40me.com&password=ella1997&create-password-repeat=ella1997&terms-of-service=on&op=webnewaccount&type=conn&_=1352846353818
Status	Complete
Response Code	200 OK
Protocol	HTTP/1.1
Method	GET
Kept Alive	Yes
Content-Type	application/jsonp
Client Address	/127.0.0.1
Remote Address	staging.filethis.com/173.203.112.186
Timing	
Request Start Time	11/13/12 2:39:13 PM
Request End Time	11/13/12 2:39:13 PM
Response Start Time	11/13/12 2:39:14 PM
Response End Time	11/13/12 2:39:14 PM
Duration	166 ms
DNS	-
Connect	-
SSL Handshake	-
Request	0 ms
Response	3 ms
Latency	142 ms
Speed	9.04 KB/s
Response Speed	137.04 KB/s
Size	
Request Header	1.09 KB (1115 bytes)
Response Header	188 bytes
Request	-
Response	233 bytes
Total	1.50 KB (1536 bytes)
Request Compression	-
Response Compression	-




jsonp	jQuery1620411283269058913_1352846335218
first	Drew
last	Wilson
email	drewmwilson@me.com
password	ella1997
create-password-repeat	ella1997
terms-of-service	on
op	webnewaccount
type	conn
_	1352846353818


https://staging.filethis.com/ftapi/ftapi?jsonp=jQuery1620411283269058913_1352846335219&first=Drew&last=Wilson&email=drewmwilson%40mailinator.com&password=ella1997&create-password-repeat=ella1997&terms-of-service=on&op=webnewaccount&type=conn&_=1352846473358

jQuery1620411283269058913_1352846335219({
    "id":350,
    "result":"OK"
})




Now you just need to activate your account by clicking on the following link: 

https://staging.filethis.com/ftapi/ftapi?op=accountVerify&accountId=350&verifyCode=v8389a93e48114551ff891c089da8dae8f6b83972

If clicking on the link doesn't work, you can copy the link out of this email and paste it into the address bar of your web browser. 




id	19823X771710
xs	1
url	https://staging.filethis.com/ftapi/ftapi?op=accountVerify&accountId=350&verifyCode=v8389a93e48114551ff891c089da8dae8f6b83972
sref	http://www.mailinator.com

op	accountVerify
accountId	350
verifyCode	v8389a93e48114551ff891c089da8dae8f6b83972

HTTP/1.1 302 Moved Temporarily
Server	nginx/0.7.67
Date	Tue, 13 Nov 2012 22:43:27 GMT
Connection	close
Location	http://staging.filethis.com/fetch/login
Content-Length	0

