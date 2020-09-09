@echo on & setlocal enabledelayedexpansion
:: Phantombot Update for Windows by InviSan
:: v0.1


:: Get Variables from config

set cfg=%1
if [%1]==[] set cfg=sample.cfg

for /F "tokens=2 delims==" %%a in ('findstr /I "home" %cfg%') do set "phome=%%a"
for /F "tokens=2 delims==" %%a in ('findstr /I "path" %cfg%') do set "ppath=%%a"
for /F "tokens=2 delims==" %%a in ('findstr /I "build" %cfg%') do set "pbuild=%%a"
for /F "tokens=2 delims==" %%a in ('findstr /I "port" %cfg%') do set "pport=%%a"
for /F "tokens=2 delims==" %%a in ('findstr /I "service" %cfg%') do set "pservice=%%a"

set phome=%phome:~1,-1%
set ppath=%ppath:~1,-1%
set pbuild=%pbuild:~1,-1%
set pport=%pport:~1,-1%
set pservice=%pservice:~1,-1%

echo This is your home Folder: %phome%
echo This is your path: %ppath%
echo This is your chosen build: %pbuild%
echo This is your chosen port: %pport%
echo This is the Service Setting: %pservice%

:main
:: Get Newest Version Number
if [%pbuild%]==[stable] curl -o build.xml --url "https://raw.githubusercontent.com/PhantomBot/PhantomBot/master/build.xml"
if [%pbuild%]==[pbotde] curl -o build.xml --url "https://raw.githubusercontent.com/PhantomBotDE/PhantomBotDE/master/build.xml"
if [%pbuild%]==[nightly] curl -o build.xml --url "https://raw.githubusercontent.com/PhantomBot/nightly-build/master/last_repo_version"
goto versioncheck

:versioncheck
:: Get Version from installed PhantomBot 
:: Copy PhantomBot.jar to get MetaInfo
xcopy %ppath%\PhantomBot.jar /C /Y /R
:: Rename jar to zip to extract it with Powershell
rename PhantomBot.jar PhantomBot.zip
:: Extract content of Jar to get access to MetaInfo File
powershell.exe Expand-Archive -LiteralPath "PhantomBot.zip" -DestinationPath "extracted" -Force
:: check if Nightly or not and set Rev or Version for Meta Check
if [%pbuild%]==[nightly] set "pvar=Revision"
if NOT [%pbuild%]==[nightly] set "pvar=Version"
:: Read current Version/Revision from Manifest File
for /F "tokens=2 delims=: " %%a in ('findstr /I "Implementation-%pvar%" extracted\META-INF\MANIFEST.MF') do set "pcurver=%%a"
:: If the Build is nightly read the Implementations-Revision directly from build.xml
if [%pbuild%]==[nightly] set /p pnewver=<build.xml
if [%pbuild%]==[nightly] goto checkver
:: If the Build is non nightly use findstr to get the Version
for /F "tokens=5 delims== " %%a in ('findstr /I "name=.version..value=" build.xml') do set pnewver=%%a
:: Remove quotes from the Variable.
set pnewver=%pnewver:"=%
:: Goto Version Check.
goto checkver

:checkver
:: This is for the nightly Build
:: Check if both Revisions/Versions are the same. If not download new Version. Else Skip.
if [%pnewver%]==[%pcurver%] goto skip
goto download


:download
:: Different Version on the Web. Downloading.
if [%pbuild%]==[stable] curl -o bot.zip --url "https://github.com/PhantomBot/PhantomBot/releases/download/v%pnewver%/PhantomBot-%pnewver%-win.zip"
if [%pbuild%]==[pbotde] curl -o bot.zip --url "https://github.com/PhantomBotDE/PhantomBotDE/releases/download/v%pnewver%/PhantomBotDE-%pnewver%.zip"
if [%pbuild%]==[nightly] curl -o bot.zip --url "https://github.com/PhantomBot/nightly-build/raw/master/PhantomBot-nightly-lin.zip"

:skip
:: No New Version found. Restarting Bot.




