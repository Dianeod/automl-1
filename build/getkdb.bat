wget --user-agent Mozilla/5.0 %W64%
mkdir q
7z x w64.zip -oq
echo|set /P =%QLIC_KC% >q\kc.lic.enc
certutil -decode q\kc.lic.enc q\kc.lic
set QHOME=%cd%\q
set PATH=%QHOME%\w64;%PATH%
echo show .z.K;show .z.k;exit 0 | q -q
