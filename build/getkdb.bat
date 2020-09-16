conda install -c kx embedPy
mkdir q
copy -r %conda info --base%/q q
conda info --base
echo|set /P =%QLIC_KC% >q\kc.lic.enc
certutil -decode q\kc.lic.enc q\kc.lic
set QHOME=%cd%\q
set PATH=%QHOME%\w64;%PATH%
echo show .z.K;show .z.k;exit 0 | q -q
