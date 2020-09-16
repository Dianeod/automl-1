conda install -c kx embedPy
mkdir q
dir C:\Miniconda3-x64\q
xcopy C:\Miniconda3-x64\q q
echo|set /P =%QLIC_KC% >q\kc.lic.enc
certutil -decode q\kc.lic.enc q\kc.lic
set QHOME=%cd%\q
set PATH=%QHOME%\w64;%PATH%
echo show .z.K;show .z.k;exit 0 | q -q
