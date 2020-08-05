call tar.exe -acf a327ex.zip a327ex/* *.lua
rename a327ex.zip a327ex.love
copy /b "love\/love.exe"+"a327ex.love" "love\/a327ex.exe"
del "a327ex.love"
