build_js: coffee/*
	coffee -c -o js coffee

continuously:
	coffee -c -w -o js coffee

deploy:
	tar cfz payload.tar.gz index.html js
	ssh cmu 'cd ~/www/VoronoiImageTiles ;\
	         rm -rf ~/www/VoronoiImageTiles/* ;\
	         cat - > payload.tar.gz ;\
	         tar xvfz payload.tar.gz ;\
	         rm payload.tar.gz' < payload.tar.gz
	rm payload.tar.gz
