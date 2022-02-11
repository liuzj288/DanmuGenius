curl -L -o version.temp https://raw.githubusercontent.com/liuzj288/DanmuGenius/master/version.txt
set /p version_old=<version.txt && set /p version_new=<version.temp
if %version_old%==%version_new% echo 1 || echo DanmuGenius已更新至%version_new% && start https://github.com/liuzj288/DanmuGenius



pause