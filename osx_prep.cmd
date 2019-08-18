@echo OFF
REM based on https://toster.ru/q/658285
REM see also https://github.com/DrDonk/unlocker
PATH=%PATH%;"C:\Program Files\Oracle\VirtualBox"
SET BOXNAME=%1
"VBoxManage" modifyvm %BOXNAME% --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff
"VBoxManage" setextradata %BOXNAME% "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
"VBoxManage" setextradata %BOXNAME% "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
"VBoxManage" setextradata %BOXNAME% "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Iloveapple"
"VBoxManage" setextradata %BOXNAME% "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
"VBoxManage" setextradata %BOXNAME% "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1
"VBoxManage" setextradata %BOXNAME% "VBoxInternal2/EfiGraphicsResolution" "1842x1026"
