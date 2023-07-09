set /p CONFIG=<build_config.txt
cd ../../Godot/
scons %CONFIG%
exit