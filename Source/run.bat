set PATH=%cd%/../Project
cd ../../Godot/bin
for %%i in (*.exe) do (
	start /b /wait %%i -e --path %PATH%
	exit
)
