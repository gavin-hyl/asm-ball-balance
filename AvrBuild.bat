@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "U:\gavinhua\ee10b-hw5\labels.tmp" -fI -W+ie -o "U:\gavinhua\ee10b-hw5\ee10b-hw5.hex" -d "U:\gavinhua\ee10b-hw5\ee10b-hw5.obj" -e "U:\gavinhua\ee10b-hw5\ee10b-hw5.eep" -m "U:\gavinhua\ee10b-hw5\ee10b-hw5.map" "U:\gavinhua\ee10b-hw5\test.asm"
