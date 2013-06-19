:: This is a helper script for fast executing of NookTouchPatches 
:: see https://github.com/doozan/NookTouchPatches for details
:: For script to work, you should rename your original JAR files adding ".orig" before .jar:
::   android.policy.jar => android.policy.orig.jar
::   android.policy.jar => android.policy.orig.jar

@echo off

:: Safety check
IF NOT EXIST android.policy.orig.jar (
  ECHO android.policy.orig.jar not found! You are likely forgot to rename original JAR file. Please rename it to android.policy.orig.jar
  goto :Err
)
IF NOT EXIST services.orig.jar (
  ECHO services.orig.jar not found! You are likely forgot to rename original JAR file. Please rename it to services.orig.jar
  goto :Err
)

:: Remove previous jars for a clean process
del android.policy.jar 2> nul
del services.jar 2> nul

:: Extract and patch android.policy.jar
java -jar baksmali.jar -o android.policy android.policy.orig.jar & ^
patch -p1 < android.policy.patch
if errorlevel 1 goto :Err

:: Compile new android.policy.jar
7za.exe e android.policy.orig.jar  -oandroid.policy-bin & ^
java -jar smali.jar -o android.policy-bin\classes.dex android.policy
if errorlevel 1 goto :Err
cd android.policy-bin
..\7za.exe a -mx9 -tzip ..\android.policy.jar *
cd ..
:: Cleanup
rd /Q/S android.policy-bin
rd /Q/S android.policy

:: Extract and patch services.jar
java -jar baksmali.jar -o services services.orig.jar & ^
patch -p1 < services.patch
if errorlevel 1 goto :Err

:: Compile new services.jar
7za.exe e services.orig.jar  -oservices-bin & ^
java -jar smali.jar -o services-bin\classes.dex services
if errorlevel 1 goto :Err
cd services-bin
..\7za.exe a -mx9 -tzip ..\services.jar *
cd ..
:: Cleanup
rd /Q/S services-bin
rd /Q/S services

echo Everything seem to be fine, now push services.jar and android.policy.jar to your Nook
goto :EOF

:Err
pause